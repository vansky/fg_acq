################################################################################
##                                                                            ##
##  This file is part of FG_Acq Copyright 2014, FG_Acq developers.            ##
##                                                                            ##
##  FG_Acq is free software: you can redistribute it and/or modify            ##
##  it under the terms of the GNU General Public License as published by      ##
##  the Free Software Foundation, either version 3 of the License, or         ##
##  (at your option) any later version.                                       ##
##                                                                            ##
##  FG_Acq is distributed in the hope that it will be useful,                 ##
##  but WITHOUT ANY WARRANTY; without even the implied warranty of            ##
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             ##
##  GNU General Public License for more details.                              ##
##                                                                            ##
##  You should have received a copy of the GNU General Public License         ##
##  along with FG_Acq.  If not, see <http://www.gnu.org/licenses/>.           ##
##                                                                            ##
################################################################################

################################################################################
#
#  i. Macros & variables
#
################################################################################

.SECONDARY:
.SUFFIXES:
.SECONDEXPANSION:


################################################################################
#
#  1. User-location files
#
################################################################################

#### location of babysrl
#### location of babysrl
user-babysrl-location.txt:
	echo '/home/corpora/original/english/babysrl' > $@
	@echo ''
	@echo 'ATTENTION: I had to create "$@" for you, which may be wrong'
	@echo 'edit it to point at your babysrl repository, and re-run make to continue!'
	@echo ''

.PRECIOUS: %.sents
%.sents: genmodel/$$*.sents
	cp $< $@

################################################################################
#
#  2. Language Acquistion
#
################################################################################

.PRECIOUS: genmodel/adam.srl.cha
genmodel/adam.srl.cha: user-babysrl-location.txt $(shell cat user-babysrl-location.txt)/adam01-23
	cat $(word 2,$^)/* > $@

.PRECIOUS: genmodel/eve.srl.cha
genmodel/eve.srl.cha: user-babysrl-location.txt $(shell cat user-babysrl-location.txt)/eve01-20
	cat $(word 2,$^)/* > $@

.PRECIOUS: genmodel/sarah.srl.cha
genmodel/sarah.srl.cha: user-babysrl-location.txt $(shell cat user-babysrl-location.txt)/sarah001-090
	cat $(word 2,$^)/* > $@

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

srlsents: genmodel/eve.sents genmodel/eve.eval.sents genmodel/eve.fullfg.eval.sents genmodel/adam.sents genmodel/adam.eval.sents genmodel/adam.fullfg.eval.sents

%/srltests: %/eve.evalled %/eve.fullfg.eval.evalled %/adam.evalled %/adam.fullfg.eval.evalled

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