#python acquireFG.py --input trainFile --model modelFile > outputFile

#trainFile: NP-chunked sentences
#outputFile: an empty file to store the model's interpretation of trainFile
#modelFile: an empty file to store the pickled model (to avoid resampling every time)

# bug when final word of sentence is verb; makes final word a noun and penultimate a verb.
#  This causes a post-verbal object to nearly always exist.

from __future__ import division
import sys
import numpy
from scipy.stats import truncnorm, norm
import string
import time
import pickle
import itertools
from model import Model, CondModel
import math
import cProfile, pstats,StringIO

OPTS = {}
for aix in range(1,len(sys.argv)):
  if len(sys.argv[aix]) < 2 or sys.argv[aix][:2] != '--':
    #filename or malformed arg
    continue
  elif aix < len(sys.argv) - 1 and len(sys.argv[aix+1]) > 2 and sys.argv[aix+1][:2] == '--':
    #missing filename
    OPTS[sys.argv[aix][2:]] = True
    continue
  else:
    OPTS[sys.argv[aix][2:]] = sys.argv[aix+1]

#########################
#
# Definitions
#
#########################

PROGRESS = False #displays incremental progress made by model (via sampling)
DIST_PRIORS = True #places priority on using low categories until high cats become established
if 'nopriors' in OPTS:
  DIST_PRIORS = False
PRIOR_BIAS = 1000 # magnitude of bias towards using low categories [1-1000]
LATENT_POSITIONS = False #treats arg locations as latent; otherwise, arg locations are chunk locations

wfuncwords = ['which','who','what'] #What does the model consider function words?
FUNC = False #includes function words in analysis; if True, make gaussians for the function words
WH = True #Should Wh relativizers be tracked?
THAT = True #Should That relativizers be tracked?
THET = False #use 'thet' as a functional 'that'

SUBJ_EXTRACT = False 
if 'extract-subj' in OPTS:
  SUBJ_EXTRACT = True #allows subjects to extract; otherwise, there is only one subject gaussian
OBJ_EXTRACT = False 
if 'extract-obj' in OPTS:
  OBJ_EXTRACT = True #allows objects to extract; otherwise, there is only one object gaussian 
IOBJ = False #assumes learners already have an indirect object distribution
IOBJ_EXTRACT = False #allows learners to extract IOBJ

PARAMSEARCH = False #explores the parameter space; SLOW!
TIMING = False #Gives detailed timing outputs to permit optimizing
variable_var = True #.5#'v' #The std dev for the model Gaussians; 'v' leads to variable, learned deviance

runIters = 20 #max number of iterations
if 'iters' in OPTS:
  runIters = int(OPTS['iters'])


if THAT:
  if THET:
    tfuncwords = ['thet'] #What does the model consider function words?
  else:
    tfuncwords = ['that'] #What does the model consider function words?
else:
  tfuncwords = []

#initializations
learnrate = .3 #The learning rate for updating the dist stddevs
skip_penalty = .00001 #penalty for not labelling args #maximum .0000801
slim_var = .5 #std_dev for learned S/O positions (.5 works)
wide_var = 3 #std_dev for extra S/O positions (3 works)
SO_offset = 1 #where the 'uniform' dists are initialized to begin finding extracted args

def calcCM(A,B,label="A_giv_B"):
  A_giv_B = CondModel(label)
  for i in range(0,len(B)):
    A_giv_B[B[i]][A[i]] += 1
  return A_giv_B

def normpdf(x, loc=0.0, scale=1.0):
    u = float((x-loc))/abs(scale)
    y = (1/(math.sqrt(2*math.pi)*abs(scale)))*math.exp(-u*u/2)
    return y

def getRelevantNodes(sent,ix=False):
  #Given a chunked/tagged sentence, return any chunked/tagged bits and discard remainder of sentence
  # If ix, just return the indicies of the chunked bits
  #  If we are returning indicies, don't return the verb (at position 0)
  out = []
  for i,w in enumerate(sent):
    if type(w) == type(()) and w[0] != 0:
      if ix:
        out.append(i)
      else:
        out.append(w)
  return out

