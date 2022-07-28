#!/bin/bash -l

#SBATCH --partition=high-moby
#SBATCH --array=1-187%20
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=4096
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00
#SBATCH --job-name fmriprep-func
#SBATCH --output=fmriprep-func_%j.out
#SBATCH --error=fmriprep-func_%j.err

STUDY="TAY"

sublist="/scratch/mjoseph/bids/${STUDY}/code/subject_list.txt"

index() {
   head -n $SLURM_ARRAY_TASK_ID $sublist \
   | tail -n 1
}

BIDS_DIR=/archive/data/${STUDY}/data/bids
OUT_DIR=/archive/data/${STUDY}/pipelines/in_progress/baseline
CODE_DIR=/scratch/mjoseph/bids/${STUDY}/code
TMP_DIR=/scratch/mjoseph/tmp
WORK_DIR=${TMP_DIR}/${STUDY}/fmriprep
FS_LICENSE=${TMP_DIR}/freesurfer_license/license.txt

SING_CONTAINER=/archive/code/containers/FMRIPREP/nipreps_fmriprep_20.2.7-2022-01-24-5df135ac568c.simg

mkdir -p $BIDS_DIR $OUT_DIR $TMP_DIR $WORK_DIR

singularity run \
  -H ${TMP_DIR} \
  -B ${BIDS_DIR}:/bids \
  -B ${OUT_DIR}:/out \
  -B ${CODE_DIR}:/code \
  -B ${WORK_DIR}:/work \
  -B ${FS_LICENSE}:/li \
  ${SING_CONTAINER} \
  /bids /out participant \
  --skip_bids_validation \
  --participant_label `index` \
  --bids-filter-file /code/filter_fmriprep.json \
  --n_cpus 4 --omp-nthreads 2 \
  --output-spaces T1w MNI152NLin2009cAsym MNI152NLin6Asym fsaverage \
  --fs-license-file /li \
  -w /work \
  --notrack