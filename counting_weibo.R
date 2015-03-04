#! /usr/bin/Rscript --vanilla --vanilla -q --slave --no-restore

library(RCurl)
library("XML")

args <- commandArgs(trailingOnly = TRUE)
cdate <- args[1] 
#print(cdate)
string <- args[2]
#print(string)

workingdir <- "/home/kwfu/WeiboSearch/"

system("export LANG=en_HK.UTF-8")

Sys.setenv(LANG="en_HK.UTF-8")

q <- Sys.setlocale("LC_ALL","en_HK.UTF-8")

cookieFILE <- paste(workingdir,"cookies.txt",sep="")

output<-c()

ue_string <- gsub('%','%25',URLencode(string))
i <- 0
wdate <- strptime(cdate,"%Y-%m-%d") + 60*60*i
date <- format(wdate,"%Y-%m-%d")
h <- 0
date1 <- format(wdate+3600,"%Y-%m-%d")
h1 <- 23
page <- 1
LINK <- paste("http://s.weibo.com/wb/",ue_string,"&xsort=time&timescope=custom:",date,"-",h,":",date,"-",h1,"&page=",page,"&nodup=1",sep="")
re <- NULL
attempt <- 1
while( is.null(re) && attempt <= 3 ) {
	  attempt <- attempt + 1
#	  try(
		curl <- getCurlHandle()
		agent="Mozilla/5.0 (Linux; Android 4.1.1; Nexus 7 Build/JRO03D) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Safari/535.19"
		curl_opt <- curlSetOpt(cookiejar=cookieFILE,  useragent = agent, followlocation = TRUE, curl=curl) 
		a <- getURL(LINK,.encoding="UTF-8", cookiefile = cookieFILE, curl=curl)
		a_parsed <- htmlParse(a, asText=TRUE)
		plain.text <- xpathSApply(a_parsed, "//div", xmlValue)
		result <- '条相关微博'
		if (length(plain.text)!=0){
			pt_sp <- strsplit(plain.text,'\n')
			re <- grep(result,pt_sp[[1]],value=TRUE)
		}
#	  )
} 
if (length(re)!=0){
	print(paste(cdate,string,re[length(re)],sep=","))
} else {
	print("Error. Nothing is found.")
}
#save.image("./tmp.RData")
