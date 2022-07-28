module load FSL

sublist=`cat /scratch/mjoseph/bids/TAY/code/subject_list.txt`

for subject in $sublist; do

	AMICO_RESAMPLED_DIR="/scratch/fogunsanya/dmri-microstructure/amico_resampled_MNI152NLin6/${subject}/ses-01/dwi"

	FMRIPREP_DIR="/archive/data/TAY/pipelines/in_progress/baseline/fmriprep/${subject}/ses-01/anat"

	OUTPUT_DIR="/scratch/fogunsanya/dmri-microstructure/NODDI_volume_space_masked/${subject}/ses-01/dwi"	
	
	mkdir -p ${OUTPUT_DIR}

	for i in ICVF ISOVF OD; do
		for mask in GM WM; do
			fslmaths ${AMICO_RESAMPLED_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_desc-${i}_NODDI.nii.gz -mul ${FMRIPREP_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_label-${mask}_probseg.nii.gz ${OUTPUT_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_desc-${i}_NODDI_label-${mask}.nii.gz
	
		done
	done
done
