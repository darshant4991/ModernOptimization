library(GA)
#This function is used by the GA to compute or report the statistics of your interest after every generation.
#This function overrides the default functionality provided by gaMonitor().
monitor <- function(obj){
  # gaMonitor(obj)                      #call the default gaMonitor to print the usual messages during evolution
  iter <- obj@iter                      #get the current iternation/generation number 
  if (iter <= maxGenerations){          #some error checking
    fitness <- obj@fitness              #get the array of all the fitness values in the present population
    #<<- assigns a value to the global variable declared outside the scope of this function.    
    thisRunResults[iter,1] <<- max(fitness)
    thisRunResults[iter,2] <<- mean(fitness)    
    thisRunResults[iter,3] <<- median(fitness)
    cat(paste("\rGA | generation =", obj@iter, "Mean =", thisRunResults[iter,2], "| Best =", thisRunResults[iter,1], "\n"))
    flush.console()
  }  
  else{                               #print error messages
    cat("ERROR: iter = ", iter, "exceeds maxGenerations = ", maxGenerations, ".\n")
    cat("Ensure maxGenerations == nrow(thisRunResults)")
  }
}

runGATRY <- function(noRuns = 30, problem = "feature"){
  #Specify GA parameter values; using the default values below. 
  if (problem == "tspcx"){
    maxGenerations <<- 300
    popSize = 16
    pcrossover = 0.2
    pmutation = 0.3
    run1 <<- 300
    type = "permutation"
    data = getData()
    lower = 1                             #minimum is city indexed 1
    upper = nrow(getData())               #maximum is the number of cities in the data set
    fitness = fitnessdistance                #fitness function defined in TSP.R
  }
  else if (problem == "tsppmx"){
    maxGenerations <<- 300
    popSize = 16
    pcrossover = 0.2
    pmutation = 0.3
    run1 <<- 300
    type = "permutation"
    data = getData()
    lower = 1                             #minimum is city indexed 1
    upper = nrow(getData())               #maximum is the number of cities in the data set
    fitness = fitnessdistance                #fitness function defined in TSP.R
  }
  else if (problem == "tspox"){
    maxGenerations <<- 300
    popSize = 16
    pcrossover = 0.2
    pmutation = 0.3
    run1 <<- 300
    type = "permutation"
    data = getData()
    lower = 1                             #minimum is city indexed 1
    upper = nrow(getData())               #maximum is the number of cities in the data set
    fitness = fitnessdistance                #fitness function defined in TSP.R
  }
  else {
    cat("invalid problem specified. Exiting ... \n")
    return()
  }
  
  
  #Set up what stats you wish to note.    
  statnames = c("best", "mean", "median")
  thisRunResults <<- matrix(nrow=maxGenerations, ncol = length(statnames)) #stats of a single run
  resultsMatrix = matrix(1:maxGenerations, ncol = 1)  #stats of all the runs
  #route_distance <- dist(route[ , 3:4], upper = T, diag = T) %>% as.matrix(labels=TRUE)
  resultNames = character(length(statnames)*noRuns)
  resultNames[1] = "Generation"
  route <- read_excel("data.xlsx")
  bestFitness <<- -Inf
  bestSolution <<- NULL
  for (i in 1:noRuns){
    cat(paste("Starting Run ", i, "\n"))
    if (problem == "tspcx")
      GA <- ga(type = "permutation", fitness = fitness,  capacity = 6, demand = route$demand,
               distMatrix = data, distance = data, lower = lower, upper = max(route$node),mutation = gaperm_swMutation, popSize = popSize, maxiter = maxGenerations,
               monitor = monitor, run = run1, crossover=gaperm_cxCrossover, pmutation = pmutation,  seed = i, replace = TRUE)
    else if (problem == "tsppmx")
      GA <- ga(type = "permutation", fitness = fitness,  capacity = 6, demand = route$demand,
               distMatrix = data, distance = data, lower = lower, upper = max(route$node),mutation = gaperm_swMutation, popSize = popSize, maxiter = maxGenerations,
               monitor = monitor, run = run1, crossover=gaperm_pmxCrossover, pmutation = pmutation,  seed = i, replace = TRUE)
    else if (problem == "tspox")
      GA <- ga(type = "permutation", fitness = fitness,  capacity = 6, demand = route$demand,
               distMatrix = data, distance = data, lower = lower, upper = max(route$node),mutation = gaperm_swMutation, popSize = popSize, maxiter = maxGenerations,
               monitor = monitor, run = run1, crossover=gaperm_oxCrossover, pmutation = pmutation,  seed = i, replace = TRUE)
    
    resultsMatrix = cbind(resultsMatrix, thisRunResults)
    
    if (GA@fitnessValue > bestFitness){
      bestFitness <<- GA@fitnessValue
      bestSolution <<- GA@solution
    }
    #Create column names for the resultsMatrix
    for (j in 1:length(statnames)) resultNames[1+(i-1)*length(statnames)+j] = paste(statnames[j],i)
  }
  colnames(resultsMatrix) = resultNames
  return (resultsMatrix)
}

getBestFitness<-function(){
  return(bestFitness)
}


getBestSolution<-function(){
  return(bestSolution)
}

StartOperation <- function(){
  ga1 <- runGATRY(problem = "tspcx")
  ga2 <- runGATRY(problem = "tsppmx")
  ga3 <- runGATRY(problem = "tspox")
  p1 <- parseData(ga1, 2 , 300)
  p2 <- parseData(ga2, 2 , 300)
  p3 <- parseData(ga3, 2 , 300)
  plotbars(p1,p2,p3,cap1 = "Cycle Crossover", cap2 = "Partially Mapped Crossover", cap3 = "Order Crossover")
  
}