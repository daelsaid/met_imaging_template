# R script to process behavioral data from psychopy output and to create task design.m files
#
# 10-09-2018: updated to bypass overwriting of task design.m files 
# 01-22-2019: updated to create task names for redo-runs only when there are redo-runs 
#
# the working directory should contain subjectlist (.csv file) and training group assignment spreadsheet (.csv file)
#
# the raw data directory should contain psychopy output files (*.csv) under PID/visit[x]/session[x]/behavioral/Results####
# -------------------------------------------------------------------------------------------

#clear workspace####
rm(list=ls())

#specify working directory, raw data directory, and file names####

dir<-'/oak/stanford/groups/menon/projects/daelsaid/2019_met/scripts/behavioral/current_met_subj' #working directory
#rawdir<-'/oak/stanford/groups/menon/projects/changh/2017_MET/data/imaging/participants/raw'
rawdir<-'/oak/stanford/groups/menon/rawdata/scsnl' #raw data directory
subjectlist<-'subjectlist.csv' #variable names: PID, visit, session
training_group<-'training_group.csv' #variable names: scanid, training_group
data_output<-'data_merged_sorted.csv' #merged psychopy ouput 
data_summary<-'data_summary.csv' #summarized behavioral data 

##################################
####processing behavioral data####
##################################

