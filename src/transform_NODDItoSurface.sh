#!/bin/bash -l
#
# module load FSL/6.0.0
# module load freesurfer/6.0.0
# module load connectome-workbench/1.3.2
#

cd /projects/cschifani/HCP/dMRI_data_surface/scripts

for subj in `cat subj3.txt`; do
#for subj in 214726; do

echo "working on" ${subj}

indir=/projects/cschifani/HCP/dMRI_data_surface/NODDItoMNI/${subj}
outdir=/projects/cschifani/HCP/dMRI_data_surface/NODDItoSurface/${subj}
surface=/scratch/cschifani/HCP/Structural_Preprocessed/${subj}/MNINonLinear/Native
surface32k=/scratch/cschifani/HCP/Structural_Preprocessed/${subj}/MNINonLinear/fsaverage_LR32k
surface_ROI=/scratch/cschifani/HCP/Structural_Preprocessed/${subj}/MNINonLinear/ROIs
shen=/projects/colin/AA_cvs_avg35_inMNI152/MNINonLinear/fsaverage_LR32k/shen268_HCPS900.dlabel.nii


if [ ! -d ${outdir} ]; then
  mkdir $outdir
fi

cd ${indir}
cp *_in_MNI_space.nii.gz ${outdir}

cd ${outdir}

#now convert the data to surfaces using the ciftify tools #both hemispheres! ::: Continue from here...

for i in ODI NDI CSF
do
wb_command -volume-to-surface-mapping ${subj}_${i}_in_MNI_space.nii.gz ${surface}/${subj}.L.midthickness.native.surf.gii ${subj}.L.${i}.native.shape.gii -ribbon-constrained ${surface}/${subj}.L.white.native.surf.gii ${surface}/${subj}.L.pial.native.surf.gii
wb_command -volume-to-surface-mapping ${subj}_${i}_in_MNI_space.nii.gz ${surface}/${subj}.R.midthickness.native.surf.gii ${subj}.R.${i}.native.shape.gii -ribbon-constrained ${surface}/${subj}.R.white.native.surf.gii ${surface}/${subj}.R.pial.native.surf.gii

done

#-------------------------------------------------------------
#Making fMRI Ribbon
#-------------------------------------------------------------

#first create signed distance volume for the white matter
wb_command -create-signed-distance-volume ${surface}/${subj}.L.white.native.surf.gii ${subj}_DWI_in_MNI_space.nii.gz L.white.native.nii.gz
#then create signed distance volume for the pial surface
wb_command -create-signed-distance-volume ${surface}/${subj}.L.pial.native.surf.gii ${subj}_DWI_in_MNI_space.nii.gz L.pial.native.nii.gz

#now use fslmaths to calculate the distance between the pial surface and white matter volumes
fslmaths L.white.native.nii.gz -thr 0 -bin -mul 255 L.white_thr0.native.nii.gz
fslmaths L.white_thr0.native.nii.gz -bin L.white_thr0.native.nii.gz
fslmaths L.pial.native.nii.gz -uthr 0 -abs -bin -mul 255 L.pial_uthr0.native.nii.gz
fslmaths L.pial_uthr0.native.nii.gz -bin L.pial_uthr0.native.nii.gz
fslmaths L.pial_uthr0.native.nii.gz -mas L.white_thr0.native.nii.gz -mul 255 L.ribbon.nii.gz
fslmaths L.ribbon.nii.gz -bin -mul 1 L.ribbon.nii.gz

#Now the right side...
wb_command -create-signed-distance-volume ${surface}/${subj}.R.white.native.surf.gii ${subj}_DWI_in_MNI_space.nii.gz R.white.native.nii.gz
wb_command -create-signed-distance-volume ${surface}/${subj}.R.pial.native.surf.gii ${subj}_DWI_in_MNI_space.nii.gz R.pial.native.nii.gz
fslmaths R.white.native.nii.gz -thr 0 -bin -mul 255 R.white_thr0.native.nii.gz
fslmaths R.white_thr0.native.nii.gz -bin R.white_thr0.native.nii.gz
fslmaths R.pial.native.nii.gz -uthr 0 -abs -bin -mul 255 R.pial_uthr0.native.nii.gz
fslmaths R.pial_uthr0.native.nii.gz -bin R.pial_uthr0.native.nii.gz
fslmaths R.pial_uthr0.native.nii.gz -mas R.white_thr0.native.nii.gz -mul 255 R.ribbon.nii.gz
fslmaths R.ribbon.nii.gz -bin -mul 1 R.ribbon.nii.gz
#Left and right together
fslmaths L.ribbon.nii.gz -add R.ribbon.nii.gz ribbon_only.nii.gz

#-------------------------------------------------------------
#2018-11-04 16:08:28.081054 : Mapping fMRI to 32k Surface
#-------------------------------------------------------------

