library(tidyverse)
library(ggrepel)
library(readxl)

getData <- function(){
  #data("eurodist", package = "datasets")
  route <- read_excel("Data.xlsx")
  route_distance <<- dist(route[ ,3:4], upper=T, diag=T) %>% as.matrix()
  D <- as.matrix(route_distance)
  return(D)
}


fitnessdistance <- function(x, capacity, demand, distance, ...){
  vehicle_load <- capacity
  visited_spot <- 1
  vehicle_num <- 1
  vehicle_range <- 500
  for (i in x) {
    initial_spot <- i
    if (vehicle_range >= distance[initial_spot] * 2) {
      if (vehicle_load >= demand[initial_spot]) {
        # Go to the spot
        visited_spot <- c(visited_spot, initial_spot)
        vehicle_load <- vehicle_load - demand[ initial_spot ]
        vehicle_range <- vehicle_range - distance[initial_spot]
      } else {
        # Go back to depot & Recharge
        vehicle_load <- capacity
        visited_spot <- c(visited_spot, 1)
        vehicle_num <- vehicle_num + 1
        vehicle_range <- 500
        # Go to the spot 
        visited_spot <- c(visited_spot, initial_spot)
        vehicle_load <- vehicle_load - demand[ initial_spot ]
        vehicle_range <- vehicle_range - distance[initial_spot]
      }		
    }
    else{
      # Go back to depot & Recharge
      vehicle_load <- capacity
      visited_spot <- c(visited_spot, 1)
      vehicle_num <- vehicle_num + 1
      vehicle_range <- 500
      # Go to the spot 
      visited_spot <- c(visited_spot, initial_spot)
      vehicle_load <- vehicle_load - demand[ initial_spot ]
      vehicle_range <- vehicle_range - distance[initial_spot]
      
    }
  }
  visited_spot <- c(visited_spot, 1)
  #total_distance <- embed(visited_spot, 2)[ , 2:1] %>% distance[.] %>% sum()
  #return(-total_distance)
  return(-vehicle_num)
}

fitness_explaindistance <- function(x, capacity, demand, distance, ...){
  
  vehicle_load <- capacity
  visited_spot <- 1
  vehicle_num <- 1
  total_demand <- NULL
  vehicle_range <- 500
  for (i in x) {
    
    initial_spot <- i
    if (vehicle_range >= distance[initial_spot] * 2) {
      if (vehicle_load >= demand[initial_spot]) {
        
        # Go to the spot
        visited_spot <- c(visited_spot, initial_spot)
        vehicle_load <- vehicle_load - demand[ initial_spot ]
        vehicle_range <- vehicle_range - distance[ initial_spot ]
        
      } else {
        
        #total_demand <- c(total_demand, 6 - vehicle_load)
        
        # Go back to depot
        vehicle_load <- capacity
        visited_spot <- c(visited_spot, 1)
        vehicle_num <- vehicle_num + 1
        vehicle_range <- 500
        
        # Go to the spot 
        visited_spot <- c(visited_spot, initial_spot)
        vehicle_load <- vehicle_load - demand[ initial_spot ]
        vehicle_range <- vehicle_range - distance[ initial_spot ]
      }
    }
    else{
      #total_demand <- c(total_demand, 6 - vehicle_load)
      
      # Go back to depot
      vehicle_load <- capacity
      visited_spot <- c(visited_spot, 1)
      vehicle_num <- vehicle_num + 1
      vehicle_range <- 500
      
      # Go to the spot 
      visited_spot <- c(visited_spot, initial_spot)
      vehicle_load <- vehicle_load - demand[ initial_spot ]
      vehicle_range <- vehicle_range - distance[ initial_spot ]
      
    }
    
  }
  
  #total_demand <- c(total_demand, 6 - vehicle_load)
  visited_spot <- c(visited_spot, 1)
  total_distance <- embed(visited_spot, 2)[ , 2:1] %>% distance[.] %>% sum()
  
  #  result <- list(route = visited_spot,
  #                 total_distance = total_distance,
  #                 vehicle_num = vehicle_num,
  #                 total_demand = total_demand)  
  result <- list(route = visited_spot,
                 total_distance = total_distance,
                 vehicle_num = vehicle_num)   
  return(result)
}

findminmax <- function(data, minimise = TRUE){
  minmax <- NA
  if (minimise) minmax <- min(data[,2])
  else minmax <- max(data[,2])
  
  rownum <- which(data[,2] == minmax)
  if (length(rownum) > 1) rownum <- rownum[1]
  
  if (minimise)
    return (minmax - data [rownum,3])
  else return (minmax + data [rownum,3])
}

plotbars<- function(data1, data2, data3, 
                    cap1 = "GA1", cap2 = "GA2", cap3 = "GA3"){
  data = data1
  hues = c("red","blue","green")
  
  min1 = findminmax(data1)   #min(data1) - data1 [which(data1 == min(data1))+2*nrow(data1)]
  min2 = findminmax(data2)   #min(data2) - data2 [which(data2 == min(data2))+nrow(data2)]
  min3 = findminmax(data3)   #min(data3) - data3 [which(data3 == min(data3))+nrow(data3)]
  
  max1 = findminmax(data1, FALSE)   #max(data1) + data1 [which(data1 == max(data1))+nrow(data1)]
  max2 = findminmax(data2, FALSE)   #max(data2) + data2 [which(data2 == max(data2))+nrow(data2)]
  max3 = findminmax(data3, FALSE)   #max(data3) + data3 [which(data3 == max(data3))+nrow(data3)]
  
  minn = min(min1, min2, min3)
  maxx = max(max1, max2, max3)
  
  df <- data.frame(x=data[,1], y=data[,2], dy = data[,3])  #dy = length of error bar
  plot(df$x, df$y, type = "l", col = hues[1],  ylim=c(-31, -34),  #ylim = c(-30, -34),   #choose ylim CAREFULLY as per your data ranges
       main = "Best Fitness Values", xlab = "Generations", ylab = "Number of Vehicles") #  #plot the line (mean values)  
  segments(df$x, df$y - df$dy, df$x, df$y + df$dy, col = hues[1]);    #plot the error bars mean-errorbar, mean+errorbar
  data = data2
  df <- data.frame(x=data[,1], y=data[,2], dy = data[,3])  #dy = length of error bar  
  lines(df$x, df$y, col = hues[2])
  segments(df$x, df$y - df$dy, df$x, df$y + df$dy, col = hues[2]); 
  data = data3
  df <- data.frame(x=data[,1], y=data[,2], dy = data[,3])  #dy = length of error bar  
  lines(df$x, df$y, col = hues[3])
  segments(df$x, df$y - df$dy, df$x, df$y + df$dy, col = hues[3]); 
  
  legend("bottomright", legend = c(cap1, cap2, cap3), col = hues, lwd = 1,
         cex = 0.8)
}