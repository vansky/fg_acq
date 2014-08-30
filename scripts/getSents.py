#python getSents.py sentsFile

import sys
import re
import math
from model import Model, CondModel
from string import punctuation, whitespace

if len(sys.argv) < 2:
  print("Incorrect args")
  print("python mungeCHILDES.py sentsFile")
  raise Exception("Incorrect args")

restart = re.compile('^start')
refinal = re.compile('\<FIN')
reskip = re.compile('[Tt]ime:')
multicap = re.compile('[A-Z].*[A-Z]')

THET = False

#########################
#
# Definitions
#
#########################

def unparse(incorp):
  # if a sentence failed to parse (notified at end of sentence),
  #  mark sentence as a parse failure
  for i in range(len(incorp)-1,-1,-1):
    incorp[i]['parsed'] = False
    if incorp[i]['sentpos'] == 0:
      return True

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
      update = [w for w in sline[1:] if w not in ['#','+']]
  else:
    updatekey = sline[0][1:-1]
    update = sline[1:]

origFile.close()

sys.stderr.write('Outputting sents\n')

for s in corpus:
  #numThat = 0
  thatlist = []
  if 'trn' in s.keys():
    for w in s['trn']:
      sw = w.split('|')
      if len(sw) > 1 and sw[1] == 'that':
        #numThat += 1
        thatlist.append(sw[0])
  if s['cds']:
    for w in s['speech']:
      if THET and w.lower() == 'that' and len(thatlist) > 0:
        #numThat -= 1
        pos = thatlist.pop(0)
        if pos in ['rel','det']:
          sys.stdout.write('thet ')
        else:
          sys.stdout.write('that ')
      elif w.lower() == 'that':
#        sys.stderr.write('Missing that.\n')
        sys.stdout.write(str(w)+' ')
      else:
        sys.stdout.write(str(w)+' ')
    sys.stdout.write('\n')
