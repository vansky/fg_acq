###############################################################################
##                                                                           ##
## This file is part of ModelBlocks. Copyright 2009, ModelBlocks developers. ##
##                                                                           ##
##    ModelBlocks is free software: you can redistribute it and/or modify    ##
##    it under the terms of the GNU General Public License as published by   ##
##    the Free Software Foundation, either version 3 of the License, or      ##
##    (at your option) any later version.                                    ##
##                                                                           ##
##    ModelBlocks is distributed in the hope that it will be useful,         ##
##    but WITHOUT ANY WARRANTY; without even the implied warranty of         ##
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          ##
##    GNU General Public License for more details.                           ##
##                                                                           ##
##    You should have received a copy of the GNU General Public License      ##
##    along with ModelBlocks.  If not, see <http://www.gnu.org/licenses/>.   ##
##                                                                           ##
###############################################################################

################################################################################
#
#  i. Macros & variables
#
################################################################################

SHELL = /bin/bash
#INCLUDES = -Iinclude -I../rvtl/include -I../slush/include #-I/sw/include #-I/Users/dingcheng/Documents/boost/boost_1_44_0
CFLAGS = -Wall `cat user-cflags.txt` -g #-DNDEBUG -O3 #-DNOWARNINGS #-g #
CC = g++ 
LD = g++
PYTHON = python3
ME_PARAMS = -i500,-g0.5
#ME_PARAMS = -i100
#X_MXSTUFF = 
X_MXSTUFF = -Xmx12g

comma = ,
space = $(subst s, ,s)

PROPTXT       = /project/nlp/data/propbank/propbank-1.0/prop.txt
READINGDATA   = /project/nlp/data/readingtimes

SWBDTRAINSECTS = 2 3
DUNDEESECTS = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20
DUNDEESUBJS = sa sb sc sd se sf sg sh si sj
WSJMAPTRAINSECTS  = 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21  ##EOS
WSJTRAINSECTS  = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21  ##EOS
WSJTRAINSECTS02  = 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21  ##EOS
WSJHELDOUTSECTS  = 00
BROWNTRAINSECTS = cf cg ck cl cm cn cp cr
BNCTRAINDIRS = A B C D E F G H J
LRSECTS = oerr oer ofr oq rnr se ser

