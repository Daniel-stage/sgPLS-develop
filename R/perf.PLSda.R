# performance assessment for PLS
perf.PLS <- function(object, K=nrow(object$X), ncomp = object$ncomp){
  
  X <- object$X
  Y <- object$Y
  n <- nrow(X)
  p <- ncol(X)

  # conditions check-up
  if(!("pls" %in% class(object)) && class(object) != "mixo_pls"){ stop("object class must either contain pls class or be mixo_pls class."); print(class(object))}
  
  if(ncomp.max > object$ncomp || ncomp.max <= 0){ stop(paste("ncomp.max must be set up between 0 and",object$ncomp,"which is the total number of components computed in the object model."))}

  if(K < 2 || K > n){ stop(paste("K must be a value between 2 and",n))}
  
  # prediction analysis
  err <- matrix(NA, nrow = K, ncol = ncomp)
  
  b <- floor(n/K) # block size
  ind <- sample(n)

  for(k in seq_len(K)){
    
    # bloc definition
    ind.beg <- (k-1) * b + 1 # block k beginning
    ind.end <- k * b # block k end
    ind.test <- ind[ind.beg:ind.end]
    nk <- length(ind.test)
    X.train <- X[-ind.test,]
    Y.train <- Y[-ind.test,]
    X.test <- X[ind.test,]
    Y.test <- Y[ind.test,]
    modele <- PLS(X = X.train, Y = Y.train, ncomp = ncomp, mode = "regression")  
    
    for(h in 1:ncomp){  
      
      # predictions
      pred <- predict.PLS(modele, newdata = X.test)$predict[,,h]
      err[k,h] <- sum(colSums(as.matrix((Y.test - pred)^2)))
      
    }
  }
  
  err.moy <- colSums(err)/b/K
  
  h.best <- min(which.min(err.moy))
  plot(err.moy, col="blue", pch = 16, type = "b", main = "MSEP of the model", xlab = "number of components", ylab = "MSEP")
  
  return(setNames(list(err.moy,h.best),c("MSEP","h.best")))
}


# performance assessment for PLSda
perf.PLSda <- function(object, K=nrow(object$X), ncomp = object$ncomp, method = "max.dist"){
  
  X <- object$X
  Y <- map(object$Y)
  n <- nrow(X)
  p <- ncol(X)
  
  if(method == "max.dist"){dist=1}else if(method == "centroids.dist"){dist=2}else{dist=3}
  
  # prediction analysis
  err <- matrix(NA, nrow = K, ncol = ncomp)
  
  b <- floor(n/K) # block size
  ind <- sample(n)
  
  for(k in seq_len(K)){
      
    # bloc definition
    ind.beg <- (k-1) * b + 1 # block k beginning
    ind.end <- k * b # block k end
    ind.test <- ind[ind.beg:ind.end]
    X.train <- X[-ind.test,]
    Y.train <- Y[-ind.test]
    X.test <- X[ind.test,]
    Y.test <- Y[ind.test]
      
    for(h in 1:ncomp){
      # model created
      modele <- PLSda(X = X.train,Y = Y.train, ncomp = h)
      pred <- predict.PLSda(modele, newdata = X.test, methode = methode)$class[[dist]]
      equal <- Y.test == pred[,h]
      err[k,h] <- sum(1-equal)
      
    }
  }
  
  err.moy <- colSums(err)/b/K
  
  h.best <- min(which.min(err.moy))
  plot(err.moy, col="blue", pch = 16, type = "b", main = "Error rate of the model", xlab = "number of components", ylab = "Error")
  
  return(setNames(list(err.moy,h.best),c("error.rate","h.best")))
}
