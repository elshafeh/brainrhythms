function brlab_preproc(cfg_in)

eventtype,eventvalue,prestim,poststim,behavioral_data)

% common preprocessing pipeline conceived by Elie & Hesham

% input: dsFileName, eventtype, eventvalue, prestim(in seconds), poststim
% (in seconds)

% behavioral_data : this is important to put in behavioral data e.g. RT ,
% correct/incorrect , trial type , bloc number , etc , this way fieldtirp
% does the bookeeping for ya.!

% for more info check this tutorial: http://www.fieldtriptoolbox.org/tutorial/preprocessing/

cfg                             = [];
cfg.dataset                     = cfg_in.dsFileName;
cfg.trialfun                    = 'ft_trialfun_general';
cfg.trialdef.eventtype          = cfg_in.eventtype;
cfg.trialdef.eventvalue         = cfg_in.eventvalue;
cfg.trialdef.prestim            = cfg_in.prestim;
cfg.trialdef.poststim           = cfg_in.poststim;
cfg                             = ft_definetrial(cfg);

if isfield(cfg_in,'behav')
    cfg.trl                  	= [cfg.trl cfg_in.behav];
end


% save data as single precision to save space

cfg                             = all_cfg.first_cue;
cfg.channel                     = {'MEG'};
cfg.continuous                  = 'yes';
cfg.bsfilter                    = 'yes';
cfg.bsfreq                      = [49 51; 99 101; 149 151];
cfg.precision                   = 'single';
data                            = ft_preprocessing(cfg);

% DownSample to 300Hz [nyquist = 150]
cfg                             = [];
cfg.resamplefs                  = 300;
cfg.detrend                     = 'no';
cfg.demean                      = 'no';
data                            = ft_resampledata(cfg, data);