#python evalFG.py testFile goldFile > outputFile

#testFile: output from scripts/testFG.py
#goldFile: a file with gold labellings to eval against

from __future__ import division
import sys
import string
import ast

COLLAPSE_OBJ = False
if sys.argv[1][0] == '-':
  if sys.argv[1][1:] == 'collapsed':
    COLLAPSE_OBJ = True
    
THET = False
wfuncwords = ['who','what','which']
if THET:
  tfuncwords = ['thet']
else:
  tfuncwords = ['that']

def parseLine(line):
  #sys.stderr.write(str(line)+'\n')
  lineout = '['
  comma = False
  word = ''
  first = True
  for c in line.strip():
    if word != '' and c not in string.letters+"_":
      lineout = lineout + '\''+word+'\''
      word = ''
    if c == ',':
      comma = True
    elif not comma and c == ' ':
      lineout = lineout + ','
    elif comma and c != ' ':
      comma = False
    if c in string.letters+"_":
      word = word + c
    elif c == '\'':
      continue
    elif c == ',' and lineout[-2] == ',':
      #if there's a comma in the text just skip it to avoid confusing literal_eval
      continue 
    else:
      lineout = lineout + c
  if word != '':
    #flush buffer if no punctuation at end of sentence
    lineout = lineout + '\''+word+'\''
  if lineout[-1] in '.?!':
    #sys.stderr.write(str(lineout[:-1]+'\''+lineout[-1]+'\'')+'\n')
    return ast.literal_eval(lineout[:-1]+'\''+lineout[-1]+'\']')
  elif lineout[-2] in '.?!':
    #account for stupid assignment of roles to punctuation
    #sys.stderr.write(str(lineout[:-1]+'\''+lineout[-1]+'\'')+'\n')
    return ast.literal_eval(lineout[:-2]+'\''+lineout[-2]+'\')]')
  else:
    #sys.stderr.write(lineout+'\n')
    return ast.literal_eval(lineout+']')

#########################
#
# Load Test File
#
#########################

testCorpus = []
testFile = open(sys.argv[1],'r')

for line in testFile.readlines():
  testSent = []
  for w in parseLine(line):
    testSent.append(w)
  testCorpus.append(testSent)
testFile.close()

#########################
#
# Load Gold File
#
#########################

goldCorpus = []
goldFile = open(sys.argv[2],'r')

for line in goldFile.readlines():
  goldSent = []
  for w in parseLine(line):
    goldSent.append(w)
  goldCorpus.append(goldSent)
goldFile.close()

#########################
#
# Run Eval
#
#########################

if COLLAPSE_OBJ:
  sys.stderr.write('Collapsing A1-A4 into A1\n')
  sys.stdout.write('Collapsing A1-A4 into A1\n')

accuracy = []
atts = []
sacc = [[0,0],[0,0]]
oacc = [[0,0],[0,0]]
tacc = [[0,0],[0,0]]
wacc = [[0,0],[0,0]]
agentacc = [[0,0],[0,0]] #accuracy of recalling agent in intrans and trans conditions
txacc = [[0,0],[0,0]]
wxacc = [[0,0],[0,0]]
precision = [0, 0] #correct hits , total hits
recall = [0, 0]
wronglabel = 0

####
#
# Actual eval
#
####