include $(wildcard */*.d)      ## don't comment out, it breaks make!

.SUFFIXES:
.SECONDEXPANSION:


################################################################################
#
#  ii. Demo
#
################################################################################

## std model, berk parser
all: wsj22-10first.wsj01to21-psg-nol-1671-3sm.berk.parsed.cnftrees
## std model, cpt parser (deprecated)
all: wsj22-10first.wsj01to21-psg-nol-1671-3sm.unked.wsj01to21-psg-nol-1671-3sm-bd.x-cfp.-xa_parsed.nosm.cnftrees
## std model, fabp parser
all: wsj22-10first.wsj02to21-psg-nol-1671-3sm-bd.x-fabp.parsed.nosm.cnftrees
## std model role labeler (published: wsj23.wsj01to21-psg-1671-5sm.berk.parsed.nosm.wsj01to21-psg.mapped.propeval)
all: wsj22-10first.wsj02to21-psg-1671-3sm.berk.parsed.nosm.wsj01to21-psg.mapped.propeval
## std model, non-psg grammar
all: wsj22-10first.wsj02to21-1671-3sm-bd.x-fabp.-b2000_parsed.nosm.syneval
## increm srl
all: wsj22-1first.wsj02to21-psg-fg-1671-0sm-bd.x-efabp.-b2000_parsed.output
## dundee evaluation (lengthy)
#all: dundee.wsj02to21-psg-fg-1671-3sm-bd.x-efabp.-c_-b2000_parsed.-nlg.dundeeeval

##### PREVNEW STYLE
### failed experiment with bd prior to sm (prev newstyle)
#all: wsj22-10first.wsj01to21-psg-bd-1671-3sm_,_berk_parsed.nosm.nobd.wsj01to21-psg_-a3,-i0,-o0,-k0_zmemapped.zpropeval

##### OLD STYLE
##### demo cky parser 
#all: wsj22-10first-mb.wsjTRAIN-mb-tdepth_,_pwdt-cc_parsed.syneval
##### demo hhmm parser 
#all: wsj22-10first-mb.wsjTRAIN-mb-tdepth_-b500,-xa_pwdt-cfp_parsed.syneval
##### demo role-labeler on gold standard tree 
#all: genmodel/wsj22.wsjTRAIN_mapped.propeval
##### demo role-labeler on parsed tree
#all: wsj22-10first.wsjTRAIN-mb-tdepth_-b500,-xa_pwdt-cfp_parsed.wsjTRAIN_mapped.propeval
##### demo parsing/annotating with maxent 
#all: wsj22-10first.wsjTRAIN-mb-tdepth_-b500,-xa_pwdt-cfp_parsed.wsjTRAIN_memapped.propeval
##### demo parsing with berkeley grammar
#all: wsj22-393first.wsjTRAINberk-2sm_unked.wsjTRAINberk-2sm-mdepth_,_x-rte_parsed.syneval
##all: wsj22-10first.wsjTRAINberk-2sm_unked.wsjTRAINberk-2sm-mdepth_-b500,-xa_x-cfp_parsed.syneval
##### demo melcuk-style dependencies from berkeley parser
#all: wsj22-393first.wsjTRAINpsg-3sm-fromgaptrees_,_berk_parsed.depeval
##all: wsj22-10first.wsjTRAIN-2sm-fromgaptrees_,_berk_parsed.depeval
##### demo propbank-style content from berkeley parser
##all: wsj22-393first.wsjTRAIN-3sm-fromgaptrees_,_berk_parsed.wsjTRAIN_-a3,-i0,-o0,-k0_zmemapped.zpropeval
##all: wsj22-393first.wsjTRAIN-3sm-fromgaptrees_,_berk_parsed.wsjTRAIN-3sm-forcedaligned_-a3,-i0,-o0,-k0_zmemapped.zpropeval
#all: wsj22-393first.wsjTRAINpsg-3sm-fromgaptrees_,_berk_parsed.wsjTRAINpsg-3sm-forcedaligned_-a3,-i0,-o0,-k0_zmemapped.zpropeval
#all: wsj22-393first.wsjTRAINpsg-3sm-fromgaptrees_,_berk_parsed.nosm.wsjTRAINpsg_-a3,-i0,-o0,-k0_zmemapped.zpropeval
##### demo good parser
#all: wsj22-393first.wsjTRAIN-3sm-fromgaptrees_unked.wsjTRAIN-3sm-fromgaptrees-mdepth_,_x-rtue_parsed.syneval
##### demo fast parser
#all: wsj22-393first.wsjTRAIN-3sm-fromgaptrees_unked.wsjTRAIN-3sm-forcedaligned-t2m_,_x-rtue_parsed.syneval


################################################################################
#
#  iii. User-specific parameter files (not shared; created by default with default values)
#
#  These parameter files differ from user to user, and should not be checked in.
#  This script just establishes 'official' default values for these parameters.
#
################################################################################

#### c++ compile flags
user-cflags.txt:   ## -g
	echo '-DNDEBUG -O3' > $@
	@echo ''
	@echo 'ATTENTION: I had to create "$@" for you, which may not be to your liking'
	@echo 'edit it to tell C++ whether to compile in debug mode or optimize, and re-run make to continue!'
	@echo ''

#### c++ compile flags
user-javaflags.txt:
	echo '-Xmx4g' > $@
	@echo ''
	@echo 'ATTENTION: I had to create "$@" for you, which may not be to your liking'
	@echo 'edit it to give java as much memory as you want to, and re-run make to continue!'
	@echo ''

#### location of treebank
user-treebank-location.txt:
	echo '/home/corpora/original/english/penn_treebank_3' > $@
	@echo ''
	@echo 'ATTENTION: I had to create "$@" for you, which may be wrong'
	@echo 'edit it to point at your treebank repository, and re-run make to continue!'
	@echo ''

#### location of bnc
user-bnc-location.txt:
	echo '/home/corpora/original/english/bnc' > $@
	@echo ''
	@echo 'ATTENTION: I had to create "$@" for you, which may be wrong'
	@echo 'edit it to point at your bnc repository, and re-run make to continue!'
	@echo ''

#### location of dundee
user-dundee-location.txt:
	echo '/home/corpora/original/english/dundee' > $@
	@echo ''
	@echo 'ATTENTION: I had to create "$@" for you, which may be wrong'
	@echo 'edit it to point at your dundee repository, and re-run make to continue!'
	@echo ''

#### location of lrbank
user-lrbank-location.txt:
	echo '/home/corpora/original/english/longrange' > $@
	@echo ''
	@echo 'ATTENTION: I had to create "$@" for you, which may be wrong'
	@echo 'edit it to point at your lrbank repository, and re-run make to continue!'
	@echo ''

#### location of propbank
user-propbank-location.txt:
	echo '/home/corpora/original/english/propbank/propbank-1.0' > $@
	@echo ''
	@echo 'ATTENTION: I had to create "$@" for you, which may be wrong'
	@echo 'edit it to point at your propbank repository, and re-run make to continue!'
	@echo ''

#### location of srilm
user-srilm-location.txt:
	echo '/home/compling/srilm/bin' > $@
	echo 'i686' >> $@
	@echo ''
	@echo 'ATTENTION: I had to create "$@" for you, which may be wrong'
	@echo 'edit it to point at your srilm binaries directory, and re-run make to continue!'
	@echo 'I had to create "$@" for you, which may be wrong'
	@echo ''

SRILM = $(shell head -1 user-srilm-location.txt)
SRILMSUB = $(shell tail -1 user-srilm-location.txt)


#### includes for user sub-projects (default includes are all commented out)
include user-subproject-includes.txt
user-subproject-includes.txt:
	echo '' > $@
	#echo '#include spliteval.mk' >> $@
	#echo '#include swbd.mk'      >> $@
	#echo '#include hdwd.mk'      >> $@
	#echo '#include srl.mk'       >> $@
	#echo '#include extra.mk'     >> $@
	#echo '#include coref.mk'     >> $@


################################################################################
#
#  iv. Code compilation items
#
################################################################################

#### bin directory (ignored by git b/c empty)
bin:
	if [ ! -d $@ ]; then mkdir $@; fi


#### c++ dependencies
.PRECIOUS: %.d
%.d: %.cpp
	echo '$*.d: \' > $@   #' ##
	echo `$(CC) $(INCLUDES) -MM $<` | sed 's/^.*:.*\.cpp */ $$(wildcard /;s/\\ *//g;s/$$/)/' >> $@
	cat $@ | sed 's/\.d:/\.cpp:/' >> $@
#	$(CC) -MM $< | sed 's/^.*://' >> $@
#### ocaml dependencies
%.d: %.ml
	echo '$@ : \' > $@   #' ##
	echo `grep '#load' $< | sed 's/.*\"\(.*\)\".*/\1/' | grep -v 'cmxa'` | sed 's/\.ml/\.cmx/g' >> $@
	echo '$< : \' >> $@   #' ##
	echo `grep '#load' $< | sed 's/.*\"\(.*\)\".*/\1/' | grep -v 'cmxa'` | sed 's/\.ml/\.cmx/g' >> $@


#### c++ executables
.PRECIOUS: bin/%
bin/%: src/%.cpp src/%.d user-cflags.txt | bin
	$(CC) $(CFLAGS) -lm $< -o $@
#	$(CC) $(CFLAGS) -L/sw/lib/ -lboost_thread -lm $< -o $@
#	$(CC) $(CFLAGS) -L/Users/dingcheng/Documents/boost/boost_1_44_0/stage/lib -lboost_thread -lm $< -o $@
#### ocaml executables
%.cmx: %.ml %.d
	ocamlopt -I scripts `grep '#load' $< | sed 's/.*\"\(.*\)\".*/\1/' | sed 's/\.ml/\.cmx/g'` $< -c $@
bin/%: scripts/%.ml scripts/%.d | bin
	ocamlopt -I scripts `grep '#load' $< | sed 's/.*\"\(.*\)\".*/\1/' | sed 's/\.ml/\.cmx/g'` $< -o $@
#### cython executables
%.c: %.py
	cython --embed $< -o $@
bin/%: scripts/%.c
	gcc  -lpython2.5 -I /Library/Frameworks/Python.framework/Versions/2.6/include/python2.6/ $< -o $@
#### java executable objects
.PRECIOUS: %.class
%.class: %.java #$$(addsuffix .class,$$(subst .,/,$$(subst import ,,$$(shell grep -o 'import edu[.a-zA-Z0-9]*' $$(subst .class,.java,$$@)))))
	javac $<

#### maxent executable
../maxent-20061005/src/opt/maxent: ../liblbfgs-1.10/lib/lbfgs.o 
	cd ../maxent-20061005 ; ./configure ; make
../liblbfgs-1.10/lib/lbfgs.o:
	cd ../liblbfgs-1.10 ; ./configure ; make

#### megam shortcut executable
#megam_0.92/megam.opt: megam_0.92/Makefile  # | megam_0.92/.depend
#	cd megam_0.92 ; make $(notdir $@)

#### berkeley parser shortcut "executable"
bin/parser-berk:  edu/berkeley/nlp/PCFGLA/BerkeleyParser.class  user-javaflags.txt  |  bin
	echo "#!/bin/sh" > $@
	echo "java $(shell cat $(word 2,$^)) edu/berkeley/nlp/PCFGLA/BerkeleyParser -viterbi -substates -binarize -gr \$$1" >> $@
	chmod u+x $@

bin/calc-cfp-hhmm: src/calc-cfp-hhmm.c src/model.c
	gcc -Wall -Isrc -o $@ $^

#### pdf formatted printouts for electronic markup
%.ps: %
	cat $< | enscript -fCourier7 -r -o $@
%.ln.ps: %
	cat $< | grep -n '' | enscript -fCourier7 -r -o $@
%.pdf: %.ps
	ps2pdf $< $@


#### GPL packages from other authors included in modelblocks
bin/evalb: src/evalb.c | bin
	gcc -Wall -g -o $@ $<
stanford-tools.jar: # for the parser and for tree surgeon
	javac ../edu/stanford/nlp/*/*.java ../edu/stanford/nlp/*/*/*.java ../edu/stanford/nlp/*/*/*/*.java
	cd ../ ;  jar -cf wsjparse/stanford-tools.jar edu/ ; cd wsjparse
berkeley-parser:
	if [ ! -d $@ ]; then mkdir $@; fi
berkeley-parser/berkeleyParser.jar: | berkeley-parser
	javac edu/berkeley/nlp/ling/CollinsHeadFinder.java
	javac edu/berkeley/nlp/PCFGLA/BerkeleyParser.java 
	javac fig/basic/Pair.java
	javac edu/berkeley/nlp/PCFGLA/WriteGrammarToTextFile.java
	jar -cf berkeley-parser/berkeleyParser.jar edu/ fig/



################################################################################
#
#  1. Text formatting items
#
################################################################################

#### obtain html from wikipedia
srcmodel/wikipedia_%.html:
	wget  en.wikipedia.org/wiki/$*  -O $@
#	wget  en.wikipedia.org/wiki/$(notdir $*)  -O $@

#### obtain txt from html by recursively removing matched pairs of markup (except for those containing the article), then unpaired markup
%.txt: %.html
	cat $< | tr -d '\n' | perl -pe 's/^.*<body[^>]*>(.*)<.body>.*$$/\1/g;  s/<p>/ /g;  s/<(a) ?.*?>(.*?)<\/\1>/\2/g;  s/<(b|i) ?.*?>(.*?)<\/\1>/\2/g;  while ( s/<(?!div id="bodyContent")([a-z0-9]*)[ >](.(?!<\1))*?<\/\1>//g ){};  s/<[^>]*>//g;  s/^[ \t]*(.*?)[ \t\n]*$$/\1/g;' | perl -pe "s/&#160;/ /g;  s/—/--/g" > $@

%.sents: %.txt
	cat $< | perl -pe "s/\"(?! )(?!\))/\`\`/g;  s/(?<! )\"/''/g" | perl -pe "s/(?<! c)(?<! ca)([\.!?])(\)|'')? */ \1 \2\n/g;  s/(\(|\`\`)(?! )/\1 /g;  s/(?<! )(\)|,|;|:|'')(?![0-9])/ \1/g;  y/[A-Z]/[a-z]/"  |  perl -pe "s/\(/\!lrb\!/g;  s/\)/\!rrb\!/g;  s/;/\!semi\!/g;  s/:/\!colon\!/g"  >  $@

#### obtain lexicon of terms that appear more than 5 times
.PRECIOUS: %.lexicon
%.lexicon: %.sents scripts/buildLexicon.py
	$(PYTHON) $(word 2,$^) $< -u5 > $@

################################################################################
#
#  2. Syntax formatting items
#
#  to construct the following file types:
#    <x>.linetrees    : treebank-tagset phase structure trees, one sentence per line, bracketed by parens
#    <x>.cnftrees     : fully-binarized chomsky normal form phase structure trees, one sentence per line, bracketed by parens
#    <x>.projtrees    : projection-annotated phase structure trees, one sentence per line, bracketed by parens
#                       tagset augmented with: -v (constituent is passive)
#    <x>-np.projtrees : <x>.projtrees, with all punctuation tokens eliminated
#    <x>.argtrees     : argument-annotated phase structure trees, one sentence per line, bracketed by parens
#                       tagset augmented with: -u (constituent contains unsatisfied argument)
#    <x>.gaptrees     : gap-annotated phase structure trees, one sentence per line, bracketed by parens
#                       tagset augmented with: -g (constituent contains unfilled gap)
#                                              -m (constituent marked with punctuation:
#                                                  -mB=brack/paren, -mC=comma, -mD=dash, -mE=eos punct, -mS=semi)
#                                              -n (constituent followed by punctuation: [as above])
#                                              -p (constituent preceded by punctuation: [as above])
#    <x>-mb.cnftrees  : fully-binarized chomsky normal form phase structure trees, one sentence per line, bracketed by parens
#    <x>-nr.cnftrees  : <x>.cnftrees, with all 'rare' (single-token type) categories replaced with 'unk'
#    <x>-rl.cnftrees  : role-labeled chomsky normal form phase structure trees, one sentence per line, bracketed by parens
#                       tagset augmented with: -l (constituent marked with role label, describing relation to parent:
#                                                  -lA=argument, -lM=modifier, -lI=identity, -lC=conjunct, -lN=no relation)
#
################################################################################

#### genmodel directory (ignored by git b/c empty)
genmodel:
	if [ ! -d $@ ]; then mkdir $@; fi


#### obtain sentence-aligned tree files (with one tree per line), extracted from various treebanks
## for wsj corpus
.PRECIOUS: genmodel/wsj%.linetrees     
genmodel/wsj%.linetrees:   user-treebank-location.txt $$(shell cat user-treebank-location.txt)/parsed/mrg/wsj/% scripts/tbtrees2linetrees.pl | genmodel
	cat $(word 2,$^)/*.mrg | perl $(word 3,$^) > $@
## for brown corpus
.PRECIOUS: genmodel/brown%.linetrees
genmodel/brown%.linetrees: user-treebank-location.txt $$(shell cat user-treebank-location.txt)/parsed/mrg/brown/% scripts/tbtrees2linetrees.pl
	cat $(word 2,$^)/*.mrg | perl $(word 3,$^) > $@
## for swbd corpus (includes some additional switchboard-specific reformatting, so there is
## an intermediate step)
.PRECIOUS: genmodel/swbd%.sedtrees
genmodel/swbd%.sedtrees:  user-treebank-location.txt $$(shell cat user-treebank-location.txt)/parsed/mrg/swbd/% scripts/removePunct.sed clean-tool/new-clean | genmodel
	cat $(word 2,$^)/*.mrg | sed -f $(word 3,$^) > $@
	$(word 4,$^) $@
.PRECIOUS: genmodel/swbd%.linetrees
genmodel/swbd%.linetrees: genmodel/swbd%.sedtrees scripts/unfLower.rb scripts/remove-edited-repetition.rb scripts/repairify-leave-edited.rb scripts/mybinarize.pl scripts/killUnaries-notEdited.pl
	cat $< | perl -p -e 's/\(S1 (.*)\)/\1/' | ruby $(word 2,$^) | ruby $(word 3,$^) | ruby $(word 4,$^) | perl $(word 5,$^) | perl $(word 6,$^) > $@
## for unbounded dependency corpus
.PRECIOUS: genmodel/lr%.sents
.PRECIOUS: genmodel/lr%.ans
#
#genmodel/lr%.sents: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/lr%.sents scripts/tbtrees2linetrees.pl
#	cat $(word 2,$^)/*.mrg | perl scripts/tbtrees2linetrees.pl > $@
#
genmodel/lr%oerr.sents: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/obj_extract_red_rel/%.raw.obj_extract_red_rel
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;" > $@
genmodel/lr%oerr.ans: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/obj_extract_red_rel/%.obj_extract_red_rel
	cp $(word 2,$^) $@
genmodel/lr%oer.sents: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/obj_extract_rel_clause/%.raw.obj_extract_rel_clause
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;" > $@
genmodel/lr%oer.ans: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/obj_extract_rel_clause/%.obj_extract_rel_clause
	cp $(word 2,$^) $@
genmodel/lr%ofr.sents: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/obj_free_rels/%.raw.obj_free_rels
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;" > $@
genmodel/lr%ofr.ans: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/obj_free_rels/%.obj_free_rels
	cp $(word 2,$^) $@
genmodel/lr%oq.sents: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/obj_qus/%.raw.obj_qus
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;" > $@
genmodel/lr%oq.ans: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/obj_qus/%.obj_qus
	cp $(word 2,$^) $@
genmodel/lr%rnr.sents: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/right_node_raising/%.raw.right_node_raising
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;" > $@
genmodel/lr%rnr.ans: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/right_node_raising/%.right_node_raising
	cp $(word 2,$^) $@
genmodel/lr%se.sents: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/sbj_embedded/%.raw.sbj_embedded
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;" > $@
genmodel/lr%se.ans: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/sbj_embedded/%.sbj_embedded
	cp $(word 2,$^) $@
genmodel/lr%ser.sents: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/sbj_extract_rel_clause/%.raw.sbj_extract_rel_clause
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;" > $@
genmodel/lr%ser.ans: user-lrbank-location.txt $$(shell cat user-lrbank-location.txt)/sbj_extract_rel_clause/%.sbj_extract_rel_clause
	cp $(word 2,$^) $@

lrdev.%:  lrdevoerr.%  lrdevoer.%  lrdevofr.%  lrdevoq.%  lrdevrnr.%  lrdevse.%  lrdevser.%
	more $^  >  $@
lrtest.%: lrtestoerr.% lrtestoer.% lrtestofr.% lrtestoq.% lrtestrnr.% lrtestse.% lrtestser.%
	more $^  >  $@

## for dundee eyetracking corpus
.PRECIOUS: genmodel/dundee%.sents
.PRECIOUS: genmodel/dundee.sents
genmodel/dundee%.sents: user-dundee-location.txt $$(shell cat user-dundee-location.txt)/tx%wrdp.dat scripts/builddundeecorpus.py
	cat $(word 2,$^) | python $(word 3,$^) > $@.raw
	cat $@.raw | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;s/  / /g;" > $@
	rm -f $@.raw

.PRECIOUS: genmodel/dundee.%.textdata
genmodel/dundee.%.textdata: user-dundee-location.txt $$(shell cat user-dundee-location.txt)/tx%wrdp.dat
	echo 'WORD ' > $@
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;s/  / /g;" >> $@

genmodel/dundee.%.textdata:  $(foreach sect,$(DUNDEESECTS),genmodel/dundee.$(sect).textdata)
	cat $^  >  $@

.PRECIOUS: genmodel/dundee.%.eventdata
genmodel/dundee.%.eventdata: user-dundee-location.txt $$(shell cat user-dundee-location.txt)/%ma1p.dat
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;s/  / /g;" > $@

genmodel/dundee.%.eventdata:  $(foreach sect,$(DUNDEESECTS),genmodel/dundee.%$(sect).eventdata)
	cat $^  >  $@

.PRECIOUS: genmodel/dundee.%.eyedata
genmodel/dundee.%.eyedata: user-dundee-location.txt $$(shell cat user-dundee-location.txt)/%ma2p.dat
	cat $(word 2,$^) | perl -pe "s/\(/-LRB-/g;s/\)/-RRB-/g;s/  / /g;" > $@

genmodel/dundee.%.eyedata: $(foreach sect,$(DUNDEESECTS),genmodel/dundee.%$(sect).eyedata)
	cat $^ > $@

genmodel/dundee.%: $(foreach sect,$(DUNDEESECTS),genmodel/dundee$(sect).%)
	cat $^ > $@

#### collections
genmodel/wsj00to21.linetrees: $(foreach sect,$(WSJMAPTRAINSECTS),genmodel/wsj$(sect).linetrees)
	cat $^  >  $@
genmodel/wsj01to21.linetrees: $(foreach sect,$(WSJTRAINSECTS),genmodel/wsj$(sect).linetrees)
	cat $^  >  $@
genmodel/wsj02to21.linetrees: $(foreach sect,$(WSJTRAINSECTS02),genmodel/wsj$(sect).linetrees)
	cat $^  >  $@
#genmodel/wsjTRAIN.linetrees: $(foreach sect,$(WSJTRAINSECTS),genmodel/wsj$(sect).linetrees)
#	cat $^  >  $@
#genmodel/wsjBERKTRAIN.extraparen.linetrees: $(foreach sect,$(WSJTRAINSECTS),genmodel/wsj$(sect).linetrees)
#	cat $^ | sed 's/^\((.*\)$$/(\1)/g' > $@

define BNCDIRMACRO
.PRECIOUS: genmodel/bnc$(1).sents
genmodel/bnc$(1).sents: $$(shell cat user-bnc-location.txt)/Texts/$(1)/*/*
	cat $$^ | sed 's|<teiHeader.*</teiHeader>||g;s|<[^<>]*>||g;s|^\s*\n||g;/^$$$$/d;s|  *| |g;' > $$@
endef

$(foreach dir,$(BNCTRAINDIRS),$(eval $(call BNCDIRMACRO,$(dir))))

.PRECIOUS: genmodel/bncTRAIN.sents
genmodel/bncTRAIN.sents: $(foreach sect,$(BNCTRAINDIRS),genmodel/bnc$(sect).sents)
	cat $^ > $@

genmodel/brownTRAIN.linetrees: $(foreach sect,$(BROWNTRAINSECTS),genmodel/brown$(sect).linetrees)
	cat $^ > $@
genmodel/swbdTRAIN.linetrees: $(foreach sect,$(SWBDTRAINSECTS),genmodel/swbd$(sect).linetrees)
	cat $^ > $@
genmodel/%qb.linetrees: genmodel/%.linetrees genmodel/qb.linetrees
	cat $^ > $@

#### selective tree sets: look for selections in the order they occur below:
#### use only trees with N or greater words
%.linetrees: $$(wordlist 2,$$(words $$(subst -minwds, ,$$@)),- $$(subst -minwds, ,$$@)).linetrees
	cat $< | perl -na -e "if (split(/\#/)>$(word 2,$(subst -minwds, ,$*))) {print $$_;}" > $@      ## (note: split >=X would mean num words >=X-1)
#### use only first N trees
%.linetrees: $$(wordlist 2,$$(words $$(subst -first, ,$$@)),- $$(subst -first, ,$$@)).linetrees
	head -$(word 2,$(subst -first, ,$*)) $< > $@
%first.linetrees: $$(subst $$(space),-,$$(wordlist 2,$$(words $$(subst -, ,$$@)),- $$(subst -, ,$$@))).linetrees
	head -$(lastword $(subst -, ,$*)) $< > $@

%.linetrees: $$(wordlist 2,$$(words $$(subst -only, ,$$@)),- $$(subst -only, ,$$@)).linetrees
	head -$(word 2,$(subst -first, ,$*)) $< > $@
%only.linetrees: $$(subst $$(space),-,$$(wordlist 2,$$(words $$(subst -, ,$$@)),- $$(subst -, ,$$@))).linetrees
	head -$(lastword $(subst -, ,$*)) $< | tail -1 > $@

#### NEWSTYLE
%first.linetrees:  $$(basename %).linetrees
	head -$(subst .,,$(suffix $*)) $<  >  $@
%last.linetrees:  $$(basename %).linetrees
	tail -$(subst .,,$(suffix $*)) $<  >  $@
%only.linetrees:  $$(basename %).linetrees
	head -$(subst .,,$(suffix $*)) $< | tail -1 >  $@

%.nounary.linetrees:  %.linetrees  scripts/killUnaries.pl
	cat $<  |  perl $(word 2,$^)  >  $@

# BACKWARD COMPATIBLITY FOR 684.01 HW5; delete after due date
#.PRECIOUS: %psg.cnftrees
#%psg.cnftrees:  %.linetrees  scripts/annotateFixes.pl  scripts/annotatePsg.pl  scripts/killUnaries.pl
#	cat $<  |  perl $(word 2,$^) -p |  perl $(word 3,$^)  |  perl $(word 4,$^)  |  perl -pe 's/.*\([A-Z]+ .*//'  |  perl -pe 's/\(([^ ]*)-f[^ ]*/\(\1/g'  >  $@

#### NEWSTYLE
.PRECIOUS: %.psg.cnftrees  ## NOTE: inline seds dispose of reannotation failures, then remove -f tags, then shift -l tags to end
%.psg.cnftrees:  %.linetrees  scripts/annotateFixes.pl  scripts/annotatePsg.pl  scripts/killUnaries.pl
	cat $<  |  perl $(word 2,$^) -p |  perl $(word 3,$^)  |  perl $(word 4,$^) -l  |  perl -pe 's/.*\([A-Z]+ .*//'  |  perl -pe 's/\(([^ ]*)-f[^ ]*/\(\1/g' | perl -pe 's/\(([^ ]*)-l([A-Z])([^ ]*)/\(\1\3-l\2/g;'  >  $@
#	cat $<  |  perl $(word 2,$^) -p |  perl $(word 3,$^)  |  perl $(word 4,$^)  |  perl -pe 's/.*\([A-Z]+ .*//'  |  perl -pe 's/\(([^ ]*)-f[^ ]*/\(\1/g' | perl -pe 's/\(([^ ]*)-l([A-Z])([^ ]*)/\(\1\3-l\2/g;' |  perl -pe 's/-[mpn][BCDESQ]//g' >  $@

.PRECIOUS: %.psg.hy.cnftrees ## this break hyphenated and slashed words for conll08 eval
%.psg.hy.cnftrees:  %.psg.cnftrees scripts/dehyphenate.py scripts/conll08Common.py
	python3 $(word 2,$^) -c $< -d1 >  $@

##### obtain psg re-annotated trees
#.PRECIOUS: %psg.gaptrees
#%psg.gaptrees: %.linetrees  scripts/annotateFixes.pl  scripts/annotatePsg.pl  scripts/killUnaries.pl
#	cat $<  |  perl $(word 2,$^) -p |  perl $(word 3,$^)  |  perl $(word 4,$^)  |  perl -pe 's/.*\([A-Z]+ .*//'  |  perl -pe 's/\(([^ ]*)-f[^ ]*/\(\1/g'  >  $@
##### obtain re-annotated trees: punctuation removed
#.PRECIOUS: %-np.gaptrees
#%-np.gaptrees: %.linetrees  scripts/annotateFixes.pl  scripts/annotateCats.pl  scripts/annotateProjs.pl  scripts/annotateArgs.pl  scripts/annotateGaps.pl  scripts/annotateMarks.pl
#	cat $<  |  perl $(word 2,$^)  |  perl $(word 3,$^)  |  perl $(word 4,$^) -p  |  perl $(word 5,$^)  |  perl $(word 6,$^)  |  perl $(word 7,$^)  >  $@
##### obtain re-annotated trees: punctuation retained
#.PRECIOUS: %.gaptrees
#%.gaptrees: %.linetrees  scripts/annotateFixes.pl  scripts/annotateCats.pl  scripts/annotateProjs.pl  scripts/annotateArgs.pl  scripts/annotateGaps.pl  scripts/annotateMarks.pl
#	cat $<  |  perl $(word 2,$^)  |  perl $(word 3,$^)  |  perl $(word 4,$^)  |  perl $(word 5,$^)  |  perl $(word 6,$^)  |  perl $(word 7,$^)  >  $@
##### obtain semrole-annotated trees
#.PRECIOUS: %-rl.gaptrees
#%-rl.gaptrees: %.gaptrees  scripts/annotateRoles.pl
#	cat $< | perl $(word 2,$^) > $@
#.PRECIOUS: %.extrapar.gaptrees
#%.extrapar.gaptrees: %.gaptrees  #scripts/rightBerkBinarize.pl
#	cat $<  |  sed 's/-[mpn][BCDESQ]//g'  |  perl -pe 's/\-(?![^ \)]*\))/\&/g'  |  sed 's/^\((.*\)$$/(\1)/g'  >  $@
##	cat $<  |  perl $(word 2,$^)  |  sed 's/-[mpn][BCDESQ]//g;s/\-/\&/g'  |  sed 's/^\(.*\)$$/(\1)/g'  >  $@

##### obtain chomsky normal form trees by removing non-maximal category labels in unary branches
#%.cnftrees: %.linetrees scripts/killUnaries.pl
#	cat $<  |  perl $(word 2,$^)  >  $@
###### obtain chomsky normal form trees by adding underscore nonterminals
#%.cnftrees: %.gaptrees
#	cat $<  >  $@
#.PRECIOUS: %-mb.cnftrees
#%-mb.cnftrees: %.gaptrees scripts/ensureCnf.pl
#	cat $< | perl $(word 2,$^) > $@
##### obtain chomsky normal form trees by adding underscore nonterminals -- WARNING: gives pos's without -l tags
#.PRECIOUS: %-mb-rl.cnftrees
## kill unbinarize.pl
##%-mb-rl.cnftrees:  %-mb.cnftrees  scripts/unbinarize.pl  scripts/annotateRoles.pl  scripts/ensureCnf.pl
##	cat $<  |  perl $(word 2,$^)  |  perl $(word 3,$^)  |  perl $(word 4,$^)  >  $@
#%-mb-rl.cnftrees:  %-mb.cnftrees  scripts/annotateRoles.pl  scripts/ensureCnf.pl
#	cat $<  |  perl $(word 2,$^)  |  perl $(word 3,$^)  >  $@
##.PRECIOUS: %-rl.cnftrees
##%-rl.cnftrees:  %.cnftrees  scripts/annotateRoles.pl
##	cat $<  |  perl $(word 2,$^)  >  $@
## kill unbinarize.pl
##%_parsed-mb-rl.cnftrees:  %_parsed.cnftrees  scripts/unbinarize.pl  scripts/annotateRoles.pl  scripts/ensureCnf.pl
##	cat $<  |  perl $(word 2,$^)  |  perl $(word 3,$^)  |  perl $(word 4,$^)  >  $@
#%_parsed-mb-rl.cnftrees:  %_parsed.cnftrees scripts/annotateRoles.pl  scripts/ensureCnf.pl
#	cat $<  |  perl $(word 2,$^)  |  perl $(word 3,$^) >  $@
##### obtain corpus with no rare (singleton) categories (mostly un-projected underscore cats)
#%-nr.cnftrees:  %.cnftrees  scripts/elim-rare-cats.py
#	cat $<  |  $(PYTHON)  $(word 2,$^)  >  $@
####### obtain cnf trees with N rarest cats removed (given by -ccN)
## %.cnftrees: $$(wordlist 2,$$(words $$(subst -cc, ,$$@)),- $$(subst -cc, ,$$@)).cnftrees  bin/expand-mod-relns  bin/remove-rare-cats
## 	cat  $<  |  sed 's/(\([^hm][^ )(]*\)/(h:\1/g'  |  $(word 2,$^)  |  $(word 3,$^)  $(word 2,$(subst -cc, ,$*))  >  $@


##### obtain depth-sensitive cnf trees
#%-tdepth.cnftrees:  %.cnftrees  scripts/cnftrees2cedepths.rb
#	cat $<  |  ruby $(word 2,$^)  |  grep -v '\^R,5'  >  $@
##### add depths but don't filter
#%-nobound-tdepth.cnftrees:  %.cnftrees  scripts/cnftrees2cedepths.rb
#	cat $<  |  ruby $(word 2,$^)  >  $@
##### trick with gaps for cogsci paper
#%-pullgap-nobound-tdepth.cnftrees:  %.cnftrees  scripts/unarizeGaps.pl  scripts/decrementNonGaps.pl
#	cat $<  |  perl $(word 2,$^)  |  perl $(word 3,$^)  >  $@


#### NEWSTYLE
%first.cnftrees:  $$(basename %).cnftrees
	head -$(subst .,,$(suffix $*)) $<  >  $@
%last.cnftrees:  $$(basename %).cnftrees
	tail -$(subst .,,$(suffix $*)) $<  >  $@
%only.cnftrees:  $$(basename %).cnftrees
	head -$(subst .,,$(suffix $*)) $< | tail -1 >  $@
%.extrpar.cnftrees:  %.cnftrees
#	cat $<  |  perl -pe 's/-[mpn][BCDESQ]//g;s/\-(?![^ \)]*\))/\&/g'  |  sed 's/^\((.*\)$$/(\1)/g'  >  $@
	cat $<  |  perl -pe 's/\-(?![^ \)]*\))/\&/g'  |  sed 's/^\((.*\)$$/(\1)/g'  >  $@
%.extrpar.linetrees: %.linetrees
	cat $<  |  sed 's/^\((.*\)$$/(\1)/g'  >  $@
%.bd.cnftrees:  %.cnftrees  scripts/annotateDepth.py
	cat $<  |  python3 $(word 2,$^)  >  $@  # |  grep -v '\-bR-d5'  >  $@
%.nobd.cnftrees:  %.cnftrees
	cat $<  |  sed 's/-b[LR]-d[0-9]//g'  >  $@
%.nol.cnftrees:  %.cnftrees
	cat $<  |  sed 's/-l.//g' > $@
%.fg.cnftrees:  %.cnftrees  scripts/annotateFGTrans.pl
	cat $<  |  perl $(word 2,$^)  >  $@

#### symbol counts
%.symbolcounts: %
	cat $< | bin/indent2 | sed 's/^ *(\([^ ]*\).*$$/\1/' | sort | uniq -c > $@


#### forced alignment -- doesn't work
#%-0sm-forcedaligned.gaptrees:  %.gaptrees  scripts/berkBinarize.pl  scripts/forcedaligner.py  %-0sm-fromgaptrees.x-cc.model
#	cat $<  |  perl $(word 2,$^)  |  python3 $(word 3,$^) $(word 4,$^)  |  sed 's/\_\([0-9][0-9]*\)/-\1/g'  >  $@
#%-1sm-forcedaligned.gaptrees:  %.gaptrees  scripts/berkBinarize.pl  scripts/forcedaligner.py  %-1sm-fromgaptrees.x-cc.model
#	cat $<  |  perl $(word 2,$^)  |  python3 $(word 3,$^) $(word 4,$^)  |  sed 's/\_\([0-9][0-9]*\)/-\1/g'  >  $@
#%-2sm-forcedaligned.gaptrees:  %.gaptrees  scripts/berkBinarize.pl  scripts/forcedaligner.py  %-1sm-fromgaptrees.x-cc.model
#	cat $<  |  perl $(word 2,$^)  |  python3 $(word 3,$^) $(word 4,$^)  |  sed 's/\_\([0-9][0-9]*\)/-\1/g'  >  $@
#%-3sm-forcedaligned.gaptrees:  %.gaptrees  scripts/berkBinarize.pl  scripts/forcedaligner.py  %-3sm-fromgaptrees.x-cc.model
#	cat $<  |  perl $(word 2,$^)  |  python3 $(word 3,$^) $(word 4,$^)  |  sed 's/\_\([0-9][0-9]*\)/-\1/g'  >  $@
#%-4sm-forcedaligned.gaptrees:  %.gaptrees  scripts/berkBinarize.pl  scripts/forcedaligner.py  %-4sm-fromgaptrees.x-cc.model
#	cat $<  |  perl $(word 2,$^)  |  python3 $(word 3,$^) $(word 4,$^)  |  sed 's/\_\([0-9][0-9]*\)/-\1/g'  >  $@

%.viewtrees: %.cnftrees scripts/viewtree
	$(word 2,$^) $<

################################################################################
#
#  3. Propositional content formatting items
#
#  to construct the following file types:
#    <x>.sentrelns : sentence-indexed relations, one per line, with role-specific propositions delimited by spaces
#    <x>.pbconts   : propbank-tagset sentence contents, one sentence per line, with role-specific propositions delimited by spaces
#    <x>.melconts  : melcuk-tagset sentence contents, one sentence per line, with role-specific propositions delimited by spaces
#
################################################################################

#### obtain relation-aligned sentence-indexed propositions for each sentence, including empty lines for `proposition-free' sentences
genmodel/wsj%.sentrelns:  user-treebank-location.txt  $$(shell cat user-treebank-location.txt)/parsed/mrg/wsj/%  user-propbank-location.txt  $$(shell cat user-propbank-location.txt)/prop.txt 
	grep '^(' $(word 2,$^)/*.mrg  |  sed 's/.*parsed\/mrg\///;s/:.*//'  |  perl -pe 'if($$prev ne $$_){$$prev=$$_;$$ct=0;} s/$$/ $$ct/; $$ct++;'  >  $@
	cat $(word 4,$^)  |  grep '^wsj.$*'  >>  $@
#### obtain relation-aligned sentence-indexed propositions for entire training set, including empty lines for `proposition-free' sentences
genmodel/wsj00to21.sentrelns: $(foreach sect,$(WSJMAPTRAINSECTS),genmodel/wsj$(sect).sentrelns) ##genmodel/wsjEOS$*trees  ##genmodel/eos.cnftrees
	cat $^ > $@
genmodel/wsj01to21.sentrelns: $(foreach sect,$(WSJTRAINSECTS),genmodel/wsj$(sect).sentrelns) ##genmodel/wsjEOS$*trees  ##genmodel/eos.cnftrees
	cat $^ > $@
genmodel/wsj02to21.sentrelns: $(foreach sect,$(WSJTRAINSECTS02),genmodel/wsj$(sect).sentrelns) ##genmodel/wsjEOS$*trees  ##genmodel/eos.cnftrees
	cat $^ > $@
genmodel/wsjTRAIN.sentrelns: $(foreach sect,$(WSJTRAINSECTS),genmodel/wsj$(sect).sentrelns) ##genmodel/wsjEOS$*trees  ##genmodel/eos.cnftrees
	cat $^ > $@


#### obtain sentence-aligned space-delimited propbank-domain propositions
.PRECIOUS: %.pbconts
%.pbconts: %.sentrelns  scripts/sentrelns2pbconts.py  %.linetrees
	cat $<  |  perl -pe 'while(s/([^ ]*)\*([^-]*)-([^ \n]*)/\1-\3 \2-\3/g){}; while(s/([^ ]*),([^-]*)-([^ \n]*)/\1-\3 \2-\3/g){}'  |  $(PYTHON) $(word 2,$^) $(word 3,$^)  >  $@
#### use only first N trees
%.pbconts: $$(wordlist 2,$$(words $$(subst -first, ,$$@)),- $$(subst -first, ,$$@)).pbconts
	head -$(word 2,$(subst -first, ,$*)) $< > $@
%first.pbconts: $$(subst $$(space),-,$$(wordlist 2,$$(words $$(subst -, ,$$@)),- $$(subst -, ,$$@))).pbconts
	head -$(lastword $(subst -, ,$*)) $< > $@


#### obtain sentence-aligned space-delimited text-based(number)-domain propositions
.PRECIOUS: %.tbconts
#%.tbconts:  %.cnftrees  scripts/trees2melconts.py
#	$(PYTHON) $(word 2,$^) -t $< -p -r >  $@
%berk.parsed.tbconts:  %berk.parsed.cnftrees scripts/trees2melconts.py
	cat $< | sed 's/(\(\))/\[\)/g;' | perl -pe 's/(\([^ ]+) +\)/\1 \]/g;' > $@.tmp
	$(PYTHON) $(word 2,$^) -t $@.tmp -p -r -c > $@
	rm -f $@.tmp

%_parsed.tbconts:  %_parsed.output scripts/output2tbconts.py scripts/output2commonconts.py
	$(PYTHON) $(word 2,$^) $<  >  $@
%.ans.tbconts:  %.ans  scripts/convertGoldUnbound.py
	$(PYTHON) $(word 2,$^) -f $< >  $@


#### obtain sentence-aligned space-delimited melcuk(number)-domain propositions
.PRECIOUS: %.melconts
## someone changed to %psg.melconts, but doesn't work for depeval!
%.melconts:  %.cnftrees  scripts/trees2melconts.py
	$(PYTHON) $(word 2,$^) -t $< -p -r >  $@
%.ans.melconts:  %.ans  scripts/convertGoldUnbound.py
	$(PYTHON) $(word 2,$^) -f $< >  $@
%nosm.melconts:  %nosm.cnftrees  scripts/trees2melconts.py
	$(PYTHON) $(word 2,$^) -t $< -p >  $@
%parsed.melconts:  %parsed.output scripts/output2melconts.py scripts/output2commonconts.py
	$(PYTHON) $(word 2,$^) $<  >  $@
%.enju.melconts:  %.enju.output scripts/enju2melconts.py
	$(PYTHON) $(word 2,$^) $<  >  $@

##old pre-psg version needed role labels to be added
#%.melconts:  %-mb-rl.cnftrees  scripts/trees2melconts.py
#	$(PYTHON) $(word 2,$^)  -t $< >  $@
%.melrels:  %.melconts
	cat $<  |  grep -n ''  |  perl -pe 's/^([0-9]+):/-----\1-----\n/;s/ (?!$$)/\n/g'  >  $@

################################################################################
#
#  4. Syntax model building items
#
#  to construct the following file types:
#
#    <m>.<x>-<y>.counts : raw counts of model patterns in <m>, using observed <x> and hidden <y> random variables:
#
#                         if <x> = pw   : Pc   (pos given category --- generative)
#                                         Pw   (pos given word --- discriminative)
#                                         P    (prior prob of pos --- used in bayes flip)
#                                         W    (prior prob of word --- used to define oov words)
#
#                                = pwdt : Pc,Pw,P,W (as above)
#                                         PwDT (decis tree for pos given word, if not in Pw)
#
#                                = x    : X    (likelihood of word given terminal category)
#
#                         if <y> = cc   : Cr   (root prior probabilities)
#                                         CC   (joint left and right child given parent)
#
#                                = ccu  : Cr,CC (as above)
#                                         Cu   (unary child given parent --- not used in cnf parsing)
#
#                                = cfp  : Ce   (expansion probability)
#                                         Ctaa (active component of active transition)
#                                         Ctaw (awaited component of active transition)
#                                         Ctww (awaited component of awaited transition)
#                                         F    (final state flag)
#
#    <m>.<x>-<y>.model : probability model, based on counts
#
################################################################################

#### pw-cc counts
.PRECIOUS: %.pw-cc.counts
%.pw-cc.counts: %.cnftrees  scripts/trees2rules.pl  scripts/relfreq.pl
	cat $<  |  perl $(word 2,$^) -p  |  perl $(word 3,$^) -f  >  $@
#### x-cc counts
.PRECIOUS: %.x-cc.counts
%.x-cc.counts: %.cnftrees  scripts/trees2rules.pl  scripts/relfreq.pl
	cat $<  |  perl $(word 2,$^)  |  perl $(word 3,$^) -f  >  $@

##### pcfg counts, not depth-specific
#.PRECIOUS: %-nobd.pw-cc.counts
#%-nobd.pw-cc.counts: %.cnftrees  scripts/trees2rules.pl  scripts/relfreq.pl
#	cat $<  |  perl $(word 2,$^)  |  perl $(word 3,$^) -f  >  $@
####
#.PRECIOUS: %-mdepth.pw-cc.counts
#%-mdepth.pw-cc.counts: %.pw-cc.counts  scripts/pcfg2bdpcfg.py
#	cat $<  |  $(PYTHON) $(word 2,$^)  >  $@
#
####
.PRECIOUS: %.x.model
%.model:  %.counts  scripts/relfreq.pl
	cat $<  |  perl $(word 2,$^)  >  $@


#### decision tree observation model (part of speech model)
.PRECIOUS: %.dt.model
%.dt.model:  %.pw-cc.counts  bin/postrainer  ##scripts/relfreq.pl
	cat $<  |  sed 's/\.0*$$//g'  |  grep '^Pw .* = [1-5]$$'  |  sed 's/^Pw/PwDT/'  |  $(word 2,$^)  >  $@


#### pwdt-cc (pcfg) model
.PRECIOUS: %.pwdt-cc.model
%.pwdt-cc.model:  %.pw-cc.counts  scripts/relfreq.pl  %.dt.model
	cat $<  |  grep -v '^Pw .* = [0]$$'  |  perl $(word 2,$^)  >  $@
	cat $(word 3,$^)  >>  $@


#### pwdt-cfp (hhmm) model
.PRECIOUS: %.pwdt-cfp.model
%.pwdt-cfp.model:  %.pw-cc.counts  scripts/calc-cfp-hhmm.py  scripts/sortbyprob.pl  %.dt.model
	cat $<  |  grep -v '^Pw .* = [0]$$'  |  $(PYTHON) $(word 2,$^)  |  perl $(word 3,$^)  >  $@
	cat $(word 4,$^)  >>  $@

#genmodel/wsjBERKTUNE.extraparen.linetrees: genmodel/wsj21.linetrees
#	cat $< | sed 's/^\((.*\)$$/(\1)/g' > $@

#.PRECIOUS: genmodel/wsjTRAINberk-%sm-fromlinetrees.gr
#genmodel/wsjTRAINberk-%sm-fromlinetrees.gr: edu/berkeley/nlp/PCFGLA/GrammarTrainer.class genmodel/wsjBERKTRAIN.extraparen.linetrees genmodel/wsjBERKTUNE.extraparen.linetrees
#	java $(X_MXSTUFF) edu.berkeley.nlp.PCFGLA.GrammarTrainer -SMcycles $* -path $(word 2,$^) -validation $(word 3,$^) -treebank SINGLEFILE -out $@
#	rm -f $@_*

#.PRECIOUS: genmodel/wsjTRAIN-%sm-fromgaptrees.gr
#genmodel/wsjTRAIN-%sm-fromgaptrees.gr:  edu/berkeley/nlp/PCFGLA/GrammarTrainer.class genmodel/wsjTRAIN.extrapar.gaptrees genmodel/wsj21.extrapar.gaptrees
#	java $(X_MXSTUFF) edu.berkeley.nlp.PCFGLA.GrammarTrainer -SMcycles $* -path $(word 2,$^) -validation $(word 3,$^) -treebank SINGLEFILE -out $@
#	rm -f $@_*
#.PRECIOUS: genmodel/wsjTRAINpsg-%sm-fromgaptrees.gr
#genmodel/wsjTRAINpsg-%sm-fromgaptrees.gr:  edu/berkeley/nlp/PCFGLA/GrammarTrainer.class genmodel/wsjTRAINpsg.extrapar.gaptrees genmodel/wsj21psg.extrapar.gaptrees
#	java $(X_MXSTUFF) edu.berkeley.nlp.PCFGLA.GrammarTrainer -SMcycles $* -path $(word 2,$^) -validation $(word 3,$^) -treebank SINGLEFILE -out $@
#	rm -f $@_*

##### berkeley model -- obtain model database
#.PRECIOUS: genmodel/wsjTRAINberk-%sm.gr
#genmodel/wsjTRAINberk-%sm.gr: berkeley-parser/berkeleyParser.jar user-treebank-location.txt $$(shell cat user-treebank-location.txt)/parsed/mrg/wsj
#	java $(X_MXSTUFF) -cp $< edu.berkeley.nlp.PCFGLA.GrammarTrainer -SMcycles $* -path $(word 3,$^) -out $@
#	rm -f $@_*
#### berkeley model -- obtain grammar and lexicon (text files)
#.PRECIOUS: genmodel/wsjTRAINberk-%sm.grammar genmodel/wsjTRAINberk-%sm.lexicon
#genmodel/wsjTRAINberk-%sm.grammar genmodel/wsjTRAINberk-%sm.lexicon: berkeley-parser/berkeleyParser.jar genmodel/wsjTRAINberk-%sm.gr
#	java -cp $< edu/berkeley/nlp/PCFGLA/WriteGrammarToTextFile $(word 2,$^) $(basename $@)
.PRECIOUS: %.splits %.grammar %.lexicon
%.splits %.grammar %.lexicon:  berkeley-parser/berkeleyParser.jar  %.gr  user-javaflags.txt
	java  $(shell cat $(word 3,$^))  -cp $<  edu/berkeley/nlp/PCFGLA/WriteGrammarToTextFile  $(word 2,$^)  $(basename $@)
.PRECIOUS: %.x-ccu.model
#### berkeley model -- obtain x-cc model (with unaries)
%.x-ccu.model:  %.grammar  %.lexicon  scripts/berkgrammar2ckygr.py  scripts/berklexicon2ckylex.py
	cat $(word 1,$^)  |  python3 $(word 3,$^)  >   $@
	cat $(word 2,$^)  |  python3 $(word 4,$^)  >>  $@


#### NEWSTYLE
.PRECIOUS: %sm.gr
%sm.gr:  edu/berkeley/nlp/PCFGLA/GrammarTrainer.class  $$(basename $$(basename %)).extrpar.cnftrees  $$(basename %)last.extrpar.cnftrees  user-javaflags.txt
	java  $(shell cat $(word 4,$^))  $(subst /,.,$(basename $<))  -SMcycles $(subst .,,$(suffix $*))  -path $(word 2,$^)  -validation $(word 3,$^)  -treebank SINGLEFILE  -out $@

.PRECIOUS: %sm.gr
%sm.gr:  edu/berkeley/nlp/PCFGLA/GrammarTrainer.class  $$(basename $$(basename %)).extrpar.linetrees  $$(basename %)last.extrpar.linetrees  user-javaflags.txt
	java  $(shell cat $(word 4,$^))  $(subst /,.,$(basename $<))  -SMcycles $(subst .,,$(suffix $*))  -path $(word 2,$^)  -validation $(word 3,$^)  -treebank SINGLEFILE  -out $@


#### silly shortcut for berkeley parser
%.berk.model: %.gr
	ln -sf $(notdir $<) $@

#### obtain strict cc model (no unaries)
.PRECIOUS: %.x-cc.model
%.x-cc.model: %.x-ccu.model  scripts/ccu2cc.py
	cat $<  |  $(PYTHON) $(word 2,$^)  >  $@


##### obtain model-based depth-bounded model (which is also strict cc model (no unaries)
#.PRECIOUS: %-mdepth.x-cc.model
#%-mdepth.x-cc.model: %.x-cc.model  scripts/pcfg2bdpcfg.py
#	cat $<  |  $(PYTHON) $(word 2,$^)  >  $@


###### obtain model-based depth-bounded model that isn't 10x larger than it should be
#.PRECIOUS: %-mdepth.x-ccp.model
#%-mdepth.x-ccp.model: %.x-cc.model  scripts/pcfg2pxmodel.py
#	cat $<  |  $(PYTHON) $(word 2,$^)  >  $@


#### NEWSTYLE
# obtain model-based depth-bounded model that isn't 10x larger than it should be
.PRECIOUS: %.bd.x-ccp.model
%.bd.x-ccp.model:  %.x-cc.model  scripts/pcfg2pxmodel.py
	cat $<  |  $(PYTHON) $(word 2,$^)  >  $@

.PRECIOUS: %.bogusbd.x-ccp.model
%.bogusbd.x-ccp.model:  %.x-cc.model  scripts/pcfg2pxmodel.py
	cat $<  |  sed 's/-eb/-bb/g;s/-ei/-bi/g;s/-ee/-be/g'  |  $(PYTHON) $(word 2,$^)  >  $@

#### x-cfp (hhmm) model
.PRECIOUS: %.x-cfp.model
#%.x-cfp.model:  %.x-ccp.model  bin/calc-cfp-hhmm  scripts/sortbyprob.pl
%.x-cfp.model:  %.x-ccp.model  scripts/calc-cfp-hhmm.py  scripts/sortbyprob.pl
	cat $<  |  egrep    '^(CC|Cr)'  | $(PYTHON) $(word 2,$^)  |  perl $(word 3,$^)  >  $@
	cat $<  |  egrep -v '^(PX|CC|Cr)' >>  $@
	# ^^^ this line just passes the X model straight through
#	cat $<  |  egrep -v '^(CC|Cr)'  |  grep -v '\^R,. '  |  grep -v '\^.,[2-5]'  |  sed 's/\^.,. / /'  >>  $@
	# ^^^ this line takes the X lines and strips off branch and depth bounds.

##### x-rte (hhmm) model
#.PRECIOUS: %.x-rte.model
#%.x-rte.model:  %.x-ccp.model  scripts/calc-rte-model.py  scripts/sortbyprob.pl
#	cat $<  |  grep -v '^PX '  |  python3 $(word 2,$^)  |  perl $(word 3,$^)  >  $@
#.PRECIOUS: %.pw-rte.model
#%.pw-rte.model:  %.pw-cc.counts  scripts/calc-rte-model.py  scripts/sortbyprob.pl
#	cat $<  |  python3 $(word 2,$^)  |  perl $(word 3,$^)  >  $@
.PRECIOUS: %.x-rtue.model
#%.x-rtue.model:  %.x-ccp.model  scripts/calc-rtue-model.py  scripts/sortbyprob.pl
#	cat $<  |  grep -v '^PX '  |  python3 $(word 2,$^)  |  perl $(word 3,$^)  >  $@
%.x-rtue.model:  %.x-ccp.model  bin/calc-rtue-model  scripts/sortbyprob.pl
	cat $<  |  grep -v '^PX '  | sed 's/^Cr : \(.*\^[Ll],1\) =/CC REST^R,0 : \1 REST^R,0 =/;s/ - - / -\^.,. -\^.,. /' \
		|  sed 's/CC \(.*\)\^\(.\),\(.\) : \(.*\)\^.,. \(.*\)\^.,. = \(.*\)/CC \2 \3 \1 : \4 \5 = \6/' |  $(word 2,$^)  |  perl $(word 3,$^)  >  $@
.PRECIOUS: %.x-fawp.model
%.x-fawp.model:  %.x-ccp.model  bin/calc-fawp-model  scripts/sortbyprob.pl
	cat $<  |  grep -v '^PX '  | sed 's/^Cr : \(.*\^[Ll],1\) =/CC REST^R,0 : \1 REST^R,0 =/;s/ - - / -\^.,. -\^.,. /' \
		|  sed 's/CC \(.*\)\^\(.\),\(.\) : \(.*\)\^.,. \(.*\)\^.,. = \(.*\)/CC \2 \3 \1 : \4 \5 = \6/' |  $(word 2,$^)  |  perl $(word 3,$^)  >  $@
.PRECIOUS: %.x-fabp.probmodel
%.x-fabp.probmodel:  %.x-ccp.model  bin/calc-fabp-model
	cat $<  |  grep -v '^PX '  | sed 's/^Cr : \(.*\^[Ll],1\) =/CC REST^R,0 : \1 REST^R,0 =/;s/ - - / -\^.,. -\^.,. /' \
		|  sed 's/CC \(.*\)\^\(.\),\(.\) : \(.*\)\^.,. \(.*\)\^.,. = \(.*\)/CC \2 \3 \1 : \4 \5 = \6/' |  $(word 2,$^)  >  $@
.PRECIOUS: %.x-srfabp.model
%.x-srfabp.model: %.x-ccu.model scripts/ccu2cc-save-edited.py scripts/pcfg2pxmodel.py bin/calc-srfabp-model scripts/sortbyprob.pl
	cat $< | $(PYTHON) $(word 2,$^) | $(PYTHON) $(word 3,$^) | grep -v '^PX ' \
		| sed 's/^Cr : \(.*\^[Ll],1\) =/CC REST^R,0 : \1 REST^R,0 =/;s/ - - / -\^.,. -\^.,. /' \
        |  sed 's/CC \(.*\)\^\(.\),\(.\) : \(.*\)\^.,. \(.*\)\^.,. = \(.*\)/CC \2 \3 \1 : \4 \5 = \6/' \
        |  sed 's/UNF[^ ]*/UNF/g' | $(word 4,$^) | perl $(word 5,$^) > $@
.PRECIOUS: %.x-wp-fabp.model #with weight pushing for speediness
%.x-wp-fabp.model:  %.x-fabp.probmodel  scripts/push-fabp-weights.py  scripts/sortbyprob.pl
	cat $<  |  python3 $(word 2,$^)  |  perl $(word 3,$^)  >  $@
.PRECIOUS: %.x-fabp.model
%.x-fabp.model:  %.x-fabp.probmodel  scripts/sortbyprob.pl
	cat $<  |  perl $(word 2,$^)  >  $@
.PRECIOUS: %.x-efawp.model
%.x-efawp.model:  %.x-fawp.model
	ln -sf $(notdir $<) $@
.PRECIOUS: %.x-wp-efabp.model
%.x-wp-efabp.model:  %.x-wp-fabp.model
	ln -sf $(notdir $<) $@
.PRECIOUS: %.x-efabp.model
%.x-efabp.model:  %.x-fabp.model
	ln -sf $(notdir $<) $@

.PRECIOUS: %.x-ctf-fawp.model
%.x-ctf-fawp.model:  $$(subst .bd,,%).splits scripts/calc-grammar-splits.py %.x-fawp.model scripts/calc-ctf-fawp-model.py scripts/sortbyprob.pl
	cat $(word 3,$^) > $(subst fawp,fawp-prectf,$(word 3,$^))
	cat $(word 1,$^) | $(PYTHON) $(word 2,$^) >> $(subst fawp,fawp-prectf,$(word 3,$^))
	cat $(subst fawp,fawp-prectf,$(word 3,$^)) | $(PYTHON) $(word 4,$^) | perl $(word 5,$^) > $@

.PRECIOUS: %.x-ctf-fabp.model
%.x-ctf-fabp.model:  $$(subst .bd,,%).splits scripts/calc-grammar-splits.py %.x-fabp.model scripts/calc-ctf-fabp-model.py scripts/sortbyprob.pl
	cat $(word 3,$^) > $(subst fabp,fabp-prectf,$(word 3,$^))
	cat $(word 1,$^) | $(PYTHON) $(word 2,$^) >> $(subst fabp,fabp-prectf,$(word 3,$^))
	cat $(subst fabp,fabp-prectf,$(word 3,$^)) | $(PYTHON) $(word 4,$^) | perl $(word 5,$^) > $@

.PRECIOUS: %.x-ctfw-fawp.model
%.x-ctfw-fawp.model:  $$(subst .bd,,%).splits scripts/calc-grammar-splits.py %.x-fawp.model scripts/calc-ctf-fawp-model.py scripts/sortbyprob.pl
	cat $(word 3,$^) > $(subst fawp,fawp-prectf,$(word 3,$^))
	cat $(word 1,$^) | $(PYTHON) $(word 2,$^) >> $(subst fawp,fawp-prectf,$(word 3,$^))
	cat $(subst fawp,fawp-prectf,$(word 3,$^)) | $(PYTHON) $(word 4,$^) | perl $(word 5,$^) > $@

.PRECIOUS: %.x-awp.model
%.x-awp.model:  %.x-ccp.model  bin/calc-rtue-model  scripts/sortbyprob.pl
	cat $<  |  grep -v '^PX '  | sed 's/^Cr : \(.*\^[Ll],1\) =/CC REST^R,0 : \1 REST^R,0 =/;s/ - - / -\^.,. -\^.,. /' \
		|  sed 's/CC \(.*\)\^\(.\),\(.\) : \(.*\)\^.,. \(.*\)\^.,. = \(.*\)/CC \2 \3 \1 : \4 \5 = \6/' |  $(word 2,$^)  |  perl $(word 3,$^)  >  $@

#.PRECIOUS: %-forcedaligned-t2m.x-rtue.model
#%-forcedaligned-t2m.x-rtue.model:  %-forcedaligned.cnftrees  %-fromgaptrees.x-cc.model  scripts/cnftrees2rtuemodel.py  scripts/relfreq.pl  scripts/sortbyprob.pl
#	cat $<  |  python3 $(word 3,$^)  |  grep -v '^X'  |  perl $(word 4,$^)  |  perl $(word 5,$^)  >  $@
#	cat $(word 2,$^)  |  grep '^X '  |  sed 's/\_\([0-9]\)/-\1/g'  >>  $@

#### NEWSTYLE
%.t2m.x-rtue.model:  %.cnftrees scripts/cnftrees2rtuemodel.py  scripts/relfreq.pl  scripts/sortbyprob.pl
	cat $<  |  python3 $(word 2,$^)  |  perl $(word 3,$^)  |  perl $(word 4,$^)  >  $@

%.t2m.x-fawp.model:  %.cnftrees scripts/cnftrees2rtuemodel.py  scripts/relfreq.pl  scripts/sortbyprob.pl
	cat $<  |  python3 $(word 2,$^)  |  perl $(word 3,$^)  |  perl $(word 4,$^)  >  $@

################################################################################
#
#  5. Parsing items
#
#  to construct the following file types:
#    <x>.sents                       : sentences, one per line, consisting of only tokenized words, delimited by spaces
#    <w>.<x>_<y>_<z>_parsed.cnftrees : .cnftrees file resulting from applying parser-<z>, using parameter <y>, and model <x>.<z>.model, to <w>.sents file
#    <x>.nosm.cnftrees              : remove latent variable annotation (berkeley split-merge grammar)
#    <x>.syneval : evaluation report for parsing
#    <x>.depeval : evaluation report for syntactic dependencies
#    <x>.gapeval : evaluation report for long-distance dependencies
#
#  e.g.: make wsj22-10first.wsjTRAINberk-2sm_unked.wsjTRAINberk-2sm-mdepth_-b500,-xa_x-cfp_parsed.syneval
#				 make wsj22-393first.wsjTRAINberk-6sm_,_berk_parsed.syneval
#
################################################################################

#### obtain input sentences from linetrees
.PRECIOUS: %.sents
%.sents: %.linetrees
	cat $<  |  sed 's/(-NONE-[^)]*)//g'  \
		|  sed 's/([^ ]* //g;s/)//g'  |  sed 's/  */ /g;s/^ *//;s/ *$$//;'  \
		| sed 's/!unf! *//g' >  $@

#### NEWSTYLE
#### obtain input sentences
.PRECIOUS: %.sents
%.sents: genmodel/$$(subst -,.,$$*).sents
	cp $< $@

.PRECIOUS: %.hysents
%.hysents: %.sents
	cat $< | perl -pe 'while ( s/(\w+)(\-)(\w+)/\1 \2 \3/g ){}; while ( s/([^ \d]+)\\(\/)([^ \d]+)/\1 \2 \3/g ){};' > $@

##### obtain input sentences with modelblocks tag (needed to fix output??)
#%-mb.sents: %-mb.cnftrees
#	cat $< | sed 's/([^ ]* //g;s/)//g;s/[^ \/]*\#//g' > $@

## replace rare words with UNKs from Berkeley set
#%_unked.sents: genmodel/$$(basename $$*).sents  genmodel/$$(word 2,$$(subst ., ,$$*)).x-ccu.model scripts/unkreplace.py
#	cat $<  |  $(PYTHON) $(word 3,$^) $(word 2,$^)  >  $@


#### NEWSTYLE
# replace rare words with UNKs from Berkeley set
%.unked.sents:  $$(basename %).sents  genmodel/$$(subst -,.,$$(subst .,,$$(suffix $$*))).x-ccu.model  scripts/unkreplace.py
	cat $<  |  python3  $(word 3,$^)  $(word 2,$^)  >  $@


##### obtain model-specific parser output by running sentences through parser given flags and model:
#.PRECIOUS: %_parsed.output
#%_parsed.output:  genmodel/$$(basename $$*).sents  bin/parser-$$(word 3,$$(subst _, ,$$(suffix $$*)))  genmodel/$$(word 1,$$(subst _, ,$$(subst .,,$$(suffix $$*)))).$$(word 3,$$(subst _, ,$$(suffix $$*))).model
#	@echo "WARNING: long build for '$@'!  Press CTRL-C to abort!"
#	@sleep 5
#	cat $<  |  $(word 2,$^) $(subst $(comma), ,$(word 2,$(subst _, ,$(suffix $*)))) $(word 3,$^)  >  $@

#### PREVNEWSTYLE
#.PRECIOUS: %_parsed.output
#%_parsed.output:  genmodel/$$(basename $$*).sents  bin/parser-$$(word 3,$$(subst _, ,$$(suffix $$*)))  genmodel/$$(subst -,.,$$(word 1,$$(subst _, ,$$(subst .,,$$(suffix $$*))))).$$(word 3,$$(subst _, ,$$(suffix $$*))).model
#	@echo "WARNING: long build for '$@'!  Press CTRL-C to abort!"
#	@sleep 5
#	cat $<  |  $(word 2,$^) $(subst $(comma), ,$(word 2,$(subst _, ,$(suffix $*)))) $(word 3,$^)  >  $@


#### NEWSTYLE: <testset>.<trainset>.<model>.(<params>_)streamed  ---->  genmodel/<testset>.sents  bin/streamparser-<model>  genmodel/<trainset>.<model>.model
.PRECIOUS: %streamed.output
%streamed.output: $$(basename $$(basename $$(basename %))).$$(findstring hy,$$*)sents \
		bin/streamparser-$$(subst .,,$$(suffix $$(basename $$*))) \
		genmodel/$$(subst -,.,$$(subst .,,$$(suffix $$(basename $$(basename $$*))))).$$(subst .,,$$(suffix $$(basename $$*))).model
	@echo "WARNING: long build for '$@'!  Press CTRL-C to abort!"
	@sleep 5
	cat $<  |  $(word 2,$^)  $(subst _, ,$(subst .,,$(suffix $*)))  $(word 3,$^)  >  $@

.PRECIOUS: %streamed.errlog
%streamed.errlog: $$(basename $$(basename $$(basename %))).sents \
		bin/streamparser-$$(subst .,,$$(suffix $$(basename $$*))) \
		genmodel/$$(subst -,.,$$(subst .,,$$(suffix $$(basename $$(basename $$*))))).$$(subst .,,$$(suffix $$(basename $$*))).model
	make $(basename $@).output 2> $@


#### NEWSTYLE: <testset>.<trainset>.<model>.(<params>_)parsed  ---->  genmodel/<testset>.sents  bin/parser-<model>  genmodel/<trainset>.<model>.model
.PRECIOUS: %parsed.output
%parsed.output: $$(basename $$(basename $$(basename %))).$$(findstring hy,$$*)sents \
		bin/parser-$$(subst .,,$$(suffix $$(basename $$*))) \
		genmodel/$$(subst -,.,$$(subst .,,$$(suffix $$(basename $$(basename $$*))))).$$(subst .,,$$(suffix $$(basename $$*))).model
	@echo "WARNING: long build for '$@'!  Press CTRL-C to abort!"
	@sleep 5
	cat $<  |  $(word 2,$^)  $(subst _, ,$(subst .,,$(suffix $*)))  $(word 3,$^)  >  $@

.PRECIOUS: %parsed.errlog
%parsed.errlog: $$(basename $$(basename $$(basename %))).sents \
		bin/parser-$$(subst .,,$$(suffix $$(basename $$*))) \
		genmodel/$$(subst -,.,$$(subst .,,$$(suffix $$(basename $$(basename $$*))))).$$(subst .,,$$(suffix $$(basename $$*))).model
	make $(basename $@).output 2> $@

.PRECIOUS: %enju.output
%enju.output: $$(basename $$(basename %)).sents ../enju-2.4.2/enju
	@echo "WARNING: long build for '$@'!  Press CTRL-C to abort!"
	@sleep 5
	$(word 2,$^) < $<  >  $@

##### obtain cnftrees by converting output using script:
#%-cfp_parsed.cnftrees:  %-cfp_parsed.output  scripts/cfpout2cnftrees.py scripts/unkrestore.py genmodel/$$(basename $$(basename $$*)).sents
#	cat $<  |  $(PYTHON) $(word 2,$^)  |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g' | $(PYTHON) $(word 3,$^) $(word 4,$^) >  $@
#%-rte_parsed.cnftrees:  %-rte_parsed.output  scripts/rteout2cnftrees.py scripts/unkrestore.py genmodel/$$(basename $$(basename $$*)).sents
#	cat $<  |  $(PYTHON) $(word 2,$^)  |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g' | $(PYTHON) $(word 3,$^) $(word 4,$^) >  $@
#%-rtue_parsed.cnftrees:  %-rtue_parsed.output  scripts/rteout2cnftrees.py scripts/unkrestore.py genmodel/$$(basename $$(basename $$*)).sents
#	cat $<  |  $(PYTHON) $(word 2,$^)  |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g' | $(PYTHON) $(word 3,$^) $(word 4,$^) >  $@
##%-cky_parsed.cnftrees:  %-cky_parsed.output
#%-cc_parsed.linetrees:  %-cc_parsed.output
#	cat $<  |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g'  >  $@
##	cat $<  |  sed 's/\^.,.//g'  >  $@


#### NEWSTYLE
#### obtain cnftrees by converting output using script:
%parsed.cnftrees: %parsed.output \
		  scripts/$$(lastword $$(subst -, ,$$(basename $$*)))out2cnftrees.py \
		  scripts/unkrestore.py \
		  genmodel/$$(basename $$(basename $$(basename $$*))).sents
	cat $<  |  python3 $(word 2,$^)  |  python3 $(word 3,$^) $(word 4,$^) |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g'  >  $@
#^ rteout2cnftrees.py | unkrestore.py sents | sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g'
# Consolidation results in moving shared berk/fawp preprocessing to nosm.cnftrees
#    This means @ and '-' tags are still in %parsed.cnftrees

#%-cfp.parsed.cnftrees:  %-cfp.parsed.output  scripts/cfpout2cnftrees.py scripts/unkrestore.py genmodel/$$(basename $$(basename $$*)).sents
#	cat $<  |  $(PYTHON) $(word 2,$^)  |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g' | $(PYTHON) $(word 3,$^) $(word 4,$^) >  $@
#%-rte.parsed.cnftrees:  %-rte.parsed.output  scripts/rteout2cnftrees.py scripts/unkrestore.py genmodel/$$(basename $$(basename $$*)).sents
#	cat $<  |  $(PYTHON) $(word 2,$^)  |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g' | $(PYTHON) $(word 3,$^) $(word 4,$^) >  $@
#%-rtue.parsed.cnftrees:  %-rtue.parsed.output  scripts/rteout2cnftrees.py scripts/unkrestore.py genmodel/$$(basename $$(basename $$*)).sents
#	cat $<  |  $(PYTHON) $(word 2,$^)  |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g' | $(PYTHON) $(word 3,$^) $(word 4,$^) >  $@
#%-fawp.parsed.cnftrees:  %-fawp.parsed.output  scripts/rteout2cnftrees.py scripts/unkrestore.py genmodel/$$(basename $$(basename $$*)).sents
#	cat $<  |  $(PYTHON) $(word 2,$^)  |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g' | $(PYTHON) $(word 3,$^) $(word 4,$^) >  $@
#%-cky.parsed.cnftrees:  %-cky.parsed.output

%-cc.parsed.linetrees:  %-cc.parsed.output
	cat $<  |  sed 's/\^.,.//g;s/\^g//g;s/\_[0-9]*//g;s/@//g'  >  $@
#	cat $<  |  sed 's/\^.,.//g'  >  $@

## sed magic fixes numbers... (CD 20 million) converted to (CD 20) (CD million)
#.PRECIOUS: %_berk_parsed.cnftrees
#%_berk_parsed.cnftrees:  %_berk_parsed.output
#	cat $<  |  perl -pe 's/\&(?=[^\)]* )/\-/g'  |  sed 's/CD\([^A-Z ]*\) \([0-9]*\) /CD\1 \2) (CD\1 /g'  |  perl -pe 's/^ *\( *//;s/ *\) *$$//;'  \
#		>  $@    ## |  sed 's/-[0-9][0-9]*//g;s/\^g//g'  >  $@    ## |  sed 's/-\([0-9][0-9]*\)/_\1/g'
## EXAMPLE: make wsj22-10first.sm2-berk_unked.sm2-berk_,_x-cc_parsed.syneval wsj22-10first.sm2-berk_berkparsed.syneval 

## NEWSTYLE
# sed magic fixes numbers... (CD 20 million) converted to (CD 20) (CD million)
# also convert things like (NP-lA-9 69 1\/4) to (NP-lA-9 (NP-lI-9 69) (NP-lA-9 1\/4))
.PRECIOUS: %.berk.parsed.cnftrees
%.berk.parsed.cnftrees:  %.berk.parsed.output scripts/killUnaries.pl
	cat $<  |  perl -pe 's/\&(?=[^\)]* )/\-/g'  |  sed 's/CD\([^A-Z ]*\) \([0-9]*\) /CD\1 \2) (CD\1 /g' |  perl -pe 's/^ *\( *//;s/ *\) *$$//;' |  perl $(word 2,$^) | perl -pe 's/\(([^ \)\(]+)(\-l[A-Z])(\-[0-9]+) ([^ \)\(]+) ([^ \)\(]+)\)/(\1\2\3 (\1-lI\3 \4) (\1-lA\3 \5))/g' >  $@
# EXAMPLE: make wsj22-10first.sm2-berk_unked.sm2-berk_,_x-cc_parsed.syneval wsj22-10first.sm2-berk_berkparsed.syneval 
# perl -pe 's/\&(?=[^\)]* )/\-/g' | sed 's/CD\([^A-Z ]*\) \([0-9]*\) /CD\1 \2) (CD\1 /g' | perl -pe 's/^ *\( *//;s/ *\) *$$//;' | killUnaries.pl

.PRECIOUS: %.nosm.cnftrees
%.nosm.cnftrees: %.cnftrees scripts/removeAt.py
#	cat $<  |  perl -pe 's/\(([A-Z]+)-[0-9a-zA-Z\-]+/\(\1/g;s/-[0-9]+//g;s/\_[0-9]+//g;s/\^g//g;s/[ ]+/ /g;s/\) \)/\)\)/g'  |  python $(word 2,$^)  >  $@
	cat $<  |  perl -pe 's/\(([^ ]+)-[0-9]+ /\(\1 /g;s/\_[0-9]+//g;s/\^g//g;s/[ ]+/ /g;s/\) \)/\)\)/g'  |  python $(word 2,$^)  >  $@
#	cat $<  |  perl -pe 's/-[0-9]+//g;s/\_[0-9]+//g;s/\^g//g'  |  python $(word 2,$^)  >  $@

# input is like: wsj23.wsj01to21-psg-nol-1671-5sm.berk.parsed.nosm.cnftrees
.PRECIOUS: %.addl.cnftrees
%.addl.cnftrees: %.cnftrees scripts/gen-l-feats.py scripts/annotateL.py 
	$(PYTHON) $(word 2,$^) -t genmodel/wsj01to21.psg.cnftrees > genmodel/wsj01to21.psg.cnftrees.lfeats
	../maxent-20061005/src/opt/maxent -v -i3000 -g100 genmodel/wsj01to21.psg.cnftrees.lfeats --model genmodel/wsj01to21.psg.cnftrees.lmodel
	$(PYTHON) $(word 3,$^) -w genmodel/wsj01to21.psg.cnftrees.lmodel -n $< > $@ 
#	$(PYTHON) $(word 2,$^) -w genmodel/wsj01to21.psg.cnftrees.lmodel -n genmodel/wsj23.psg.nol.cnftrees -g genmodel/wsj23.psg.cnftrees > genmodel/wsj23.psg.l.cnftrees

# eliminates all '-' tags (incl. nosm),cosmetic space reduction
# perl -pe 's/\(([A-Z]+)-[0-9a-zA-Z\-]+/\($1/g;s/\_[0-9]+//g;s/\^g//g;s/[ ]+/ /g;s/\) \)/\)\)/g'

#### turn cnftrees into more standard, flatter parse format
.PRECIOUS: %.evalform
%.evalform: %.cnftrees scripts/unbinarize.pl
	cat $< | sed 's/[^ \/]*\#//g' | sed 's/[^\(\) ]*://g;s/\.e[0-9]//g' | perl $(word 2,$^) | perl -p -e 's/(\([A-Z\$$\.\,\!\`\'\'']+)[-a-z\$$]+[-a-zA-Z0-9\$$]*/\1/g' > $@
#' # need this to view rest of make correctly following single-quote trickery above

#### obtain eval by running evaluator on gold and hypoth trees
#%.syneval:  user-subproject-includes.txt  bin/evalb  srcmodel/new.prm  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).evalform  %.evalform
%.syneval:  user-subproject-includes.txt  bin/evalb  srcmodel/new.prm  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).nounary.linetrees  %.cnftrees
	$(word 2,$^) -p $(word 3,$^) $(word 4,$^) $(word 5,$^) > $@

# wsj22-10first.sm2-berk_unked.sm2-berk_,_x-cc_parsed.syneval

%.failures:  $$(basename $$(basename %)).cnftrees  scripts/getfailures.py  genmodel/$$(subst .,,$$(suffix $$(basename $$*))).$$(subst .,,$$(suffix $$*)).model
	cat $<  |  $(PYTHON) $(word 2,$^) $(word 3,$^)  >  $@

#### obtain syntactic dependency eval on enju parser
%.enju.depeval:  scripts/depeval.py  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).psg.melconts  %.enju.melconts
	$(PYTHON) $< -l $(word 2,$^) $(word 3,$^)  |  grep -n ''  >  $@
