#!/bin/bash

#SBATCH --partition=debug
#SBATCH --time=01:00:00
#SBATCH --array=0
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --job-name=HCP_test_clean
#SBATCH --output=HCP_test_clean_%j.txt

#this script will call a cleaning and time series extraction script for a sample of the HCP S1200
#runs a subject as a task in the array (runs as array for the number of subjects in the sample)
#path to HCP data
basedir=$SCRATCH/FLEXCOG/inputs/data/MSMAll_Clean
outdir=$SCRATCH/FLEXCOG/outputs/r_HCP_clean

#load modules needed to run the cleaning
#runs with R, gnu-parallel and python
##python environment is loaded with connectome-workbench/1.3.2 and ciftify modules
module load NiaEnv/2019b
module load intel/2019u4
module load gcc/9.2.0
module load r/4.0.3
module load gnu-parallel/20191122
#source activate ciftify2.3.3_bspace
#module load singularity/3

# make ouput directory and set paths to data and output directories
indir=${basedir}/${subid}
cleandir=${outdir}/cleaned_data/${subid}

mkdir -p ${cleandir}

ls -1d ${basedir}/${subid}/rfMRI_REST[12]_??
tasklist=''
#generate the merged tsv for each tresting state task for the subject
run_cleaning_script() {
  indir=${basedir}/${1}
  cleandir=${outdir}/cleaned_data/${1}
  mkdir -p ${cleandir}
  $SCRATCH/FLEXCOG/code/merge_HCPtxt_fixed.R ${cleandir} ${indir}/${2}
}

export -f run_cleaning_script

allsubs=`cat $SCRATCH/FLEXCOG/code/r_test_sub.txt`

parallel -j 40 "run_cleaning_script {1} {2}" ::: $allsubs ::: "rfMRI_REST1_LR" "rfMRI_REST1_RL" "rfMRI_REST2_LR" "rfMRI_REST2_RL"
