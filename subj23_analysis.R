# Script for doing Slice-Based analysis of fMRI data. 
# 
# If you use this code for analysis that is published in an indexed journal or repository, please cite the following article:
# Janssen, Hernández-Cabrera, & Ezama "Improving the temnporal accuracy of functional Magnetic Resonance Imaging"
# doi: http://dx.doi.org/10.1101/073437
#

rm(list=ls(all=TRUE)) 
library(oro.nifti)

# read the data for this subject
niftifile = paste("/media/nielsj/fMRI_disk2/Chipotle_run1_only/subj23/despiked_mcf_tempfilt.nii.gz", sep="")
X = readNIfTI(niftifile)

# read the onsets (from a standard FSL formatted onset file)
onsetfile = paste("/Data/fMRI_DATA/Chipotle_fMRI/subj23/onsets/run1_naming.txt", sep="")
onsets = read.table(onsetfile)
onsets = onsets[,1]

# Set some parameters
num_bins = 7 # 7 bins = TR resolution, 14 bins = TR / 2 resolution, etc. CHANGE THIS!!!
num_slices=dim(X)[3]
num_timepoints=dim(X)[4]
TR=1.908
slice_time=TR/num_slices

# The x and y coordinates where maximum t-values in left motor cortex for this subject (determined in previous analysis)
x=45
y=30

# and three z coordinates at which signal is maximal
z1=24
z2=25
z3=26

# Extract the time courses for five voxels surrounding these (x,y) across all slices
slicets=list()
for (i in 1:num_slices){
  xy = scale(X[x,y,i,]) 
  xy1 = scale(X[x,y+1,i,])
  xy2 = scale(X[x,y-1,i,])
  x1y = scale(X[x+1,y,i,])
  x2y = scale(X[x-1,y,i,])
  slicets[[i]] = rowMeans(cbind(xy,xy1,xy2,x1y,x2y))
}
slicets = rapply(slicets, f=function(x) ifelse(is.nan(x),0,x), how="replace" ) # this just replaces each NaN with 0.

# how and when are the slices sampled?
# set up basic sequence
# The slicesampletimes generates a list where each element refers to a slice and its specific sample times
slicesampletimes=list()
for (i in 1:num_slices){
  slicesampletimes[[i]]=seq(slice_time*(i-1),num_timepoints*TR,TR)
}
slicesampletimes[[1]] = slicesampletimes[[1]][-length(slicesampletimes[[1]])]

# The data were acquired interleaved, so we need to change the order of this list
odd = seq(1,36,2)
even = seq(2,36,2)
intorder = c(odd,even)
interleavedlist=list()
for (i in 1:length(slicesampletimes)){
  newpos=intorder[i]
  interleavedlist[[newpos]]=slicesampletimes[[i]]
}

# In case data were acquired top-down or bottom-up
revorder=rev(seq(1,36))
revinterleavedlist=list()
for (i in 1:length(slicesampletimes)){
  newpos=revorder[i]
  revinterleavedlist[[newpos]]=interleavedlist[[i]]
}

# Finally, data were motion corrected, so we need to update our acquisition times with temporal corrections
yardfile = paste("/media/nielsj/fMRI_disk2/Chipotle_run1_only/subj23/yardstick_4D_total.nii.gz",sep="")
M = readNIfTI(yardfile)

corslicets=list()
for (i in 1:num_slices){
  corslicets[[i]] = M[x,y,i,] + 1
}

corsampletimes = list()
for (s in 1:num_slices){
  cortimes=c()
  for (i in 1:255){
    cortimes=c(cortimes,revinterleavedlist[[corslicets[[s]][i]]][i])
  }
  corsampletimes[[s]] = cortimes
}


####################
### EXTRACT SIGNAL - SLICE BASED METHOD
####################
epoch_length=7*TR

# setup a dataframe
slices = gl(num_slices, num_timepoints)
times = round(as.numeric(unlist(corsampletimes)),3)
signal = unlist(slicets)
df = data.frame(slices=slices, times=times, signal=signal)

# align the actual onsets with the time frame of the current data
stim_times = onsets
stims_aligned=c()
for (i in 1:length(stim_times)){
  stims_aligned[i]=times[which(abs(times-stim_times[i])==min(abs(times-stim_times[i])))]
}
stims_aligned=round(stims_aligned,3)