#### obtain syntactic dependency eval
%.depeval:  scripts/depeval.py  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).psg.melconts  %.melconts
	$(PYTHON) $< $(word 2,$^) $(word 3,$^)  |  grep -n ''  >  $@
#### obtain syntactic dependency eval
%.hydepeval:  scripts/depeval.py  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).psg.hy.melconts  %.melconts
	$(PYTHON) $< $(word 2,$^) $(word 3,$^)  |  grep -n ''  >  $@

#### obtain long-distance dependency eval
%.gapeval:  scripts/lrdepeval.py  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).ans.tbconts  %.tbconts
	$(PYTHON) $< $(word 2,$^) $(word 3,$^)  |  grep -n ''  >  $@
%.lrview:  scripts/lrviewer.py  %.gapeval %.output %.tbconts
	$(PYTHON) $<  $(word 2,$^) $(word 3,$^) $(word 4,$^)  |  grep -n ''  >  $@


### scores
%.scores: %.syneval
	cat $< | grep -v '^2 or' | grep -v '^    ' | grep '^[ 0-9]' | perl -na -e 'if ($$F[1]<=40) {print "$$F[0] $$F[3]\n";}' > $@


################################################################################
#
#  6. Propositional content extraction (semantic role labeling) items
#
#  to construct the following file types:
#    <x>.lmodel             : a learned mapping from melconts to pbconts
#    <x>.<y>_mapped.pbconts : .pbconts file resulting from applying <y>.lmodel to <x>.melconts file
#    <x>.propeval           : evaluation report for proposition extraction
#
#  e.g.: from gold trees: make genmodel/wsj22.wsjTRAIN_mapped.propeval
#        from live parse: make wsj22-first10.wsjTRAIN_-b500_pwdt-cfp_parsed.wsjTRAIN_mapped.propeval
#
################################################################################