for i,ts in enumerate(testCorpus):
  latts = []
  lprecision = [0, 0]
  lrecall = [0, 0]
  arecall = [0, 0]
  first = ''
  func = {'T':0,'W':0}
  THAT = False
  WH = False
  TRANS = False
  #sys.stdout.write('ts: '+str(ts)+'\n'+'gold: '+str(goldCorpus[i])+'\n')
  for j,tw in enumerate(ts):
    if type(goldCorpus[i][j]) == type(()):
      if goldCorpus[i][j][0] in tfuncwords:
        THAT = True
      elif goldCorpus[i][j][0] in wfuncwords:
        WH = True
    else:
      if goldCorpus[i][j] in tfuncwords:
        THAT = True
      elif goldCorpus[i][j] in wfuncwords:
        WH = True

    if type(tw) == type(()) and type(tw[0]) != type(1):
      #hit
      lprecision[1] += 1
      if type(goldCorpus[i][j]) == type(()):
        #possible true hit
        lrecall[1] += 1
        if first == "" and goldCorpus[i][j][-1] != 'V':
          first = goldCorpus[i][j][-1]
        if goldCorpus[i][j][-1] == 1:
          TRANS = True
        elif goldCorpus[i][j][-1] == 0:
          arecall[1] = 1

        if goldCorpus[i][j][-1] == 'V':
          #verbs don't count against us
          lrecall[1] -= 1
          if tw[0] == 'V' or tw[0][0] == 'F':
            #verbs and function words don't count against us
            lprecision[1] -= 1
        elif tw[0] == 'V' or tw[0][0] == 'F':
          #verbs don't count for or against us
          lprecision[1] -= 1
        elif tw[0][0] == goldCorpus[i][j][-1]:
          #true hit
          lprecision[0] += 1
          lrecall[0] += 1
          if tw[0][0] == 0:
            arecall[0] = 1
        elif COLLAPSE_OBJ and goldCorpus[i][j][-1] >= 1 and tw[0][0] == 1:
          #collapsed arg true hit
          lprecision[0] += 1
          lrecall[0] += 1
        else:
          #chose wrong label
          wronglabel += 1
      elif tw[0] == 'V' or tw[0][0] == 'F':
        #function words aren't silver annotated, so don't eval those
        # they are indirectly being evaluated since they modify the other arg labels
        lprecision[1] -= 1
        if goldCorpus[i][j][-1] == 1:
          TRANS = True

        if goldCorpus[i][j] in tfuncwords:
          func['T'] += 1
        elif goldCorpus[i][j] in wfuncwords:
          func['W'] += 1
        elif goldCorpus[i][j][-1] == 0:
          arecall[1] = 1
      else:
        #false hit
        if goldCorpus[i][j][-1] == 1:
          TRANS = True

        if goldCorpus[i][j] in tfuncwords:
          func['T'] += 1
        elif goldCorpus[i][j] in wfuncwords:
          func['W'] += 1
        elif goldCorpus[i][j][-1] == 0:
          arecall[1] = 1
    else:
      #possible miss
      if type(goldCorpus[i][j]) == type(()) and goldCorpus[i][j][-1] != 'V':
        #false negative (don't penalize for unlabelled verbs...)
        if first == "":
          first = goldCorpus[i][j][-1]
        lrecall[1] += 1

        if goldCorpus[i][j][-1] == 1:
          TRANS = True
        elif goldCorpus[i][j][-1] == 0:
          arecall[1] = 1
      else:
        #true negative
        if goldCorpus[i][j] in tfuncwords:
          func['T'] += 1
        elif goldCorpus[i][j] in wfuncwords:
          func['W'] += 1
#  sys.stdout.write('P: '+str(lprecision)+' R: '+str(lrecall)+'\n')
#  sys.stdout.write(str(func)+'\n')
  if first == 0:
    sacc[0][0] += lprecision[0]
    sacc[0][1] += lprecision[1]
    sacc[1][0] += lrecall[0]
    sacc[1][1] += lrecall[1]
    latts.append('S')
  else:
    oacc[0][0] += lprecision[0]
    oacc[0][1] += lprecision[1]
    oacc[1][0] += lrecall[0]
    oacc[1][1] += lrecall[1]
    latts.append('O')
  if func['W'] > 0 or func['T'] > 0:
    #sentence involves a functional use/relativizer
    if func['W'] > func['T']:
      #wh- sentence
      wacc[0][0] += lprecision[0]
      wacc[0][1] += lprecision[1]
      wacc[1][0] += lrecall[0]
      wacc[1][1] += lrecall[1]
      latts.append('FW')
    else:
      #that sentence
      tacc[0][0] += lprecision[0]
      tacc[0][1] += lprecision[1]
      tacc[1][0] += lrecall[0]
      tacc[1][1] += lrecall[1]
      latts.append('FT')
  if THAT:
    #that sentence
    txacc[0][0] += lprecision[0]
    txacc[0][1] += lprecision[1]
    txacc[1][0] += lrecall[0]
    txacc[1][1] += lrecall[1]
    latts.append('T')
  if WH:
    #wh- sentence
    wxacc[0][0] += lprecision[0]
    wxacc[0][1] += lprecision[1]
    wxacc[1][0] += lrecall[0]
    wxacc[1][1] += lrecall[1]
    latts.append('W')
  if TRANS:
    #transitive sentence
    agentacc[1][0] += arecall[0]
    agentacc[1][1] += arecall[1]
    latts.append('Trans')
  else:
    #intransitive sentence
    agentacc[0][0] += arecall[0]
    agentacc[0][1] += arecall[1]
    latts.append('Intrans')
  accuracy.append( (lprecision,lrecall) )
  precision[0] += lprecision[0]
  precision[1] += lprecision[1]
  recall[0] += lrecall[0]
  recall[1] += lrecall[1]
  atts.append(latts)

