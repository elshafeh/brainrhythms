function [x,y1_avgs,y1_sems,y2_avgs,y2_sems] = mta6_grandaverage(whichfun,varargin)
% MTA6_GRANDAVERAGE takes the given function number and computes the grand
% average of the data computed by that function. If multiple versions of
% the data are computed (eg. different segment lengths), best to run the
% previous function first before this one.
%
% Use as
%   
%           mta6_grandaverage(whichfun,modality);
%           whichfun        = function number to use
%                             4 = mta4_virutalsensors
%                             5 = mta5_connectivity
%
%           modality        = 'auditory' or 'motor' -- only necessary for
%                             mta4_virtualsensors
%

%%

addpath /home/mrphys/wylin/toolboxes/


switch whichfun
    
    case 4 % mta4_virtualsensors
        
        %% get files
        filepath        = '/project/3016057.03/project_mta/output/virtualsensors/';
        savepath        = '/project/3016057.03/project_mta/output/virtualsensors/grandavg/';
        modality        = varargin{1};
        files           = dir([filepath '*' modality '_virtualchannels.mat']);
        
        %% load files
        nSubj           = length(files);
        % read in first file to get dimensions
        load([filepath files(1).name],'rhyt_fft','rhyt_itc','rand_fft','rand_itc');
        rhyt_ffts       = zeros(nSubj,length(rhyt_fft.freq)-1);
        rhyt_itcs       = zeros(nSubj,length(rhyt_itc.freq)-1);
        
        rand_ffts       = zeros(nSubj,length(rand_fft.freq)-1);
        rand_itcs       = zeros(nSubj,length(rand_itc.freq)-1);
        
        %% compute grand average
        for i=1:nSubj
            
            if i ~= 1
                load([filepath files(i).name],'rhyt_fft','rhyt_itc','rand_fft','rand_itc');
            end

            rhyt_ffts(i,:)   = rhyt_fft.powspctrm(2:end);
            rhyt_itcs(i,:)   = rhyt_itc.powspctrm(2:end);
            
            rand_ffts(i,:)   = rand_fft.powspctrm(2:end);
            rand_itcs(i,:)   = rand_itc.powspctrm(2:end);
            
        end
        
        freqs           = rhyt_fft.freq(2:end);
        %% plot 
        freq10idx       = find(freqs == 10);
        figure;%('units','normalized','outerposition',[0 0 1 1]);
        
        x = freqs;
        y1_avgs = mean(rhyt_ffts);
        y1_sems = std(rhyt_ffts)/sqrt(size(rhyt_ffts, 1));
        y2_avgs = mean(rand_ffts);
        y2_sems = std(rand_ffts)/sqrt(size(rand_ffts, 1));
    
        % fft 0-40 Hz
        subplot(2,2,1);
        shadedErrorBar(x, y1_avgs, y1_sems, 'lineprops','-b');
        hold on;
        shadedErrorBar(x, y2_avgs, y2_sems, 'lineprops','-g');
        title('fft 0-40 Hz');
        xlabel('frequencies');
        ylabel('power');
        legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
        
        % fft 0-10 Hz
        subplot(2,2,2);
        shadedErrorBar(x(1:freq10idx), y1_avgs(1:freq10idx), y1_sems(1:freq10idx), 'lineprops','-b');
        hold on;
        shadedErrorBar(x(1:freq10idx), y2_avgs(1:freq10idx), y2_sems(1:freq10idx), 'lineprops','-g');
        title('fft 0-10 Hz');
        xlabel('frequencies');
        ylabel('power');
        legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
        
        x = freqs;
        y1_avgs = mean(rhyt_itcs);
        y1_sems = std(rhyt_itcs)/sqrt(size(rhyt_itcs, 1));
        y2_avgs = mean(rand_itcs);
        y2_sems = std(rand_itcs)/sqrt(size(rand_itcs, 1));
        
        % itc 0-40 Hz
        subplot(2,2,3);
        shadedErrorBar(x, y1_avgs, y1_sems, 'lineprops','-b');
        hold on;
        shadedErrorBar(x, y2_avgs, y2_sems, 'lineprops','-g');
        title('itc 0-40 Hz');
        xlabel('frequencies');
        ylabel('power');
        legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
        
        % itc 0-10 Hz
        subplot(2,2,4);
        ax = shadedErrorBar(x(1:freq10idx), y1_avgs(1:freq10idx), y1_sems(1:freq10idx), 'lineprops','-b');
        hold on;
        shadedErrorBar(x(1:freq10idx), y2_avgs(1:freq10idx), y2_sems(1:freq10idx), 'lineprops','-g');
        title('Intertrial Phase Coherence');
        xlabel('Frequency');
        ylabel('ITC');
        legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');

        
        
    case 5 % mta5_connectivity
        
        %% get files
        filepath        = '/project/3016057.03/project_mta/output/connectivity/';
        savepath        = '/project/3016057.03/project_mta/output/connectivity/grandavg';
        files           = dir([filepath '*connectivity.mat']);
        
        %% load files
        nSubj           = length(files);
        % read in first file to get dimensions
        load([filepath files(1).name],'coh_rhyt','coh_rand','ppc_rhyt','ppc_rand');
        cohs_rhyt       = zeros(nSubj,length(coh_rhyt.freq));
        cohs_rand       = zeros(nSubj,length(coh_rand.freq));
        ppcs_rhyt       = zeros(nSubj,length(ppc_rhyt.freq));
        ppcs_rand       = zeros(nSubj,length(ppc_rand.freq));
        
        %% compute grand average
        for i=1:nSubj
            
            if i ~= 1
                load([filepath files(i).name],'coh_rhyt','coh_rand','ppc_rhyt','ppc_rand');
            end
            
            cohs_rhyt(i,:)  = squeeze(coh_rhyt.cohspctrm(2,1,:));
            cohs_rand(i,:)  = squeeze(coh_rand.cohspctrm(2,1,:));
            ppcs_rhyt(i,:)  = squeeze(ppc_rhyt.ppcspctrm(2,1,:));
            ppcs_rand(i,:)  = squeeze(ppc_rand.ppcspctrm(2,1,:));
            
        end

        freqs           = coh_rhyt.freq;
        
        %% plot
        
        freq10idx       = find(freqs==15);
        figure;%('units','normalized','outerposition',[0 0 1 1]);
        
        x = freqs;
        y1_avgs = mean(cohs_rhyt);
        y1_sems = std(cohs_rhyt)/sqrt(size(cohs_rhyt, 1));
        y2_avgs = mean(cohs_rand);
        y2_sems = std(cohs_rand)/sqrt(size(cohs_rand, 1));
        
        % coh 0-40 Hz
        subplot(2,2,1);
        shadedErrorBar(x, y1_avgs, y1_sems, 'lineprops','-b')
        hold on;
        shadedErrorBar(x, y2_avgs, y2_sems, 'lineprops','-g')
        title('coherence 0-40 Hz');
        xlabel('frequencies');
        ylabel('coherence');
        legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
        
        coh 0-10 hz
        subplot(2,2,2);
        shadedErrorBar(x(1:freq10idx), y1_avgs(1:freq10idx), y1_sems(1:freq10idx), 'lineprops','-b')
        hold on;
        shadedErrorBar(x(1:freq10idx), y2_avgs(1:freq10idx), y2_sems(1:freq10idx), 'lineprops','-g')
        hold off;
        title('coherence 0-10 Hz');
        xlabel('frequencies');
        ylabel('coherence');
        legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
        
        x = freqs;
        y1_avgs = mean(ppcs_rhyt);
        y1_sems = std(ppcs_rhyt)/sqrt(size(ppcs_rhyt, 1));
        y2_avgs = mean(ppcs_rand);
        y2_sems = std(ppcs_rand)/sqrt(size(ppcs_rand, 1));
        
        % ppc 0-40 Hz
        subplot(2,2,3);
        shadedErrorBar(x, y1_avgs, y1_sems, 'lineprops','-b')
        hold on;
        shadedErrorBar(x, y2_avgs, y2_sems, 'lineprops','-g')
        hold off;
        title('ppc 0-40 Hz');
        xlabel('frequencies');
        ylabel('ppc');
        legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
        
        % ppc 0-10 Hz
        subplot(2,2,4);
        shadedErrorBar(x(1:freq10idx), y1_avgs(1:freq10idx), y1_sems(1:freq10idx), 'lineprops','-b')
        hold on;
        shadedErrorBar(x(1:freq10idx), y2_avgs(1:freq10idx), y2_sems(1:freq10idx), 'lineprops','-g')
        title('ppc 0-10 Hz');
        xlabel('frequencies');
        ylabel('ppc');
        legend({'rhythmic','random'},'orientation','horizontal','location','southoutside');
%         
end



end