#### THIS IS A TOTAL HACK TO MAKE PROPEVAL RUN WITH PSG --- SHOULD BE REMOVED!!!!
%.psg.pbconts: %.pbconts
	cat $< > $@

##### obtain model of pb label given mel label, words, and cats
#.PRECIOUS: %.lmodel
#%.lmodel:  scripts/calc-l-model.py  %.melconts  %.pbconts
#	$(PYTHON) $< $(word 2,$^) $(word 3,$^)  >  $@

#.PRECIOUS: %.lmodelme
#%.lmodelme:  scripts/calc-l-model-maxent.py  %.melconts  %.pbconts
#	$(PYTHON) $< $(word 2,$^) $(word 3,$^) srcmodel/pbrolesMap >  $@

##### obtain pbconts from melconts
#.PRECIOUS: %_mapped.pbconts
#%_mapped.pbconts: $$(basename %).melconts  scripts/melconts2pbconts.py  genmodel/$$(subst .,,$$(suffix $$*)).lmodel
#	$(PYTHON) $(word 2,$^) $(word 3,$^) $< >  $@


#### obtain proposition eval
%.propeval:  scripts/propeval.py  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).pbconts  %.pbconts
	$(PYTHON) $< -h $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@
	tail -n3 $@ 
	@echo "Constituent-based evaluation: exact boundaries match"
	$(PYTHON) $< -c $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@.consti.exactmatch
	tail -n3 $@.consti.exactmatch 
	@echo "Constituent-based evaluation: hypoth nested in gold"
	$(PYTHON) $< -l $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@.consti.h.nestedin.g
	tail -n3 $@.consti.h.nestedin.g 
	@echo "Constituent-based evaluation: hypoth covered gold"
	$(PYTHON) $< -g $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@.consti.h.covered.g
	tail -n3 $@.consti.h.covered.g ; date
	@echo "Same evaluations above but consolidating adjacent propbank args"
	$(PYTHON) $< -s -h $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@.pbargs.consolidated
	tail -n3 $@.pbargs.consolidated 
	@echo "Constituent-based evaluation: exact boundaries match"
	$(PYTHON) $< -s -c $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@.consti.exactmatch.pbargs.consolidated
	tail -n3 $@.consti.exactmatch.pbargs.consolidated 
	@echo "Constituent-based evaluation: hypoth nested in gold"
	$(PYTHON) $< -s -l $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@.consti.h.nestedin.g.pbargs.consolidated
	tail -n3 $@.consti.h.nestedin.g.pbargs.consolidated 
	@echo "Constituent-based evaluation: hypoth covered gold"
	$(PYTHON) $< -s -g $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@.consti.h.covered.g.pbargs.consolidated
	tail -n3 $@.consti.h.covered.g.pbargs.consolidated ; date

