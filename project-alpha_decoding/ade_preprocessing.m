% Preprocesses and downsamples raw MEG data: Additya
%%
clear ; clc ; clearvars ;

% add Fieldtrip path
fieldtrip_path                                  = '/project/3015039.04/fieldtrip-20190618';
addpath(fieldtrip_path); ft_defaults ;

%% Subject details
list_sub                                        = {'28'};
sub_list                                        = {'sub028'};
list_session                                    = {'aud','vis'};
trigger_val(1,:)                                = [201,202,203,204,211,212,213,214]; % trigger codes in MEG
trigger_val(2,:)                                = [101,102,103,104,111,112,113,114];
nsub                                            = 1 ;
nses                                            = input ('Enter 1 for aud; 2 for vis:' );
dir_data                                        = ['/project/3015039.04/raw/sub-0' list_sub{nsub} '/ses-meg' list_session{nses} '/meg/'] ;

    % sub024-auditory - 2 .ds raw files
if strcmp(sub_list{nsub},'sub024') && strcmp(list_session{nses},'aud')
    ds_name                                     = '/project/3015039.04/raw/sub-024/ses-megaud/meg/sub024sesaud_3015039.04_20191022_01.ds' ;
    raw_input                                   = ds_name ;
    % sub031-auditory 2 .ds files
elseif strcmp(sub_list{nsub},'sub031') && strcmp(list_session{nses},'aud')
    ds_name                                     = '/project/3015039.04/raw/sub-031/ses-megaud/meg/sub031sesaud_3015039.04_20191102_01.ds';
    raw_input                                   = ds_name ;
    % sub029 -auditory 2 .ds files
elseif strcmp(sub_list{nsub},'sub028') && strcmp(list_session{nses},'aud')
    ds_name                                     = '/project/3015039.04/raw/sub-028/ses-megaud/meg/sub028sesaud_3015039.04_20191102_01.ds';
    raw_input                                   = ds_name ;
else
    ds_name                                     = dir(fullfile(dir_data,'*.ds'));
    raw_input                                   = {}; raw_input{1} = ds_name.folder; raw_input{2} = ds_name.name;
    raw_input                                   = strjoin(raw_input,'/');
end

% define trials
cfg                                             = [];
cfg.dataset                                     = raw_input ;
cfg.trialdef.eventvalue                         = trigger_val(nses,:);       % locking trial based on targets- trigger coding scheme
cfg.trialdef.eventtype                          = 'UPPT001';                 % frontpanel and uppt001 send same trigger codes
cfg.trialfun                                    = 'ft_trialfun_general' ;
cfg.trialdef.prestim                            = 3 ;
cfg.trialdef.poststim                           = 3 ;
cfg.continuous                                  = 'yes';
fprintf('Defining trials %s \n',sub_list{nsub});
cfg                                             = ft_definetrial(cfg);

%% Exception Section
if strcmp(sub_list{nsub},'sub006') && strcmp(list_session{nses},'vis')
    new_trl                            = cfg.trl(1:192,:);
    new_trl(193:864,:)                 = cfg.trl(273:944,:);
    cfg.trl                            = [] ; cfg.trl = new_trl ;
end

if strcmp(sub_list{nsub},'sub007') && strcmp(list_session{nses},'aud')
    new_trl                            = cfg.trl(1:576,:);
    new_trl(577:864,:)                 = cfg.trl(716:1003,:);
    cfg.trl                            = [] ; cfg.trl  = new_trl ;
end

if strcmp(sub_list{nsub},'sub008') && strcmp(list_session{nses},'aud')
    new_trl                            = cfg.trl(1:384,:);
    cfg.trl                            = [] ; cfg.trl = new_trl ;
end

if strcmp(sub_list{nsub},'sub012') && strcmp(list_session{nses},'aud')
    new_trl                            = cfg.trl ;
    new_trl(481:484,:)                 = [];  cfg.trl = new_trl;
end

if strcmp(sub_list{nsub},'sub013') && strcmp(list_session{nses},'aud')
    new_trl                            = cfg.trl ;
    new_trl(1:96,:)                    = [];cfg.trl  = new_trl;
end

if strcmp(sub_list{nsub},'sub021') && strcmp(list_session{nses},'aud')
    new_trl                           = cfg.trl ;
    new_trl(1:192,:)                  = [] ;
    new_trl(97:192,:)                 = [] ;
    cfg.trl                           = new_trl;
end

if strcmp(sub_list{nsub},'sub023') && strcmp(list_session{nses},'aud')
    new_trl                           = cfg.trl ;
    new_trl(481:576,:)                = [] ; cfg.trl = new_trl;
end

if strcmp(sub_list{nsub},'sub024') && strcmp(list_session{nses},'vis')
    new_trl                           = cfg.trl ;
    new_trl(1:96,:)                   = [] ; 
    new_trl(97:192,:)                 = [] ;
    cfg.trl = new_trl;
end

% logfile information into cfg.trl (Hesham's custom function to import behavioral data)
cfg                                    = h_log2trl(cfg,sub_list{nsub},list_session{nses});  

%% Preprocessing
cfg.channel                            = 'MEG';
cfg.bsfilter                           = 'yes';
cfg.bsfreq                             = [49 51; 99 100; 49 151];   % bandstop filter for line noise
cfg.precision                          = 'single' ;                 % single precision data for memory efficiency
fprintf('Preprocessing %s \n',sub_list{nsub});
preprocessed_data                      = ft_preprocessing(cfg);

%% Downsampling to 300 Hz (sampling frequency = 1200 Hz)
cfg                                    = [];
cfg.resamplefs                         = 300 ;
cfg.detrend                            = 'no'; % to be explicitly mentioned
cfg.demean                             = 'no';
fprintf('Downsampling to 300Hz %s \n',sub_list{nsub});
downsampled_data                       = ft_resampledata(cfg,preprocessed_data);

clear preprocessed_data ;
dir_data                               = ['/project/3015039.04/data/sub0' list_sub{nsub} '/preprocessed/'];
fname                                  = ([dir_data 'sub0' list_sub{nsub} '_downsampled_' list_session{nses} '.mat']) ;
fprintf('saving %s \n',fname); save(fname,'downsampled_data', '-v7.3');

clear cfg downsampled_data ds_name raw_input
