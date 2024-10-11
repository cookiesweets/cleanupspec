#!/bin/bash

############ NOTE: This script sets up the following variables and then runs the command below ############

# **(modify these as needed)**
# OUTPUT_DIR: Where the results will be written
# GEM5_PATH: path for current cleanupspec directory
# BENCHMARK: name of the benchmark being run
# CKPT_OUT_DIR: directory in which Checkpoint being restored for current benchmark
# INST_TAKE_CHECKPOINT: instruction at which to restore checkpoint
# SCHEME_CLEANUPSPEC: Scheme name to simulate (see README or configs/common/Scheme.py for supported list)
# MAX_INSTS: Number of instructions to simulate
# SCRIPT_OUT: Log file

#$GEM5_PATH/build/X86_MESI_Two_Level/gem5.opt \
#    --outdir=$OUTPUT_DIR $GEM5_PATH/configs/example/spec06_config.py \
#    --benchmark=$BENCHMARK --benchmark_stdout=$OUTPUT_DIR/$BENCHMARK.out \
#    --benchmark_stderr=$OUTPUT_DIR/$BENCHMARK.err \
#    --num-cpus=1 --mem-size=4GB \
#    --checkpoint-dir=$CKPT_OUT_DIR \
#    --checkpoint-restore=$INST_TAKE_CHECKPOINT --at-instruction \
#    --l1d_assoc=8 --l2_assoc=16 --l1i_assoc=4 \
#    --cpu-type=DerivO3CPU --needsTSO=0 --scheme_invisispec=UnsafeBaseline \
#    --scheme_cleanupcache=$SCHEME_CLEANUPCACHE \
#    --num-dirs=1 --ruby --maxinsts=$MAX_INSTS  \
#    --network=simple --topology=Mesh_XY --mesh-rows=1 --prog-interval=0.003MHz | tee -a $SCRIPT_OUT


######################### CONFIG OPTIONS #########################################
# To be modified as required

BENCHMARK=perlbench                    # Benchmark name, e.g. perlbench
RUN_CONFIG="Test"                      # Name of configuration being run (will decide output directory name)

#SCHEME_CLEANUPCACHE="UnsafeBaseline"   # Baseline 
SCHEME_CLEANUPCACHE="Cleanup_FOR_L1L2"  # CleanupSpec (final version)

MAX_INSTS=500000                      # Number of instructions to be simulated
CHECKPOINT_CONFIG="ooo_16Gmem_100K"    # Name of directory inside CKPT_PATH
INST_TAKE_CHECKPOINT=100000           # Instruction count after which checkpoint was taken

#MAX_INSTS=500000000
#CHECKPOINT_CONFIG="ooo_4Gmem_10Bn"     
#INST_TAKE_CHECKPOINT=10000000000      

############ DIRECTORY PATHS TO BE EXPORTED #############

#Need to export GEM5_PATH
if [ -z ${GEM5_PATH+x} ];
then
    echo "GEM5_PATH is unset";
    exit
else
    echo "GEM5_PATH is set to '$GEM5_PATH'";
fi
#Need to export SPEC_PATH
if [ -z ${SPEC_PATH+x} ];
then
    echo "SPEC_PATH is unset";
    exit
else
    echo "SPEC_PATH is set to '$SPEC_PATH'";
fi
#Need to export CKPT_PATH
if [ -z ${CKPT_PATH+x} ];
then
    echo "CKPT_PATH is unset";
    exit
else
    echo "CKPT_PATH is set to '$CKPT_PATH'";
fi

######################### BENCHMARK FOLDER NAMES ####################
PERLBENCH_CODE=500.perlbench_r
BZIP2_CODE=401.bzip2
GCC_CODE=502.gcc_r
BWAVES_CODE=503.bwaves_r
GAMESS_CODE=416.gamess
MCF_CODE=505.mcf_r
MILC_CODE=433.milc
ZEUSMP_CODE=434.zeusmp
GROMACS_CODE=435.gromacs
CACTUSADM_CODE=436.cactusADM
LESLIE3D_CODE=437.leslie3d
NAMD_CODE=508.namd_r
GOBMK_CODE=445.gobmk
DEALII_CODE=447.dealII
SOPLEX_CODE=450.soplex
POVRAY_CODE=453.povray
CALCULIX_CODE=454.calculix
HMMER_CODE=456.hmmer
DEEPSJENG_CODE=531.deepsjeng_r
GEMSFDTD_CODE=459.GemsFDTD
LIBQUANTUM_CODE=462.libquantum
H264REF_CODE=464.h264ref
TONTO_CODE=465.tonto
LBM_CODE=508.lbm_r
OMNETPP_CODE=520.omnetpp_r
ASTAR_CODE=473.astar
WRF_CODE=521.wrf_r
SPHINX3_CODE=482.sphinx3
XALANCBMK_CODE=523.xalancbmk_r
SPECRAND_INT_CODE=998.specrand
SPECRAND_FLOAT_CODE=999.specrand
##################################################################

