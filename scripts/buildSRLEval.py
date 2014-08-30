#python buildSRLEval.py *.srl.cha

import sys
import re
import math
from model import Model, CondModel
from string import punctuation, whitespace

if len(sys.argv) < 2:
  print("Incorrect args")
  print("python buildSRLEval.py *.srl.cha")
  raise Exception("Incorrect args")

restart = re.compile('^start')
refinal = re.compile('\<FIN')
reskip = re.compile('[Tt]ime:')
multicap = re.compile('[A-Z].*[A-Z]')

#########################
#
# Load Original File
#
#########################

sys.stderr.write('Loading original file\n')

origFile = open(sys.argv[1],'r')

corpus = []
update = []
updatekey = ''
elem = {}
THET = False

for line in origFile.readlines():
  #ctr += 1
  #if ctr % 100000 == 0:
  #  sys.stderr.write(' Loaded '+str(ctr)+'\n')

  #beginning processing a new file
  if line[0] == '@':
    #metadata, so omit
    continue

  sline = line.split()
  if sline == [] or line.strip() == '':
    #empty line
    continue
  if line[0] in whitespace:
    #continuation
    update += sline
    continue
  else:
    #finish previous continuation
    if len(update) > 2 and update[-2] == '[+':
      update = update[:-2]
    if updatekey in ('parse','srl'):
      try:
        elem[updatekey].append(update)
      except:
        elem[updatekey] = [update]
    elif updatekey != []:
      try:
        elem[updatekey] += update
      except:
        elem[updatekey] = update

  if line[0] == '*':
    #Speech
    #Add previous element to corpus
    if elem != {} and '' not in elem.keys():
      corpus.append(elem)
      elem = {}
    else:
      elem = {}

    #Begin new elem
    if sline[0] == '*CHI:':
      elem['cds'] = False
    else:
      elem['cds'] = True
    elem['spkr'] = sline[0][1:-1]
    updatekey = 'speech'
    if sline[-1][0] == '[':
      elem['tag'] = sline[-1][1:-1]
      update = sline[1:-1]
    else:
      update = [w for w in sline[1:] if w not in ['#']]
  else:
    updatekey = sline[0][1:-1]
#    if updatekey == 'mor':
#      mor = line.split()[1:]
#      mor = [a for w in mor for a in w.split('~')] #this assumes children can do affixal parsing...
      #sys.stderr.write(str(trn)+'\n')
#      update = mor
#    else:
    update = sline[1:]

origFile.close()

#########################
#
# Building Eval Corpus
#
#########################

sys.stderr.write('Building eval corpus\n')

#evalCorpus = []

validArgs = ['A0','A1','A2','A3','A4']

for s in corpus:
  #{'spkr': 'MOT', 
  #'trn': ['pro|you', 'v|have', 'det|another', 'n|cookie', 'adv|right', 'prep|on', 'det|the', 'n|table', '.'], 
  #'mor': ['pro|you', 'v|have', 'det|another', 'n|cookie', 'adv|right', 'prep|on', 'det|the', 'n|table', '.'], 
  #'srl': [['you', '-', '(A0*)'], ['have', 'have', '(V*)'], ['another', '-', '(A1*'], ['cookie', '-', '*)'], ['right', '-', '(AM-LOC*'], ['on', '-', '*'], ['the', '-', '*'], ['table', '-', '*)'], ['.', '-', '*']], 
  #'parse': [['(S1'], ['(S'], ['(NP'], ['(PRP', 'you))'], ['(VP'], ['(VBP', 'have)'], ['(NP'], ['(DT', 'another)'], ['(NN', 'cookie))'], ['(PP'], ['(ADVP'], ['(RB', 'right))'], ['(IN', 'on)'], ['(NP'], ['(DT', 'the)'], ['(NN', 'table))))'], ['(.', '.)))']],
  #'speech': ['you', 'have', 'another', 'cookie', 'right', 'on', 'the', 'table', '.'], 
  #'cds': True}
  evalSent = []
#  sys.stdout.write(str(s)+'\n')
  if 'srl' not in s.keys():
    continue
  argin = '*'
  trnmod = 0
  trnused = []
  for i,w in enumerate(s['srl']): #this would be more difficult if we were considering all verbs and not just final verb
    if w[0] in [',',';',':']:
      #punctuation we don't want in the input anyway
      trnmod -= 1
      continue
    elif 'trn' in s.keys():
      #if there's a transcription to go from
      try:
        if w[0] in ["'s"] or (len(s['trn'][i+trnmod].split('|')) > 1 and s['trn'][i+trnmod].split('|')[1] in ['out_of',"c'mon"]):
          #things we want in the input that are transcribed oddly
          trnmod -=1
        else:
          modupdate = 0
          newtrn = re.split('~|\+',s['trn'][i+trnmod])
          for t in newtrn:
            newt = t.split('|')
            if len(newt) > 1 and newt[1] != '':
              modupdate += 1
          
          if modupdate > 1 and (i + trnmod) not in trnused:
            trnmod -= (modupdate - 1)

          if THET and w[0].lower() == 'that':
            if s['trn'][i+trnmod].split('|')[0] in ['rel','det']:
              #convert all relative and determiner 'that's into thets
              w = ['thet'] + w[1:]
      except:
        sys.stderr.write('trnmod: '+str(trnmod)+'\n'+'trnused: '+str(trnused)+'\n')
        sys.stderr.write('w: '+str(w)+'\n'+str(i)+'/'+str(len(s['trn']))+'\n'+'trn: '+str(s['trn'])+'\n'+'srl: '+str(s['srl'])+'\n')
        raise
      if (i + trnmod) not in trnused:
        trnused.append( i + trnmod )

    if w[-1] == '*':
      #not an arg
      evalSent.append(w[0])
    elif w[-1][-1] == ')':
      if w[-1][1:-2] == 'V':
        evalSent.append( str((w[0], w[-1][1:-2])) ) #label verbs in eval.sents
      elif (argin not in validArgs and w[-1][1:-2] not in validArgs):
        evalSent.append(w[0])
      elif w[-1][0] == '(':
        evalSent.append( str((w[0], w[-1][2:-2])) )
      else:
        evalSent.append( str((w[0], argin[-1])) )
        argin = '*'
    else:
      evalSent.append(w[0])
      argin = w[-1][2:-1]
  #evalCorpus.append(evalSent)
  sys.stdout.write(' '.join(evalSent)+'\n')
