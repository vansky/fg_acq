#python buildChunker.py modelfile 
import sys
import nltk
import pickle
from nltk.chunk.util import conlltags2tree

#nltk.config_megam('/home/compling/megam_64-bit/megam-64.opt')

modelix = 1

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

sys.stderr.write('Loading training corpus\n')
train_sents = nltk.corpus.conll2000.chunked_sents('train.txt', chunk_types=['NP'])

sys.stderr.write('Training chunker\n')
chunker = ConsecutiveNPChunker(train_sents)

sys.stderr.write('Saving chunker\n')
modelFile = open(sys.argv[modelix],'wb')
pickle.dump(chunker,modelFile)
modelFile.close()
