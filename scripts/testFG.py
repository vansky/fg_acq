#python testFG.py modelFile testFile > outputFile

#testFile: NP-chunked sentences
#outputFile: an empty file to store the model's interpretation of testFile
#modelFile: an empty file to store the pickled model (to avoid resampling every time

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
import random

#########################
#
# Definitions
#
#########################

THET = False
OPTIMAL_LEARNER = True #True: Learner always picks best labelling option; False: Learner chooses label probabilistically from the possibilities
DIST_PRIORS = True #places priority on using low categories until high cats become established
LATENT_POSITIONS = False #treats arg locations as latent; otherwise, arg locations are chunk locations
SUBJ_EXTRACT = True #allows subjects to extract; otherwise, there is only one subject gaussian
runIters = 1 #max number of iterations
wfuncwords = ['which','who','what'] #What does the model consider function words?
if THET:
  tfuncwords = ['thet'] #What does the model consider function words?
else:
  tfuncwords = ['that'] #What does the model consider function words?

#initializations
skip_penalty = .0001 #801 #penalty for not labelling args #minimum .000801

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
    elif DIST_PRIORS and label[0][0][0] != 'F':
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

def findLabels(sent,distlist,skip_penalty,shell = True,debug = False):
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

  if OPTIMAL_LEARNER:
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
  else:
    #choose a labelling scheme probabilistically from the potential options
    normconst = 0
    resultix = 0
    #we call likelyCalc three times here; Could probably make this more efficient
    potentialLabels = sorted(potentialLabels,key=lambda label: likelyCalc(label))
    for labelling in potentialLabels:
      normconst += likelyCalc(labelling)
    random.seed()
    cutoff = random.uniform(0,normconst)
    prob = 0
    for i,labelling in enumerate(potentialLabels):
      prob += likelyCalc(labelling)
      if prob >= cutoff:
        resultix = i
        break
  return potentialLabels[resultix]

def truncNormSample(mu, sigma, x0, x1):
    transX0 = (x0 - mu) / sigma
    transX1 = (x1 - mu) / sigma
    return truncnorm.rvs(transX0, transX1, mu, sigma)

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

def calcpost(dists,corpus,skip_penalty,runIters=10):
  # Calculates the posterior distributions based on corpus

  run0 = time.clock()
  inCorpus = corpus
  for iteration in range(runIters):
    outCorpus = []
    distobs = {}  

    sys.stderr.write('Iterating: '+str(iteration)+'\n')
    #estimate arg vector
    start = time.clock()
    loglike = 0
    for j,sent in enumerate(inCorpus):
      if j % 1000 == 0:
        sys.stderr.write('Parsing: '+str(j)+'\n')

      outSent = []
      newCorpus = findLabels(getRelevantNodes(sent),dists,skip_penalty)
      if LATENT_POSITIONS:
        #Make positions latent: sample from label dist
        newCorpus = resample(newCorpus)
#      sys.stdout.write('Sent: '+str(sent)+'\n')
#      sys.stdout.write('Resampled: '+str(newCorpus)+'\n')
      if 0 == len(getRelevantNodes(sent))-len(newCorpus):
        loglike += math.log(likelyCalc(newCorpus))
      else:
        loglike += math.log(likelyCalc(newCorpus)) + math.log(skip_penalty*(len(getRelevantNodes(sent))-len(newCorpus)))

      nodeix = getRelevantNodes(sent,True)
      #newCorpus = [ ((r0name,r0dist), (L0, x0)), ((r1name,r1dist), (L1, x1)), ... ]
      newCorpus.reverse() #make pop refer to the correct element
      for i,w in enumerate(sent):
        if i in nodeix and newCorpus != [] and newCorpus[-1][1][1] == w[1]:
          # just checks to see if word matches
          # won't work if a given word is mentioned twice in succession and the second is optimal, but the 
          #   first is reached first by this check
          x = newCorpus.pop()
#          A.append((x[0][0],x[1][0])) #A[i] = (ri,Li)
          outSent.append((x[0][0],x[1][0],x[1][1]))
        else:
          outSent.append(w)
      outCorpus.append(outSent)

    end = time.clock()
    sys.stderr.write('Iteration time: '+str(end-start)+'\n')
  run1 = time.clock()
  sys.stderr.write('Testing time: '+str(run1-run0)+'\n')

  return(dists,outCorpus,loglike)


#########################
#
# Load Model
#
#########################

sys.stderr.write('Loading model\n')

f = open(sys.argv[1],'rb')
mymodel = pickle.load(f)
f.close()
distlist = mymodel['distlist']

#sys.stdout.write(str(distlist)+'\n')
#########################
#
# Load Test File
#
#########################

Corpus = []

SEENV = False #a boolean denoting whether the verb has been seen or not
              #this is an oversimplification since only the first verb will trigger this

foundFlag = False
tryme = True
testFile = open(sys.argv[2],'r')
#testFile = (N;The boy)(X;quickly)(V;called)(N;the cops)

#N:-2:I V::want N:-1:you V:0:to go N:1:home


for line in testFile.readlines():
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
    elif sw[0] == 'N' or sw[1] in tfuncwords+wfuncwords:
      ixes += 1
  numV -= 1 #one of the Vs is relevant
  cnt = 0 #count of relevant nodes
#  if not SEENV:
    # Never found a verb, so skip the sentence; ERROR: This throws off the alignment during eval
#    continue
  for w in sline:
    sw = w.split(';')
    if SEENV and (sw[0] in ('N','V') or sw[1] in tfuncwords+wfuncwords):
      if sw[0] == 'V' and numV: #if we're not at the last V, pop a V and keep going
        tmpCorpus.append(sw[1])
        numV -= 1
        continue
      cnt += 1 #we've seen another relevant node
      tmpCorpus.append((cnt-vix,sw[1])) #[(-2,the boy), (-1,the cat), (0, saw)]
    else:
      tmpCorpus.append(sw[1])
  Corpus.append(tmpCorpus)
testFile.close()

#########################
#
# Estimate posterior
#
#########################

outCorpus = []
#sys.stdout.write('InitDistlist: '+str(distlist)+'\n')

distlist,outCorpus,corpusloglike = calcpost(distlist,Corpus,skip_penalty,runIters)

#########################
#
# Output Interpreted Test Data
#
#########################

sys.stderr.write('Outputting test interpretation\n')
sys.stderr.write('LogLikelihood: '+str(corpusloglike)+'\n')

for sent in outCorpus:
  outsent = []
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
