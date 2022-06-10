
#!/usr/bin/

# MDT needs GPU!!!

#####################################
### RUN MDT TOOLBOX BATCHFIT MODE ###
#####################################

# TO SUBMIT DATA:
# to submit job, go to folder with all subject subfolders and run this line: mdt-batch-fit . NODDI

# TO PREPARE DATA FOR SUBMISSION:
# in each subfolder you need a file called:
# 1) data: preprocessed multi-shell data
# 2) mask: nodif_mask after preprocessing
# 3) bval: merged bval file
# 4) bvec: merged eddy-corrected bvec file
# 5) noise_std: text files with number 1 in it
# MDT will create a protocol file out of the inputted bval and bvec file


module load MDT/0.20_0


tmpdir=$(mktemp --tmpdir=/export/ramdisk -d tmp.XXXXXX)
cd ${tmpdir}
mkdir data

######################################

echo `date`

for subj in `cat /KIMEL/tigrlab/projects/cschifani/HCP/MDT_batchfit/batch20_21_22.txt`; do

  echo `date`

  #get files
  cd /external/rprshnas01/hcp_downloads/Diffusion_Preprocessed/
  unzip ${subj}*.zip -d $tmpdir/data
  cd $tmpdir/data/$subj/T1w/Diffusion
  mv data.nii.gz $tmpdir/data/$subj/data.nii.gz
  mv bvals $tmpdir/data/$subj/bval.txt
  mv bvecs $tmpdir/data/$subj/bvec.txt
  mv nodif_brain_mask.nii.gz $tmpdir/data/$subj/mask.nii.gz
  cd $tmpdir/data/$subj/
  echo 1 > noise_std.txt
  rm -rf T1w
  rm -rf release-notes

done


#--------------------------------------------------------------------------------
  ### RUN MDT batch fit ###

  # will run it for all available subdirectories in 'data' and creates an output folder called data_output containing all subject subdirectories

#for whole batch!

cd $tmpdir/data
mdt-batch-fit . NODDI

cd $tmpdir/data_output

##copy required files
mv * /KIMEL/tigrlab/projects/cschifani/HCP/MDT_batchfit/output/

echo `date`


  function cleanup_ramdisk {
      echo -n "Cleaning up ramdisk directory ${tmpdir} on "
      date
      rm -rf ${tmpdir}
      echo -n "done at "
      date
  }

  #trap the termination signal, and call the function 'trap_term' when
  # that happens, so results may be saved.
  trap cleanup_ramdisk 0