def likelyCalc(labelling):
  likelihood = 1.0
  for label in labelling: #label = ((rname,rmu,rsigma),(loc,x))
    if label[0][0][1] == 'T' and label[1][1] not in tfuncwords: #require 'T' label be assigned to t-function words
      likelihood = 0.0
    elif label[0][0][1] == 'W' and label[1][1] not in wfuncwords: #require 'W' label be assigned to w-function words
      likelihood = 0.0
    elif label[0][0][0] != 'F' and DIST_PRIORS:
      likelihood *= normpdf(x=label[1][0],loc=label[0][1],scale=label[0][2])*label[0][3]
    else:
      likelihood *= normpdf(x=label[1][0],loc=label[0][1],scale=label[0][2])
  return likelihood

def chooseLabels(labels, usedl):
  if labels == []:
    return []
  labellings = []
  for li in range(len(labels[0])):
    if labels[0][li][0][0] in usedl:
      continue
    postLabels = chooseLabels(labels[1:],usedl + [labels[0][li][0][0]])
    for g in labels[0][li][0]:
      labellings.append([(g,labels[0][li][1])])
    for p in postLabels:
      for g in labels[0][li][0]:
        labellings.append([(g,labels[0][li][1])] + p)
  if len(labels) > 1:
    #try labellings that skip this word
    labellings += chooseLabels(labels[1:],usedl)
  return labellings

def findLabels(sent,distlist,skip_penalty,shell = True):
  #return a labelled version of sent that maximizes the likelihood given the distributions in distlist
  #distlist = [[rname,rdist),...],...]

  if sent == []:
    return []
  elif sent[0][0] == 0:
    #don't try to label the verb
    sent = sent[1:]
    if sent == []:
      return []
  elif distlist == []:
    #if we've used up all the distributions...
    return []
  potentialLabels = []

  potentialMixes = []
  for w in sent:
    potentialMixes.append( [(d,w) for d in distlist] )
  potentialLabels = chooseLabels(potentialMixes, [])

  #this method prefers that each word is represented in order, but it can skip words...dangerous
#  for dix in range(len(distlist)+1): #try assigning each label to first word
                                     #and recursively try other labelling combos
                                     #+1 means skip this word (with penalty of skip_penalty)
#    if dix == len(distlist): #skip this word
#      potentialLabels += findLabels(sent[1:],distlist,skip_penalty,False)
#    else: #try each label with this word
#      postLabels = findLabels(sent[1:],distlist[:dix]+distlist[dix+1:],skip_penalty,False)
#      for g in distlist[dix]: #for each gaussian in the chosen mixture...
#        if postLabels == []:
#          potentialLabels.append( [(g,sent[0])] )
#        else:
#          for l in postLabels:
#            potentialLabels.append( [(g,sent[0])] + l)

#  if not shell:
    #we're in an inner call, so return the list of possible candidates
#    return potentialLabels

  #return argmax of potential labels
  maxprob = 0.0
  resultix = 0
  maxlen = 0
  for labelling in potentialLabels:
    # find the longest sequence of labels
    maxlen = max(maxlen,len(labelling))
  for i,labelling in enumerate(potentialLabels):
    #potentialLabels = [ [ ((r0name,r0dist), (L0, x0)), ((r1name,r1dist), (L1, x1)), ... ], ... ]
    thisprob = likelyCalc(labelling) #can unzip the roles from the corpus entries
    if maxlen != len(labelling):
      thisprob *= skip_penalty**(maxlen-len(labelling)) #penalty for skipping words
    if thisprob > maxprob:
      maxprob = thisprob
      resultix = i
  return potentialLabels[resultix]


