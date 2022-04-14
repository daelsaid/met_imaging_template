%-Parallel or not
paralist.parallel = '1';

%-Subject list
paralist.subjectlist = 'temp.txt';

%-Run list
paralist.runlist = '/oak/stanford/groups/menon/projects/daelsaid/2019_met/data/subjectlist/run_list.txt';
%-Raw data directory (where task_design.m are saved)
paralist.rawdir =  '/oak/stanford/groups/menon/projects/daelsaid/2019_met/data/imaging/participants';

%-Project directory (where task_design.mat should be saved for each subject)
paralist.projectdir = '/oak/stanford/groups/menon/projects/daelsaid/2019_met/';

%-Please specify the task design m file
paralist.task_dsgn  = 'task_design.m';

%Please specify the name that you want to use for task design mat file
paralist.task_dsgn_mat = 'task_design.mat';

%-SPM version (this is not important for the current function; keep it in order to use mlsubmit.sh)
paralist.spmversion = 'spm12';
