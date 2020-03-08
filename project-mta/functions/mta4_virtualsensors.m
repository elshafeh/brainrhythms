function mta4_virtualsensors(subj_num,modality,tlock,twin,cycles2keep,phases2keep)
% MTA4_VIRTUALSENSORS computes the virtual sensors from the max source
% location based on the whole data
%
% Use as 
%
%       mta4_virtualsensors(subj_num,modality)
% 
%       subj_num        = participant number as an integer
%       modality        = 'auditory' or 'motor', soon to include visual
%       begtime         = time to start segmenting the data from for the
%                         fft and itc analyses
%       endtime         = time to stop segmenting the data for the fft and
%                         itc analyses
%
% The function will determine the location of the max source and compute
% the virtual sensor at that location based on the whole data.

%% setup

addpath /home/common/matlab/fieldtrip/
ft_defaults;
addpath /home/mrphys/wylin/toolboxes/obob_ownft/
obob_init_ft;
addpath /project/3016057.03/project_mta/functions

datapath               = '/project/3016057.03/project_mta/data/prepro/final/';
outpath                = '/project/3016057.03/project_mta/output/';
savepath               = '/project/3016057.03/project_mta/output/virtualsensors/';

padlength              = (twin(2) - twin(1)) * 2;

%% load data from the other functions

% load all meg data
load([datapath 'data' num2str(subj_num) '.mat']);
data.grad = ft_convert_units(data.grad,'m');
% prep4coreg data
load([outpath 'prep4coreg/s' num2str(subj_num) '_' modality '_prep4coreg.mat'],'timelock*','channels_used');
% sourceanalysis
load([outpath 'sourceanalysis/s' num2str(subj_num) '_' modality '_sourceanalysis.mat'],'leadfield','source_diff');


%% position of the max source in the appropriate hemisphere + name of source
% usually will just take the max source position, but if there are more
% than one lickely source positions, brute force manual clicking was done
% to find max position of the appropriate source

switch modality
    case 'auditory'
        source_diff.avg.mask    = (source_diff.pos(:,2) < 0) .* source_diff.avg.pow;
        label                   = 'auditory_source';
        
        if subj_num == 1 
            sourcepos           = 1808;
        elseif subj_num == 32
            sourcepos           = 1776;
        else
            [~,sourcepos]       = max(source_diff.avg.mask);
        end
        
    case 'motor'
        source_diff.avg.mask    = (source_diff.pos(:,2) > 0) .* source_diff.avg.pow;
        label                   = 'motor_source';
        
        if subj_num == 1
            sourcepos           = 2848;
        elseif subj_num == 3   
            sourcepos           = 2979;
        elseif subj_num == 21
            sourcepos           = 2746;
        elseif subj_num == 24
            sourcepos           = 3145;
        elseif subj_num == 26
            sourcepos           = 2962;
        elseif subj_num == 28
            sourcepos           = 2150;
        elseif subj_num == 32
            sourcepos           = 2373;
        elseif subj_num == 34
            sourcepos           = 2796;
        else
            [~,sourcepos]       = max(source_diff.avg.mask);
        end

end

%% timelock all data (the whole time window of the trial)

cfg                     = [];
cfg.covariance          = 'yes';
cfg.channel             = channels_used;
timelock_all_data       = ft_timelockanalysis(cfg,data);
timelock_all_data.grad  = ft_convert_units(timelock_all_data.grad,'m');

%% use obob to compute the common spatial filter with the max source position

lf_maxpow               = leadfield;
lf_maxpow.pos           = lf_maxpow.pos(sourcepos,:);
lf_maxpow.inside        = true(1,1);
lf_maxpow.leadfield     = lf_maxpow.leadfield(sourcepos);

cfg                     = [];
cfg.grid                = lf_maxpow;
cfg.fixedori            = 'yes';
filter                  = obob_svs_compute_spat_filters(cfg,timelock_all_data);

%% extract the time series of the virtual channel

cfg                     = [];
cfg.spatial_filter      = filter;
data_source             = obob_svs_beamtrials_lcmv(cfg,data); % <- virtual channel!!

%% Segment the data to appropriate time window and define trials to analyze

data_source_clean       = data_source;

% segment out trials based on cycles of interest
cfg                     = [];
cfg.trials              = logical(sum(data_source_clean.trialinfo(:,5) == cycles2keep,2));
data_source_clean       = ft_selectdata(cfg,data_source_clean);

% segment out trials based on the phases (in phase, out of phase, random)
cfg                     = [];
cfg.trials              = logical(sum(data_source_clean.trialinfo(:,6) == phases2keep,2));
data_source_clean       = ft_selectdata(cfg,data_source_clean);

