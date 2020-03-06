%% MTA project command script to run functions through all participants
% By Wy Ming Lin, Lab rotation/internship
% last updated 14.02.2020

%% Settings

whichfun            = 5;
modality            = 'motor'; 
subjs               = 'audmotor';
where2run           = 'locally'; 
save_plot           = 1; 

% relevant for virtual sensors and connectivity
tlock               = 'target'; 
twin                = [-1 0]; 
cycles2keep         = [2.5 3 3.5 4]; 
phases2keep         = [1 3];

%% Info for settings
%
% // What settings are needed for each function
%
% mta1_prep4coreg           -> whichfun = 1; modality; subjs; where2run
% mta2_coreg                -> whichfun = 2; subjs; where2run
% mta3_sourceanalysis       -> whichfun = 3; subjs; modality; where2run
% mta3_sourceanalysis_plot  -> whichfun = 35; subjs; modality; where2run; save_plot
% mta4_virtualsensors       -> whichfun = 4; subjs; modality; where2run; tlock; twin; cycles2keep; phases2keep
% mta4_virtualsensors_plot  -> whichfun = 45; subjs; modality; where2run; save_plot
% mta5_connectivity         -> whichfun = 5; subjs; modality; where2run; tlock; twin; cycles2keep; phases2keep
% mta5_connectivity_plot    -> whichfun = 55; subjs; modality; where2run; save_plot
%
% // Description of settings
%
% whichfun          = 1, 2, 3, 4, or 5
%                     1  -> mta1_prep4coreg
%                     2  -> mta2_coreg
%                     3  -> mta3_sourceanalysis
%                     35 -> mta3_sourceanalysis_plot
%                     4  -> mta4_virtualsensors
%                     45 -> mta4_virtualsensors_plot
%                     5  -> mta5_connectivity
%                     55 -> mta5_connectivity_plot
%
% modality          = 'auditory' or 'motor'
% 
% subjs             = subject numbers that you want to loop through,
%                     'all', 'aud_subjs', 'motor_subjs', or 'audmotor'
%
% where_to_run      = 'locally' or 'cluster'
%
% save_plot         = 0 or 1, only necessary for plotting functions
%                     0 -> no saving
%                     1 -> yes saving
%
% %% relevant settings for virtual sensors and connectivity
%
% tlock             = where to timelock
%                     'cueonset', 'cueoffset', or 'target'
%
% twin              = time window of interest
%                     [beg end]
%
% cycles2keep       = which cycles to keep in the analyses, ie cycle that
%                     the target occurs at
%
% phases2keep       = which phases do you want to keep in the analyses
%                     1 -> in phase
%                     2 -> out of phase
%                     3 -> random


%% add paths

restoredefaultpath
addpath /project/3016057.03/project_mta/functions/

% cluster specific stuff
addpath /home/common/matlab/fieldtrip/qsub/
cd /project/3016057.03/project_mta/scripts/cluster/ % changes directory to save all the cluster output stuff here, pretty useless stuff unless you're debugging and need to see what the error is
memreq              = 64 * ((1000 * 1024) * 1024);
timreq              = 30 * 60;

%% define subjects

subjects            = [1 2 3 5 6 8 9 11 12 13 14 16 17 18 19 21 22 24 25 26 27 28 29 30 31 32 33 34 35];
aud_subjs           = [2 3 5 6 8 11 12 13 16 21 22 24 25 26 28 29 30 31 32 34 35];
motor_subjs         = [1 2 5 6 8 11 12 14 16 17 18 19 21 22 24 26 27 28 29 31 32 33 35];
audmotor            = [1 2 3 5 6 8 11 12 16 21 22 24 26 28 29 31 32 34 35];

if isa(subjs,'double')
    subjects        = subjs;
elseif isa(subjs,'char')
    switch subjs
        case 'all'
            subjects = subjects; % seems ridiculous
        case 'aud_subjs'
            subjects = aud_subjs;
        case 'motor_subjs'
            subjects = motor_subjs;
        case 'audmotor'
            subjects = audmotor;
    end
end

%% display chosen function and parameters

