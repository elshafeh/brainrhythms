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

% only plot the top 5% of power values
% mask_val                   = max(source_diff_int_spm.pow,[],'all') * 0.65;
% mask_idx                   = source_diff_int_spm.pow > mask_val;
% source_diff_int_spm.mask   = source_diff_int_spm.pow .* mask_idx;
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
        viewvector      = [1 0 0]; % point describing a vector from where the camera is located in space
        viewvector2     = [-1 0 0];
    case 'motor'
        surffile        = 'surface_white_left.mat';
        viewvector      = [-1 0 0]; % point describing a vector from where the camera is located in space
        viewvector2     = [1 0 0];
end

% actual sourceplot code
cfg                     = [];
cfg.funparameter        = 'mask';
cfg.maskparameter       = cfg.funparameter;

% if strcmp(modality,'motor')
%     atlas                   = ft_read_atlas('/home/common/matlab/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
%     cfg                     = [];
%     cfg.inputcoord          = 'mni';
%     cfg.atlas               = atlas;
%     cfg.roi                 = {'Precentral_L','Supp_Motor_Area_L'};
%     roi_mask                = ft_volumelookup(cfg,source_diff_int_spm);
%     source_diff_int_spm.roi_mask = roi_mask;
%     
%     % cfg stuff for sourceplot
%     cfg                     = [];
%     cfg.funparameter        = 'mask';
%     cfg.maskparameter       = 'roi_mask';
% end

cfg.method              = 'surface';
cfg.surffile            = surffile;
cfg.funcolormap         = 'jet';
cfg.opacitymap          = 'rampup';
cfg.colorbar            = 'yes';

% % have it wait to get the camera into the right orientation to save fig
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
% 
% % uiwait(fig);

% mask the irrelevant hemisphere
% maskdim                 = source_diff_int.dim;
% xdim                    = maskdim(1);
% mask                    = zeros(maskdim);
% switch modality    
%     case 'auditory' 
%         mask(xdim/2+1:xdim,:,:) = 1;
%         mask                    = find(mask == 0);
%         source_diff_int.mask    = source_diff_int.pow;
%         source_diff_int.mask(mask)  = -1; % set all values inside of the mask to -1
%         
%     case 'motor'
%         % define motor region if necessary based on participant
%         if subj_num == 19
%             mask(1:xdim/2,100:125,65:100)       = 1;
%         elseif subj_num == 21
%             mask(1:xdim/2,40:60,70:100)         = 1;
%         elseif subj_num == 24
%             mask(1:xdim/2,60:75,75:110)         = 1;
%         elseif subj_num == 26
%             mask(1:xdim/2,60:80,70:95)          = 1;
%         elseif subj_num == 27
%             mask(1:xdim/2,70:100,70:100)        = 1;
%         elseif subj_num == 28
%             mask(1:xdim/2,60:90,75:110)         = 1;
%         elseif subj_num == 3
%             mask(1:xdim/2,50:70,70:100)         = 1;
%         elseif subj_num == 34
%             mask(1:xdim/2,50:65,75:100)         = 1;
%         else
%             mask(1:xdim/2,:,:)                  = 1;
%         end
%         mask                    = find(mask == 0);
%         source_diff_int.mask    = source_diff_int.pow;
%         source_diff_int.mask(mask)  = -1; % set all values inside of the mask to -1
% end
% 
% % plot
% cfg                     = [];
% cfg.funparameter        = 'mask';
% cfg.maskparameter       = cfg.funparameter;
% cfg.method              = 'ortho';
% cfg.funcolormap         = 'jet';
% cfg.opacitymap          = 'rampup';
% cfg.colorbar            = 'yes';
% cfg.funcolorlim         = [0 max(source_diff_int.pow)];
% 
% source_diff_int_half    = source_diff_int;
% 
% ft_sourceplot(cfg,source_diff_int);
        
% save([source_path filename],'source_diff_int_half','-v7.3','-append');


%% save figure

% if save_plot == 1
%     savefile                = strcat(savepath,'s',num2str(subj_num),'_',modality,'_source');
%     saveas(gcf,savefile,'png');
% end

end
