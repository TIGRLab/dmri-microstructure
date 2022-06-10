#!/bin/bash -l
#
# module load FSL/6.0.0
# module load freesurfer/6.0.0
#

subj=$1
echo "working on" ${subj}
tmpdir=$(mktemp --tmpdir=/export/ramdisk -d tmp${subj}.XXXXXX)
function cleanup_ramdisk {
  echo -n "Cleaning up ramdisk directory ${tmpdir} on "
  date
  rm -rf ${tmpdir}
  echo -n "done at "
  date
}

#trap the termination signal, and call the function 'trap_term' when
# that happens, so results may be saved.
trap cleanup_ramdisk EXIT SIGTERM

########### ------------ GET REQUIRED FILES ---------- ###############

echo `date`

#if [ ! /KIMEL/tigrlab/projects/cschifani/HCP/dMRI_data_surface/NODDItoMNI/${subj}/${subj}_DWI_in_MNI_space.nii.gz ]; then


  #get T1 files
  cd $tmpdir
  mkdir structural
  cd /external/rprshnas01/hcp_downloads/Structural_Preprocessed
  unzip ${subj}*.zip -d $tmpdir/structural

  cd $tmpdir
  mkdir diffusion
  cd /external/rprshnas01/hcp_downloads/Diffusion_Preprocessed
  unzip ${subj}*.zip -d $tmpdir/diffusion

  indir1=/${tmpdir}/structural/${subj}/T1w/
  indir2=/${tmpdir}/diffusion/${subj}/T1w/Diffusion
  indir3=/KIMEL/tigrlab/projects/cschifani/HCP/MDT_batchfit/output/${subj}/NODDI
  template=/KIMEL/tigrlab/projects/cschifani/HCP/dMRI_data_surface/templates
  outdir=/${tmpdir}
  endoutdir=/KIMEL/tigrlab/projects/cschifani/HCP/dMRI_data_surface/NODDItoMNI/${subj}
  scratchdir=/KIMEL/tigrlab/scratch/cschifani/HCP/Structural_Preprocessed/${subj}


  if [ ! -d ${endoutdir} ]; then
    mkdir $endoutdir
  fi

  if [ ! -d ${scratchdir} ]; then
    mkdir $scratchdir
  fi

# if [ ! -d ${scratchdir}/MNINonLinear/Native/${subj}.L.midthickness.native.surf.gii ]; then
#
#   cd /${tmpdir}/structural/${subj}
#   #cp -r ./T1w $scratchdir
#   cp -r ./release-notes $scratchdir
#   cp -r ./MNINonLinear $scratchdir
# fi

  cd ${indir1}
  cp T1w_acpc_dc_restore_brain.nii.gz ${outdir}
  cp T1w_acpc_dc.nii.gz ${outdir}
  fslreorient2std T1w_acpc_dc_restore_brain ${outdir}/${subj}_T1w_restore_brain_standard.nii.gz
  fslreorient2std T1w_acpc_dc ${outdir}/${subj}_T1_standard.nii.gz

  cd ${indir2}
  cp data.nii.gz ${outdir}
  fslroi data.nii.gz b0 0 1 #isolate first b0 from corrected data
  bet b0 ${outdir}/${subj}_nodif_brain -m -R -f 0.3 #skull strip new b0


  cd ${outdir}
  #now align the T1 to the MNI_152_2mm_brain image using an affine transform
  flirt -in ${subj}_T1w_restore_brain_standard.nii.gz -ref ${template}/MNI152_T1_2mm_brain.nii.gz -out T1_MNI_Affine.nii.gz -omat T1_MNI_Affine.mat
  #now use a nonlinear transform (fnirt) to warp the T1 to the MNI space
  fnirt --ref=${template}/MNI152_T1_2mm_brain.nii.gz --in=${subj}_T1w_restore_brain_standard.nii.gz --aff=T1_MNI_Affine.mat --config=T1_2_MNI152_2mm --cout=T1_MNI_Nonlin --iout=T1_in_MNI_space
  #now flirt the DWI image to the anatomical image using boundary based registration (BBR)
  epi_reg --epi=${subj}_nodif_brain.nii.gz --t1=${subj}_T1_standard.nii.gz --t1brain=${subj}_T1w_restore_brain_standard.nii.gz --out=DWI_to_T1 -v
  #now concatenate the transforms
  convertwarp --ref=${template}/MNI152_T1_2mm_brain.nii.gz --warp1=T1_MNI_Nonlin.nii.gz --premat=DWI_to_T1.mat --out=my_comprehensive_warps --relout
  #apply the transforms to the relevant data
  applywarp --ref=${template}/MNI152_T1_2mm_brain.nii.gz --in=${indir3}/NDI.nii.gz --warp=my_comprehensive_warps.nii.gz --rel --out=${outdir}/${subj}_NDI_in_MNI_space
  applywarp --ref=${template}/MNI152_T1_2mm_brain.nii.gz --in=${indir3}/ODI.nii.gz --warp=my_comprehensive_warps.nii.gz --rel --out=${outdir}/${subj}_ODI_in_MNI_space
  applywarp --ref=${template}/MNI152_T1_2mm_brain.nii.gz --in=${indir3}/w_csf.w.nii.gz --warp=my_comprehensive_warps.nii.gz --rel --out=${outdir}/${subj}_CSF_in_MNI_space
  applywarp --ref=${template}/MNI152_T1_2mm_brain.nii.gz --in=${subj}_nodif_brain.nii.gz --warp=my_comprehensive_warps.nii.gz --rel --out=${outdir}/${subj}_DWI_in_MNI_space


  ## move data##
  for file in *.nii.gz *.mat *.log *.gii; do
    mv -v $file ${endoutdir}/; done

#fi
