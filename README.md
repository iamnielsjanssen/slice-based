# slice-based
Functions for Slice-Based fMRI analysis

Please cite the following article if you use this code in published work:

Janssen, N., Hernández-Cabrera, JA., Ezama Foronda, L. 
"Improving the temporal accuracy of functional Magnetic Resonance Imaging"
bioRxiv doi: http://dx.doi.org/10.1101/073437

The folder [`data`](data) contains the raw fmri data file, the stimulus onset file, and the yardstick for the temporal correction in motion correction. The folder [`script`](scripts) contains the R script. 

## Installation

Download the zipped code and extract on your computer. 

Open the script [`subj23_analysis.R`](scripts/subj23_analysis.R) in Rstudio. Ensure the [`subj23_run1_truncated.nii.gz`], [`run1_naming.txt`] and [`yardstick_4D_total.nii.gz`] are in the [`data`] folder.

## Usage

In Rstudio, select the whole script and press 'run'. Assuming the path to folders are set correctly, this will produce the graph of subject 23 that is also included in the paper. 

It is very easy to adjust the temporal resolution by which the signal is extracted. You can adjust the temporal resolution by changing the 'num_bins' parameter in the 'Set some parameters' section in the beginning of the script. For example, given that the epoch length is 7 times the TR, setting the number of bins will produce an epoch with a temporal resolution equal to the TR. Setting the number of bins to 14 will produce an epoch with a temporal resolution equal to the TR divided by 2. The user is encouraged to play around with this number see the impact on the quality of the extracted BOLD signal. Note that increasing the temporal resolution will result in a poorer quality signal because the same data is distributed across a larger number of time points in the epoch. 

This script is meant to provide insight into the inner workings of the Slice-Based fMRI data analysis framework. It is not intended to be used in a full-scale fMRI data analysis. For faster implementations we have a Python version available. Please contact me for questions, errors, or problems with the program.