def testLabellings(corpus,distlist,skip_penalty):
  #return score from sampling possible labellings of sent given the distributions in distlist
  #distlist = [[rname,rdist),...],...]
  numLabellings = 10
  counts = {}

  for rawsent in corpus:
    probLabels = []
    resultLabels = []

    sent == getRelevantNodes(rawsent)
    if sent == []:
      continue
    elif sent[0][0] == 0:
      #don't try to label the verb
      sent = sent[1:]
      if sent == []:
        continue
    elif distlist == []:
      #if we've used up all the distributions...
      continue
    potentialLabels = []

    potentialMixes = []
    for w in sent:
      potentialMixes.append( [(d,w) for d in distlist] )
    potentialLabels = chooseLabels(potentialMixes, [])

    #return a label based on the probability of potential labels
    maxprob = 0.0
    resultix = 0
    maxlen = 0
    for labelling in potentialLabels:
      # find the longest sequence of labels
      maxlen = max(maxlen,len(labelling))

    for labelling in potentialLabels:
      #build a list of the possible labels
      thisprob = likelyCalc(labelling) #can unzip the roles from the corpus entries
      if maxlen != len(labelling):
        thisprob *= skip_penalty**(maxlen-len(labelling)) #penalty for skipping words
      probLabels.append( (thisprob,labelling) )

    #sort probLabels
    probLabels.sort(key=lambda x:x[0])

    for run in range(numLabellings):
      resultLabels.append(countlabelpos(test(probLabels)))

    for result in resultLabels:
      #resultLabels = [ {0: {0:1,1:0}, 1: {0:0,1:1}, 2: {0:0,1:0}...}, ... ]
      for pos in result.keys():
        #increment each pos with the args in them
        counts[pos] = counts[pos].get(result[pos].keys()[0],0) + 1  
  return counts

def countlabelpos(labelling):
  #report which labels are in which positions
  counts = {}
  for w in labelling:
    if type(w[0]) == type(()):
      #this word has a label
      # counts[pos]   = {label:1}
      counts[w[1][0]] = {w[0][0]:1}
    else:
      #this word has no label
      counts[w[0]] = {}
  return counts

def initdists(initpos,stddeva,stddevb,hcounts=1):
  # Initializes distributions given:
  # initpos: a list of initial positions
  # stddeva: a smaller stddev to reflect well-learned label positions
  # stddevb: a large stddev to mimic uniform distributions
  # hcounts: pseudocounts of high category to determine prior
  #initpos.reverse() #reverse initpos, so pop() method works as expected
  labels = []
  subj_dists = []
  if SUBJ_EXTRACT:
    subj_dists = [(0,'H'),(0,'L')]
  else:
    subj_dists = [(0,'L')]
  labels.append(subj_dists)
  obj_dists = []
  if OBJ_EXTRACT:
    obj_dists = [(1,'H'),(1,'L')]
  else:
    obj_dists = [(1,'L')]
  labels.append(obj_dists)
  iobj_dists = []
  if IOBJ:
    if IOBJ_EXTRACT:
      iobj_dists = [(2,'H'),(2,'L')]
    else:
      iobj_dists = [(2,'L')]
    labels.append(iobj_dists)
  if FUNC:
    if WH:
      labels.append([('F','W')])
    if THAT:
      labels.append([('F','T')])

  
