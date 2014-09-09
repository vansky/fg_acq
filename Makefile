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

acl2014: #Replicates van Schijndel and Elsner (2014)
	mkdir acl_eval0_soinit
	make acl_eval0_soinit/eve.--extract-subject_--extract-object_--iters_0.--uncollapsed.evalled
	make acl_eval0_soinit/eve.--extract-subject_--extract-object_--iters_0.--collapsed.evalled
	make acl_eval0_soinit/adam.--extract-subject_--extract-object_--iters_0.--uncollapsed.evalled
	make acl_eval0_soinit/adam.--extract-subject_--extract-object_--iters_0.--collapsed.evalled
	make acl_eval0_soinit/eve.--extract-subject_--extract-object_--iters_0.fullfg.--uncollapsed.evalled
	make acl_eval0_soinit/eve.--extract-subject_--extract-object_--iters_0.fullfg.--collapsed.evalled
	make acl_eval0_soinit/adam.--extract-subject_--extract-object_--iters_0.fullfg.--uncollapsed.evalled
	make acl_eval0_soinit/adam.--extract-subject_--extract-object_--iters_0.fullfg.--collapsed.evalled
	mkdir acl_eval1_so
	make acl_eval1_so/eve.--extract-subject_--extract-object.--uncollapsed.evalled
	make acl_eval1_so/eve.--extract-subject_--extract-object.--collapsed.evalled
	make acl_eval1_so/adam.--extract-subject_--extract-object.--uncollapsed.evalled
	make acl_eval1_so/adam.--extract-subject_--extract-object.--collapsed.evalled
	make acl_eval1_so/eve.--extract-subject_--extract-object.fullfg.--uncollapsed.evalled
	make acl_eval1_so/eve.--extract-subject_--extract-object.fullfg.--collapsed.evalled
	make acl_eval1_so/adam.--extract-subject_--extract-object.fullfg.--uncollapsed.evalled
	make acl_eval1_so/adam.--extract-subject_--extract-object.fullfg.--collapsed.evalled
	cp -r acl_eval1_so acl_eval1_so_noimp
	make acl_eval1_so_noimp/eve.eval.noimpmunged
	make acl_eval1_so_noimp/adam.eval.noimpmunged
	make acl_eval1_so_noimp/eve.fullfg.eval.noimpmunged
	make acl_eval1_so_noimp/adam.fullfg.eval.noimpmunged
	mv acl_eval1_so_noimp/eve.eval.noimpmunged acl_eval1_so_noimp/eve.eval.munged
	mv acl_eval1_so_noimp/adam.eval.noimpmunged acl_eval1_so_noimp/adam.eval.munged
	mv acl_eval1_so_noimp/eve.fullfg.eval.noimpmunged acl_eval1_so_noimp/eve.fullfg.eval.munged
	mv acl_eval1_so_noimp/adam.fullfg.eval.noimpmunged acl_eval1_so_noimp/adam.fullfg.eval.munged
	make acl_eval1_so/eve.--extract-subject_--extract-object.--uncollapsed.evalled
	make acl_eval1_so/eve.--extract-subject_--extract-object.--collapsed.evalled
	make acl_eval1_so/adam.--extract-subject_--extract-object.--uncollapsed.evalled
	make acl_eval1_so/adam.--extract-subject_--extract-object.--collapsed.evalled
	make acl_eval1_so/eve.--extract-subject_--extract-object.fullfg.--uncollapsed.evalled
	make acl_eval1_so/eve.--extract-subject_--extract-object.fullfg.--collapsed.evalled
	make acl_eval1_so/adam.--extract-subject_--extract-object.fullfg.--uncollapsed.evalled
	make acl_eval1_so/adam.--extract-subject_--extract-object.fullfg.--collapsed.evalled


dir_guard=@mkdir -p $(@D)

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
.PRECIOUS: genmodel
genmodel:
	mkdir genmodel

.PRECIOUS: genmodel/adam.srl.cha | genmodel
genmodel/adam.srl.cha: user-babysrl-location.txt $(shell cat user-babysrl-location.txt)/adam01-23
	$(dir_guard)
	cat $(word 2,$^)/* > $@

.PRECIOUS: genmodel/eve.srl.cha | genmodel
genmodel/eve.srl.cha: user-babysrl-location.txt $(shell cat user-babysrl-location.txt)/eve01-20
	$(dir_guard)
	cat $(word 2,$^)/* > $@

.PRECIOUS: genmodel/sarah.srl.cha | genmodel
genmodel/sarah.srl.cha: user-babysrl-location.txt $(shell cat user-babysrl-location.txt)/sarah001-090
	$(dir_guard)
	cat $(word 2,$^)/* > $@

.PRECIOUS: %.sents
#eve.sents
%.sents: %.srl.cha scripts/getSents.py
	python $(word 2,$^) $< | perl -pe "s/[\(\)\/]//g;s/\[\?\]//g;s/[<>\[\]]//g;s/[\"\#\+_]/ /g;s/@[coltb]//g;s/@wp//g;s/ [ ]*/ /g;" > $@