#################### BENCHMARK NAME TO FOLDER NAME MAPPING ######################

BENCHMARK_CODE="none"

if [[ "$BENCHMARK" == "perlbench" ]]; then
    BENCHMARK_CODE=$PERLBENCH_CODE
fi
if [[ "$BENCHMARK" == "bzip2" ]]; then
    BENCHMARK_CODE=$BZIP2_CODE
fi
if [[ "$BENCHMARK" == "gcc" ]]; then
    BENCHMARK_CODE=$GCC_CODE
fi
if [[ "$BENCHMARK" == "bwaves" ]]; then
    BENCHMARK_CODE=$BWAVES_CODE
fi
if [[ "$BENCHMARK" == "gamess" ]]; then
    BENCHMARK_CODE=$GAMESS_CODE
fi
if [[ "$BENCHMARK" == "mcf" ]]; then
    BENCHMARK_CODE=$MCF_CODE
fi
if [[ "$BENCHMARK" == "milc" ]]; then
    BENCHMARK_CODE=$MILC_CODE
fi
if [[ "$BENCHMARK" == "zeusmp" ]]; then
    BENCHMARK_CODE=$ZEUSMP_CODE
fi
if [[ "$BENCHMARK" == "gromacs" ]]; then
    BENCHMARK_CODE=$GROMACS_CODE
fi
if [[ "$BENCHMARK" == "cactusADM" ]]; then
    BENCHMARK_CODE=$CACTUSADM_CODE
fi
if [[ "$BENCHMARK" == "leslie3d" ]]; then
    BENCHMARK_CODE=$LESLIE3D_CODE
fi
if [[ "$BENCHMARK" == "namd" ]]; then
    BENCHMARK_CODE=$NAMD_CODE
fi
if [[ "$BENCHMARK" == "gobmk" ]]; then
    BENCHMARK_CODE=$GOBMK_CODE
fi
if [[ "$BENCHMARK" == "dealII" ]]; then 
    BENCHMARK_CODE=$DEALII_CODE
fi
if [[ "$BENCHMARK" == "soplex" ]]; then
    BENCHMARK_CODE=$SOPLEX_CODE
fi
if [[ "$BENCHMARK" == "povray" ]]; then
    BENCHMARK_CODE=$POVRAY_CODE
fi
if [[ "$BENCHMARK" == "calculix" ]]; then
    BENCHMARK_CODE=$CALCULIX_CODE
fi
if [[ "$BENCHMARK" == "hmmer" ]]; then
    BENCHMARK_CODE=$HMMER_CODE
fi
if [[ "$BENCHMARK" == "sjeng" ]]; then
    BENCHMARK_CODE=$SJENG_CODE
fi
if [[ "$BENCHMARK" == "GemsFDTD" ]]; then
    BENCHMARK_CODE=$GEMSFDTD_CODE
fi
if [[ "$BENCHMARK" == "libquantum" ]]; then
    BENCHMARK_CODE=$LIBQUANTUM_CODE
fi
if [[ "$BENCHMARK" == "h264ref" ]]; then
    BENCHMARK_CODE=$H264REF_CODE
fi
if [[ "$BENCHMARK" == "tonto" ]]; then
    BENCHMARK_CODE=$TONTO_CODE
fi
if [[ "$BENCHMARK" == "lbm" ]]; then
    BENCHMARK_CODE=$LBM_CODE
fi
if [[ "$BENCHMARK" == "omnetpp" ]]; then
    BENCHMARK_CODE=$OMNETPP_CODE
fi
if [[ "$BENCHMARK" == "astar" ]]; then
    BENCHMARK_CODE=$ASTAR_CODE
