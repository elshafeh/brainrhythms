function mta3_sourceanalysis(subj_num,modality)
% MTA3_SOURCEANALYSIS takes the outputs from mta1_prep4coreg and mta2_coreg
% to do a source analysis of data. 
% 
% Use as
%       
%       mta3_sourceanalysis(subj_num,modallity,plot)
%
%       subj_num        = participant number as an integer
%       modality        = 'auditory', 'motor' or 'visual'
%       plot            = 0 or 1 to indicate whether you want to plot the
%                         results, 0 = no, 1 = yes
%
% The function will take the outputs of the previous two functions in the
% series to compute the leadfield, the contrasted source differences, and
% the interpolation of these sources onto the anatomical mri. 
% 
% Mat file includes 'leadfield', 'source_diff', and 'source_diffint'. The
% data will be saved in the '/project/3016057.03/project_mta/output/sourcenalysis' 
% folder. 

%% setup

addpath /home/common/matlab/fieldtrip/
ft_defaults;
addpath /home/mrphys/wylin/toolboxes/obob_ownft/
obob_init_ft;

outpath                = '/project/3016057.03/project_mta/output/'; 
savepath               = '/project/3016057.03/project_mta/output/sourceanalysis/';

%% load data from the other functions

% prep4coreg data
load([outpath 'prep4coreg/s' num2str(subj_num) '_' modality '_prep4coreg.mat'],'timelock*','channels_used');
% coreg headmodel and mri_aligned
load([outpath 'coreg/s' num2str(subj_num) '_mri_coreged.mat']);

%% LEADFIELD from meg and mri data (modality specific)

cfg                     = [];
cfg.headmodel           = headmodel;
cfg.reducerank          = 2;
cfg.resolution          = 0.01; % cm resolution (units are in m)
cfg.sourcemodel.unit    = 'm'; 
cfg.channel             = channels_used;
[leadfield]             = ft_prepare_leadfield(cfg,timelock_all); 

%% compute the common filter
        
cfg                     = [];
cfg.method              = 'lcmv';
cfg.sourcemodel         = leadfield;
cfg.headmodel           = headmodel;
cfg.channel             = channels_used;
cfg.lcmv.keepfilter     = 'yes';
cfg.lcmv.fixedori       = 'yes';

source_all              = ft_sourceanalysis(cfg,timelock_all);

%% apply the filter to the two separate time windows

% apply filter and do source analysis
cfg                     = [];
cfg.method              = 'lcmv';
cfg.sourcemodel         = leadfield;
cfg.headmodel           = headmodel;
cfg.channel             = channels_used;
cfg.lcmv.keepfilter     = 'yes';
cfg.lcmv.fixedori       = 'yes';

cfg.sourcemodel.filter  = source_all.avg.filter;
source_pre              = ft_sourceanalysis(cfg,timelock_pre);
source_post             = ft_sourceanalysis(cfg,timelock_post);

% compute the contrast
source_diff             = source_all;
source_diff.avg.pow     = (source_post.avg.pow - source_pre.avg.pow) ./ source_pre.avg.pow;


%% interpolate onto mri

cfg                     = [];
cfg.downsample          = 2;
cfg.parameter           = 'pow';

source_diff_int         = ft_sourceinterpolate(cfg,source_diff,mri_aligned);

% create normalized version of the source
% this defaults to the T1.nii template used in spm8
source_diff_int_spm     = ft_volumenormalise([],source_diff_int);

%% save output

save([savepath 's' num2str(subj_num) '_' modality '_sourceanalysis.mat'],'leadfield','source_diff','source_diff_int','source_diff_int_spm','-v7.3');

end