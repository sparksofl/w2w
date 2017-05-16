library('mongolite')
require(quanteda)
c = mongo(collection = "movies", db = "what2watch_development")
df = c$aggregate()

dataset <- df[,c('overview', 'desc', '_id')]
dataset$text <- paste(df$overview,df$desc)
dataset$text <- paste(dataset$text,df$genres)


inaugCorpus <- corpus(dataset)
docnames(inaugCorpus) <- dataset$`_id`
sw <- stopwords("english")
sw <- append(sw, 'film')
myDfm <- dfm(inaugCorpus, verbose = FALSE, remove = sw, stem = TRUE, remove_punct = TRUE)
ts = textstat_simil(myDfm, docnames(myDfm), margin = "documents", method = "cosine")


m <- ts
for (i in 1:NROW(m)) {
    row <- m[,i]
    row = rev(sort(row))
    movieID <- names(row)[1]
    row <- row[2:length(row)]
    row <- row[row >= 0.1]
    ids <- toString(names(row))

    keywords <- toString(colnames(dfm_sort(myDfm[i,])[,1:10]))
    c$update(paste0('{"_id" : { "$oid" : "',movieID,'"}}'), paste0('{"$set":{"similar_ids": "',ids,'"}}'), multiple = TRUE)
    c$update(paste0('{"_id" : { "$oid" : "',movieID,'"}}'), paste0('{"$set":{"keywords_str":"',keywords,'"}}'), multiple = TRUE)
}

rm(c); gc()