%.conll: scripts/formatConll.py $$(basename $$(basename $$(basename %))).melconts genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).sents %.pbconts
	$(PYTHON) $< -m $(word 2,$^) -s $(word 3,$^) -p $(word 4,$^) > $@
%.conll: scripts/formatConll.py $$(basename $$(basename %)).cnftrees genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).sents %.pbconts
	$(PYTHON) $< -c $(word 2,$^) -s $(word 3,$^) -p $(word 4,$^) > $@
#%.conll: scripts/formatConll.py genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).sents %.pbconts
#	$(PYTHON) $< -s $(word 2,$^) -p $(word 3,$^)  > $@


### we can't do this
#genmodel/test.wsj.props: ../conll05st-release/conll05st-tests/test.wsj/props/test.wsj.props.gz
#	gunzip -c $< > $@

%.conlleval: scripts/SRL/srl-eval.pl genmodel/test.wsj.props %.conll 
	perl -Iscripts $< $(word 2,$^) $(word 3,$^) > $@


##### obtain proposition eval with params tacked on end
#%.zpropeval:  scripts/propeval.py  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).pbconts %.pbconts$(ME_PARAMS)
#	$(PYTHON) $< $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@$(ME_PARAMS)
#	tail -n3 $@$(ME_PARAMS) ; date

