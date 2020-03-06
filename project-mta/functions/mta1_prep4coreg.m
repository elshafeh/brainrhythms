function mta1_prep4coreg(subj_num,modality)
% MTA1_PREP4COREG is the first step in analyzing the MTA data
% 
% Use as 
%
%       mta1_prep4coreg(subj_num,modality)
%       
%       subj_num        = participant number as an integer
%       modality        = 'auditory', 'motor', or 'visual'
% 
% The function will automatically take the preprocessed MEG data from 
% '/project/3016057.03/project_mta/data/prepro/final/' and will save a pre
% and post sections of the time windows of interest for the given modality.
% Edit time windows in the script before running.
%
% pre   = baseline segment used in the source contrast
% post  = time window of interest containing evoked responses, also used in
%         source contrast
% all   = segment of data used to create common filter (note it is not
%         necessarily just the combination of pre and post segments!)
%
% Mat file includes 'data_pre', 'data_post', 'data_all', 'timelock_pre',
% 'timelock_post', 'timelock_all', and 'bad_channels'. Data will be saved 
% in the '/project/3016057.03/project_mta/output/prep4coreg' folder. 

%% setup

restoredefaultpath
addpath /home/common/matlab/fieldtrip/
addpath /project/3016057.03/project_mta/functions
ft_defaults;

datapath                = '/project/3016057.03/project_mta/data/';
megpath                 = [datapath 'prepro/final/'];
savepath                = '/project/3016057.03/project_mta/output/prep4coreg/';

subj                    = ['s' num2str(subj_num)];
meg_file_to_read        = [megpath 'data' num2str(subj_num) '.mat'];

%% load data + define channels used after preprocessing

load(meg_file_to_read);
channels_used           = ft_channelselection('meg',data);

%% cut out whole time window of interest

switch modality
    
    case 'auditory'
        
        % edit as necessary (relative to cue onset)
        starttime               = -0.5; 
        endtime                 = 2;
        endtime_contrast        = 0.5;
        
        % segment out whole time window baseline + cue) - to be used to make the common filter
        cfg                     = [];
        cfg.latency             = [starttime endtime];
        data_all                = ft_selectdata(cfg,data);
        data_all                = rmfield(data_all,'cfg');
        
        % segment out baseline and cue windows - to be used in the contrasts
        
        % baseline window
        cfg                     = [];
        cfg.latency             = [starttime 0];
        data_pre                = ft_selectdata(cfg,data);
        data_pre                = rmfield(data_pre, 'cfg');

        % cue/response window
        cfg                     = [];
        cfg.latency             = [0 endtime_contrast];
        data_post               = ft_selectdata(cfg,data);
        data_post               = rmfield(data_post, 'cfg');
        
        
    case 'motor'
        
        % edit as necessary (relative to button press)
        starttime               = -0.2; 
        endtime                 = 0.2; 
        
        % get rid of trials with NaN in the reaction time column
        if any(isnan(data.trialinfo(:,9)))
            cfg                 = [];
            cfg.trials          = find(~isnan(data.trialinfo(:,9)));
            data                = ft_selectdata(cfg,data);
        end
        
        % shouldn't this be 1500?
        % this should be correct   (cue window time) +  ( cue-stim window ) + (        RT       )
        bp_time                 = (      1500        +  data.trialinfo(:,4) + data.trialinfo(:,9))/1000;
        
        % convert to sample
        bp_sample               = zeros(length(bp_time),1);
        trialtime               = data.time{1};
        for i=1:length(bp_time)
            [~,sampleid]        = min(abs(trialtime - bp_time(i)));
            bp_sample(i)        = sampleid;
        end
        
        % if any poststim goes outside of trial length, drop
        if any((bp_sample + endtime*data.fsample) > 1800)
            cfg                 = [];
            cfg.trials          = (bp_sample + endtime*data.fsample) < 1800;
            data                = ft_selectdata(cfg,data);

            bp_sample           = bp_sample(cfg.trials);
        end

        % recenter onto button press and segment out appropriate section -- for common filter
        cfg                     = [];
        cfg.offset              = -(bp_sample-301); % offset takes as input the number of samples to move 0, -301 to correct for this since bp_sample counts from the beginning of slice, not from where 0 occurs
        data_all                = ft_redefinetrial(cfg,data);
        
        cfg                     = [];
        cfg.latency             = [starttime endtime];
        data_all                = ft_selectdata(cfg,data_all);

        % segment out pre and post sections -- for source contrast
        cfg                     = [];
        cfg.latency             = [starttime 0];
        data_pre                = ft_selectdata(cfg,data_all);
        
        cfg                     = [];
        cfg.latency             = [0 endtime];
        data_post               = ft_selectdata(cfg,data_all);

end

%% timelock average

cfg                     = [];
cfg.covariance          = 'yes';
cfg.channel             = channels_used;

timelock_all            = ft_timelockanalysis(cfg,data_all);
timelock_all.grad       = ft_convert_units(timelock_all.grad,'m');

timelock_pre            = ft_timelockanalysis(cfg,data_pre);
timelock_pre.grad       = ft_convert_units(timelock_pre.grad,'m');

timelock_post           = ft_timelockanalysis(cfg,data_post);
timelock_post.grad      = ft_convert_units(timelock_post.grad,'m');

%% save data into mat file

save([savepath subj '_' modality '_prep4coreg.mat'],'data_all','data_pre','data_post','timelock_all','timelock_pre','timelock_post','channels_used','-v7.3');

end