.PRECIOUS: %.eval.sents
#eve.eval.sents
%.eval.sents: %.srl.cha scripts/buildSRLEval.py
	python $(word 2,$^) $< | perl -pe "s/m :/m/g;s/o : h/oh/g;" > $@

.PRECIOUS: %.fullfg.eval.sents
#eve.fullfg.eval.sents
%.fullfg.eval.sents: %.eval.sents
	#egrep "(1'\) [a-zA-Z\(][^V]*V)|(0'\) [a-zA-Z])" $< > $@
	egrep "(1'\) [^V]*V)|(0'\) [a-zA-Z])" $< > $@

.PRECIOUS: genmodel/chunker
genmodel/chunker: scripts/buildChunker.py
	python $< $@

.PRECIOUS: %.chunked
#eve.chunked
#eve.fullfg.eval.chunked
%.chunked: %.sents scripts/chunkCHILDES.py genmodel/chunker
	python $(word 2,$^) $< $(word 3,$^) | tail -n +2 | perl -pe "s/\(NP yes\/NNS\)/yes\/OH/g;" > $@

#.PRECIOUS: %.oracle.eval.chunked
#%.oracle.eval.chunked: %.eval.sents scripts/oracleChunkCHILDES.py
#	python $(word 2,$^) $< > $@

.PRECIOUS: %.munged
#eve.munged
#eve.fullfg.eval.munged
%.munged: %.chunked scripts/mungeChunkedCHILDES.py
	python $(word 2,$^) $< > $@

#.PRECIOUS: %.thatmunged
#%.thatmunged: scripts/reinsertThat.py %.munged %.sents
#	python $< $(word 2,$^) $(word 3,$^) | sed '/^$$/d;' | sed 's/[^X];thet/X;thet/g;' > $@

#.PRECIOUS: %.thatnoimpmunged #all imperatives removed and functional 'that' changed to 'thet'
#%.thatnoimpmunged: scripts/reinsertThat.py %.munged %.sents
#	python $< $(word 2,$^) $(word 3,$^) | sed '/^$$/d;' | sed 's/[^X];thet/X;thet/g;' | grep -v '^(\([^N][^\)]*\))*(\(V[^\)]*\))(\([^V][^\)]*\))*$$' > $@

.PRECIOUS: %.noimpmunged #all imperatives removed
%.noimpmunged: %.munged
	cat $< | sed '/^$$/d;' | grep -v '^(\([^N][^\)]*\))*(\(V[^\)]*\))(\([^V][^\)]*\))*$$' > $@

.PRECIOUS: %.model
#eve.--extract-subject_--extract-object.model
.PRECIOUS: %.output
%.output %.model: $$(basename %).munged scripts/acquireFG.py
	python $(word 2,$^) $(subst _, ,$(subst .,,$(suffix $*))) --input $< --model $*.model > $*.output

.PRECIOUS: %.tested
#eve.--extract-subject_--extract-object.tested
%.tested: scripts/testFG.py %.model $$(basename %).eval.munged
	python $< $(word 2,$^) $(word 3,$^) | sed 's/can not/cannot/g' > $@

#eve.--extract-subject_--extract-object.fullfg.tested
%.tested: scripts/testFG.py  $$(basename %).model $$(basename $$(basename %))$$(suffix $$*).eval.munged
	python $< $(word 2,$^) $(word 3,$^) | sed 's/can not/cannot/g' > $@

.PRECIOUS: %.evalled
# %.sents must be the gold annotated sents
#eve.--extract-subject_--extract-object.fullfg.--collapsed.evalled
%.evalled: scripts/evalFG.py $$(basename %).tested $$(basename $$(basename $$(basename %)))$$(suffix $$(basename $$*)).eval.sents
	python $< $(subst .,,$(suffix $*)) --test $(word 2,$^) --gold $(word 3,$^) > $@

#eve.--extract-subject_--extract-object.--collapsed.evalled
%.evalled: scripts/evalFG.py $$(basename %).tested $$(basename $$(basename %)).eval.sents
	python $< $(subst .,,$(suffix $*)) --test $(word 2,$^) --gold $(word 3,$^) > $@