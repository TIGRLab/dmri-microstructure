#!/bin/bash -l

#module load FSL/6.0.0
#get voxel values for amygdala and hippocampus NDI and NDI


for k in `cat /projects/cschifani/HCP/bothScansTrue.txt`; do
#for k in 996782; do

indir=/projects/cschifani/HCP/dMRI_data_surface/NODDItoSurface/${k}
outdir=/projects/cschifani/HCP/WM_voxel/${k}

echo 'working on' ${k}

if [ ! -d ${outdir} ]; then
  mkdir $outdir
fi


cd $outdir

fslmaths ${indir}/${k}_NDI_combineddscalar_subcortLabel.nii.gz -ero -thr 2.5 -uthr 3.5 -bin ${k}_subcortLabel_3_LAmy_ero.nii.gz
fslmaths ${indir}/${k}_NDI_combineddscalar_subcortLabel.nii.gz -ero -thr 3.5 -uthr 4.5 -bin ${k}_subcortLabel_4_RAmy_ero.nii.gz
fslmaths ${indir}/${k}_NDI_combineddscalar_subcortLabel.nii.gz -ero -thr 11.5 -uthr 12.5 -bin ${k}_subcortLabel_12_LHpc_ero.nii.gz
fslmaths ${indir}/${k}_NDI_combineddscalar_subcortLabel.nii.gz -ero -thr 12.5 -uthr 13.5 -bin ${k}_subcortLabel_13_RHpc_ero.nii.gz

fslmaths ${indir}/${k}_NDI_combineddscalar_subcort.nii.gz -mas ${k}_subcortLabel_3_LAmy_ero.nii.gz ${k}_NDI_3_LAmy_ero.nii.gz
fslmaths ${indir}/${k}_NDI_combineddscalar_subcort.nii.gz -mas ${k}_subcortLabel_4_RAmy_ero.nii.gz ${k}_NDI_4_RAmy_ero.nii.gz
fslmaths ${indir}/${k}_NDI_combineddscalar_subcort.nii.gz -mas ${k}_subcortLabel_12_LHpc_ero.nii.gz ${k}_NDI_12_LHpc_ero.nii.gz
fslmaths ${indir}/${k}_NDI_combineddscalar_subcort.nii.gz -mas ${k}_subcortLabel_13_RHpc_ero.nii.gz ${k}_NDI_13_RHpc_ero.nii.gz

fslmaths ${indir}/${k}_ODI_combineddscalar_subcort.nii.gz -mas ${k}_subcortLabel_3_LAmy_ero.nii.gz ${k}_ODI_3_LAmy_ero.nii.gz
fslmaths ${indir}/${k}_ODI_combineddscalar_subcort.nii.gz -mas ${k}_subcortLabel_4_RAmy_ero.nii.gz ${k}_ODI_4_RAmy_ero.nii.gz
fslmaths ${indir}/${k}_ODI_combineddscalar_subcort.nii.gz -mas ${k}_subcortLabel_12_LHpc_ero.nii.gz ${k}_ODI_12_LHpc_ero.nii.gz
fslmaths ${indir}/${k}_ODI_combineddscalar_subcort.nii.gz -mas ${k}_subcortLabel_13_RHpc_ero.nii.gz ${k}_ODI_13_RHpc_ero.nii.gz


done