switch tlock
    case 'cueonset'
        % do nothing, already time locked to cue onset
        
    case 'cueoffset'
        cfg             = [];
        cfg.offset      = -(data_source.fsample * 1.5);
        data_source_clean = ft_redefinetrial(cfg,data_source_clean);
        
    case 'target'
        %                 (last cue time) + (       cue - stim window       )
        bp_time         = (     1500      +  data_source_clean.trialinfo(:,4))/1000;

        % convert to time to sample
        bp_sample       = zeros(length(bp_time),1);
        trialtime       = data_source_clean.time{1};
        for i=1:length(bp_time)
            [~,sampleid] = min(abs(trialtime - bp_time(i)));
            bp_sample(i) = sampleid;
        end
        
        % redefine trial
        cfg             = [];
        cfg.offset      = -(bp_sample-301);
        data_source_clean = ft_redefinetrial(cfg,data_source_clean);
end

% extract time segment of interest
cfg                     = [];
cfg.latency             = twin;
data_segment            = ft_selectdata(cfg,data_source_clean);

%% power analysis on virtual channel

% only correct trials and equalize number 
f1                      = find(data_segment.trialinfo(:,2)==4 & data_segment.trialinfo(:,8)==1); % rhythmic and correct
nf1                     = length(f1);
f2                      = find(data_segment.trialinfo(:,2)==1 & data_segment.trialinfo(:,8)==1); % rhythmic and correct
nf2                     = length(f2);
minn                    = min(nf1, nf2);
tf1                     = f1(randperm(nf1, minn));
tf2                     = f2(randperm(nf2, minn));

% power analysis
cfg                     = [];
cfg.method              = 'mtmfft';
cfg.output              = 'pow';
cfg.pad                 = padlength;
cfg.taper               = 'hanning';
cfg.foilim              = [0 40];

all_fft                 = ft_freqanalysis(cfg,data_segment);

% rhythmic correct
cfg.trials              = tf1;
rhyt_fft                = ft_freqanalysis(cfg,data_segment);

% random correct
cfg.trials              = tf2;
rand_fft                = ft_freqanalysis(cfg,data_segment);

%% itc on the virtual channel

% frequency analysis on the cue window
cfg                     = [];
cfg.method              = 'mtmfft';
cfg.output              = 'fourier';
cfg.pad                 = padlength;
cfg.taper               = 'hanning';
cfg.foilim              = [0 40];

all_freq                = ft_freqanalysis(cfg,data_segment);

cfg.trials              = tf1;
rhyt_freq               = ft_freqanalysis(cfg,data_segment);

cfg.trials              = tf2;
rand_freq               = ft_freqanalysis(cfg,data_segment);

rhyt_itc.label           = rhyt_freq.label;
rhyt_itc.freq            = rhyt_freq.freq;
rhyt_itc.dimord          = 'chan_freq_time';

F_rhyt                   = rhyt_freq.fourierspctrm;
N_rhyt                   = size(F_rhyt,1);

rhyt_itc.powspctrm       = F_rhyt./abs(F_rhyt);
rhyt_itc.powspctrm       = sum(rhyt_itc.powspctrm,1);
rhyt_itc.powspctrm       = abs(rhyt_itc.powspctrm)/N_rhyt;
rhyt_itc.powspctrm       = squeeze(rhyt_itc.powspctrm);
rhyt_itc.powspctrm       = rhyt_itc.powspctrm';

rand_itc.label           = rand_freq.label;
rand_itc.freq            = rand_freq.freq;
rand_itc.dimord          = 'chan_freq_time';

F_rand                   = rand_freq.fourierspctrm;
N_rand                   = size(F_rand,1);

rand_itc.powspctrm       = F_rand./abs(F_rand);
rand_itc.powspctrm       = sum(rand_itc.powspctrm,1);
rand_itc.powspctrm       = abs(rand_itc.powspctrm)/N_rand;
rand_itc.powspctrm       = squeeze(rand_itc.powspctrm);
rand_itc.powspctrm       = rand_itc.powspctrm';

all_itc.label            = all_freq.label;
all_itc.freq             = all_freq.freq;
all_itc.dimord           = 'chan_freq_time';

F_all                    = all_freq.fourierspctrm;
N_all                    = size(F_all,1);

all_itc.powspctrm       = F_all./abs(F_all);
all_itc.powspctrm       = sum(all_itc.powspctrm,1);
all_itc.powspctrm       = abs(all_itc.powspctrm)/N_all;
all_itc.powspctrm       = squeeze(all_itc.powspctrm);
all_itc.powspctrm       = all_itc.powspctrm';

%% save 

save([savepath 's' num2str(subj_num) '_' modality '_virtualchannels.mat'],'all_fft','all_itc','data_source','rhyt_fft','rhyt_itc','rand_fft','rand_itc','-v7.3');

end