#! /usr/bin/Rscript --vanilla --vanilla -q --slave --no-restore

library(RCurl)
library("XML")

args <- commandArgs(trailingOnly = TRUE)
cdate <- args[1] 
print(cdate)
string <- args[2]
print(string)

workingdir <- "/home/kwfu/WeiboSearch/"

system("export LANG=en_HK.UTF-8")

Sys.setenv(LANG="en_HK.UTF-8")

q <- Sys.setlocale("LC_ALL","en_HK.UTF-8")

cookieFILE <- paste(workingdir,"cookies.txt",sep="")

CALL <- function(LINK){
	a <- getURL(LINK,.encoding="UTF-8", cookiefile = cookieFILE, curl=curl)
	a_parsed <- htmlParse(a)

	Search_str1 <- function(str,ap){
		 re <- gregexpr(str,ap)
		 lapply(1:length(re[[1]]), function(i){
			return(substring(ap,re[[1]][i],(re[[1]][i]+attr(re[[1]],"match.length")[i]-1)))
	 	})
	}

	ap.mid <- getNodeSet(a_parsed, "//div[@class='card item_weibo']/@action-data")
	ap.time <- getNodeSet(a_parsed, "//div[@class='card item_weibo']//div[@class='content']/p[@class='time']/span[1]",,xmlValue)
	ap.name <- getNodeSet(a_parsed, "//div[@class='card item_weibo']//div[@class='content']/p[@class='tit_m']",,xmlValue)
	s_result <- Search_str1('<p>.+?<p class="s_reply">|<p>.+?<div class="feeds clearfix">',a)
	ap.text <- do.call(rbind,lapply(s_result, function(i) {getNodeSet(htmlParse(i,encoding='UTF-8'),"//p[1][not(@*)]",,xmlValue)}))
	all <- cbind(ap.mid,ap.time,gsub('\n','',ap.name),gsub(',',' ',ap.text))
	currenttime <- system('date +"%Y%m%d-%H%M"',intern = TRUE)
	all <- cbind(all,rep(currenttime,nrow(all)))
	return(all)
}

curl <- getCurlHandle()
agent="Mozilla/5.0 (Linux; Android 4.1.1; Nexus 7 Build/JRO03D) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Safari/535.19"
curl_opt <- curlSetOpt(cookiejar=cookieFILE,  useragent = agent, followlocation = TRUE, curl=curl) 

output<-c()

ue_string <- gsub('%','%25',URLencode(string))
for (i in 0:23){
        wdate <- strptime(cdate,"%Y-%m-%d") + 60*60*i
        date <- format(wdate,"%Y-%m-%d")
        h <- format(wdate,"%H")
        date1 <- format(wdate+3600,"%Y-%m-%d")
        h1 <- format((wdate+60*60),"%H")
	for (page in 1:50){
		LINK <- paste("http://s.weibo.com/wb/",ue_string,"&xsort=time&timescope=custom:",date,"-",h,":",date,"-",h,"&page=",page,"&nodup=1",sep="")
		re <- NULL
		attempt <- 1
		while( is.null(re) && attempt <= 3 ) {
			  attempt <- attempt + 1
			  try(
			    re <- CALL(LINK)
			  , silent = TRUE)
		} 
		Sys.sleep(3)
		if (!is.null(re)){
			output <- rbind(output,re)
			print(paste("Hour:",i,"Page:",page,"Date:",date,"# of weibos:",nrow(re),sep=","))
		} else {
			break
		}		
	}
}

currenttime <- system('date +"%Y%m%d-%H%M"',intern = TRUE)
file_na <- paste(workingdir,"weibo_ROUNDCLOCK.",cdate,".txt",sep="")
write.csv(output,file=file_na)
