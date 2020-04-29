% Artifact rejection , runICA; Additya - 5th September,2019

%%
clear ; clc ; clearvars ;

% Fieldtrip path
fieldtrip_path                                 = '/project/3015039.04/fieldtrip-20190618';
addpath(fieldtrip_path); ft_defaults ;

% subject, session lists
list_sub                                       = {'21'};
sub_list                                       = {'sub021'};
list_session                                   = {'aud','vis'};
nsub                                           = 1 ;
nses                                           = input ('Enter 1 for aud; 2 for vis:' );

%% First artifact rejection
% loading downsampled data
dir_data                               = ['../data/' sub_list{nsub} '/preprocessed/'];
fname                                  = ([dir_data 'sub0' list_sub{nsub} '_downsampled_' list_session{nses} '.mat']) ;

fprintf('Loading %s \n',fname);
load(fname);

% first manual rejection- summary mode
cfg                                    = [];
cfg.method                             = 'summary';
cfg.alim                               = 1e-12;
first_reject                           = ft_rejectvisual(cfg,downsampled_data);

dir_data                               = ['/project/3015039.04/data/sub0' list_sub{nsub} '/preprocessed/'];
fname                                  = ([dir_data 'sub0' list_sub{nsub} '_firstreject_' list_session{nses} '.mat']) ;
fprintf('saving %s \n',fname); save(fname,'first_reject', '-v7.3');

clear first_reject ; clear dir_data ; clear fname ; clear cfg; clear downsampled_data ;

%% runica
% loading first rejection data
dir_data                               = ['../data/' sub_list{nsub} '/preprocessed/'];
fname                                  = ([dir_data 'sub0' list_sub{nsub} '_firstreject_' list_session{nses} '.mat']) ;
fprintf('Loading %s \n',fname); load(fname);

cfg                                    = [];
cfg.method                             = 'runica';
cfg.channel                            = 'MEG';
comps_runica                           = ft_componentanalysis(cfg,first_reject);

dir_data                               = ['/project/3015039.04/data/sub0' list_sub{nsub} '/preprocessed/'];
fname                                  = ([dir_data 'sub0' list_sub{nsub} '_compsica_' list_session{nses} '.mat']) ;
fprintf('saving %s \n',fname); save(fname,'comps_runica', '-v7.3');

clear comps_runica ; clear first_reject ; clear dir_data ; clear fname ; clear cfg ;

%% rejecting ica components
% load ica components
dir_data                               = ['../data/' sub_list{nsub} '/preprocessed/'];
fname                                  = ([dir_data 'sub0' list_sub{nsub} '_compsica_' list_session{nses} '.mat']) ;
fprintf('Loading %s \n',fname); load(fname);

% load first rejection data
dir_data                               = ['../data/' sub_list{nsub} '/preprocessed/'];
fname                                  = ([dir_data 'sub0' list_sub{nsub} '_firstreject_' list_session{nses} '.mat']) ;
fprintf('Loading %s \n',fname); load(fname);

cfg                                    = [];
cfg.layout                             = 'CTF275.lay';
cfg.viewmode                           = 'component';
ft_databrowser(cfg, comps_runica)

% input components to visualize and reject
comps                                  = input('Enter components to see topo plots and reject, in []: ');
figure
cfg                                    = [];
cfg.component                          = comps ;      % component(s) that should be plotted
cfg.layout                             = 'CTF275.lay';
cfg.comment                            = 'no';
ft_topoplotIC(cfg, comps_runica)

cfg                                    = [];
cfg.component                          = comps;       % to be removed component(s)
firstreject_postica                    = ft_rejectcomponent(cfg,comps_runica,first_reject) ;

dir_data                               = ['/project/3015039.04/data/sub0' list_sub{nsub} '/preprocessed/'];
fname                                  = ([dir_data 'sub0' list_sub{nsub} '_firstreject_postica_' list_session{nses} '.mat']) ;
fprintf('saving %s \n',fname); save(fname,'firstreject_postica', '-v7.3'); clear fname ;

%% second artifact rejection - Trial by trial (ALWAYS ADJUST megscale !!!!)
cfg                                            = [];
cfg.channel                                    = 'MEG';
cfg.viewmode                                   = 'vertical';
cfg.alim                                       = 1e-12;   % adjusts the amplitude of visualziation
cfg.megscale                                   = 1.3;     % adjusts meg channels scaling
cfg.method                                     = 'trial' ;

secondreject_postica                           = ft_rejectvisual(cfg,firstreject_postica);

dir_data                                       = ['/project/3015039.04/data/sub0' list_sub{nsub} '/preprocessed/'];
fname                                          = ([dir_data 'sub0' list_sub{nsub} '_secondreject_postica_' list_session{nses} '.mat']) ;
fprintf('saving %s \n',fname);
save(fname,'secondreject_postica', '-v7.3'); clear fname ;
