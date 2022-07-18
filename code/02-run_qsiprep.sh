#!/bin/bash -l

#SBATCH --partition=high-moby
#SBATCH --array=1-187%20
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4096
#SBATCH --time=24:00:00
#SBATCH --job-name qsiprep
#SBATCH --output=qsiprep_%j.out
#SBATCH --error=qsiprep_%j.err

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
WORK_DIR=${TMP_DIR}/${STUDY}/qsiprep
FS_LICENSE=${TMP_DIR}/freesurfer_license/license.txt

SING_CONTAINER=/archive/code/containers/QSIPREP/pennbbl_qsiprep_0.16.0RC3-2022-06-03-9c3b9f2e4ac1.simg

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
  --skip-bids-validation \
  --participant_label `index` \
  --bids-filter-file /code/filter_qsiprep.json \
  --n_cpus 4 --omp-nthreads 2 \
  --freesurfer-input /out/baseline/freesurfer \
  --denoise_method dwidenoise \
  --unringing_method mrdegibbs \
  --separate_all_dwis \
  --hmc_model eddy \
  --output-resolution 1.7 \
  --fs-license-file /li \
  -w /work \
  --notrack