#python oracleChunkCHILDES.py testfile > outfile
import sys
import string
import re

testix = 1

def processArgs(c,quotes=False):
  if c[-2] == 'V':
    #verb so label as generic verb
    if quotes:
      #surrounded by "; it has \' in it, so change the stripping method
      return c[1:].split('"')[0]+'/V'
    else:
      return c[1:].split('\'')[0]+'/V'
  else:
    #arg, so label as generic NN
    if quotes:
      return '(NP '+c[1:].split('"')[0]+'/NN)'
    else:
      return '(NP '+c[1:].split('\'')[0]+'/NN)'

def chunk(line):
  lineout = ''
  sline = re.split('[\(\)]',line)
  for e in sline:
    se = e.strip()
    if se == '':
      #skip null splits
      continue
    elif se[0] in '\'' and se[-1] == '\'':
      #a tuple; aka an arg/verb
      lineout = lineout + ' ' + processArgs(se)
    elif se[0] in '"' and se[-1] == '\'':
      #a tuple; aka an arg/verb
      lineout = lineout + ' ' + processArgs(se,True)
    else:
      #a non-arg
      for sf in se.split():
        if sf in string.punctuation:
          lineout = lineout + ' ' + sf+'/.' #just label it with a non-NP for munging
        else:
          lineout = lineout + ' ' + sf+'/RB' #just label it with a non-NP for munging
  return '(S'+lineout+')'

sys.stderr.write('Loading corpus for chunking\n')
inFile = open(sys.argv[testix],'r')
test_sents = inFile.readlines()
inFile.close()

sys.stderr.write('Loading oracular insight\n')

sys.stderr.write('Chunking corpus\n')
for s in test_sents:
  print chunk(s)