#%.z2spropeval:  scripts/propeval.py  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).pbconts %.pbconts$(ME_PARAMS)
#	$(PYTHON) $< $(word 2,$^) $(word 3,$^)  | grep -n ''  >  $@$(ME_PARAMS)
#	tail -n3 $@$(ME_PARAMS) ; date

#%.propevalme:  megam_0.92/megam.opt genmodel/$$(notdir $$(word 2,$$(subst ., ,$$@))).lmodelme  genmodel/$$(notdir $$(word 1,$$(subst ., ,$$@))).lmodelme
#	$< -lambda 0 -maxi 1000 multiclass $(word 2,$^) > $(word 2,$^).weight
#	$< -predict $(word 2,$^).weight multiclass $(word 3,$^) &>  $@


#### obtrain decision tree features (ordinary model format)
.PRECIOUS: %.l.cptfeats
%.l.cptfeats:  scripts/calc-l-cptfeats.py  %.melconts  %.pbconts
	$(PYTHON) $< $(word 2,$^) $(word 3,$^)  >  $@

#### obtain binary decision tree model
#### line format: <modelid> <root attrib position in condition> <root attrib 1 value> ... <leaf attrib position in condition> <leaf attrib value> : <modeled value> = <prob>
%.l.bdtmodel:  %.l.cptfeats  scripts/bdtreetrainer.py  scripts/sortbyprob.pl
	cat $<  |  $(PYTHON) $(word 2,$^)  |  perl $(word 3,$^)  >  $@