#  if SUBJ_EXTRACT:
#    if IOBJ:
#      if IOBJ_EXTRACT:
#        labels = [[(0,'H'),(0,'L')],[(1,'H'),(1,'L')],[(2,'H'),(2,'L')],[('F','T')],[('F','W')]]
#      else:
#        labels = [[(0,'H'),(0,'L')],[(1,'H'),(1,'L')],[(2,'L')],[('F','T')],[('F','W')]]
#    else:
#      if not FUNC:
#        labels = [[(0,'H'),(0,'L')],[(1,'H'),(1,'L')]]
#      else:
#        if THAT:
#          labels = [[(0,'H'),(0,'L')],[(1,'H'),(1,'L')],[('F','T')],[('F','W')]]
#        else:
#          labels = [[(0,'H'),(0,'L')],[(1,'H'),(1,'L')],[('F','W')]]
#  else:
#    if IOBJ:
#      if IOBJ_EXTRACT:
#        labels = [[(0,'L')],[(1,'H'),(1,'L')],[(2,'H'),(2,'L')],[('F','T')],[('F','W')]]
#      else:
#        labels = [[(0,'L')],[(1,'H'),(1,'L')],[(2,'L')],[('F','T')],[('F','W')]]
#    else:
#      labels = [[(0,'L')],[(1,'H'),(1,'L')],[('F','T')],[('F','W')]]
  output = []
  for l in labels:
    #0,1,'F'
    newl = []
    for d in l:
      #'H','L','T/W'
      if d[0] == 'F':
        pos = initpos[-1]
      else:
        pos = initpos[d[0]]
      if d[1] == 'L':# or d[0] == 'F':
        newl.append((d,pos,stddeva,float(PRIOR_BIAS-hcounts)/PRIOR_BIAS))
      elif d[0] == 'F':
        #newl.append((d,pos,stddeva,.8*float(PRIOR_BIAS-hcounts)/PRIOR_BIAS))
        newl.append((d,pos,stddevb,float(hcounts)/PRIOR_BIAS))
      else:
        newl.append((d,pos,stddevb,float(hcounts)/PRIOR_BIAS))
    output.append(newl)
  return output

def truncNormSample(mu, sigma, x0, x1):
    transX0 = (x0 - mu) / sigma
    transX1 = (x1 - mu) / sigma
    return truncnorm.rvs(transX0, transX1, mu, sigma)

def test(labelList):
  #pick a random labelling based on their probs
  threshold = random.uniform(0,1)
  probmass = 0
  for l in labelList:
    probmass += l[0]
    if probmass >= threshold:
      return l[1]

def resample(inList):
  outList = []
  #((('F', 'T'), 0, 3), (-2, 'that'))
  minpos = -100
  breakpos = 0
  for i,w in enumerate(inList):
    if minpos < 0:
      #we're looking for the postverbal positions
      if w[1][0] > 0:
        #this is the first postverbal position we've seen
        minpos = 0
        breakpos = i - 1
      else:
        continue
    #we've crossed over the verb position
    minpos = truncNormSample(mu=w[0][1],sigma=w[0][2],x0=minpos,x1=float("inf"))
    while minpos == 0:
      #ensure args don't overlay the verb
      minpos = truncNormSample(mu=w[0][1],sigma=w[0][2],x0=0,x1=float("inf"))
    outList.append((w[0],(minpos,w[1][1])))

  maxpos = 0
  outList2 = []
  while breakpos >= 0:
    w = inList[breakpos]
    breakpos -= 1
    #we're squeezing positions before the verb now
    maxpos = truncNormSample(mu=w[0][1],sigma=w[0][2],x0=float("-inf"),x1=maxpos)
    while maxpos == 0:
      #ensure args don't overlay the verb
      maxpos = truncNormSample(mu=w[0][1],sigma=w[0][2],x0=float("-inf"),x1=0)
    outList2.append((w[0],(maxpos,w[1][1])))
  outList2.reverse()
  return outList2 + outList

def calcpost(dists,corpus,learnrate,skip_penalty,variable_var=True,runIters=10,progressCorpus=[]):
  # Calculates the posterior distributions based on corpus
  prevA = []

  run0 = time.clock()
  inCorpus = corpus
  for iteration in range(runIters):
    outCorpus = []
    newIn = []
    A = []
    distobs = {}  

    sys.stderr.write('Iterating: '+str(iteration)+'\n')
    #estimate arg vector
    start = time.clock()
    for j,sent in enumerate(inCorpus):
      if j % 1000 == 0:
        sys.stderr.write('Parsing: '+str(j)+'\n')
      outSent = []
      newInSent = []
      if PROGRESS:
        #sample several labellings to see which the model currently prefers
        progressCorpus.append(testLabellings(corpus,dists,skip_penalty))
      newCorpus = findLabels(getRelevantNodes(sent),dists,skip_penalty)
      if LATENT_POSITIONS:
        #Make positions latent: sample from label dist
        newCorpus = resample(newCorpus)
