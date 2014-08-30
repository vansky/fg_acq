#python reinsertThat.py mungedFile sentsFile

import sys

sents = []
INPAREN = False
with open(sys.argv[2],'r') as sentfile:
  for line in sentfile.readlines():
    sent = []
    tup = []
    chunk = ''
    for c in line:
      if INPAREN:
        if c == ' ':
          if chunk[-1] == "'":
            chunk = chunk.strip("'")
          tup.append(chunk)
          chunk = ''
        elif c == ')':
          INPAREN = False
          if chunk[-1] == "'":
            chunk = chunk.strip("'")
          tup.append(chunk)
          sent.append(tup)
          tup = []
          chunk = ''
        elif c == ',':
          continue
        else:
          chunk = chunk + c
      else:
        if c == '(':
          INPAREN = True
        elif c == ' ':
          if chunk != '':
            sent.append(chunk)
          chunk = ''
        else:
          chunk = chunk + c
    sents.append(sent)

mungesents = []

with open(sys.argv[1],'r') as mungefile:
  for line in mungefile.readlines():
    sent = []
    sline = line.strip().strip('()').split(')(')
    for w in sline:
      sent.append(w.split(';'))
    mungesents.append(sent)

#could save an order of complexity by folding the following into the reading of mungefile, but it might be less clear
for si,s in enumerate(sents):
  mj = 0 #index to munged word
#  sys.stdout.write('M: '+str(mungesents[si])+' S: '+str(s)+'\n')
  for wj,w in enumerate(s):
    if w == '!!':
      #CHILDES has some ellision annotation, so ignore it and move on
      sys.stdout.write('('+mungesents[si][-1][0]+';'+mungesents[si][-1][1]+')')  
      sys.stdout.write('\n')
      break
    if type(w) == type([]):
      #w was allocated a role, so target the word
      if mungesents[si][mj][1] != w[0]:
        #munge word doesn't line up, so we've chunked out the sents words
        if w[0] == 'thet':
          #if we've chunked out a functional thet, put it back in to the munged sents
          sys.stdout.write("(X;thet)")
        else:
          continue
      else:
        #munge word lines up so keep on truckin'
        sys.stdout.write('('+mungesents[si][mj][0]+';'+mungesents[si][mj][1]+')')
        mj += 1
    else:
      #w wasn't allocated a role, so target the word
      if mungesents[si][mj][1] != w:
        #munge word doesn't line up, so we've chunked out the sents words
        if w == 'thet':
          #if we've chunked out a functional thet, put it back in to the munged sents
          sys.stdout.write("(X;thet)")
        else:
          continue
      else:
        #munge word lines up so keep on truckin'
        sys.stdout.write('('+mungesents[si][mj][0]+';'+mungesents[si][mj][1]+')')
        mj += 1
  #throw in final punctuation and move on
  sys.stdout.write('('+mungesents[si][-1][0]+';'+mungesents[si][-1][1]+')')  
  sys.stdout.write('\n')
