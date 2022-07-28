module load ANTS/2.3.3

sublist=`cat /scratch/mjoseph/bids/TAY/code/subject_list.txt`

for subject in $sublist; do

	FMRIPREP_DIR="/archive/data/TAY/pipelines/in_progress/baseline/fmriprep/${subject}/ses-01/anat"

	T1_ACPC_TRANSFORM="/scratch/mjoseph/tmp/TAY/qsiprep/qsiprep_wf/${subject/sub-/single_subject_}_wf/anat_preproc_wf/skullstrip_wf/rigid_acpc_align/transform0GenericAffine.mat"

	T1_MNI_TRANSFORM="${FMRIPREP_DIR}/${subject}_ses-01_from-T1w_to-MNI152NLin6Asym_mode-image_xfm.h5"

	AMICO_DIR="/scratch/fogunsanya/dmri-microstructure/amico/qsirecon/${subject}/ses-01/dwi"

	OUTPUT_DIR="/scratch/fogunsanya/dmri-microstructure/amico_resampled_MNI152NLin6/${subject}/ses-01/dwi"

	mkdir -p $OUTPUT_DIR

	for i in ICVF ISOVF OD; do
		
		antsApplyTransforms   -d 3   -r "${FMRIPREP_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_desc-preproc_T1w.nii.gz"   -t ${T1_MNI_TRANSFORM}   -t [ ${T1_ACPC_TRANSFORM}, 1 ]   -n NearestNeighbor   -i "${AMICO_DIR}/${subject}_ses-01_space-T1w_desc-preproc_space-T1w_desc-${i}_NODDI.nii.gz"   -o "${OUTPUT_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_desc-${i}_NODDI.nii.gz"   -v

	done

done