#      sys.stdout.write('Sent: '+str(sent)+'\n')
#      sys.stdout.write('Resampled: '+str(newCorpus)+'\n')

      nodeix = getRelevantNodes(sent,True)
      #newCorpus = [ ((r0name,r0dist), (L0, x0)), ((r1name,r1dist), (L1, x1)), ... ]
      newCorpus.reverse() #make pop refer to the correct element
      for i,w in enumerate(sent):
        if i in nodeix and newCorpus != [] and newCorpus[-1][1][1] == w[1]:
          # just checks to see if word matches
          # won't work if a given word is mentioned twice in succession and the second is optimal, but the 
          #   first is reached first by this check
          x = newCorpus.pop()
          A.append((x[0][0],x[1][0])) #A[i] = (ri,Li)
          outSent.append((x[0][0],x[1][0],x[1][1]))
          newInSent.append(x[1])
        else:
          outSent.append(w)
          newInSent.append(w)
      outCorpus.append(outSent)
      newIn.append(newInSent)

    inCorpus = newIn
    for m in dists:
      for g in m:
        distobs[g[0]] = [0.0,0.0] #distobs[x] = (xsum, xnum)

    pseudocounts = {}
    #maximize likelihood via parameter estimation
    for d in dists:
      if d[0][0][0] == 'F':
        pseudocounts[d[0][0][1]] = 0
      else:
        pseudocounts[d[0][0][0]] = {'H':0,'L':0}
    for a in A:
      #since we need to do this for variance again, we could save a loop over A by moving this within the g[d] loop
      #  at the cost of making optional variance estimation less clean
      distobs[a[0]][0] += a[1]
      if a[0][0] != 'F':
        pseudocounts[a[0][0]][a[0][1]] += 1
      else:
        pseudocounts[a[0][1]] += 1
      distobs[a[0]][1] += 1

    for mi in pseudocounts.keys():
      if mi not in ['W','T']:
        pseudocounts[mi]['Tot'] = sum(pseudocounts[mi][gi] for gi in pseudocounts[mi])

    for mi,md in enumerate(dists):
      for gj,gd in enumerate(md):
        #update means
        if distobs[gd[0]][1] == 0: #if no evidence for this label, retain its parameters
          dists[mi][gj] = (gd[0],gd[1],gd[2],gd[3])
        else:
          dists[mi][gj] = (gd[0],float(distobs[gd[0]][0])/distobs[gd[0]][1],gd[2],gd[3])
        if gd[0][0] != 'F':
          #update priors for arg dists
          dists[mi][gj] = (gd[0],dists[mi][gj][1],gd[2],float(pseudocounts[gd[0][0]][gd[0][1]])/pseudocounts[gd[0][0]]['Tot'])
        else:
          #update priors for function words
          dists[mi][gj] = (gd[0],dists[mi][gj][1],gd[2],min(len(A),float(pseudocounts[gd[0][1]]))/len(A))#PRIOR_BIAS)
        #update stddev; change variable_var to False to retain unit Gaussians
        if variable_var:
          varsum = 0.0
          for a in A:
            if a[0] == gd[0]:
              varsum += (a[1]-gd[1])**2
          if varsum == 0.0: #if no evidence for this label, retain its parameters
            dists[mi][gj] = (gd[0],dists[mi][gj][1],gd[2],dists[mi][gj][3])
          else:
            #Only leave one clause uncommented
            # The first uses maxlikelihood to determine new stddev
            #dists[mi][gj] = (gd[0],dists[mi][gj][1],math.sqrt(varsum/distobs[gd[0]][1]))
            # The second uses a learning rate to slowly change stddev
            dists[mi][gj] = (gd[0],dists[mi][gj][1],math.sqrt(gd[2] + learnrate*(varsum/distobs[gd[0]][1]-gd[2])),dists[mi][gj][3])

    end = time.clock()
    sys.stderr.write('Iteration time: '+str(end-start)+'\n')
    if not PARAMSEARCH:
      sys.stdout.write('newDists: '+str(dists)+'\n')
    sys.stdout.flush()
    if A == prevA:
      sys.stderr.write('Converged\n')
      break
    prevA = list(A)
  run1 = time.clock()
  sys.stderr.write('Training time: '+str(run1-run0)+'\n')

  return((dists,outCorpus))