P = precision[0]/precision[1]
R = recall[0]/recall[1]
F = 2*P*R/(P+R)
SP = sacc[0][0]/sacc[0][1]
SR = sacc[1][0]/sacc[1][1]
SF = 2*SP*SR/(SP+SR)
if oacc[0][1] > 0 and oacc[1][1] > 0:
  #we have to guess at least one obj-extract and there must be at least one, or we don't report this
  OP = oacc[0][0]/oacc[0][1]
  OR = oacc[1][0]/oacc[1][1]
  OF = 2*OP*OR/(OP+OR)
else:
  OP = float('-inf')
  OR = float('-inf')
  OF = float('-inf')

try:
  IAg = agentacc[0][0] / agentacc[0][1]
except:
  IAg = float('-inf')
try:
  TAg = agentacc[1][0] / agentacc[1][1]
except:
  TAg = float('-inf')

try:
  WP = wacc[0][0]/wacc[0][1]
  WR = wacc[1][0]/wacc[1][1]
  WF = 2*WP*WR/(WP+WR)
except:
  WP = 0
  WR = 0
  WF = 0
if tacc[0][1] > 0 and tacc[1][1] > 0:
  TP = tacc[0][0]/tacc[0][1]
  TR = tacc[1][0]/tacc[1][1]
  TF = 2*TP*TR/(TP+TR)
else:
  TP = float('-inf')
  TR = float('-inf')
  TF = float('-inf')
if wxacc[0][1] > 0 and wxacc[1][1] > 0:
  WXP = wxacc[0][0]/wxacc[0][1]
  WXR = wxacc[1][0]/wxacc[1][1]
  WXF = 2*WXP*WXR/(WXP+WXR)
else:
  WXP = float('-inf')
  WXR = float('-inf')
  WXF = float('-inf')
if txacc[0][1] > 0 and txacc[1][1] > 0:
  TXP = txacc[0][0]/txacc[0][1]
  TXR = txacc[1][0]/txacc[1][1]
  TXF = 2*TXP*TXR/(TXP+TXR)
else:
  TXP = float('-inf')
  TXR = float('-inf')
  TXF = float('-inf')

W = wronglabel/precision[1]
sys.stdout.write('Precision: %d/%d (%f)  Recall: %d/%d (%f) F-Score: %f\n' % (precision[0],precision[1],P,recall[0],recall[1],R,F))
sys.stdout.write('SubjPrec: %d/%d (%f)  SubjRecall: %d/%d (%f) SubjF-Score: %f -- ObjPrec: %d/%d (%f)  ObjRecall: %d/%d (%f) ObjF-Score: %f\n' % (sacc[0][0],sacc[0][1],SP,sacc[1][0],sacc[1][1],SR,SF,oacc[0][0],oacc[0][1],OP,oacc[1][0],oacc[1][1],OR,OF))
sys.stdout.write('Functional:\n')
sys.stdout.write('WhPrec: %d/%d (%f)  WhRecall: %d/%d (%f) WhF-Score: %f -- ThatPrec: %d/%d (%f)  ThatRecall: %d/%d (%f) ThatF-Score: %f\n' % (wacc[0][0],wacc[0][1],WP,wacc[1][0],wacc[1][1],WR,WF,tacc[0][0],tacc[0][1],TP,tacc[1][0],tacc[1][1],TR,TF))
sys.stdout.write('Observed:\n')
sys.stdout.write('WhPrec: %d/%d (%f)  WhRecall: %d/%d (%f) WhF-Score: %f -- ThatPrec: %d/%d (%f)  ThatRecall: %d/%d (%f) ThatF-Score: %f\n' % (wxacc[0][0],wxacc[0][1],WXP,wxacc[1][0],wxacc[1][1],WXR,WXF,txacc[0][0],txacc[0][1],TXP,txacc[1][0],txacc[1][1],TXR,TXF))
sys.stdout.write('WrongLabel: %d/%d (%f)\n' % (wronglabel,precision[1],W))
sys.stdout.write('Intransitive Agent Recall: %d/%d (%f) -- Transitive Agent Recall: %d/%d (%f)\n\n' % (agentacc[0][0],agentacc[0][1],IAg,agentacc[1][0],agentacc[1][1],TAg))

for i in range(len(testCorpus)):
  sys.stdout.write('atts: %s\n' % (str(atts[i])))
  sys.stdout.write('a: P(%d/%d) R(%d/%d)\n' % (accuracy[i][0][0],accuracy[i][0][1],accuracy[i][1][0],accuracy[i][1][1]))
  sys.stdout.write('t: '+str(testCorpus[i])+'\n')
  sys.stdout.write('g: '+str(goldCorpus[i])+'\n')
