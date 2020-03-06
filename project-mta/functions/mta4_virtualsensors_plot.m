function mta4_virtualsensors_plot(subj_num,modality,varargin)
% MTA4_VIRTUALSENSORS_PLOT takes the virtual sensors output from
% mta4_virtualsensors and plots the corresponding power spectrum and ITC
% spectrum for the right and left hemispheres
%
% Use as
%
%       mta4_virtualsensors_plot(subj_num,modality,save_plot)
%       subj_num        = integer value of the subject number
%       modality        = 'auditory' or 'motor' to determine which file to
%                         read
%       save_plot       = 0 or 1, tells the function whether or not to save
%                         the plot (default = 1);

%%

addpath /home/common/matlab/fieldtrip/
ft_defaults;

if isempty(varargin)
    save_plot = 1;
elseif ~isempty(varargin)
    if length(varargin) > 1
        error('only input 0 or 1 for saving the plot');
    elseif length(varargin) == 1
        save_plot = varargin{1};
    end
end

%%

virtualsenspath         = '/project/3016057.03/project_mta/output/virtualsensors/';
savepath                = [virtualsenspath modality '/'];
load([virtualsenspath 's' num2str(subj_num) '_' modality '_virtualchannels.mat']);

%% PLOT

% fft
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1)
% 0-40 Hz
cfg                     = [];
cfg.showlabels          = 'yes';
ft_singleplotER(cfg,all_fft);
title('fft 0-40 Hz');
% zoom in 0-10Hz
subplot(2,2,2);
cfg.xlim                = [0 10];
ft_singleplotER(cfg,all_fft);
title('fft 0-10 Hz');

% itc
subplot(2,2,3)
% 0-40 Hz
cfg                     = [];
cfg.showlabels          = 'yes';
ft_singleplotER(cfg,all_itc);
title('itc 0-40 Hz');
% zoom in 0-10Hz
subplot(2,2,4);
cfg.xlim                = [0 10];
ft_singleplotER(cfg,all_itc);
title('itc 0-10 Hz');

suptitle(sprintf('subj s%d', subj_num));

%% save
if save_plot == 1
    savefile                = strcat(savepath,'s',num2str(subj_num),'_',modality,'_virtsens');
    saveas(gcf,savefile,'png');
end

end
