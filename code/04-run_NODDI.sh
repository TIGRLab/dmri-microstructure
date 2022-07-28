#!/bin/bash -l
 
#SBATCH --partition=high-moby
#SBATCH --array=1-187
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4096
#SBATCH --time=24:00:00
#SBATCH --job-name qsiprep
#SBATCH --output=qsiprep_%j.out
#SBATCH --error=qsiprep_%j.err

STUDY="TAY"

sublist="/scratch/mjoseph/bids/${STUDY}/code/subject_list_dwi.txt"

index() {
   head -n $SLURM_ARRAY_TASK_ID $sublist \
   | tail -n 1
}

BIDS_DIR=/archive/data/${STUDY}/data/bids
QSIPREP_DIR=/archive/data/${STUDY}/pipelines/in_progress/qsiprep
OUT_DIR=/scratch/fogunsanya/dmri-microstructure/amico 
TMP_DIR=/scratch/fogunsanya/dmri-microstructure/tmp 
WORK_DIR=/scratch/fogunsanya/dmri-microstructure/tmp/${STUDY} 
FS_LICENSE=/scratch/mjoseph/tmp/freesurfer_license/license.txt

SING_CONTAINER=/archive/code/containers/QSIPREP/pennbbl_qsiprep_0.14.3-2021-09-16-e97e6c169493.simg

mkdir -p $BIDS_DIR $OUT_DIR $TMP_DIR $WORK_DIR

singularity run \
  -H ${TMP_DIR} \
  -B ${BIDS_DIR}:/bids \
  -B ${QSIPREP_DIR}:/qsiprep \
  -B ${OUT_DIR}:/out \
  -B ${WORK_DIR}:/work \
  -B ${FS_LICENSE}:/li \
  ${SING_CONTAINER} \
  /bids /out participant \
  --skip-bids-validation \
  --participant_label `index` \
  --recon-only \
  --recon-spec amico_noddi \
  --recon-input /qsiprep \
  --n_cpus 4 --omp-nthreads 2 \
  --output-resolution 1.7 \
  --fs-license-file /li \
  -w /work \
  --notrack
