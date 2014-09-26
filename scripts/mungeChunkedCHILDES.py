#python mungeChunkedCHILDES.py chunkedSentsFile

import sys
import re
import math
from model import Model, CondModel
from string import punctuation, whitespace

if len(sys.argv) < 2:
  print("Incorrect args")
  print("python mungeChunkedCHILDES.py chunkedSentsFile")
  raise Exception("Incorrect args")

#########################
#
# Definitions
#
#########################

def processNonNP(e):
  #Pull out nonNP words; label verb V and everything else X
  #sys.stderr.write(str(e)+'\n')
  out = []
  se = e.strip().split()
  for i in se:
    i = i.split('/')
    if len(i) > 1: #avoid null splits
      if i[1][0] == 'V':
        out.append( ('V', i[0]) )
      else:
        out.append( ('X', i[0]) )
  return out

def processNP(e):
  #replace NP with head noun
  #sys.stderr.write(str(e)+'\n')
  se = e.strip().split()
  return [('N',se[-1].split('/')[0])]

#########################
#
# Load Original File
#
#########################

sys.stderr.write('Loading original file\n')

origFile = open(sys.argv[1],'r')

corpus = []
sent = []
first = True

for line in origFile.readlines():
  sline = re.split('[\(\)]',line)
  if line.strip() == '': #or sline == []
    #empty line
    continue
  if not first and line[0] not in whitespace:
    #not a continuation
    corpus.append(sent)
    sent = []
  
  first = False

  for e in sline:
    if len(e) == 0:
      continue
    if e[0] == 'N': #If a noun chunk:
      sent += processNP(e)
    #Otherwise, split this chunk based on spaces
      #and go through the subchunks
    else:
      for sube in e.split():
        if sube =='S':
          #ignore beginning of sentence
          continue
        else:
          sent += processNonNP(sube)
#    if e[0] == ' ':
#      sent += processNonNP(e)
#    if e[0] == 'S':
#      sent += processNonNP(e[1:])

origFile.close()

corpus.append(sent)

#########################
#
# Output Compiled Data
#
#########################

sys.stderr.write('Writing output\n')

for s in corpus:
  for w in s:
    sys.stdout.write('('+w[0]+';')
    sys.stdout.write(w[1]+')')
  sys.stdout.write('\n')
