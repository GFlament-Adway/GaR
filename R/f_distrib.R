library(sn)
# type_function : "gaussian", "skew-t" or ...
# compile_qt : matrix that contains different quantiles and values 
# starting_values : initial values for optim function

f_distrib <- function(type_function, compile_qt, starting_values){
  
  # for a gaussian funci
  if(type_function=="gaussian"){
    
    
    # error management
    error_results <- FALSE
    if (length(starting_values)!=2 && is.matrix(compile_qt)==FALSE){
      error_results <- TRUE
      error_msg <- "ERROR : for a gaussian function, starting_values has to be of dimension 2 and compile_qt has to be a matrix"
    }else if(length(starting_values)!=2){
      error_results <- TRUE
      if(nrow(compile_qt)<2){
        error_msg <- "ERROR : for a gaussian function, starting_values has to be of dimension 2 and compile_qt has to be a matrix with a minimum of 2 rows"
      }else{
        error_msg <- "ERROR : for a gaussian function, starting_values has to be of dimension 2"
      }
    }else if(is.matrix(compile_qt)==FALSE){
      error_results <- TRUE
      error_msg <- "ERROR : compile_qt has to be a matrix"
    }else if(nrow(compile_qt)<2){
      error_results <- TRUE
      error_msg <- "ERROR : compile_qt has to be a matrix with a minimum of 2 rows"
    }else{
      # objective function
      f_objective <- function(X, par){
        # initialization
        sum <- 0
        
        # Loop on each elements of X
        for (compteur in 1:nrow(X)){
          sum <- sum + (qnorm(X[compteur,1], mean=par[1], sd=par[2]) - X[compteur,2])^2
        }
        return(sum)
      }
      # optimization
      param <-nmkb(par=starting_values, fn=f_objective,
                   lower=c(-Inf,0),
                   upper=c(+Inf, +Inf), X=compile_qt)
    }
    
    results <- data.frame("mean"=param$par[1], "sd"=param$par[2])
    
  # for a skew-t function
  }else if(type_function=="skew-t"){
    
    # error management
    error_results <- FALSE
    if (length(starting_values)!=4 && is.matrix(compile_qt)==FALSE){
      error_results <- TRUE
      error_msg <- "ERROR : for a gaussian function, starting_values has to be of dimension 4 and compile_qt has to be a matrix"
    }else if(length(starting_values)!=4){
      error_results <- TRUE
      if(nrow(compile_qt)<2){
        error_msg <- "ERROR : for a gaussian function, starting_values has to be of dimension 4 and compile_qt has to be a matrix with a minimum of 4 rows"
      }else{
        error_msg <- "ERROR : for a gaussian function, starting_values has to be of dimension 4"
      }
    }else if(is.matrix(compile_qt)==FALSE){
      error_results <- TRUE
      error_msg <- "ERROR : compile_qt has to be a matrix"
    }else if(nrow(compile_qt)<4){
      error_results <- TRUE
      error_msg <- "ERROR : compile_qt has to be a matrix with a minimum of 4 rows"
    }else{
      # objective function
      f_objective <- function(X, par){
        # initialization
        sum <- 0
        # Loop on each elements of X
        for (compteur in 1:nrow(X)){
          sum <- sum + (qst(X[compteur,1], xi=par[1], omega=par[2], alpha=par[3], nu=par[4], tol=1e-08, method=0) - X[compteur,2])^2
        }
        return(sum)
      }
    # optimization
    param <-nmkb(par=starting_values, fn=f_objective,
               lower=c(-Inf,10e-6, -1, 10e-6),
               upper=c(+Inf, +Inf, 1, +Inf), X=results_quantile_reg)
    }
  results <- data.frame("xi"=param$par[1], "omega"=param$par[2], "alpha"=param$par[3], "nu"=param$par[4])
  }else{
    
  }
  
  if(error_results==TRUE){
    return(error_msg)
  }else{
    return(results)
  }
}
