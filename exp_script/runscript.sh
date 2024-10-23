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

BENCHMARK=$1                    # Benchmark name, e.g. perlbench
RUN_CONFIG="Ref"                      # Name of configuration being run (will decide output directory name)

#SCHEME_CLEANUPCACHE="UnsafeBaseline"   # Baseline 
SCHEME_CLEANUPCACHE=Cleanup_FOR_L1L2  # CleanupSpec (final version)

# MAX_INSTS=500000                      # Number of instructions to be simulated
# CHECKPOINT_CONFIG="ooo_8Gmem_100K"    # Name of directory inside CKPT_PATH
# INST_TAKE_CHECKPOINT=100000           # Instruction count after which checkpoint was taken

MAX_INSTS=500000000
CHECKPOINT_CONFIG="ooo_8Gmem_10Bn"     
INST_TAKE_CHECKPOINT=10000000000      

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
GCC_CODE=502.gcc_r
BWAVES_CODE=503.bwaves_r
MCF_CODE=505.mcf_r
CACTUBSSN_CODE=507.cactuBSSN_r
NAMD_CODE=508.namd_r
PAREST_CODE=510.parest_r
POVRAY_CODE=511.povray_r
LBM_CODE=519.lbm_r
OMNETPP_CODE=520.omnetpp_r
WRF_CODE=521.wrf_r
XALANCBMK_CODE=523.xalancbmk_r
X264_CODE=525.x264_r
BLENDER_CODE=526.blender_r
CAM4_CODE=527.cam4_r
DEEPSJENG_CODE=531.deepsjeng_r
IMAGICK_CODE=538.imagick_r
LEELA_CODE=541.leela_r
NAB_CODE=544.nab_r
FOTONIK3D_CODE=549.fotonik3d_r
ROMS_CODE=554.roms_r
XZ_CODE=557.xz_r
##################################################################

#################### BENCHMARK NAME TO FOLDER NAME MAPPING ######################

BENCHMARK_CODE="none"

if [[ "$BENCHMARK" == "perlbench" ]]; then
    BENCHMARK_CODE=$PERLBENCH_CODE
fi

if [[ "$BENCHMARK" == "gcc" ]]; then
    BENCHMARK_CODE=$GCC_CODE
fi

if [[ "$BENCHMARK" == "bwaves" ]]; then
    BENCHMARK_CODE=$BWAVES_CODE
fi

if [[ "$BENCHMARK" == "mcf" ]]; then
    BENCHMARK_CODE=$MCF_CODE
fi

if [[ "$BENCHMARK" == "cactuBSSN" ]]; then
    BENCHMARK_CODE=$CACTUBSSN_CODE
fi

if [[ "$BENCHMARK" == "namd" ]]; then
    BENCHMARK_CODE=$NAMD_CODE
fi

if [[ "$BENCHMARK" == "parest" ]]; then
    BENCHMARK_CODE=$PAREST_CODE
fi

if [[ "$BENCHMARK" == "povray" ]]; then
    BENCHMARK_CODE=$POVRAY_CODE
fi

if [[ "$BENCHMARK" == "lbm" ]]; then
    BENCHMARK_CODE=$LBM_CODE
fi

if [[ "$BENCHMARK" == "omnetpp" ]]; then
    BENCHMARK_CODE=$OMNETPP_CODE
fi

if [[ "$BENCHMARK" == "wrf" ]]; then
    BENCHMARK_CODE=$WRF_CODE
fi

if [[ "$BENCHMARK" == "xalancbmk" ]]; then
    BENCHMARK_CODE=$XALANCBMK_CODE
fi

if [[ "$BENCHMARK" == "x264" ]]; then
    BENCHMARK_CODE=$X264_CODE
fi

if [[ "$BENCHMARK" == "blender" ]]; then
    BENCHMARK_CODE=$BLENDER_CODE
fi

if [[ "$BENCHMARK" == "cam4" ]]; then
    BENCHMARK_CODE=$CAM4_CODE
fi

if [[ "$BENCHMARK" == "deepsjeng" ]]; then
    BENCHMARK_CODE=$DEEPSJENG_CODE
fi

if [[ "$BENCHMARK" == "imagick" ]]; then
    BENCHMARK_CODE=$IMAGICK_CODE
fi

if [[ "$BENCHMARK" == "leela" ]]; then
    BENCHMARK_CODE=$LEELA_CODE
fi

if [[ "$BENCHMARK" == "nab" ]]; then
    BENCHMARK_CODE=$NAB_CODE
fi

if [[ "$BENCHMARK" == "fotonik3d" ]]; then
    BENCHMARK_CODE=$FOTONIK3D_CODE
fi

if [[ "$BENCHMARK" == "roms" ]]; then
    BENCHMARK_CODE=$ROMS_CODE
fi

if [[ "$BENCHMARK" == "xz" ]]; then
    BENCHMARK_CODE=$XZ_CODE
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
    --num-cpus=1 --mem-size=8GB \
    --checkpoint-dir=$CKPT_OUT_DIR \
    --checkpoint-restore=$INST_TAKE_CHECKPOINT --at-instruction \
    --l1d_assoc=8 --l2_assoc=16 --l1i_assoc=4 \
    --cpu-type=DerivO3CPU --needsTSO=0 \
    --restore-with-cpu=DerivO3CPU \
    --scheme_invisispec=UnsafeBaseline \
    --scheme_cleanupcache=$SCHEME_CLEANUPCACHE \
    --num-dirs=1 --ruby --maxinsts=$MAX_INSTS  \
    --network=simple --topology=Mesh_XY --mesh-rows=1 --prog-interval=0.003MHz | tee -a $SCRIPT_OUT
