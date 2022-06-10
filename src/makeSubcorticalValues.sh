#!/bin/bash -l
#
#module load FSL/6.0.0
#module load connectome-workbench/1.3.2

cd /projects/cschifani/HCP/dMRI_data_surface/NODDItoSurface

for subj in `cat subj.txt`; do

echo "working on" ${subj}
indir=/projects/cschifani/HCP/dMRI_data_surface/NODDItoSurface/${subj}
results=/projects/cschifani/HCP/surface_results/subcortical


if [ -d ${indir} ]; then
  cd $indir
  for i in ODI NDI CSF
  do
    wb_command -cifti-separate ${i}_32K_combined.dscalar.nii COLUMN -volume-all ${subj}_${i}_combineddscalar_subcort.nii.gz -label ${subj}_${i}_combineddscalar_subcortLabel.nii.gz

    fslmeants -i ${subj}_${i}_combineddscalar_subcort.nii.gz --label=${subj}_${i}_combineddscalar_subcortLabel.nii.gz -o ${subj}_${i}_subcorticalROIs.csv
  done

fi

echo ${subj} `cat ${subj}_NDI_subcorticalROIs.csv` >> ${results}/NDI_subcorticalROIs.csv
echo ${subj} `cat ${subj}_ODI_subcorticalROIs.csv` >> ${results}/ODI_subcorticalROIs.csv
echo ${subj} `cat ${subj}_CSF_subcorticalROIs.csv` >> ${results}/CSF_subcorticalROIs.csv

done
