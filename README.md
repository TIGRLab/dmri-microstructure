# dmri-microstructure

## Quality Control Process
I quality controlled the QSIPrep diffusion MRI data of the Toronto Adolescent and Youth CAMH Cohort Study (TAY study) with Lindsay Heyland as a co-rater. Images from the following preprocessing workflow steps were quality controlled:
- Static
  - T1w mask alignment
  - T1w MNILin6 Space Registration
  - Subject B0 template registration
  - dMRI Bias Correction
  - dMRI sampling scheme 
  - susceptibility distortion correction
  - dMRI B0 to T1w Registration
- Dynamic
  - dMRI Corrected Scan 
  - Colour Fractional Anisotropy Map
The results from the QC process can be found in the docs folder.

## dMRI NODDI Grey Matter/ White Matter Extraction Workflow
The following section contains the steps that were taken to create a processing pipeline for the extraction of gray matter and white matter mean neurite orientation dispersion and density imaging (NODDI) metrics, using the Accelerated Microstructure Imaging via Convex Optimization as a framework (Daducci 2015).

I ran steps 1-4 in the dMRI NODDI workflow and then wrote code for steps 5-7, to obtain our final NODDI metrics as an output. 

The Subject_list.txt file was used in the code for steps 1-2 & 4-6 to loop through TAY participants. Filter_fmriprep.json and Filter_qsiprep.json were used in steps 01-run_fmriprep.sh & 02-run_qsiprep.sh, respectively to filter the files to be input to the respective preprocessing pipeline.

### Steps
**01-run_fmriprep.sh**

sbatch script to run fMRIPrep via Singularity container

*Sample Command:*

```
sbatch 01-run_fmriprep.sh
```
Input folder: /archive/data/TAY/data/bids

Output folder: /archive/data/TAY/pipelines/in_progress/baseline

**02-run_qsiprep.sh**

sbatch script to run fMRIPrep via Singularity container
*Sample Command:*
```
sbatch 02-run_qsiprep.sh
```
Input folder: /archive/data/TAY/data/bids

Output folder: /archive/data/TAY/pipelines/in_progress/baseline

**03-gen_qsiprep_motion_metrics.R**

Using R to read qsiprep subject metrics and writing to csv file. The motion metrics were used as an independent variable in a set of linear regressions intended for the Summer Undergraduate Research Program poster presentation (poster can be found in the docs).

*Sample command:*

```
qsiprep_file_path=/archive/data/TAY/pipelines/in_progress/baseline/qsiprep
csv_output_path=/scratch/fogunsanya/dmri-microstructure/motion_data/qsiprep_metrics.csv

Rscript 03-gen_qsiprep_motion_metrics.R $qsiprep_file_path $csv_output_path
```
Input folder: /archive/data/TAY/pipelines/in_progress/baseline/qsiprep

Output file: /scratch/fogunsanya/dmri-microstructure/motion_data/qsiprep_metrics.csv

**04-run_NODDI.sh**

Running NODDI model from Accelerated Microstructure Imaging via Convex Optimization (AMICO) toolbox on study subjects, placing outputs in user’s scratch directory.

*Sample Command:*
```
sbatch 04-run_NODDI.sh
```
Input folder: /archive/data/TAY/data/bids

Output folder: /scratch/fogunsanya/dmri-microstructure/amico 

**05-transform_NODDItoMNI.sh**

Applying AntsApplyTransforms command to concatenate T1 to MNIMNI152NLin6Asym transform and the inverse of T1 to ACPC transform and apply to NODDI outputs images in order to move NODDI outputs from ACPC space to MNI152NLin6Asym space.

*Sample Command:*
```
Study=TAY
sub_path=/scratch/mjoseph/bids/TAY/code/subject_list.txt
USER_qsiprep=mjoseph 
USER_noddi=fogunsanya
bash 05-transform_NODDItoMNI.sh $Study $sub_path $USER_qsiprep $USER_noddi
```
Input folder: /scratch/fogunsanya/dmri-microstructure/amico/qsirecon

Output folder: /scratch/fogunsanya/dmri-microstructure/amico_resampled_MNI152NLin6

**06-apply_GM_WM_mask.sh**

Using fslmaths multiply command to apply subject T1 grey matter and white matter masks to NODDI outputs.

*Sample Command:*
```
Study=TAY
sub_path=/scratch/mjoseph/bids/TAY/code/subject_list.txt
USER_noddi=fogunsanya
bash 06-apply_GM_WM_mask.sh $Study $sub_path $USER_noddi
```

Input folder: /scratch/fogunsanya/dmri-microstructure/amico_resampled_MNI152NLin6

Output folder: /scratch/fogunsanya/dmri-microstructure/NODDI_volume_space_masked

**07-extract_NODDI_indices.py**

Extracting average NODDI metrics from both grey and white matter masks and outputting them into a CSV file.

*Sample command:*
```
NODDI_direc=/scratch/fogunsanya/dmri-microstructure/NODDI_volume_space_masked 
Output_path=/scratch/fogunsanya/dmri-microstructure/NODDI_Measures.csv
python 07-extract_NODDI_indices.py $NODDI_direc $Output_path
```
Input folder: /scratch/fogunsanya/dmri-microstructure/NODDI_volume_space_masked

Output folder: /scratch/fogunsanya/dmri-microstructure/NODDI_Measures.csv

## Software Environments
All code was run in the kimel lab

## Contact
Feyi Ogunsaya

4th year BMSc Student Western University

Email: feyi.ogunsanya@gmail.com

Kimel Lab Summer Student June 1, 2022 - Aug 24, 2022
