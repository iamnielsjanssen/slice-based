# Slice-Based fMRI
Functions for Slice-Based fMRI analysis

Please cite the following article if you use this code in published work:

Janssen, N., Hernández-Cabrera, JA., Ezama Foronda, L. (2018)
"Improving the signal detection accuracy of functional Magnetic Resonance Imaging" 
NeuroImage, 176, 92-109.

The folder [`data`](data) contains the raw fmri data file containing data from a single subject (subj23) in a single run in the picture naming task, the stimulus onsets file, and the yardstick for the temporal correction in motion correction. The folder [`script`](scripts) contains the R script. 

This script is meant to provide insight into the inner workings of the Slice-Based fMRI data analysis framework. It can also be used for your own full-scale fMRI data analysis (see below). 

Please contact me for questions, errors, or problems with the program.

## Installation

Download the zipped code and extract on your computer. 

Open the script [`slice_based_subj23_v01.0.R`](scripts/slice_based_subj23_v1.0.R) in Rstudio. Ensure the [`subj23_run1_truncated.nii.gz`], [`run1_naming.txt`] and [`yardstick_4D_total.nii.gz`] are in the [`data`] folder. Ensure that all the folders inside the script are set correctly, including the path where the niftis are saved at the two places at bottom of the script.

## Usage

In Rstudio, select the whole script and press 'run'. Assuming the path/to/folders are set correctly, this will then run the truncated analysis for 49 voxels.

In addition, it is easy to adjust the temporal resolution by which the signal is extracted. You can adjust the temporal resolution by changing the 'num_bins' parameter in the 'Set some parameters' section in the beginning of the script. For example, given that the epoch length is 7 times the TR, setting the number of bins to 7 will produce an epoch with a temporal resolution equal to the TR (in this case 1908 ms). Setting the number of bins to 14 will produce an epoch with a temporal resolution equal to the TR divided by 2 (i.e., 954 ms). The user is encouraged to play around with this number see the impact on the quality of the extracted BOLD signal. Note that increasing the temporal resolution will result in a poorer quality signal because the same data is distributed across a larger number of time points in the epoch. 

After the analysis has finished, the program will write four nifti files. A file with the beta values, the standard error values, the degrees of freedom, and the t-values for every voxel analyzed. You can use FSLview to inspect these files and use the example_func file of this subject for localization purposes. Note these are 4D files and you can use the 'volume' button in FSLview to step through the various timepoints in the epoch. By clicking on a voxel and using the 'Tools/time series' option you can visualize the time course of each voxel. The data should look like the example image below.

![alt tag](https://cloud.githubusercontent.com/assets/8832136/22594539/599dae12-ea1b-11e6-9e04-33c4075236e1.png)

## Doing your own Analyses

You can easily adapt the script to run on your own Slice Based analysis on your data. All the program needs is a 4D fMRI data file in nifti format and a text file with the stimulus onsets. Please make sure that you correctly set the parameters for interleaved, topdown, and motion correction. Incorrect specification of these parameters results in incorrect extraction of the BOLD signal.

Please contact me for any questions.
