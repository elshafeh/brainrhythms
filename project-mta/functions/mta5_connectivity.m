function mta5_connectivity(subj_num,tlock,twin,cycles2keep,phases2keep)
% MTA5_connectivity computes the coherence and ppc of the virtual sensors
% for the auditory and motor sources.
%
% Use as 
%
%       mta5_connectivity(subj_num)
% 
%       subj_num        = participant number as an integer

%% setup

addpath /project/3016057.03/project_mta/functions
addpath /home/common/matlab/fieldtrip/
ft_defaults;

datapath                = '/project/3016057.03/project_mta/output/virtualsensors/';
savepath                = '/project/3016057.03/project_mta/output/connectivity/';

%% load data and create struct with auditory and motor source

subj                    = ['s' num2str(subj_num)];
padlength               = (twin(2) - twin(1)) * 2;

load([datapath subj '_auditory_virtualchannels.mat'],'data_source');
aud_source              = data_source;
aud_source.label        = {'aud_source'};
load([datapath subj '_motor_virtualchannels.mat'],'data_source');
motor_source            = data_source;
motor_source.label      = {'motor_source'};

% combine auditory and motor channels
virtualsens             = ft_appenddata([],aud_source,motor_source);

% segment out trials based on cycles of interest
cfg                     = [];
cfg.trials              = logical(sum(virtualsens.trialinfo(:,5) == cycles2keep,2));
virtualsens             = ft_selectdata(cfg,virtualsens);

% segment out trials based on the phases (in phase, out of phase, random)
cfg                     = [];
cfg.trials              = logical(sum(virtualsens.trialinfo(:,6) == phases2keep,2));
virtualsens             = ft_selectdata(cfg,virtualsens);

%% lock to cue or target and segment out appropriate time window

switch tlock
    case 'cueonset'
        % do nothing, already time locked to cue onset
    case 'cueoffset'
        cfg             = [];
        cfg.offset      = -(virtualsens.fsample * 1.5);
        virtualsens     = ft_redefinetrial(cfg,virtualsens);
    case 'target'
        % lock to target
        %                 (last cue time) + (   cue - stim window    )
        bp_time         = (     1500       + virtualsens.trialinfo(:,4))/1000;

        % convert to time to sample
        bp_sample       = zeros(length(bp_time),1);
        trialtime       = virtualsens.time{1};
        for i=1:length(bp_time)
            [~,sampleid] = min(abs(trialtime - bp_time(i)));
            bp_sample(i) = sampleid;
        end
        
        % redefine trial
        cfg             = [];
        cfg.offset      = -(bp_sample-301);
        virtualsens     = ft_redefinetrial(cfg,virtualsens);
end

% segment out pretarget
cfg                     = [];
cfg.latency             = twin;
vsens_segment           = ft_selectdata(cfg,virtualsens);

%% coherence and pairwise phase consistency
% 
% % frequency analysis
% cfg                     = [];
% cfg.method              = 'mtmfft';
% cfg.pad                 = padlength;
% cfg.output              = 'fourier';
% cfg.taper               = 'hanning';
% cfg.foilim              = [0 40];
% fourier_segment         = ft_freqanalysis(cfg,vsens_segment);
% 
% % coherence
% cfg                     = [];
% cfg.method              = 'coh';
% coh                     = ft_connectivityanalysis(cfg,fourier_segment);
% 
% % pairwise phase consistency
% cfg                     = [];
% cfg.method              = 'ppc';
% ppc                     = ft_connectivityanalysis(cfg,fourier_segment);

%% // rhythmic vs random //

% equalize trial numbers and take only hits
f1                      = find(vsens_segment.trialinfo(:,2)==4 & vsens_segment.trialinfo(:,8)==1); % rhythmic and correct
nf1                     = length(f1);
f2                      = find(vsens_segment.trialinfo(:,2)==1 & vsens_segment.trialinfo(:,8)==1); % rhythmic and correct
nf2                     = length(f2);
minn                    = min(nf1, nf2);
tf1                     = f1(randperm(nf1, minn));
tf2                     = f2(randperm(nf2, minn));

% print out number of dropped trials
fprintf('Subject s%d\n',subj_num);
fprintf('number of rhythmic trials: %d;\tafter dropping trials: %d\n',nf1,length(tf1));
fprintf('number of random trials:   %d;\tafter dropping trials: %d\n',nf2,length(tf2));

% frequency analysis
cfg                     = [];
cfg.method              = 'mtmfft';
cfg.pad                 = padlength;
cfg.output              = 'fourier';
cfg.taper               = 'hanning';
cfg.foilim              = [0 40];

cfg.trials              = tf1;
fourier_rhyt            = ft_freqanalysis(cfg,vsens_segment);

cfg.trials              = tf2;
fourier_rand            = ft_freqanalysis(cfg,vsens_segment);

% coherence
cfg                     = [];
cfg.method              = 'coh';
coh_rhyt                = ft_connectivityanalysis(cfg,fourier_rhyt);
coh_rand                = ft_connectivityanalysis(cfg,fourier_rand);


% pairwise phase consistency
cfg                     = [];
cfg.method              = 'ppc';
ppc_rhyt                = ft_connectivityanalysis(cfg,fourier_rhyt);
ppc_rand                = ft_connectivityanalysis(cfg,fourier_rand);

%% save

save([savepath subj '_connectivity.mat'],'coh_rhyt','coh_rand','ppc_rhyt','ppc_rand','-v7.3');

end