#########################
#
# Load Original File
#
#########################

if LATENT_POSITIONS:
  sys.stderr.write('Positions are Latent\n')
  sys.stdout.write('Positions are Latent\n')
else:
  sys.stderr.write('Positions are Pseudo-Observed\n')
  sys.stdout.write('Positions are Pseudo-Observed\n')
if SUBJ_EXTRACT:
  sys.stderr.write('Subjects can extract\n')
  sys.stdout.write('Subjects can extract\n')
else:
  sys.stderr.write('Subjects cannot extract\n')
  sys.stdout.write('Subjects cannot extract\n')
if IOBJ:
  if IOBJ_EXTRACT:
    sys.stderr.write('IObjs can extract\n')
    sys.stdout.write('IObjs can extract\n')
  else:
    sys.stderr.write('IObjs cannot extract\n')
    sys.stdout.write('IObjs cannot extract\n')
else:
  sys.stderr.write('IObjs not tracked\n')
  sys.stdout.write('IObjs not tracked\n')
if FUNC:
  sys.stderr.write('Function words tracked ')
  sys.stdout.write('Function words tracked ')
  if THAT:
    sys.stderr.write('(That,Wh-)')
    sys.stdout.write('(That,Wh-)')
  else:
    sys.stderr.write('(Wh-)')
    sys.stdout.write('(Wh-)')
  sys.stderr.write('\n')
  sys.stdout.write('\n')
else:
  sys.stderr.write('Function words not tracked\n')
  sys.stdout.write('Function words not tracked\n')
if PROGRESS:
  sys.stderr.write('Progress tracked\n')
  sys.stdout.write('Progress tracked\n')
else:
  sys.stderr.write('Progress not tracked\n')
  sys.stdout.write('Progress not tracked\n')


sys.stderr.write('Loading training corpus\n')

A = []

Corpus = []

SEENV = False #a boolean denoting whether the verb has been seen or not
              #this is an oversimplification since only the first verb will trigger this

foundFlag = False
trainFile = open(OPTS['input'],'r')
#trainFile = (N;The boy)(X;quickly)(V;called)(N;the cops)

#N:-2:I V::want N:-1:you V:0:to go N:1:home


for line in trainFile.readlines():
  #mainline = [] #main holder for N's and V's
#  if line.strip() == '':
#    continue
  SEENV = False
  sline = line.strip('()\n').split(')(')
  tmpCorpus = []
  vix = -1
  ixes = 0 #number of relevant nodes
  numV = 0 #number of verbs
  for w in sline:
    sw = w.split(';') #sw = [POS,X]
    if sw[0] == 'V': #NB: This will always consider the last verb to be the matrix
      SEENV = True
      if not numV:
        ixes += 1
      numV += 1
      vix = ixes #set vix as being at current position among relevant nodes
    elif sw[0] == 'N' or (FUNC and sw[1] in tfuncwords+wfuncwords):
      ixes += 1
  numV -= 1 #one of the Vs is relevant
  cnt = 0 #count of relevant nodes
  if not SEENV:
    # Never found a verb, so skip the sentence
    continue
  for w in sline:
    sw = w.split(';')
    if sw[0] in ('N','V') or (FUNC and sw[1] in tfuncwords+wfuncwords):
      if sw[0] == 'V' and numV: #if we're not at the last V, pop a V and keep going
        tmpCorpus.append(sw[1])
        numV -= 1
        continue
      cnt += 1 #we've seen another relevant node
      tmpCorpus.append((cnt-vix,sw[1])) #[(-2,the boy), (-1,the cat), (0, saw)]
    else:
      tmpCorpus.append(sw[1])
  Corpus.append(tmpCorpus)
trainFile.close()

