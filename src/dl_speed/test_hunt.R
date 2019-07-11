
# Libraries, need to be installed

library("dplyr")
library("ggforce")
library("ggplot2")


# Load log of sftp

logDF <- read.table("docs/dl_speed/log.txt", header = F, stringsAsFactors = F)


# Convert units

timeDF <- logDF[, c(3,4)]
names(timeDF) <- c("size", "speed")

for (i in 1:nrow(timeDF)) {
  
  size <- timeDF[i, 1]
  sizeLength <- nchar(size)
  
  if (substr(x = size, start = sizeLength, stop = sizeLength) == 'B') {
    
    scale <- substr(x = size, start = sizeLength - 1, stop = sizeLength - 1)
    
    if (scale == 'K') {
      
      timeDF[i, 1] <- 1024 * as.numeric(substr(x = size, start = 1, stop = sizeLength - 2))
      
    } else if (scale == 'M') {
      
      timeDF[i, 1] <- 1024 * 1024 * as.numeric(substr(x = size, start = 1, stop = sizeLength - 2))
      
    } else {
      
      stop("Unit not supported")
      
    }
  }
  
  speed <- timeDF[i, 2]
  speedLength <- nchar(speed)
  
  if (substr(x = speed, start = speedLength - 2, stop = speedLength) == 'B/s') {
    
    scale <- substr(x = speed, start = speedLength - 3, stop = speedLength - 3)
    
    if (scale == 'K') {
      
      timeDF[i, 2] <- 1024 * as.numeric(substr(x = speed, start = 1, stop = speedLength - 4))
      
    } else if (scale == 'M') {
      
      timeDF[i, 2] <- 1024 * 1024 * as.numeric(substr(x = speed, start = 1, stop = speedLength - 4))
      
    } else {
      
      stop("Unit not supported")
      
    }
  
  } else {
    
    stop("No speed unit")
    
  }
}


# Filter null speed, format as numeric, and take the log

timeDF %>% 
  filter(
    speed > 0
  ) %>%
  mutate(
    size = as.numeric(size),
    speed = as.numeric(speed),
    sizeLog = log10(size),
    speedLog = log10(speed)
  ) -> timeDF


# Plot speed vs size

plot <- ggplot() + theme_bw(base_size = 16) +
  geom_point(data = timeDF, mapping = aes(x = sizeLog, y = speedLog)) +
  scale_x_continuous(name = "File Size [log10]", breaks = c(0, 3, 6, 9), minor_breaks = c(0:9), labels = c("B", "KB", "MB", "GB"), limits = c(0, 9)) +
  scale_y_continuous(name = "Download Speed [log10]", breaks = c(0, 3, 6, 9), minor_breaks = c(0:9), labels = c("B/s", "KB/s", "MB/s", "GB/s"), limits = c(0, 9)) +
  ggtitle(paste("n =", nrow(timeDF))) + 
  theme(plot.title = element_text(hjust = 1))

png("docs/dl_speed/speed_size.png", height = 600, width = 800)
plot(plot)
dummy <- dev.off()


# Select size > 1MB

speedDF <- timeDF %>%
  filter(
    size > 1024 * 1024
  )


# Get quantiles

speedQuantiles <- quantile(speedDF$speed, probs = c(0.05, 0.25, 0.5, 0.75, 0.95))
speedLabels <- paste(round(speedQuantiles / 1024 ^ 2, 1), "MB/s", paste0("(", names(speedQuantiles), ")"))
annotationDF <- data.frame(
  y = log10(speedQuantiles),
  label = speedLabels,
  stringsAsFactors = F
)


# Plot speed distribution

plot <- ggplot() + theme_bw(base_size = 16) +
  geom_sina(data = speedDF, mapping = aes(x = 0, y = speedLog)) +
  geom_violin(data = speedDF, mapping = aes(x = 0, y = speedLog), alpha = 0.5) +
  geom_segment(data = annotationDF, mapping = aes(x = 0, xend = 0.55, y = y, yend = y), col = "blue3", linetype = "dashed") +
  geom_text(data = annotationDF, mapping = aes(x = 0.6, y = y, label = label), col = "blue3", hjust = 0, size = 5) +
  geom_boxplot(data = speedDF, mapping = aes(x = 0, y = speedLog), outlier.shape = NULL, width = 0.25, alpha = 0.5) +
  scale_x_continuous(breaks = 0, limits = c(-0.5, 1.1)) +
  scale_y_continuous(name = "Download Speed [log10]", breaks = c(5, 6, 7), minor_breaks = c(5:7), labels = c("100 KB/s", "1 MB/s", "10 MB/s"), limits = c(5, 7)) +
  ggtitle(paste("Size > 1MB, n =", nrow(speedDF))) +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    plot.title = element_text(hjust = 1)
  )

png("docs/dl_speed/speed.png", height = 800, width = 600)
plot(plot)
dummy <- dev.off()