#package loading function####
load.packages <- function(package.list){ 
new.packages <- package.list[!(package.list %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
for (i in 1:length(package.list)){
library(package.list[i],character.only=TRUE)
}
}

#load packages, install if needed####
package.list <- c("filesstrings","plyr")
load.packages(package.list)

#rename behavioral files####
setwd(dir)
raw.folder <- paste(dir,'/raw',sep="")

if (!dir.exists(raw.folder)){
dir.create(raw.folder)
} else {
    print("raw directory already exists!")
}

subjects<-read.csv(subjectlist)
subject <-paste(subjects$PID,"_",subjects$visit,"_",subjects$session,".3T2",sep="")
pid <-subjects$PID
visit <-subjects$visit
session <-subjects$session

#if the files were already renamed a warning message will appear####
for (i in 1:length(subject)){
setwd(dir = paste(rawdir,'/',pid[i],'/visit',visit[i],'/session',session[i],'/behavioral/Results',sep=""))
#setwd(dir = paste(dir,subject[i],"/Results/",sep=""))
filepath<-getwd()
quit_files<-list.files(pattern="QUIT.csv")
if (isTRUE(file.exists(quit_files))) {
	dir.create(paste(filepath,'/quit',sep=""))
	file.move(paste(filepath,'/',list.files(pattern="QUIT.csv"),sep=""),paste(filepath,'/quit',sep=""))
}	
file_names<-list.files(pattern="*.csv")
file_names_revised<-gsub(paste(as.character(subject[i]),"_",sep=""),"",file_names)
new_names<-paste(subject[i],"_",file_names_revised,sep="")
file.rename(from=file_names,to=new_names)
list_files<-list.files(pattern="*.csv")
file.copy(list_files, raw.folder)
}

#go to raw data folder and merge data####
setwd(raw.folder)
filenames <- list.files()
data_merged <- do.call("rbind", lapply(filenames, read.csv, header = TRUE))
setwd(dir = '..')

#recode, merge, and sort data and save data set####
data_merged$timedout <- 0
data_merged$timedout[is.na(data_merged$accuracy)] <- 1
data_merged$accuracy[is.na(data_merged$accuracy)] <- 0
data_merged$rtcorrect[data_merged$accuracy==1] <- data_merged$response.time[data_merged$accuracy==1]
data_merged$rtcorrect[data_merged$accuracy==0] <- NA

data_merged$rerun.order[data_merged$rerun==1]<-data_merged$run.order[data_merged$rerun==1]
data_merged$rerun.order[data_merged$rerun==0]<-NA

data_merged$run.order[data_merged$rerun==1]<-NA
data_merged$run.order[data_merged$rerun==0]<-data_merged$run.order[data_merged$rerun==0]

data_merged$taskname<-paste(data_merged$task,data_merged$list,sep='')

training_group<-read.csv(training_group)
data_merged<-merge(data_merged, training_group, all.x = TRUE)

data_merged<-data_merged[!is.na(data_merged$training_group),] 

data_merged_groupA_Acc<-data_merged[data_merged$training_group=="A"&data_merged$accuracy==1,]
data_merged_groupB_Acc<-data_merged[data_merged$training_group=="B"&data_merged$accuracy==1,]
data_merged_groupA_InAcc<-data_merged[data_merged$training_group=="A"&data_merged$accuracy==0,]
data_merged_groupB_InAcc<-data_merged[data_merged$training_group=="B"&data_merged$accuracy==0,]

data_merged_groupA_Acc$probset<-gsub("A", "Trained_Acc", data_merged_groupA_Acc$probset)
data_merged_groupA_Acc$probset<-gsub("B", "Untrained_Acc", data_merged_groupA_Acc$probset)
data_merged_groupA_Acc$probset<-gsub("Control", "Control_Acc", data_merged_groupA_Acc$probset)

data_merged_groupB_Acc$probset<-gsub("A", "Untrained_Acc", data_merged_groupB_Acc$probset)
data_merged_groupB_Acc$probset<-gsub("B", "Trained_Acc", data_merged_groupB_Acc$probset)
data_merged_groupB_Acc$probset<-gsub("Control", "Control_Acc", data_merged_groupB_Acc$probset)

data_merged_groupA_InAcc$probset<-gsub("A", "Trained_InAcc", data_merged_groupA_InAcc$probset)
data_merged_groupA_InAcc$probset<-gsub("B", "Untrained_InAcc", data_merged_groupA_InAcc$probset)
data_merged_groupA_InAcc$probset<-gsub("Control", "Control_InAcc", data_merged_groupA_InAcc$probset)

data_merged_groupB_InAcc$probset<-gsub("A", "Untrained_InAcc", data_merged_groupB_InAcc$probset)
data_merged_groupB_InAcc$probset<-gsub("B", "Trained_InAcc", data_merged_groupB_InAcc$probset)
data_merged_groupB_InAcc$probset<-gsub("Control", "Control_InAcc", data_merged_groupB_InAcc$probset)

data_merged<-rbind(data_merged_groupA_Acc,data_merged_groupB_Acc,data_merged_groupA_InAcc,data_merged_groupB_InAcc)

data_final<-data_merged[order(data_merged$scanid,data_merged$task,data_merged$run.order,data_merged$probset,data_merged$stim_onset),]

write.csv(data_final,data_output,row.names = FALSE)

#create tasknames for main runs####
data_final_orig<-data_final[data_final$rerun==0,]
data_final_orig$taskname<-paste(data_final_orig$task,data_final_orig$run.order,sep="")

#create tasknames for redo runs (only if there are redo runs)####
if(sum(data_final$rerun == 1)>0){
data_final_rerun<-data_final[data_final$rerun==1,]
data_final_rerun$taskname<-paste(data_final_rerun$task,data_final_rerun$rerun.order,"_redo",sep="")
data_final_revised<-rbind(data_final_orig,data_final_rerun)
} else {
data_final_revised<-data_final_orig
}

#summary statistics####
data.sum<-ddply(data_final_revised,c("scanid","taskname"),summarise,
                     accuracy.mean=signif(mean(na.omit(accuracy)),digits=2),
                     accuracy.se=signif(sd(na.omit(accuracy))/sqrt(length(na.omit(accuracy))),digits=2),
					 rtcorrect.mean=signif(mean(na.omit(rtcorrect)),digits=2),
                     rtcorrect.se=signif(sd(na.omit(rtcorrect))/sqrt(length(na.omit(rtcorrect))),digits=2),
                     timedout.sum=sum(na.omit(timedout)))

write.csv(data.sum,data_summary,row.names = FALSE)

####################################
####creating task design.m files####
####################################

#function to print stimulus onset in each condition####
print_stuff <- function(condition_index, data_list) {
	cat(paste('names{',condition_index,'} = \'',condition[condition_index],'\';\n',sep=""))
	if (length(data_list) == 0) {
		cat(paste('onsets{', condition_index, '} = [ 1000.00 ];\n', sep=''))
		cat(paste('durations{', condition_index, '} = [ 0.00 ];\n\n', sep=''))
	} else {
		cat(paste('onsets{', condition_index, '} = [ ', sep=''))
		cat(paste(data_list, sep=' '))
		cat(' ];\n')
		cat(paste('durations{', condition_index, '} = [ 6.00 ];\n\n', sep=''))
	}
}

#set working directory and variables
setwd(dir)
subjects<-read.csv(subjectlist)
subject <-paste(subjects$PID,"_",subjects$visit,"_",subjects$session,".3T2",sep="")
pid <-subjects$PID
visit <-subjects$visit
session <-subjects$session
data_final<-read.csv(data_output)
task <-c('sym','grid')
run <-c(1:4)
condition<-c('Trained_Acc','Trained_InAcc','Untrained_Acc','Untrained_InAcc','Control_Acc','Control_InAcc')

#print stim onset for each condition of each run of each task in each subject - main runs####
Trained_Acc<-list()
Trained_InAcc<-list()
Untrained_Acc<-list()
Untrained_InAcc<-list()
Control_Acc<-list()
Control_InAcc<-list()

for (k in 1:4*2*length(subject)) {
	for (i in 1:length(subject)) {
		for (l in 1:2) {			
			for (j in 1:4) {

		        taskname<-data_final$taskname[data_final$scanid==subject[i]&data_final$task==task[l]&data_final$run.order==run[j]&!is.na(data_final$run.order)][1]

		        if(!is.na(taskname)){

					taskdesign.folder <- paste(rawdir,'/',pid[i],'/visit',visit[i],'/session',session[i],'/fmri/',task[l],run[j],'/task_design',sep="")

					#new.folder <- paste(dir,'/',subject[i],'/',task[1],run[j],'/task_design',sep="")

					if (!dir.exists(taskdesign.folder)){
						dir.create(taskdesign.folder,recursive = TRUE)

						setwd(taskdesign.folder)
						#sink(paste('task_design_',subject[i],'_',task[l],'_run',j,'.m',sep=""))
						sink(paste('task_design.m'))
						cat(paste('sess_name = \'',taskname,'_run',j,'\';\n\n', sep=''))
						
						Trained_Acc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[l]&data_final$run.order==run[j]&data_final$probset==condition[1]&!is.na(data_final$run.order)]
						print_stuff(1, Trained_Acc[[k]])
						
						Trained_InAcc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[l]&data_final$run.order==run[j]&data_final$probset==condition[2]&!is.na(data_final$run.order)]
						print_stuff(2, Trained_InAcc[[k]])

						Untrained_Acc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[l]&data_final$run.order==run[j]&data_final$probset==condition[3]&!is.na(data_final$run.order)]
						print_stuff(3, Untrained_Acc[[k]])

						Untrained_InAcc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[l]&data_final$run.order==run[j]&data_final$probset==condition[4]&!is.na(data_final$run.order)]
						print_stuff(4, Untrained_InAcc[[k]])

						Control_Acc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[l]&data_final$run.order==run[j]&data_final$probset==condition[5]&!is.na(data_final$run.order)]
						print_stuff(5, Control_Acc[[k]])

						Control_InAcc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[l]&data_final$run.order==run[j]&data_final$probset==condition[6]&!is.na(data_final$run.order)]
						print_stuff(6, Control_InAcc[[k]])

						cat('rest_exists = 1;\n\n')
						cat('save task_design.mat sess_name names onsets durations rest_exists\n')
						sink()

					} else {
					    print("task design directory already exists!")
					}
				}
			}
	    }
    }
}