###########
# EPOCH DATA USING SLICE-BASED METHOD
###########

D = data.frame(slicenum=integer(0),stim_times=integer(0),rel_time=integer(0),value=numeric(0))
for (s in 1:length(stim_times)){
  epoch_times = round(seq(stims_aligned[s], stims_aligned[s]+epoch_length, slice_time),3)
  
  for (e in 1:length(epoch_times)){
    if (epoch_times[e] > max(df$times)){
      break
    }
    slice = df[df$times==epoch_times[e],]$slices
    value = df[df$times==epoch_times[e],]$signal
    rel_time = epoch_times[e] - stim_times[s]
    newline = c(slice,stim_times[s],rel_time,value)
    D[nrow(D)+1,]=newline
  }
}



##################################
### DATA BINNING
##################################
# The next function makes bins for the number of unique data points since stimulus onset
determine_bins = function (data, num_bins) {
  time_points = sort(unique(data$rel_time))
  num_unique_time_points = length(time_points)
  if(num_unique_time_points%%num_bins==0){
    bin_vector=gl(num_bins,num_unique_time_points/num_bins)
    bin_match=as.data.frame(cbind(time_points, bin_vector))
    colnames(bin_match)=c("rel_time","time_bin")
  }
  else {
    extra_points=num_unique_time_points%%num_bins
    bin_vector=gl(num_bins,(num_unique_time_points-extra_points)/num_bins)
    #bin_vector=c(bin_vector,rep(num_bins,extra_points)) # this adds the extra bins to the end.
    extra_bins=sample(num_bins, extra_points) # take random sample of bins
    bin_vector=sort(c(bin_vector, extra_bins)) # add them to the bin_vector
    bin_match=as.data.frame(cbind(time_points, bin_vector))
    colnames(bin_match)=c("rel_time","time_bin")
  }
  bin_match
}


bins = determine_bins(D,num_bins)
E = merge(D,bins, by="rel_time")

#########################################
# Slice-Based signal extraction using time point-by-time point with Baseline as time point 1 in epoch
#########################################

slicestats=data.frame(slice_num=integer(0), tp=numeric(0), tval=numeric(0), pval=numeric(0))
timepoints=sort(unique(E$time_bin))
tzero = E[E$time_bin==1,]
tzero$fac = 0

for (i in 1:num_slices){
  for (t in 1:length(timepoints)){
    if (t==1){
      slicestats[nrow(slicestats)+1,] = c(i, t, 0, 1)
    }
    else{
      #tzerop = tzero[tzero$slicenum==i | tzero$slicenum==i+1 | tzero$slicenum==i-1 | tzero$slicenum==i+2 | tzero$slicenum==i-2,] 
      p = E[E$slicenum==i & E$time_bin==timepoints[t],]
      p$fac = 1
      p = rbind(tzero,p)
      #p = rbind(tzerop,p)
      mod = lm(value ~ fac, data=p)
      tval=coef(summary(mod))[6]
      pval=coef(summary(mod))[8]
      slicestats[nrow(slicestats)+1,] = c(i, t, tval, pval)
    }
  }
}


###############################
### GRAPHS
###############################
ylimit=c(-6,12)
tvalpts=seq(-6,12)
tps=1:num_bins
tps_lab=round(seq(0,11.4, length=num_bins),1)

plot(slicestats[slicestats$slice_num==z1,]$tval, type="n", ylim=ylimit, ylab="t-value", xlab="Time (in s.)", bty="n", axes=FALSE, main="Slice-Based")
abline(h=tvalpts, col="gray90")
abline(v=tps, col="gray90")
abline(h=0, lty=2)
lines(slicestats[slicestats$slice_num==z1,]$tval, type="l",ylim=ylimit, col="red")
lines(slicestats[slicestats$slice_num==z2,]$tval, type="l", ylim=ylimit, col="green")
lines(slicestats[slicestats$slice_num==z3,]$tval, type="l", ylim=ylimit, col="blue")
axis(1, at=tps, labels=tps_lab)
axis(2, at=tvalpts, labels=tvalpts, line=0)
legend("topright",legend=paste("slice",c(z1,z2,z3), sep=""), lty=1, col=c("red","green","blue"), bty="n")
