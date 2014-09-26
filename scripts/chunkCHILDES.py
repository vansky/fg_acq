#python chunkCHILDES.py testfile modelfile > outfile
import sys
import nltk
import pickle
from nltk.chunk.util import conlltags2tree

#nltk.config_megam('/home/compling/megam_64-bit/megam-64.opt')

testix = 1
modelix = 2

class ConsecutiveNPChunkTagger(nltk.TaggerI):
    def __init__(self, train_sents):
        train_set = []
        for tagged_sent in train_sents:
            untagged_sent = nltk.tag.untag(tagged_sent)
            history = []
            for i, (word, tag) in enumerate(tagged_sent):
                featureset = npchunk_features(untagged_sent, i, history)
                train_set.append( (featureset, tag) )
                history.append(tag)
        self.classifier = nltk.MaxentClassifier.train(
            train_set, algorithm='iis', trace=0) #megam', trace=0)

    def tag(self, sentence):
        history = []
        for i, word in enumerate(sentence):
            featureset = npchunk_features(sentence, i, history)
            tag = self.classifier.classify(featureset)
            history.append(tag)
        return zip(sentence, history)

class ConsecutiveNPChunker(nltk.ChunkParserI):
    def __init__(self, train_sents):
        tagged_sents = [[((w,t),c) for (w,t,c) in
                         nltk.chunk.tree2conlltags(sent)]
                        for sent in train_sents]
        self.tagger = ConsecutiveNPChunkTagger(tagged_sents)

    def parse(self, sentence):
        tagged_sents = self.tagger.tag(sentence)
        conlltags = [(w,t,c) for ((w,t),c) in tagged_sents]
        return conlltags2tree(conlltags)

def tags_since_dt(sentence, i):
     tags = set()
     for word, pos in sentence[:i]:
         if pos == 'DT':
             tags = set()
         else:
             tags.add(pos)
     return '+'.join(sorted(tags))

def npchunk_features(sentence, i, history):
     word, pos = sentence[i]
     if i == 0:
         prevword, prevpos = "<START>", "<START>"
     else:
         prevword, prevpos = sentence[i-1]
     if i == len(sentence)-1:
         nextword, nextpos = "<END>", "<END>"
     else:
         nextword, nextpos = sentence[i+1]
     return {"pos": pos,
             "word": word,
             "prevpos": prevpos,
             "nextpos": nextpos,
             "prevpos+pos": "%s+%s" % (prevpos, pos),
             "pos+nextpos": "%s+%s" % (pos, nextpos),
             "tags-since-dt": tags_since_dt(sentence, i)}

def clean(sent):
  mysent = []
  inparens = False
  tag = True
  quote = False
  for c in sent:
    if c == '(':
      inparens = True
    elif inparens and c == ',':
      tag = False
    elif inparens and c == "\"":
      if quote:
        quote = False
      else:
        quote = True
    elif inparens and c == "'":
      if quote:
        mysent.append(c)
      else:
        continue
    elif c == ')':
      inparens = False
      tag = True
    elif tag:
      mysent.append(c)
  return ''.join(mysent)

sys.stderr.write('Loading chunker\n')
modelFile = open(sys.argv[modelix],'rb')
chunker = pickle.load(modelFile)
modelFile.close()

sys.stderr.write('Loading corpus for chunking\n')
inFile = open(sys.argv[testix],'r')
test_sents = inFile.readlines()
inFile.close()

sys.stderr.write('Chunking corpus\n')
for s in test_sents:
  #do we need to do the tagging, or does it occur within the parse function?
  newS = ''

#  sys.stderr.write(str(clean(s))+'\n')
  for w in clean(s).split():
    #we only want to chunk the words of the sentences
    if type(w) == type(''):
      newS = newS + ' ' + w
    else:
      newS = newS + ' ' + w[0]
  print chunker.parse(nltk.pos_tag(nltk.word_tokenize(newS)))
  #print chunker.parse(s)

