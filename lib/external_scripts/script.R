library('mongolite')
require(quanteda)
c = mongo(collection = "movies", db = "what2watch_development")
df = c$aggregate()

dataset <- df[,c('overview', '_id')]
names(dataset)[names(dataset)=="overview"] <- "text"


inaugCorpus <- corpus(dataset)
docnames(inaugCorpus) <- dataset$`_id`
myDfm <- dfm(inaugCorpus, verbose = FALSE, remove = stopwords("english"), stem = TRUE, remove_punct = TRUE)
ts = textstat_simil(myDfm, docnames(myDfm), margin = "documents", method = "cosine")


m <- ts
for (i in 1:NROW(m)) {
    row <- m[,i]
    row = rev(sort(row))
    movieID <- names(row)[1]
    row <- row[2:length(row)]
    row <- row[row >= 0.05]
    ids <- toString(names(row))

    c$update(paste0('{"_id" : { "$oid" : "',movieID,'"}}'), paste0('{"$set":{"similar_ids": "',ids,'"}}'), multiple = TRUE)
}

rm(mongo); gc()