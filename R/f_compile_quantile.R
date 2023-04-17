library(quantreg)

# Function f_compile_quantile
# Input : 
#   - qt_trgt : vector, dim k, of k quantiles for different qt-estimations (k>=4)
#   - v_dep : vector of the dependent variable
#   - v_expl : vector of the explanatory variable(s)
#   - t_trgt : time target (optional)
#
# Output : 
# matrix with the predicted values based on each quantile regression, at time fixed in input
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
f_compile_quantile <- function(qt_trgt, v_dep, v_expl, t_trgt){
  
  # number of quantile regressions (for k quantile regressions)
  nb_qt <- length(qt_trgt)
  
  # initialization of matrix results
  results_qt <- matrix(data=0, ncol=2, nrow=nb_qt)
  
  # loop on each quantile regression
  for (ct_qt in 1:nb_qt){
    
    
    reg_qt <- rq(v_dep ~ cbind(v_expl), tau=qt_trgt[ct_qt]) # quantile regression
    pred_qt <- predict(reg_qt, newdata=as.data.frame(v_expl)) # prediction
    
    # store the value that corresponds to t_trgt, time target
    if(missing(t_trgt)){
      results_qt[ct_qt,2] <- pred_qt[length(pred_qt)] 
    }else{
      results_qt[ct_qt,2] <- pred_qt[t_trgt]
    }
    
  }
  results_qt[,1] <- qt_trgt
  return(results_qt)
}
