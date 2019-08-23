
library(ggplot2)

values <- rnorm(10000000)

ns <- c()
is <- c()
meanEstimate <- c()
sdEstimate <- c()
estimator <- c()

k <- 1

for (n in 3^(1:10)) {
  
  for (i in 1:1000) {
    
    sampled <- c(sample(values, n, replace = T), rep(10, 10))
    
    ns[k] <- n
    is[k] <- i
    meanEstimate[k] <- mean(sampled)
    sdEstimate[k] <- sd(sampled)
    estimator[k] <- "Normal"
    
    k <- k + 1
    
    ns[k] <- n
    is[k] <- i
    meanEstimate[k] <- median(sampled)
    sdEstimate[k] <- (quantile(sampled, probs = pnorm(1)) - quantile(sampled, probs = pnorm(-1)))/2
    estimator[k] <- "Robust"
    
    k <- k + 1
    
  }
}

result <- data.frame(
  n = as.factor(ns),
  i = as.factor(is),
  mean = meanEstimate,
  sd = sdEstimate,
  estimator = estimator,
  stringsAsFactors = F
)

meanPlot <- ggplot() + theme_bw() +
  geom_violin(data = result, mapping = aes(x = n, y = mean, col = estimator, fill = estimator), alpha = 0.8)
meanPlot

sdPlot <- ggplot() + theme_bw() +
  geom_violin(data = result, mapping = aes(x = n, y = sd, col = estimator, fill = estimator), alpha = 0.8)
sdPlot



