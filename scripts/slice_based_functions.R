library(oro.nifti)
library(methods)
library(lme4)
library(data.table)

##################################
### Function DATA BINNING
##################################
# The next function makes bins for the number of unique data points since stimulus onset
determine_bins = function (data, num_bins, end_baseline) {
  time_points = sort(unique(data$rel_time))
  baseline = time_points[time_points < end_baseline]
  num_baseline = length(unique(baseline))
  time_points_to_bin = time_points[time_points >= end_baseline]
  num_unique_time_points = length(time_points_to_bin)
#  if(num_unique_time_points%%num_bins==0){
#    bin_vector=c(rep(1,num_baseline), as.numeric(gl(num_bins,num_unique_time_points/num_bins)) +1 )
#    bin_match=as.data.frame(cbind(time_points, bin_vector))
#    colnames(bin_match)=c("rel_time","time_bin")
#  }
#  else {
    extra_points=num_unique_time_points%%num_bins
    bin_vector=c(rep(1,num_baseline), as.numeric(gl(num_bins,(num_unique_time_points-extra_points)/num_bins)) +1 )
    #bin_vector=c(bin_vector,rep(num_bins,extra_points)) # this adds the extra bins to the end.
    extra_bins=sample(num_bins, extra_points) # take random sample of bins
    bin_vector=sort(c(bin_vector, extra_bins)) # add them to the bin_vector
    bin_match=as.data.frame(cbind(time_points, bin_vector))
    colnames(bin_match)=c("rel_time","time_bin")
 # }
  return(bin_match)
}

##################################
### Function MODEL FITTING
##################################

fitonemodel = function (timepoints,Esub, tzero) {
  dt = Esub[Esub$time_bin==timepoints,]
  dt = rbind(tzero,dt)
  if (length(unique(dt$value))>10){ # check if there is any data
    #mod = lme4::lmer(value ~ fac + (1|epoch), data = dt, control = lmerControl(optimizer = "nloptwrap", calc.derivs = FALSE))
    mod = lm(value ~ fac, dt)
  }
}



# Next function thanks to WINVECTOR.
#' Copy arguments into env and re-bind any function's lexical scope to bindTargetEnv .
#' 
#' See http://winvector.github.io/Parallel/PExample.html for example use.
#' 
#' 
#' Used to send data along with a function in situations such as parallel execution 
#' (when the global environment would not be available).  Typically called within 
#' a function that constructs the worker function to pass to the parallel processes
#' (so we have a nice lexical closure to work with).
#' 
#' @param bindTargetEnv environment to bind to
#' @param objNames additional names to lookup in parent environment and bind
#' @param names of functions to NOT rebind the lexical environments of
bindToEnv <- function(bindTargetEnv=parent.frame(),objNames,doNotRebind=c()) {
  # Bind the values into environment
  # and switch any functions to this environment!
  for(var in objNames) {
    val <- get(var,envir=parent.frame())
    if(is.function(val) && (!(var %in% doNotRebind))) {
      # replace function's lexical environment with our target (DANGEROUS)
      environment(val) <- bindTargetEnv
    }
    # assign object to target environment, only after any possible alteration
    assign(var,val,envir=bindTargetEnv)
  }
}