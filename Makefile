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


all: ${BASE_BIN}/python ${PHYLOSIFT}/bin/python ${PHYLOSIFT}/share/phylosift_20141126/bin/phylosift

clean: 
	rm -rf ${MC} mc.sh

.PHONY: all clean
.SECONDARY:

${BASE_BIN}/python:
	wget -O - ${MC_LINK} > mc.sh
	bash mc.sh -bf -p ${MC}
	.mc/bin/conda config --system --add channels r --add channels bioconda --add channels conda-forge
	.mc/bin/conda config --system --set always_yes True
	rm -fr mc.sh


${PHYLOSIFT}/share/phylosift_20141126/bin/phylosift: ${BASE_BIN}/python ${PHYLOSIFT}/bin/python
	mkdir -p ${PHYLOSIFT}/share
	cd ${PHYLOSIFT}/share && wget http://edhar.genomecenter.ucdavis.edu/~koadman/phylosift/devel/phylosift_20141126.tar.bz2 && tar xjf phylosift_20141126.tar.bz2
	mkdir -p ${PHYLOSIFT}/etc/conda/activate.d
	echo -n "export PATH=${PHYLOSIFT_PATH}/share/phylosift_20141126/bin:" > ${PHYLOSIFT}/etc/conda/activate.d/env_vars.sh
	echo '$PATH' >> ${PHYLOSIFT}/etc/conda/activate.d/env_vars.sh

${PHYLOSIFT}/bin/python: ${BASE_BIN}/python
	conda create -yn phylosift fasttree trimal