fi
if [[ "$BENCHMARK" == "wrf" ]]; then
    BENCHMARK_CODE=$WRF_CODE
fi
if [[ "$BENCHMARK" == "sphinx3" ]]; then
    BENCHMARK_CODE=$SPHINX3_CODE
fi
if [[ "$BENCHMARK" == "xalancbmk" ]]; then
    BENCHMARK_CODE=$XALANCBMK_CODE
fi
if [[ "$BENCHMARK" == "specrand_i" ]]; then
    BENCHMARK_CODE=$SPECRAND_INT_CODE
fi
if [[ "$BENCHMARK" == "specrand_f" ]]; then
    BENCHMARK_CODE=$SPECRAND_FLOAT_CODE
fi

# Sanity check
if [[ "$BENCHMARK_CODE" == "none" ]]; then
    echo "Input benchmark selection $BENCHMARK did not match any known SPEC CPU2006 benchmarks! Exiting."
    exit 1
fi


################## DIRECTORY NAMES (CHECKPOINT, OUTPUT, RUN DIRECTORY)  ###################
#Set up based on path variables & configuration

# Ckpt Dir
CKPT_OUT_DIR=$CKPT_PATH/$CHECKPOINT_CONFIG/$BENCHMARK-1-ref-x86
echo "checkpoint directory: " $CKPT_OUT_DIR

# Output Dir
OUTPUT_DIR=$GEM5_PATH/output/$CHECKPOINT_CONFIG/$RUN_CONFIG/${SCHEME_CLEANUPCACHE}/$BENCHMARK
echo "output directory: " $OUTPUT_DIR
if [ -d "$OUTPUT_DIR" ]
then
    rm -r $OUTPUT_DIR
fi
mkdir -p $OUTPUT_DIR

#Run Dir
RUN_DIR=$SPEC_PATH/benchspec/CPU/$BENCHMARK_CODE/run/run_base_refrate_sparespec-m64.0000

# File log used for stdout
SCRIPT_OUT=$OUTPUT_DIR/runscript.log

#Report directory names 
echo "Command line:"                                | tee $SCRIPT_OUT
echo "$0 $*"                                        | tee -a $SCRIPT_OUT
echo "================= Hardcoded directories ==================" | tee -a $SCRIPT_OUT
echo "GEM5_PATH:                                     $GEM5_PATH" | tee -a $SCRIPT_OUT
echo "SPEC_PATH:                                     $SPEC_PATH" | tee -a $SCRIPT_OUT
echo "==================== Script inputs =======================" | tee -a $SCRIPT_OUT
echo "BENCHMARK:                                    $BENCHMARK" | tee -a $SCRIPT_OUT
echo "OUTPUT_DIR:                                   $OUTPUT_DIR" | tee -a $SCRIPT_OUT
echo "==========================================================" | tee -a $SCRIPT_OUT
##################################################################


#################### LAUNCH GEM5 SIMULATION ######################
echo ""
echo "Changing to SPEC benchmark runtime directory: $RUN_DIR" | tee -a $SCRIPT_OUT
cd $RUN_DIR

echo "" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT
echo "--------- Here goes nothing! Starting gem5! ------------" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT

# Launch Gem5:
$GEM5_PATH/build/X86_MESI_Two_Level/gem5.opt \
    --outdir=$OUTPUT_DIR $GEM5_PATH/configs/example/spec17_config.py \
    --benchmark=$BENCHMARK --benchmark_stdout=$OUTPUT_DIR/$BENCHMARK.out \
    --benchmark_stderr=$OUTPUT_DIR/$BENCHMARK.err \
    --num-cpus=1 --mem-size=16GB \
    --checkpoint-dir=$CKPT_OUT_DIR \
    --checkpoint-restore=$INST_TAKE_CHECKPOINT --at-instruction \
    --l1d_assoc=8 --l2_assoc=16 --l1i_assoc=4 \
    --cpu-type=DerivO3CPU --needsTSO=0 --scheme_invisispec=UnsafeBaseline \
    --scheme_cleanupcache=$SCHEME_CLEANUPCACHE \
    --num-dirs=1 --ruby --maxinsts=$MAX_INSTS  \
    --network=simple --topology=Mesh_XY --mesh-rows=1 --prog-interval=0.003MHz | tee -a $SCRIPT_OUT