#### obtain binary-decision-tree mapped propositional content in propbank form
%_bdtmapped.pbconts:  $$(basename %).melconts  scripts/bdtreemapper.py  genmodel/$$(subst .,,$$(suffix $$*)).l.bdtmodel
	$(PYTHON) $(word 2,$^) $(word 3,$^) $<  >  $@

##### e.g. wsjTRAIN_-a3,-i0,-o0,-s0-c1.l.megfeats 
##### obtrain maxent features (include dev (wsj00) and test (wsj22) )
#.PRECIOUS: %.l.megfeats
#%.l.megfeats:  scripts/calc-feats.py  $$(word 1,$$(subst _, ,%)).melconts  $$(word 1,$$(subst _, ,%)).pbconts  srcmodel/pbrolesMap  genmodel/wsj00.melconts  genmodel/wsj00.pbconts scripts/mecommon.py
#	$(PYTHON) $< -m $(word 2,$^) -p $(word 3,$^) -r $(word 4,$^) $(subst $(comma), ,$(word 2,$(subst _, ,$(lastword $(subst ., ,$*))))) -f $*.cutoffFile >  $@
#	@echo "use wsj00 as dev set"
#	echo "DEV" >> $@  #tuning set
#	$(PYTHON) scripts/calc-feats-fordevtest.py -m $(word 5,$^) -p $(word 6,$^) -r $(word 4,$^) $(subst $(comma), ,$(word 2,$(subst _, ,$(lastword $(subst ., ,$*))))) -f $*.cutoffFile  >> $@
##	# i deleted this b/c we don't use it anymore (right?)
##	@echo "use wsj22 as test set. This looks at gold standard to measure the effectiveness of maxent learning alone"
##	echo "TEST" >> $@  #eval set
##	$(PYTHON) scripts/calc-feats-fordevtest.py -m genmodel/wsj22.melconts -p genmodel/wsj22.pbconts -r srcmodel/pbrolesMap -a3 -i0 -o0 -f $*.cutoffFile -s1 >> $@

#### e.g. wsjTRAIN_-a3,-i0,-o0,-k0-c0.l.zmefeats 
#### obtrain maxent features (include dev (wsj00) and test (wsj22) )
#.PRECIOUS: %.l.mefeats
#%.l.mefeats:  scripts/calc-feats.py  $$(word 1,$$(subst _, ,%)).melconts  $$(word 1,$$(subst -, ,$$(subst _, ,%))).pbconts  srcmodel/pbrolesMap scripts/splitTrain-Heldout.sh   scripts/mecommon.py
#	$(word 5,$^) $(word 2,$^) $(word 3,$^)
#	$(PYTHON) $< -g1 -m $(word 2,$^).train -p $(word 3,$^).train -r $(word 4,$^) $(subst $(comma), ,$(word 2,$(subst _, ,$(lastword $(subst ., ,$*)))))  >  $@
#	$(PYTHON) $< -g1 -m $(word 2,$^).heldout -p $(word 3,$^).heldout -r $(word 4,$^) $(subst $(comma), ,$(word 2,$(subst _, ,$(lastword $(subst ., ,$*)))))  > $@.heldout
##	$(PYTHON) scripts/calc-feats-fordevtest.py -m $(word 2,$^).heldout -p $(word 3,$^).heldout -r $(word 4,$^) $(subst $(comma), ,$(word 2,$(subst _, ,$(lastword $(subst ., ,$*)))))  > $@.heldout

#### NEWSTYLE
#.PRECIOUS: %l.mefeats
#%l.mefeats:	scripts/splitTrain-Heldout.sh \
#		$$(basename %).melconts \
#		$$(basename %).pbconts \
#		scripts/calc-feats.py \
#		srcmodel/pbrolesMap \
#		scripts/mecommon.py
#	$(word 1,$^)  $(word 2,$^)  $(word 3,$^)
#	python3  $(word 4,$^)  -g1  -m $(word 2,$^).train    -p $(word 3,$^).train    -r $(word 5,$^)  -a3 -i0 -o0 -k0 $(subst _, ,$(subst .,,$(suffix $*)))  >  $@.train
#	python3  $(word 4,$^)  -g1  -m $(word 2,$^).heldout  -p $(word 3,$^).heldout  -r $(word 5,$^)  -a3 -i0 -o0 -k0 $(subst _, ,$(subst .,,$(suffix $*)))  >  $@.heldout

%.train.melconts %.train.pbconts %.heldout.melconts %.heldout.pbconts:  scripts/splitTrain-Heldout.sh  %.melconts  %.pbconts
	$(word 1,$^)  $(basename $(word 2,$^))  $(basename $(word 3,$^))

.PRECIOUS: %l.mefeats
%l.mefeats:	scripts/calc-feats.py \
		$$(basename %).melconts \
		$$(basename %).pbconts \
		srcmodel/pbrolesMap \
		scripts/mecommon.py
	python3  $(word 1,$^)  -g1  -m $(word 2,$^)  -p $(word 3,$^)  -r $(word 4,$^)  -a3 -i0 -o0 -k0 $(subst _, ,$(subst .,,$(suffix $*)))  >  $@


##### e.g. wsjTRAIN_-a3,-i0,-o0,-k0-c0.l.z2smefeats wsjTRAIN_-a3,-i0,-o0,-k0-c0.l.z2smefeats.heldout wsjTRAIN_-a3,-i0,-o0,-k0-c0.l.z2smefeats.binary wsjTRAIN_-a3,-i0,-o0,-k0-c0.l.z2smefeats.binary.heldout 
##### obtrain maxent features (include dev (wsj00) and test (wsj22) )
#.PRECIOUS: %.l.z2smefeats
#%.l.z2smefeats:  scripts/calc-feats.py  $$(word 1,$$(subst _, ,%)).melconts  $$(word 1,$$(subst _, ,%)).pbconts  srcmodel/pbrolesMap scripts/splitTrain-Heldout.sh
#	$(word 5,$^) $(word 2,$^) $(word 3,$^)
#	$(PYTHON) $< -m $(word 2,$^).train -p $(word 3,$^).train -r $(word 4,$^) $(subst $(comma), ,$(word 2,$(subst _, ,$(lastword $(subst ., ,$*))))) >  $@.z2s
#	$(PYTHON) scripts/calc-feats-fordevtest.py -m $(word 2,$^).heldout -p $(word 3,$^).heldout -r $(word 4,$^) $(subst $(comma), ,$(word 2,$(subst _, ,$(lastword $(subst ., ,$*)))))  > $@.z2s.heldout
#	@echo "generate binary feats"
#	cat $@.z2s | grep "^20 " | sed 's/:[0-9\.]* /:1 /g' > $@.binary
#	cat $@.z2s | grep -v "^20 " | sed 's/^[0-9]* /200 /g' | sed 's/:[0-9\.]* /:2 /g' >> $@.binary
#	@echo "generate binary feats heldout"
#	cat $@.z2s.heldout | grep "^20 " | sed 's/:[0-9\.]* / /g' > $@.binary.heldout
#	cat $@.z2s.heldout | grep -v "^20 " | sed 's/^[0-9]* /200 /g;s/:[0-9\.]* / /g' >> $@.binary.heldout
#	@echo "generate non-NIL only feats"
#	cat $@.z2s | grep -v "^20 " > $@
#	@echo "generate non-NIL only feats heldout"
#	cat $@.z2s.heldout | grep -v "^20 " > $@.heldout

##### obtain maxent model using Hal Daume's megam
##### line format: <modelid> <root attrib position in condition> <root attrib 1 value> ... <leaf attrib position in condition> <leaf attrib value> : <modeled value> = <prob>
#.PRECIOUS: %.l.megmodel
#%.l.megmodel:  %.l.megfeats ./megam_0.92/megam.opt
#	echo "Traing with bias=$(findstring -nobias,$<)"
##	$(word 2,$^) $(findstring -nobias,$<)  -lambda 0 -maxi 10000 -tune -dpp 0.00000000001 multiclass $< > $@ 
#	$(word 2,$^) $(findstring -nobias,$<) -lambda 0.0000001 -maxi 10000 -tune -dpp 0.00000000001 multiclass $< > $@ 
##	$(word 2,$^) -nobias -lambda 0.0000001 -maxi 10000 -tune -dpp 0.00000000001 multiclass $< > $@ 


#### obtain maxent model using Zhang's maxent
#### line format: <modelid> <root attrib position in condition> <root attrib 1 value> ... <leaf attrib position in condition> <leaf attrib value> : <modeled value> = <prob>
.PRECIOUS: %l.memodel
%l.memodel:  ../maxent-20061005/src/opt/maxent  $$(basename %).train$$(suffix $$*)l.mefeats  $$(basename %).heldout$$(suffix $$*)l.mefeats
	$(word 1,$^)  -v -i1000 -g0.5  $(word 2,$^)  --heldout $(word 3,$^)  --model $@ 


#.PRECIOUS: %.l.z2smemodel$(ME_PARAMS)
#%.l.z2smemodel$(ME_PARAMS):  %.l.z2smefeats ../maxent-20061005/src/opt/maxent 
#	echo "Training the binary feats (NIL or non-NIL) for arg identification"
#	$(word 2,$^) -v $(subst $(comma), ,$(ME_PARAMS)) $<.binary --heldout $<.binary.heldout --model $@.binary 
#	echo "Training the non-NIL feats for arg classification"
#	$(word 2,$^) -v $(subst $(comma), ,$(ME_PARAMS)) $< --heldout $<.heldout --model $@ 

##### obtain maxent mapped propositional content in propbank form using Hal Daume's megam
#.PRECIOUS: %_megmapped.pbconts
#%_megmapped.pbconts:  $$(basename %).melconts  scripts/mel2pb.py  genmodel/$$(subst .,,$$(suffix $$*)).l.megmodel scripts/mecommon.py
#	$(PYTHON) $(word 2,$^) -w $(word 3,$^) -r srcmodel/pbrolesMap $(subst $(comma), ,$(word 2,$(subst _, ,$(lastword $(subst ., ,$*))))) -m $< -f genmodel/$(subst .,,$(suffix $*)).cutoffFile >  $@

