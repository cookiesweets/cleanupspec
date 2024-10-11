#Source paths for GCC version 6.4.0
source /root/LOCAL_LIB/env_gcc_binutils.sh

#Source path for protobuf and gperftools recommended for Gem5
# (http://learning.gem5.org/book/part1/building.html)
source /root/LOCAL_LIB/protobuf/env_protobuf.sh
source /root/LOCAL_LIB/gperftools/env_gperftools.sh

#Source path for python 2.7 or higher
source /root/LOCAL_LIB/python/env_anaconda2.sh

#Paths for Gem5 & SPEC
export GEM5_PATH=/root/cleanupspec
export SPEC_PATH=/root/Benchmark/SPEC2017
export CKPT_PATH=/root/Benchmark/cleanup_ckpt
