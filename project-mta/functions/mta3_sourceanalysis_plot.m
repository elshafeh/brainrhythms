function mta3_sourceanalysis_plot(subj_num,modality,varargin)
% MTA3_SOURCEANALYSIS_PLOT takes the the output of mta3_sourceanalysis
% and plots the interpolated differences of the source with the cross hairs
% pointing to the max source. Note the function only
% works after mta3_sourceanalysis has been run. 
%
% Use as 
%
%       mta3_sourceanalysis_plot(subj_num,modality,save_plot)
%
%       subj_num        = integer value of the subject number
%       modality        = 'auditory' or 'motor' to determine which file to
%                         read
%       save_plot       = 0 or 1, tells the function whether or not to save
%                         the plot (default = 1);
%

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

source_path             = '/project/3016057.03/project_mta/output/sourceanalysis/';
subj                    = ['s' num2str(subj_num)];
filename                = [subj '_' modality '_sourceanalysis.mat'];
savepath                = [source_path modality '_source/'];

load([source_path filename],'source_diff_int_spm');

%% plot
% project-mta: plot motor on left hemisphere and auditory on right

% only plot the top 5% of power values
[val,idx] = sort(source_diff_int_spm.pow(:),'MissingPlacement','First');
top95idx = round(length(idx) * 0.95);
minval = val(top95idx);
mask_idx                   = source_diff_int_spm.pow > minval;
source_diff_int_spm.mask   = source_diff_int_spm.pow .* mask_idx; 


% determine which hemisphere to plot and how to view
% play around with the view
switch modality
    case 'auditory'
        surffile        = 'surface_white_right.mat';
        viewvector      = [1 0 0]; 
        viewvector2     = [-1 0 0]; % view from midplane
    case 'motor'
        surffile        = 'surface_white_left.mat';
        viewvector      = [-1 0 0]; 
        viewvector2     = [1 0 0]; % view from midplace
end

% actual sourceplot code
cfg                     = [];
cfg.funparameter        = 'mask';
cfg.maskparameter       = cfg.funparameter;
cfg.method              = 'surface';
cfg.surffile            = surffile;
cfg.funcolormap         = 'jet';
cfg.opacitymap          = 'rampup';
cfg.colorbar            = 'yes';

% have it wait to get the camera into the right orientation to save fig
ft_sourceplot(cfg,source_diff_int_spm);
view(viewvector); % turns the camera to the right orientation
camlight HEADLIGHT
if save_plot == 1
    savefile                = strcat(savepath,'s',num2str(subj_num),'_',modality,'_source1');
    saveas(gcf,savefile,'png');
end

view(viewvector2);
camlight HEADLIGHT
if save_plot == 1
    savefile                = strcat(savepath,'s',num2str(subj_num),'_',modality,'_source2');
    saveas(gcf,savefile,'png');
end


%% save figure

if save_plot == 1
    savefile                = strcat(savepath,'s',num2str(subj_num),'_',modality,'_source');
    saveas(gcf,savefile,'png');
end

end
