paralist.batchtemplatepath = '/oak/stanford/groups/menon/scsnlscripts/brainImaging/mri/fmri/preprocessing/spm12/preprocessfmrimodules/batchtemplates/';
paralist.spmversion = 'spm12';
paralist.parallel = '1';



paralist.subjectlist = 'subjectlist_all_met.txt';
paralist.spgrsubjectlist ='subjectlist_all_met_spgr.txt';

paralist.rawdatadir = '/oak/stanford/groups/menon/rawdata/scsnl';
paralist.projectdir = '/oak/stanford/groups/menon/projects/daelsaid/2019_met/';


paralist.spgrfilename = 'spgr';

paralist.runlist = '/oak/stanford/groups/menon/projects/daelsaid/2019_met/data/subjectlist/sym4_redo_runlist.txt';

paralist.pipeline = 'swar';
paralist.outputdirname = 'swar_spm12';

paralist.inputimgprefix = '';
paralist.trval = 0.49;
paralist.customslicetiming = 0;
paralist.slicetimingfile = '';
paralist.sliceacq= 'ascend';
paralist.smoothwidth = [6 6 6];
paralist.boundingboxdim = [-90 -126 -72; 90 90 108];

runconfig.jobcpus ='4';
runconfig.jobmem = '16G';
runconfig.jobtime= '3:00:00';
runconfig.overwrite='0';
runconfig.outputfile='${projectdir}/data/imaging/participants/${pid}/visit${visit}/session${session}/fmri/sym4_redo/swar_spm12/swarI.nii.gz'