#########################
#
# Estimate posterior
#
#########################

if PARAMSEARCH:
  sys.stdout.write('Initiating exploration of parameter space\n')
  count = 0

  for learnrate in numpy.arange(.3,1.1,.35):
    for skip_penalty in (.0001,.00001,.000001):#(.001,.0001,.00001,.000001,.0000001):
      for stddev_narrow in numpy.arange(.25,1,.25):
        for stddev_wide in range(1,4,1):
          for pos_offset in range(0,3,1):
            count += 1
            distlist,outCorpus = calcpost(initdists([-1*pos_offset,pos_offset,2*pos_offset,0],stddev_narrow,stddev_wide),Corpus,learnrate,skip_penalty,variable_var,runIters)
            sys.stdout.write('count: %d learnrate: %f skip_penalty: %f stddev_narrow: %f stddev_wide: %f pos_offset: %f\n' % (count,learnrate,skip_penalty,stddev_narrow,stddev_wide,pos_offset))
            sys.stdout.write('dists: '+str(distlist)+'\n\n')
else:
  outCorpus = []
  progressCorpus = []
  distlist = initdists([-1*SO_offset,SO_offset,2*SO_offset,0],slim_var,wide_var)
  sys.stdout.write('InitDistlist: '+str(distlist)+'\n')

  if TIMING:
    pr = cProfile.Profile()
#    cProfile.run('initdists([-1*pos_offset,pos_offset,2*pos_offset,0],stddev_narrow,stddev_wide)')
    pr.enable()
  if PROGRESS:
    random.seed()
    distlist,outCorpus = calcpost(initdists([-1*SO_offset,SO_offset,2*SO_offset,0],slim_var,wide_var),Corpus,learnrate,skip_penalty,variable_var,runIters,progressCorpus)
    sys.stdout.write('PROGRESSION:\n')
    for i in progressCorpus:
      sys.stdout.write(str(i)+'\n')
    sys.stdout.write('RESULTS:\n')
  else:
    distlist,outCorpus = calcpost(initdists([-1*SO_offset,SO_offset,2*SO_offset,0],slim_var,wide_var),Corpus,learnrate,skip_penalty,variable_var,runIters)
  if TIMING:
    pr.disable()
    #s = StringIO.StringIO
    ps = pstats.Stats(pr).sort_stats('cumulative')
    ps.print_stats(10)
  sys.stdout.write('FinDistlist: '+str(distlist)+'\n')

#########################
#
# Output Interpreted Training Data
#
#########################

if not PARAMSEARCH:
  sys.stderr.write('Outputting training interpretation\n')

  sys.stdout.write('Distributions: '+str(distlist)+'\n')
  for sent in outCorpus:
    for w in sent:
      if type(w) == type(()):
        if len(w) == 2 and w[-2] == 0: #verb, so give it the V label
          sys.stdout.write('(V '+str(w[0])+' '+str(w[1])+') ')
        elif len(w) == 2: #potential arg that was ignored #could pick args based on salience...!!!
          sys.stdout.write('('+str(w[0])+' '+str(w[1])+') ')
        else: #labelled arg
          sys.stdout.write('('+str(w[0])+' '+str(w[1])+' '+str(w[2])+') ')
      else:
        sys.stdout.write(str(w)+' ')
    sys.stdout.write('\n')

#########################
#
# Output Inferred Model
#
#########################

sys.stderr.write('Outputting inferred model\n')

modelFile = open(OPTS['model'],'wb')

model = {}
model['A'] = A
model['distlist'] = distlist

pickle.dump(model,modelFile)
modelFile.close()


#xs = numpy.arange(-5, 5, 10 / 5000)
#colors = ['red','blue','green','magenta']
#for mi,md in enumerate(distlist):
#  color = colors[mi]
#  for gi,gd in enumerate(md):
#    currDist = scipy.stats.norm(gd[1], gd[2])
#    pylab.plot(xs, [currDist.pdf(xi) for xi in xs], "-",color=color)

#pylab.savefig('output_dists.png')