#### obtain maxent mapped propositional content in propbank form using Zhang's maxent
.PRECIOUS: %mapped.pbconts
%mapped.pbconts: scripts/mel2pb-zhang.py \
		 $$(basename $$(basename %)).melconts \
		 genmodel/$$(subst -,.,$$(subst .,,$$(suffix $$(basename $$*)))).$$(subst .,,$$(suffix $$*))l.memodel \
		 srcmodel/pbrolesMap \
		 $$(basename $$(basename %)).cnftrees \
		 scripts/mecommon.py
	python3  $<  -m $(word 2,$^)  -g1 -w  $(word 3,$^)  -r $(word 4,$^) -c $(word 5,$^)  -a3 -i0 -o0 -k0 $(subst _, ,$(subst .,,$(suffix $*)))  >  $@

.PRECIOUS: %mapped.i.pbconts
%mapped.i.pbconts: scripts/mel2pb-zhang.py \
		 $$(basename $$(basename %)).melconts \
		 genmodel/$$(subst -,.,$$(subst .,,$$(suffix $$(basename $$*)))).$$(subst .,,$$(suffix $$*))l.memodel \
		 srcmodel/pbrolesMap \
		 scripts/mecommon.py
	python3  $<  -m $(word 2,$^)  -g1 -w  $(word 3,$^)  -r $(word 4,$^) -a3 -i0 -o0 -k0 $(subst _, ,$(subst .,,$(suffix $*)))  >  $@

#.PRECIOUS: %_z2smemapped.pbconts$(ME_PARAMS)
#%_z2smemapped.pbconts$(ME_PARAMS):  $$(basename %).melconts  scripts/mel2pb-zhang.py  genmodel/$$(subst .,,$$(suffix $$*)).l.z2smemodel$(ME_PARAMS) scripts/mecommon.py
#	$(PYTHON) $(word 2,$^) -w $(word 3,$^) -r srcmodel/pbrolesMap $(subst $(comma), ,$(word 2,$(subst _, ,$(lastword $(subst ., ,$*))))) -m $< >  $@

################################################################################
#
#  7. Eyetracking
#
#  to construct the following file types:
#    <x>.eyemodel           : a model of eyetracking behavior
#    <x>.eyemodels          : a model of eyetracking behavior from a variety of subjects
#    <x>.ngrams             : unigram and bigram models
#    <x>.srilmngrams        : unigram and forward and backward bigram models calculated using SRILM, smoothed with Kneser-Ney
#    <x>.nooutliers.<y>     : <x>.<y> with all datapoints deviating by more than 2 std deviations from the mean removed
#    <x>.dundeeeval         : A linear mixed effects model fitting the datapoints of <x>.eyemodels (typically from the Dundee Corpus)
#
################################################################################

.PRECIOUS: %.complex
%.complex: %.errlog
	cp $< $@

.PRECIOUS: %.unfiltered.ccomplex
%.unfiltered.ccomplex: scripts/compileComplexity.py $$(basename %).complex \
	$$(basename $$(basename $$(basename $$(basename %)))).sents
	$(PYTHON) $< $(basename $(subst .,,$(suffix $*))) $(word 2,$^) $(word 3,$^) > $@
%.unfiltered.ccomplex: scripts/compileComplexity.py %.complex \
	$$(basename $$(basename $$(basename $$(basename %)))).sents
	$(PYTHON) $< $(word 2,$^) $(word 3,$^) > $@

.PRECIOUS: %.ccomplex
%.ccomplex: scripts/filterComplex.py %.unfiltered.ccomplex
	$(PYTHON) $< $(word 2,$^) > $@

genmodel/broadcoveragetraining.sents: genmodel/brownTRAIN.sents genmodel/wsj02to21.sents genmodel/bncTRAIN.sents genmodel/dundee.sents
	cat $^ | grep -v '\*x\*' > $@

genmodel/broadcoveragetraining.revsents: genmodel/broadcoveragetraining.sents
	cat $^ | sed 's/\n/ <LINEBREAK> /g;' | sed 's/ /\n/g;' > $@.tmp
	tac $@.tmp | sed 's/\n/ /g;' | sed 's/ <LINEBREAK> /\n/g;' > $@
	rm -f $@.tmp

.PRECIOUS: %.ngrams
%.ngrams: %.sents scripts/calc-unigrams.py scripts/calc-bigrams.py
	cat $< | sed 's/\([^A-Za-z0-9]\)/ \1 /g;s/  */ /g;' > $@.tmp 
	$(PYTHON) $(word 2,$^) -kn $@.tmp > $@.uni
	$(PYTHON) $(word 3,$^) -kn $@.tmp $@.uni > $@.bi
	cat $@.uni $@.bi > $@
	rm -f $@.tmp $@.uni $@.bi

.PRECIOUS: %.srilmngrams
%.srilmngrams: %.sents %.revsents scripts/convert_srilm.py user-srilm-location.txt
	cat $< | sed 's/\([^A-Za-z0-9]\)/ \1 /g;s/  */ /g;' > $@.fwtmp
	cat $(word 2, $^) | sed 's/\([^A-Za-z0-9]\)/ \1 /g;s/  */ /g;' > $@.bwtmp
	$(SRILM)/$(SRILMSUB)/ngram-count -order 1 -kndiscount -text $@.fwtmp -lm $@.uprobs
	$(SRILM)/$(SRILMSUB)/ngram-count -order 2 -kndiscount -interpolate -text $@.fwtmp -lm $@.fwprobs
	$(SRILM)/$(SRILMSUB)/ngram-count -order 2 -kndiscount -interpolate -text $@.bwtmp -lm $@.bwprobs
	$(PYTHON) $(word 3,$^) $@.uprobs -U > $@
	$(PYTHON) $(word 3,$^) $@.fwprobs -BF >> $@
	$(PYTHON) $(word 3,$^) $@.bwprobs -BB >> $@
	rm -f $@.{uprobs,fwtmp,fwprobs,bwtmp,bwprobs}

.PRECIOUS: %.eyemodel
%.eyemodel: scripts/analyzeComplexity.py $$(basename %).complex \
	genmodel/dundee.$$(subst .,,$$(suffix $$(subst _,.,$$*))).textdata \
	genmodel/dundee.$$(subst .,,$$(suffix $$(subst _,.,$$*))).eyedata \
	genmodel/dundee.$$(subst .,,$$(suffix $$(subst _,.,$$*))).eventdata \
	genmodel/broadcoveragetraining.srilmngrams genmodel/wsj02to21.lexicon
	$(PYTHON) $<  $(basename $(subst _,.,$(subst .,,$(suffix $*)))) $(word 2,$^) $(word 3,$^) $(word 4,$^) $(word 5,$^) $(word 6,$^) $(word 7,$^) > $@

.PRECIOUS: %.unfiltered.eyemodels
%.unfiltered.eyemodels: $(foreach subj,$(DUNDEESUBJS),%_$(subj).eyemodel)
	head -1 $< > $@
	cat $^ | grep -v '^subject word' >> $@

.PRECIOUS: %.eyemodels
%.eyemodels: scripts/filterComplex.py %.unfiltered.eyemodels
	$(PYTHON) $< $(word 2,$^) > $@

.PRECIOUS: %.nooutliers.unfiltered.eyemodels
%.nooutliers.unfiltered.eyemodels: %.unfiltered.eyemodels scripts/rmOutliers.py
	$(PYTHON) $(word 2,$^) $< > $@

.PRECIOUS: %.dundeeeval
%.dundeeeval: %.eyemodels scripts/dundeeLME.r
	$(word 2,$^) $< > $@

define SRIEYEMODEL
.PRECIOUS: %.$(1).srieyemodel
%.$(1).srieyemodel: scripts/analyzeComplexity.py %.complex genmodel/dundee.$(1).textdata genmodel/dundee.$(1).eyedata genmodel/dundee.$(1).eventdata genmodel/broadcoveragetraining.srilmngrams genmodel/broadcoveragetraining.srilmngrams genmodel/wsj02to21.lexicon
	$$(PYTHON) $$< -nl $$(word 2,$$^) $$(word 3,$$^) $$(word 4,$$^) $$(word 5,$$^) $$(word 6,$$^) $$(word 7,$$^) $$(word 8,$$^) > $$@
endef

$(foreach subj,$(DUNDEESUBJS),$(eval $(call SRIEYEMODEL,$(subj))))

.PRECIOUS: %.srieyemodels
%.srieyemodels: $(foreach subj,$(DUNDEESUBJS),%.$(subj).srieyemodel)
	head -1 $< > $@
	cat $^ | grep -v '^subject word' >> $@

.PRECIOUS: %.nooutliers.srieyemodels
%.nooutliers.srieyemodels: %.srieyemodels scripts/rmOutliers.py
	$(PYTHON) $(word 2,$^) $< > $@

.PRECIOUS: %.sridundeeeval
%.sridundeeeval: %.srieyemodels scripts/dundeeLME.r
	$(word 2,$^) $< > $@


################################################################################
#
#  8. Language Acquistion
#
################################################################################

srlsents: genmodel/eve.sents genmodel/eve.eval.sents genmodel/eve.fullfg.eval.sents genmodel/adam.sents genmodel/adam.eval.sents genmodel/adam.fullfg.eval.sents

%/srltests: %/eve.evalled %/eve.fullfg.eval.evalled %/adam.evalled %/adam.fullfg.eval.evalled
	cat $^ > $@
	rm $@

.PRECIOUS: %.sents
%.sents: %.srl.cha scripts/getSents.py
	python $(word 2,$^) $< | perl -pe "s/[\(\)\/]//g;s/\[\?\]//g;s/[<>\[\]]//g;s/[\"\#\+_]/ /g;s/@[coltb]//g;s/@wp//g;s/ [ ]*/ /g;" > $@

.PRECIOUS: %.eval.sents
%.eval.sents: %.srl.cha scripts/buildSRLEval.py
	python $(word 2,$^) $< | perl -pe "s/m :/m/g;s/o : h/oh/g;" > $@

.PRECIOUS: %.fullfg.eval.sents
%.fullfg.eval.sents: %.eval.sents
	#egrep "(1'\) [a-zA-Z\(][^V]*V)|(0'\) [a-zA-Z])" $< > $@
	egrep "(1'\) [^V]*V)|(0'\) [a-zA-Z])" $< > $@

.PRECIOUS: %.chunked
%.chunked: %.sents scripts/chunkCHILDES.py genmodel/chunker
	python $(word 2,$^) $< $(word 3,$^) | tail -n +2 | perl -pe "s/\(NP yes\/NNS\)/yes\/OH/g;" > $@

.PRECIOUS: %.oracle.eval.chunked
%.oracle.eval.chunked: %.eval.sents scripts/oracleChunkCHILDES.py
	python $(word 2,$^) $< > $@

.PRECIOUS: genmodel/chunker
genmodel/chunker: scripts/buildChunker.py
	python $< $@

.PRECIOUS: %.munged
%.munged: %.chunked scripts/mungeChunkedCHILDES.py
	python $(word 2,$^) $< > $@

.PRECIOUS: %.thatmunged
%.thatmunged: scripts/reinsertThat.py %.munged %.sents
	python $< $(word 2,$^) $(word 3,$^) | sed '/^$$/d;' | sed 's/[^X];thet/X;thet/g;' > $@

.PRECIOUS: %.thatnoimpmunged #all imperatives removed and functional 'that' changed to 'thet'
%.thatnoimpmunged: scripts/reinsertThat.py %.munged %.sents
	python $< $(word 2,$^) $(word 3,$^) | sed '/^$$/d;' | sed 's/[^X];thet/X;thet/g;' | grep -v '^(\([^N][^\)]*\))*(\(V[^\)]*\))(\([^V][^\)]*\))*$$' > $@

.PRECIOUS: %.model
.PRECIOUS: %.output
%.output %.model: %.munged scripts/acquireFG.py
	python $(word 2,$^) $< $*.model > $*.output

.PRECIOUS: %.tested
%.tested: scripts/testFG.py %.model %.eval.munged
	python $< $(word 2,$^) $(word 3,$^) > $@

.PRECIOUS: %.eval.tested
%.eval.tested: scripts/testFG.py  $$(basename %).model %.eval.munged
	python $< $(word 2,$^) $(word 3,$^) > $@

.PRECIOUS: %.eval.tested
%.eval.tested: scripts/testFG.py  $$(basename $$(basename %)).model %.eval.munged
	python $< $(word 2,$^) $(word 3,$^) > $@

.PRECIOUS: %.evalled
# %.sents must be the gold annotated sents 
%.evalled: scripts/evalFG.py %.tested %.eval.sents
	python $< $(word 2,$^) $(word 3,$^) > $@

.PRECIOUS: %.evalled
# %.sents must be the gold annotated sents 
%.evalled: scripts/evalFG.py %.eval.tested %.eval.sents
	python $< $(word 2,$^) $(word 3,$^) > $@

.PRECIOUS: %.evalled
# %.sents must be the gold annotated sents 
%.evalled: scripts/evalFG.py %.eval.tested $$(basename %).eval.sents
	python $< $(word 2,$^) $(word 3,$^) > $@


################################################################################
#
#  Misc utilities
#
################################################################################

grep.%:
	grep $(subst '.',' ',$*) src/*.cpp include/*.h ../rvtl/include/*.h -n

%.memprof: run-%
	valgrind --tool=massif --time-unit=i --max-snapshots=500 --massif-out-file=$@ -v $<
#	ms_print $@ | less

%.procprof: 
	cat user-cflags.txt > user-cflags.tmp.txt
	echo '-DNDEBUG -O3 -pg' > user-cflags.txt
	make $* -B
	gprof $* > $@
	cat user-cflags.tmp.txt > user-cflags.txt

dist-clean:
	@echo 'Do you really want to destroy all models in genmodel?  If not, CTRL-C and copy it from somewhere!'
	@sleep 5
	-rm bin/* genmodel/* */*.o ./*~ ./*~ */*.a */*.cmx */*.d ./semantic.cache pkgmodel/*
clean:
	@echo 'Do you really want to destroy all models in genmodel?  If not, CTRL-C and copy it from somewhere!'
	@sleep 5
	-rm bin/* genmodel/* */*.o ./*~ ./*~ */*.a */*.cmx */*.d ./semantic.cache
tidy:
	-rm bin/*            */*.o ./*~ ./*~ */*.a */*.cmx */*.d ./semantic.cache

#depend:
#	makedepend -Iinclude -I../rvtl/include -I../slush/include src/*.cpp -Y
# #	g++ -MM -Iinclude -I../rvtl/include -I../slush/include src/*.cpp ### but then do what with this?