#print stim onset for each condition of each run of each task in each subject - sym reruns####
Trained_Acc<-list()
Trained_InAcc<-list()
Untrained_Acc<-list()
Untrained_InAcc<-list()
Control_Acc<-list()
Control_InAcc<-list()

for (k in 1:4*length(subject)) {
	for (i in 1:length(subject)) {
		for (j in 1:4) {

	        taskname<-data_final$taskname[data_final$scanid==subject[i]&data_final$task==task[1]&data_final$rerun.order==run[j]&!is.na(data_final$rerun.order)][1]

	        if(!is.na(taskname)){

				taskdesign.folder <- paste(rawdir,'/',pid[i],'/visit',visit[i],'/session',session[i],'/fmri/',task[1],run[j],'_redo/task_design',sep="")

				#new.folder <- paste(dir,'/',subject[i],'/',task[1],run[j],'_redo/task_design',sep="")

				if (!dir.exists(taskdesign.folder)){
					dir.create(taskdesign.folder,recursive = TRUE)

					setwd(taskdesign.folder)
					#sink(paste('task_design_',subject[i],'_',task[1],'_rerun',j,'.m',sep=""))
					sink(paste('task_design.m'))
					cat(paste('sess_name = \'',taskname,'_rerun',j,'\';\n\n', sep=''))
					
					Trained_Acc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[1]&data_final$rerun.order==run[j]&data_final$probset==condition[1]&!is.na(data_final$rerun.order)]
					print_stuff(1, Trained_Acc[[k]])
					
					Trained_InAcc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[1]&data_final$rerun.order==run[j]&data_final$probset==condition[2]&!is.na(data_final$rerun.order)]
					print_stuff(2, Trained_InAcc[[k]])

					Untrained_Acc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[1]&data_final$rerun.order==run[j]&data_final$probset==condition[3]&!is.na(data_final$rerun.order)]
					print_stuff(3, Untrained_Acc[[k]])

					Untrained_InAcc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[1]&data_final$rerun.order==run[j]&data_final$probset==condition[4]&!is.na(data_final$rerun.order)]
					print_stuff(4, Untrained_InAcc[[k]])

					Control_Acc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[1]&data_final$rerun.order==run[j]&data_final$probset==condition[5]&!is.na(data_final$rerun.order)]
					print_stuff(5, Control_Acc[[k]])

					Control_InAcc[[k]]<-data_final$stim_onset[data_final$scanid==subject[i]&data_final$task==task[1]&data_final$rerun.order==run[j]&data_final$probset==condition[6]&!is.na(data_final$rerun.order)]
					print_stuff(6, Control_InAcc[[k]])

					cat('rest_exists = 1;\n\n')
					cat('save task_design.mat sess_name names onsets durations rest_exists\n')
					sink()

				} else {
					print("task design directory already exists!")
				}
				
			}
		}   
    }
}

setwd(dir)
