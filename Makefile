MC = .mc
BASE_BIN = .mc/bin
PHYLOSIFT = .mc/envs/phylosift
export PHYLOSIFT_PATH := $(abspath ${PHYLOSIFT})
export BIN_PATH := $(abspath ${BASE_BIN})
export PATH := ${BIN_PATH}:${PATH}

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	CCFLAGS += -D LINUX
	MC_LINK := https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
endif
ifeq ($(UNAME_S),Darwin)
	CCFLAGS += -D OSX
	MC_LINK := https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
endif
UNAME_P := $(shell uname -p)
ifeq ($(UNAME_P),x86_64)
	CCFLAGS += -D AMD64
endif
ifneq ($(filter %86,$(UNAME_P)),)
	CCFLAGS += -D IA32
endif
ifneq ($(filter arm%,$(UNAME_P)),)
	CCFLAGS += -D ARM
endif

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))


all: ${BASE_BIN}/python ${MC}/share/PhyloSift-1.0.0_01/bin/phylosift

clean: 
	rm -rf ${MC} mc.sh raw_data analysis_results logs .temp

.PHONY: all clean
.SECONDARY:

${BASE_BIN}/python:
	wget -O - ${MC_LINK} > mc.sh
	bash mc.sh -bf -p ${MC}
	.mc/bin/conda config --system --add channels r --add channels bioconda --add channels conda-forge
	.mc/bin/conda config --system --set always_yes True
	.mc/bin/conda install -y fasttree trimal biopython
	mkdir -p raw_data analysis_results logs
	chmod 755 scripts/* run_phylosift-hpc build_tree-hpc download_genomes
	rm -fr mc.sh


${MC}/opt/phylosift_20141126/bin/phylosift: ${BASE_BIN}/python
	mkdir -p ${MC}/opt
	mv phylosift_20141126.tar.bz2 ${MC}/opt && cd ${MC}/opt && tar xjf phylosift_20141126.tar.bz2 && rm phylosift_20141126.tar.bz2



