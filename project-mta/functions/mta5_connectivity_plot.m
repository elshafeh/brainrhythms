function mta5_connectivity_plot(subj_num,varargin)
% MTA5_connectivity computes the coherence and ppc of the virtual sensors
% for the auditory and motor sources.
%
% Use as 
%
%       mta5_connectivity(subj_num)
% 
%       subj_num        = participant number as an integer

%% setup

if isempty(varargin)
    save_plot = 1;
elseif ~isempty(varargin)
    if length(varargin) > 1
        error('only input 0 or 1 for saving the plot');
    elseif length(varargin) == 1
        save_plot = varargin{1};
    end
end

addpath /home/common/matlab/fieldtrip/
ft_defaults;

datapath                = '/project/3016057.03/project_mta/output/connectivity/';
savepath                = '/project/3016057.03/project_mta/output/connectivity/plots/';

%% load data

subj                    = ['s' num2str(subj_num)];
load([datapath subj '_connectivity.mat']);

%% plot coh and ppc

% coh
coh_x                   = coh_rhyt.freq;
coh_rhyt_y              = squeeze(coh_rhyt.cohspctrm(2,1,:));
coh_rand_y              = squeeze(coh_rand.cohspctrm(2,1,:));
coh10idx                = find(coh_x == 10);
coh_x10                 = coh_x(1:coh10idx);
coh_rhyt_y10            = coh_rhyt_y(1:coh10idx);
coh_rand_y10            = coh_rand_y(1:coh10idx);

% ppc
ppc_x                   = ppc_rhyt.freq;
ppc_rhyt_y              = squeeze(ppc_rhyt.ppcspctrm(2,1,:));
ppc_rand_y              = squeeze(ppc_rand.ppcspctrm(2,1,:));
ppc10idx                = find(ppc_x == 10);
ppc_x10                 = ppc_x(1:ppc10idx);
ppc_rhyt_y10            = ppc_rhyt_y(1:ppc10idx);
ppc_rand_y10            = ppc_rand_y(1:ppc10idx);

% plot the two in one
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1);
hold on
plot(coh_x,coh_rhyt_y,'b');
plot(coh_x,coh_rand_y,'r');
hold off
legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
title('coh 0-40 Hz');
subplot(2,2,2);
hold on
plot(coh_x10,coh_rhyt_y10,'b');
plot(coh_x10,coh_rand_y10,'r');
hold off
legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
title('coh 0-10 Hz');
subplot(2,2,3);
hold on
plot(ppc_x,ppc_rhyt_y,'b');
plot(ppc_x,ppc_rand_y,'r');
hold off
legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
title('ppc 0-40 Hz');
subplot(2,2,4);
hold on
plot(ppc_x10,ppc_rhyt_y10,'b');
plot(ppc_x10,ppc_rand_y10,'r');
hold off
legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
title('ppc 0-10 Hz');
suptitle(sprintf('%s connectivity',subj));

%% save

if save_plot == 1
    savefile                = strcat(savepath,subj,'connectivity');
    saveas(gcf,savefile,'png');
end

end