disp('###########');
switch whichfun
    case 1
        disp('running function mta1_prep4coreg');
        fprintf('modality: %s\n',modality);
    case 2
        disp('running function mta2_coreg')
    case 3
        disp('running function mta3_sourceanalysis');
        fprintf('modality: %s\n',modality);
    case 35
        disp('running function mta3_sourceanalysis_plot');
        fprintf('modality: %s\n',modality);
        fprintf('save plot: %d\n',save_plot);
    case 4
        disp('running function mta4_virtualsensors');
        fprintf('modality: %s\n',modality);
        fprintf('time lock: %s\n',tlock);
        fprintf('time window: [%d %d]\n',twin(1),twin(2));
        fprintf('cycles kept in analysis: [ ');
        for cycle=1:length(cycles2keep);fprintf('%f1 ',round(cycles2keep(cycle),1));end;fprintf(']\n');
        fprintf('phases kept in analysis: [ ');
        for phase=1:length(phases2keep);fprintf('%d ',phases2keep(phase));end;fprintf(']\n');
    case 45
        disp('running function mta4_virtualsensors_plot');
        fprintf('modality: %s\n',modality);
        fprintf('save plot: %d\n',save_plot);
    case 5
        disp('running function mta5_connectivity');
        fprintf('time lock: %s\n',tlock);
        fprintf('time window: [%d %d]\n',twin(1),twin(2));
        fprintf('cycles kept in analysis: [ ');
        for cycle=1:length(cycles2keep);fprintf('%f1 ',round(cycles2keep(cycle),1));end;fprintf(']\n');
        fprintf('phases kept in analysis: [ ');
        for phase=1:length(phases2keep);fprintf('%d ',phases2keep(phase));end;fprintf(']\n');
    case 55
        disp('running function mta5_connectivity_plot');
        fprintf('save plot: %d\n',save_plot);
end

%% run chosen function

if strcmp(where2run,'locally')

    for i=1:length(subjects)
        currsubj        = subjects(i);
        switch whichfun
            case 1
                mta1_prep4coreg(currsubj,modality);
            case 2
                mta2_coreg(currsubj);
            case 3
                addpath /project/3016057.03/project_mta/functions/
                mta3_sourceanalysis(currsubj,modality);
            case 35
                addpath /project/3016057.03/project_mta/functions/
                mta3_sourceanalysis_plot(currsubj,modality,save_plot);
            case 4
                addpath /project/3016057.03/project_mta/functions
                mta4_virtualsensors(currsubj,modality,tlock,twin,cycles2keep,phases2keep);
            case 45
                mta4_virtualsensors_plot(currsubj,modality,save_plot);
            case 5
                mta5_connectivity(currsubj,tlock,twin,cycles2keep,phases2keep);
            case 55
                mta5_connectivity_plot(currsubj,save_plot);
        end
        
    fprintf('\n####### step %d for subject %d is done #######\n\n',whichfun,currsubj);
        
    end

elseif strcmp(where2run,'cluster')
    
    for i=1:length(subjects)
        currsubj        = subjects(i);
        switch whichfun
            case 1
                qsubfeval('mta1_prep4coreg',currsubj,modality,'timreq',timreq,'memreq',memreq);
            case 2
                qsubfeval('mta2_coreg',currsubj,'timreq',timreq,'memreq',memreq);
            case 3
                qsubfeval('mta3_sourceanalysis',currsubj,modality,'timreq',timreq,'memreq',memreq);
            case 35
                addpath /project/3016057.03/project_mta/functions/
                qsubfeval('mta3_sourceanalysis_plot',currsubj,modality,save_plot,'timreq',timreq,'memreq',memreq);
            case 4
                qsubfeval('mta4_virtualsensors',currsubj,modality,tlock,twin,cycles2keep,phases2keep,'timreq',timreq,'memreq',memreq);
            case 45
                qsubfeval('mta4_virtualsensors_plot',currsubj,modality,save_plot,'timreq',timreq,'memreq',memreq);
            case 5
                qsubfeval('mta5_connectivity',currsubj,tlock,twin,cycles2keep,phases2keep,'timreq',timreq,'memreq',memreq);
            case 55
                qsubfeval('mta5_connectivity_plot',currsubj,save_plot,'timreq',timreq,'memreq',memreq);
        end
    end
    
end

%% just look at the plots you saved
if save_plot == 1
    close all
end



