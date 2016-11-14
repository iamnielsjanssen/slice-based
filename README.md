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

Select the whole script and press 'run'. This will produce the graph of subject 23 that is also included in the paper. 

Can you adjust the temporal resolution by which the signal is extracted by changing the 'num_bins' parameter in the 'Set some parameters' section in the beginning of the script. 

This script is meant to provide insight into how the Slice-Based fMRI data analysis framework. It is not intended to be used in a full-scale fMRI data analysis as R is likely too slow. We have a Python implementation for this in the works. Please let me know of any errors, bugs, or questions. 
