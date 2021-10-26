#!/bin/bash
#SBATCH --cpus-per-task=80
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=1
#SBATCH --partition=compute
#SBATCH --time=01:00:00
#SBATCH --job-name=HCP_test_clean
#SBATCH --output=HCP_test_clean_%j.txt

#this script will call a cleaning and time series extraction script for a sample of the HCP S1200
#runs a subject as a task in the array (runs as array for the number of subjects in the sample)
#path to HCP data
export prefix=${SCRATCH}/FLEXCOG
export basedir=${prefix}/inputs/data/MSMAll_Clean
export cleandir=${prefix}/outputs/r_HCP_clean/cleaned_data

#load modules needed to run the cleaning
#runs with R, gnu-parallel and python
##python environment is loaded with connectome-workbench/1.3.2 and ciftify modules
module load intel/2019u4
module load gcc/9.2.0
module load r/4.0.3
module load gnu-parallel/20191122
#source activate ciftify2.3.3_bspace
#module load singularity/3

parallel --nn -j80 --keep-order \
         "indir=${basedir}/{1}
          outdir=${cleandir}/{1}
          mkdir -p \${indir} \${outdir}
          \${prefix}/code/merge_HCPtxt_fixed.R \${outdir} \${indir}/{2}" \
         :::: ${prefix}/code/r_test_sub.txt \
         ::: "rfMRI_REST1_LR" "rfMRI_REST1_RL" \
             "rfMRI_REST2_LR" "rfMRI_REST2_RL"
