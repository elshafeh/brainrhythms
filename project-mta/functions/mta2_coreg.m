function mta2_coreg(subj_num)
% MTA2_COREG coregisters the digitizer positions with the anatomical scan.
% This uses either FieldTrip or obob_ownft. This function is also
% independent of modality (ie. each modality would use the same output from
% this function). 
% 
% Use as 
% 
%       mta2_coreg(subj_num)
%
%       subj_num        = participant number as an integer
% 
% If ft_volumerealign with cfg.method = 'interactive' or or obob_coregister
% was already done with the interactive clicking of fiducial points, then
% the function will automatically read this from the mta3_read_fidpts 
% function (you have to manually input these unfortunately). If not, then 
% you will have to do this interactively. 

%% paths

addpath /home/common/matlab/fieldtrip/
ft_defaults;
addpath /home/mrphys/wylin/toolboxes/obob_ownft/
obob_init_ft;
addpath /project/3016057.03/project_mta/functions/

datapath                = '/project/3016057.03/project_mta/data/';
mridatapath             = [datapath 'orig/mri/'];
pospath                 = [datapath 'orig/polh/'];
savepath                = '/project/3016057.03/project_mta/output/coreg/';

%% read anatomical scans
% because they come in different file types for each subject, loop over
% each subject and determine file type/which initial file to read
% read_this_mri_file can be any mri file in the folder, as long as it's in
% the correct series, usually reading file number 100 is a safe bet 

currmrifiles            = dir([mridatapath 's' num2str(subj_num)]);
currmrifiles            = currmrifiles(3:end);

if length(currmrifiles) < 10
    filetype            = split(currmrifiles(1).name,'.');
    filetype            = filetype{end};
    if strcmp(filetype,'nii') || strcmp(filetype,'gz')
        read_this_mri_file  = [currmrifiles(1).folder '/' currmrifiles(1).name];
    elseif strcmp(filetype,'DCCN Skyra') % one participant has a rabbit hole of folders until actual MRI data
        currmrifiles        = dir([currmrifiles(1).folder '/' currmrifiles(1).name]); 
        currmrifiles        = dir([currmrifiles(end).folder '/' currmrifiles(end).name]); % why is it in yet ANOTHER folder?
        read_this_mri_file  = [currmrifiles(100).folder '/' currmrifiles(100).name]; 
    end
else
    filetype            = split(currmrifiles(100).name,'.');
    filetype            = filetype{end};
    if strcmp(filetype,'IMA')
        read_this_mri_file  = [currmrifiles(100).folder '/' currmrifiles(100).name]; % 100 should be a safe bet
    end
end

mri_raw                 = ft_read_mri(read_this_mri_file);
mri_raw                 = ft_convert_units(mri_raw,'m');

%% decide whether to use obob or fieldtrip based on pos data
% obob works best if pos file exists for subject

% check if pos file exists
pos                     = 'obob';
posfiles                = dir([pospath 's*']);

if ~any(strcmp({posfiles.name},['s' num2str(subj_num) '.pos']))
    warning(['No pos file found for subject ' num2str(subj_num)]);
    pos                 = 'fieldtrip';
end

%% run coregistration

% read fiducial points, if any
% if you need to repeat this function for any subject for whatever reason,
% but don't have to repeat looking for fiducial points, manually save
% fiducial points into mta2_read_fidpts so you don't have to do this
% interactively every time
realign_method              = 'fiducial';
fidpts                      = mta2_read_fidpts(['s' num2str(subj_num)]);
if isempty(fidpts)
    warning('No fiducial points found for the participant, reverting to interactive method for volume realign.');
    realign_method          = 'interactive';
end

% process mri data
switch pos
    
    case 'obob'
        
        posfile             = [pospath 's' num2str(subj_num) '.pos'];
        posdata             = ft_read_headshape(posfile);
        posdata             = ft_convert_units(posdata,'m');
        posdata.coordsys    = 'ctf';

        % use obob_coregister to coregister the polh data with the mri data
        cfg                     = [];
        cfg.mrifile             = mri_raw;
        cfg.headshape           = posdata;
        cfg.reslice             = 'yes';
        cfg.skipfiducial        = 'no';
        cfg.skiphs              = 'no';
        cfg.cleanhs             = 'no';
        cfg.plotresult          = 'no';
        if strcmp(realign_method,'fiducial')
            cfg.fiducial.nas        = fidpts.nas;
            cfg.fiducial.lpa        = fidpts.lpa;
            cfg.fiducial.rpa        = fidpts.rpa;
            cfg.fiducial.zpoint     = fidpts.zpoint;
        end

        [mri_aligned,~,headmodel,mri_segmented] = obob_coregister(cfg);

    case 'fieldtrip'
    
        % reslice data
        cfg                     = [];
        cfg.method              = 'flip';
        mri_resliced            = ft_volumereslice(cfg,mri_raw);

        % realign anatomical scan from DICOM to CTF
        cfg                     = [];
        cfg.coordsys            = 'ctf';
        cfg.method              = realign_method;
        if strcmp(realign_method,'fiducial')
            cfg.fiducial.nas    = fidpts.nas;
            cfg.fiducial.lpa    = fidpts.lpa;
            cfg.fiducial.rpa    = fidpts.rpa;
            cfg.fiducial.zpoint = fidpts.zpoint;
        end
        
        mri_aligned             = ft_volumerealign(cfg,mri_resliced);

        % segment the mri 
        cfg                     = [];
        cfg.write               = 'no';
        mri_segmented           = ft_volumesegment(cfg,mri_aligned);

        % create headmodel
        cfg                     = [];
        cfg.method              = 'singleshell';
        headmodel               = ft_prepare_headmodel(cfg,mri_segmented);
    
end

%% save data

save([savepath 's' num2str(subj_num) '_mri_coreged.mat'],'mri_aligned','mri_segmented','headmodel','-v7.3');

end
