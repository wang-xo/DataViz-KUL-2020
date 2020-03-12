library(ca)
library(tidyverse)

file <- readLines("../../mxm_dataset_test.txt/mxm_dataset_test.txt")

#load top word list
topwords <- str_split(file[18], ",")
topwords <- as.character(topwords[[1]][-1])

#load song and feature for the first 100
data <- list()
for (i in 19:118) {
  serial <- str_split(file[i], ",")
  ID <- serial[[1]][1]
  words <- double()
  cnt <- double()
  wordlist <- double()
  for (pair in serial[[1]][-(1:2)]) {
    word <- as.numeric(str_split(pair, ":")[[1]][1])
    count <- str_split(pair, ":")[[1]][2]
    words <- c(words, topwords[word])
    cnt <- c(cnt, count)
    wordlist <- data.frame(cnt, row.names = words)
  }
  data[ID] <- list(wordlist)
}



# ---load feature list
#(features <- read_types("features.txt"))
#(features <- as_types(features,
#                      remove_duplicates = TRUE))
features <- unique(unlist(read.table(file="features.txt")))

d <- data.frame(row.names = features)

#match features in song to feature vector
for (ID in names(data)){
  cv <- numeric()
  for (name in row.names(d)) {
    if (is.na(data[ID][[1]][name,])) {
      cv <- c(cv, 0)
    } else {
      cv <- c(cv, as.numeric(data[ID][[1]][name,]))
    }
  }
  d[[ID]] <- cv
}


#load genre mapping
genre <- read.table(file="../../Songs_genre/msd-topMAGD-genreAssignment.cls.txt", sep = "\t", row.names = 1)

#ca analysis and visualization
d <- t(as.matrix(d))
d <- d[rowSums(d) > 0, colSums(d) > 0, drop = FALSE]


(d_ca <- ca(d))
summary(d_ca)

text_coord <- d_ca$rowcoord %*% diag(d_ca$sv)
feat_coord <- d_ca$colcoord %*% diag(d_ca$sv)

feats_df <- tibble(
  feat = colnames(d),
  x = feat_coord[,20],
  y = feat_coord[,21])
texts_df <- tibble(
  text = rownames(d),
  genre = genre[rownames(d),],
  x = text_coord[,20],
  y = text_coord[,21])

ggplot() +
  geom_text(data = feats_df,
            mapping = aes(x = x, y = y, label = feat),
            col = "gray") +
  geom_point(data = texts_df,
             mapping = aes(x = x, y = y, col = genre))


#data[row.names(!is.na(genre))]