library('mongolite')
library('phrasemachine')
require(quanteda)
c = mongo(collection = "movies", db = "what2watch_development")
df = c$aggregate()

dataset <- df[,c('overview', 'desc', '_id')]
#dataset$text <- paste(df$overview,df$desc)
#dataset$text <- paste(df$processed_text,df$genres)
dataset$text <- df$processed_text

# for (i in 1:NROW(dataset$text)) {
#   dataset$text[i] <- gsub("\\b[A-Z][^ ]*(\\s+)?", "", dataset$text[i])
#   phrases <- phrasemachine(dataset$text[i],
#                            minimum_ngram_length = 1,
#                            maximum_ngram_length = 3,
#                            return_phrase_vectors = TRUE,
#                            return_tag_sequences = TRUE)
#   dataset$text[i] <- toString(phrases[[1]]$phrases)
# }


inaugCorpus <- corpus(dataset)
docnames(inaugCorpus) <- dataset$`_id`
sw <- stopwords("english")

custom_stopwords <- c('film', '-', '—', 'na', 'world', 'find', 'one', 'will', 'becom', 'live', 'released',
'get', 'movi', 'also', 'allow', 'million', 'best', 'make', 'new', 'paramount', 'release', 'became', "a", "about", "above", "above", "across", "after",
"afterwards", "again", "against", "all", "almost", "alone", "along", "already", "also","although","always","am","among", "amongst", "amoungst", "amount",
"an", "and", "another", "any","anyhow","anyone","anything","anyway", "anywhere", "are", "around", "as",  "at", "back","be","became", "because","become",
"becomes", "becoming", "been", "before", "beforehand", "behind", "being", "below", "beside", "besides", "between", "beyond", "bill", "both", "bottom","but",
"by", "call", "can", "cannot", "cant", "co", "con", "could", "couldnt", "cry", "de", "describe", "detail", "do", "done", "down", "due", "during", "each",
"eg", "eight", "either", "eleven","else", "elsewhere", "empty", "enough", "etc", "even", "ever", "every", "everyone", "everything", "everywhere", "except",
"few", "fifteen", "fify", "fill", "find", "fire", "first", "five", "for", "former", "formerly", "forty", "found", "four", "from", "front", "full", "further",
"get", "give", "go", "had", "has", "hasnt", "have", "he", "hence", "her", "here", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "him",
"himself", "his", "how", "however", "hundred", "ie", "if", "in", "inc", "indeed", "interest", "into", "is", "it", "its", "itself", "keep", "last", "latter",
"latterly", "least", "less", "ltd", "made", "many", "may", "me", "meanwhile", "might", "mill", "mine", "more", "moreover", "most", "mostly", "move", "much",
"must", "my", "myself", "name", "namely", "neither", "never", "nevertheless", "next", "nine", "no", "nobody", "none", "noone", "nor", "not", "nothing", "now",
"nowhere", "of", "off", "often", "on", "once", "one", "only", "onto", "or", "other", "others", "otherwise", "our", "ours", "ourselves", "out", "over", "own",
"part", "per", "perhaps", "please", "put", "rather", "re", "same", "see", "seem", "seemed", "seeming", "seems", "serious", "several", "she", "should", "show",
"side", "since", "sincere", "six", "sixty", "so", "some", "somehow", "someone", "something", "sometime", "sometimes", "somewhere", "still", "such", "system",
"take", "ten", "than", "that", "the", "their", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "therefore", "therein", "thereupon",
"these", "they", "thickv", "thin", "third", "this", "those", "though", "three", "through", "throughout", "thru", "thus", "to", "together", "too", "top",
"toward", "towards", "twelve", "twenty", "two", "un", "under", "until", "up", "upon", "us", "very", "via", "was", "we", "well", "were", "what", "whatever",
"when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "wh.ither", "who",
"whoever", "whole", "whom", "whose", "why", "will", "with", "within", "without", "would", "yet", "you", "your", "yours", "yourself", "yourselves", "the")
sw <- c(sw,custom_stopwords)
myDfm <- dfm(inaugCorpus, verbose = FALSE, remove = sw, stem = TRUE, remove_punct = TRUE, remove_numbers = TRUE, tolower = TRUE, select = ".{3,}")
ts = textstat_simil(myDfm, docnames(myDfm), margin = "documents", method = "cosine")


m <- ts
for (i in 1:NROW(m)) {
    row <- m[,i]
    row <- rev(sort(row))
    movieID <- names(row)[1]
    row <- row[2:length(row)]
    row <- row[row >= 0.2]
    ids <- toString(names(row))

    keywords <- toString(colnames(dfm_sort(myDfm[i,])[,1:10]))
    c$update(paste0('{"_id" : { "$oid" : "',movieID,'"}}'), paste0('{"$set":{"similar_ids": "',ids,'"}}'), multiple = TRUE)
    c$update(paste0('{"_id" : { "$oid" : "',movieID,'"}}'), paste0('{"$set":{"keywords_str":"',keywords,'"}}'), multiple = TRUE)
    #c$update(paste0('{"_id" : { "$oid" : "',movieID,'"}}'), paste0('{"$set":{"processed_text":"',gsub("\"", "", dataset[i,]$text),'"}}'), multiple = TRUE)
}

rm(c); gc()
