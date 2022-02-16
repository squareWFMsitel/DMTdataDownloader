library(KeyboardSimulator)
library(dplyr)
library(purrr)
library(tcltk)

setwd("~/WFM SQUARE Files/R files/DMTdataDownloader")

# Data import
agents <- read.csv(url("https://raw.githubusercontent.com/squareWFMsitel/AbsenteeismReports/main/Data/bpoemails.csv"))
emails <- agents$Email.Addresses

# Open the URL
browseURL("https://squarecc-us-prod-v1.awsapps.com/connect/historical-metrics/agent-activity-audit")

Year = 2022
Month = "02"
dateStart = 1
dateEnd = 2

DateRange = c("01","02","03","04","05","06","07","08","09",10:31)
DateRange = DateRange[dateStart:dateEnd]

# Check if ready

msgBox <- tkmessageBox(title = "Hello WFM",
                       message = "Are you Ready?", icon = "info", type = "ok")





# time zone setting
mouse.move(2690,414)
mouse.click(button = "left")
Sys.sleep(0.5)
keybd.type_string("Europe/Warsaw")
Sys.sleep(1)
mouse.move(2699,475)
mouse.click(button = "left")

# for (n in 201:length(emails)-16) #length(emails)
for (n in 1:2) # test
{
  # Agent Login
  mouse.move(2061,338)
  mouse.click(button = "left")
  Sys.sleep(0.5)
  
  mouse.move(2061,367)
  mouse.click(button = "left")
  
  Sys.sleep(0.5)
  keybd.type_string(emails[n])
  Sys.sleep(1.5)
  mouse.move(2102,399)
  mouse.click(button = "left")
  
  for (date in DateRange)
  {
    #Date
    mouse.move(2063,416)
    mouse.click(button = "left")
    Sys.sleep(0.5)
    mouse.click(button = "left")
    keybd.press('ctrl+a')
    Sys.sleep(0.5)
    keybd.press('del')
    Sys.sleep(0.5)
    keybd.type_string(paste0(Year,"-",Month,"-",date))
    mouse.move(2446,450)
    mouse.click(button = "left")
    Sys.sleep(0.5)
    
    # Generate
    mouse.move(2077,473)
    mouse.click(button = "left")
    Sys.sleep(2)
    
    # Download
    mouse.move(4351,310)
    mouse.click(button = "left")
    Sys.sleep(2)
    
  }
  # compile to one file and save
  filenames <- list.files(path="Data/file_downloads",
                          full.names=TRUE,
                          pattern = "^Agent Audit Report.*.csv$")
  
  #read the files in as plaintext
  csv_list <- lapply(filenames , readLines)
  
  #remove the header from all but the first file
  csv_list[-1] <- sapply(csv_list[-1], "[", 2)
  
  #unlist to create a character vector
  csv_list <- unlist(csv_list)
  
  #write the csv as one single file
  write.csv(csv_list,file = paste0("Data/dmt_data_output/",sub("\\-.*", "", emails[n]),".csv"),row.names = F)

  # delete individual files
  unlink(filenames)
}
# compile to final file
files <- list.files(path="Data/dmt_data_output",
                        full.names=TRUE,
                        pattern = "*.csv$")

FinalData <- map_df(files, ~read.csv(.x, sep =",") %>% mutate(File = basename(.x)))

# delete individual files
unlink(files)

library(splitstackshape)
FinalData <- cSplit(FinalData,"x","\"")[,c(1,3,5)]
colnames(FinalData) <- c("Agent","DateTime","Status")
FinalData$Agent <- sub("\\..*", "", FinalData$Agent)
write.csv(FinalData,file = "Data/finalDMTdata/FinalData2.csv",row.names = F)

# Final Message
msgBox2 <- tkmessageBox(title = "Hello Again!",
                       message = "I am done!", icon = "info", type = "ok")