for i in ODI NDI CSF
do
#Make sure to change for cortex right !!!!!
wb_command -cifti-separate ${surface}/${subj}.thickness.native.dscalar.nii COLUMN -metric CORTEX_LEFT ${subj}.thickness.native.L.shape.gii
wb_command -volume-to-surface-mapping ${subj}_${i}_in_MNI_space.nii.gz ${surface}/${subj}.L.midthickness.native.surf.gii ${subj}.L.${i}.myelin.native.shape.gii -myelin-style ribbon_only.nii.gz ${subj}.thickness.native.L.shape.gii 1
wb_command -metric-dilate ${subj}.L.${i}.myelin.native.shape.gii ${surface}/${subj}.L.midthickness.native.surf.gii 10 ${subj}.L.${i}.myelin.native.shape.gii -nearest
cp ${subj}.L.${i}.myelin.native.shape.gii ${indir}/${subj}.L.${i}.myelin.native.shape_before32k.gii

#mask, resample, mask,command
#MASK #1
wb_command -metric-mask ${subj}.L.${i}.myelin.native.shape.gii ${surface}/${subj}.L.roi.native.shape.gii ${subj}.L.${i}.myelin.native.shape.gii
#RESAMPLE
wb_command -metric-resample ${subj}.L.${i}.myelin.native.shape.gii ${surface}/${subj}.L.sphere.MSMSulc.native.surf.gii ${surface32k}/${subj}.L.sphere.32k_fs_LR.surf.gii ADAP_BARY_AREA ${subj}.L.${i}.myelin.32k_fs_LR.shape.gii -area-surfs ${surface}/${subj}.L.midthickness.native.surf.gii ${surface32k}/${subj}.L.midthickness.32k_fs_LR.surf.gii -current-roi ${surface}/${subj}.L.roi.native.shape.gii
#MASK #2
wb_command -metric-mask ${subj}.L.${i}.myelin.32k_fs_LR.shape.gii ${surface32k}/${subj}.L.atlasroi.32k_fs_LR.shape.gii ${subj}.L.${i}.myelin.32k_fs_LR.shape.gii

#Now the right side...

#Make sure to change for cortex right !!!!!
wb_command -cifti-separate ${surface}/${subj}.thickness.native.dscalar.nii COLUMN -metric CORTEX_RIGHT ${subj}.thickness.native.R.shape.gii
wb_command -volume-to-surface-mapping ${subj}_${i}_in_MNI_space.nii.gz ${surface}/${subj}.R.midthickness.native.surf.gii ${subj}.R.${i}.myelin.native.shape.gii -myelin-style ribbon_only.nii.gz ${subj}.thickness.native.R.shape.gii 1
wb_command -metric-dilate ${subj}.R.${i}.myelin.native.shape.gii ${surface}/${subj}.R.midthickness.native.surf.gii 10 ${subj}.R.${i}.myelin.native.shape.gii -nearest
cp ${subj}.R.${i}.myelin.native.shape.gii ${indir}/${subj}.L.${i}.myelin.native.shape_before32k.gii

#mask, resample, mask,command
#MASK #1
wb_command -metric-mask ${subj}.R.${i}.myelin.native.shape.gii ${surface}/${subj}.R.roi.native.shape.gii ${subj}.R.${i}.myelin.native.shape.gii
#RESAMPLE
wb_command -metric-resample ${subj}.R.${i}.myelin.native.shape.gii ${surface}/${subj}.R.sphere.MSMSulc.native.surf.gii ${surface32k}/${subj}.R.sphere.32k_fs_LR.surf.gii ADAP_BARY_AREA ${subj}.R.${i}.myelin.32k_fs_LR.shape.gii -area-surfs ${surface}/${subj}.R.midthickness.native.surf.gii ${surface32k}/${subj}.R.midthickness.32k_fs_LR.surf.gii -current-roi ${surface}/${subj}.R.roi.native.shape.gii
#MASK #2
wb_command -metric-mask ${subj}.R.${i}.myelin.32k_fs_LR.shape.gii ${surface32k}/${subj}.R.atlasroi.32k_fs_LR.shape.gii ${subj}.R.${i}.myelin.32k_fs_LR.shape.gii


wb_command -cifti-create-dense-scalar  ${i}_32K_combined.dscalar.nii -volume ${subj}_${i}_in_MNI_space.nii.gz ${surface_ROI}/Atlas_ROIs.2.nii.gz -left-metric ${subj}.L.${i}.myelin.32k_fs_LR.shape.gii -right-metric ${subj}.R.${i}.myelin.32k_fs_LR.shape.gii

wb_command -cifti-parcellate ${i}_32K_combined.dscalar.nii /projects/janderson/PACTMD/pipelines/NODDI_mdt/surface/Glasser.dlabel.nii COLUMN ${i}_R_Glasser.pscalar.nii

wb_command -cifti-convert -to-text ${i}_R_Glasser.pscalar.nii ${i}_Glasser.csv


wb_command -cifti-parcellate ${i}_32K_combined.dscalar.nii /projects/cschifani/rTMSWM/task_fmri/NODDI_surface/templates/shen268_HCPS900.dlabel.nii COLUMN ${i}_R_Shen.pscalar.nii

wb_command -cifti-convert -to-text ${i}_R_Shen.pscalar.nii ${i}_Shen.csv

done

done
