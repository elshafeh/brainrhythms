%
% Preprocess MRI data for the PredAlpha project.
% REF: http://www.fieldtriptoolbox.org/tutorial/sourcemodel/#construction-of-a-source-model-based-on-a-surface-description-of-the-cortical-sheet
%
%
% JY (April, 2020)
%
%


clearvars; close all; clc;

addpath(genpath('/project/3018041.02'));
if isempty(which('ft_defaults')) %when fieldtrip is not yet in the path
    addpath('/home/common/matlab/fieldtrip');
    addpath('/home/common/matlab/fieldtrip/qsub/');
    ft_defaults;
end


%% define global params for subject of interest

SubjectID = str2double( input('Specify SubjectID:\n','s') );

% define subject-specifc path and files
p = jy_definepath_predalpha( SubjectID );

% define which stage we are interested in running
step1  = 'Pre- FreeSurfer';
step2  = 'Post- FreeSurfer';
step3  = 'construct sourcemodel';
answer = questdlg('Indicate the step of preprocessing:',...
    'step quest', step1, step2, step3, step1);


%%
switch answer %jump to different stages
    
    case step1 %prepare for and send job to freesurfer

        %% Co-registration to CTF and ACPC coordinates
        % The one in CTF coordinates will be used for creation of head model.
        % The one in ACPC coordinates will be used for creation of cortical sheet.
        
        % ====== Align volume to CTF coordsys: check if this has been done. ======
        
        if exist([p.filePreprocMRI,'.mat'],'file') %if this is done in "JY_preproc_anatomy"
            
            
            % see JY_preproc_anatomy.m for processing details.
            % note that this aligns the dicom images to CTF.
            load( p.filePreprocMRI, 'mri_realigned' );
            
        else
            
            warning('Please run JY_preproc_anatomy first!'); 
            
            % ============= from JY_preproc_anatomy ==============
            %{
            % read the dicom files
            mri = ft_read_mri([p.MRI_dicom(3).folder, filesep, p.MRI_dicom(3).name]);
            
            % manually align the MRI to the CTF coordsys
            cfg            = [];
            cfg.method     = 'interactive';
            cfg.coordsys   = 'ctf';
            mri_realigned0 = ft_volumerealign(cfg, mri);
            
            % refine the coregistration based on the polhemus point cloud
            if ~isempty( p.filePolhemus )
                
                h = [p.filePolhemus.folder, filesep, p.filePolhemus.name];
                
                polhemus = ft_read_headshape( h );
                polhemus.pos(polhemus.pos(:,3)<-10,:)=[];
                polhemus.unit ='cm';
                
                cfg                         = [];
                cfg.coordsys                = 'ctf';
                cfg.parameter               = 'anatomy';
                cfg.viewresult              = 'yes';
                cfg.method                  = 'headshape';
                cfg.headshape.headshape     = polhemus;
                cfg.headshape.interactive   = 'yes';
                cfg.headshape.icp           = 'no';
                mri_realigned = ft_volumerealign(cfg, mri_realigned0);
                
            else
                
                mri_realigned = mri_realigned0;
                
            end
            %}
            
            return;
            
        end
        
        
        % ========= Align the resliced volume to acpc coordinates ==========
        % Note the ACPC coordinates are defined exactly as the MNI coordinates
        % system. For details, see:
        % http://www.fieldtriptoolbox.org/faq/how_are_the_different_head_and_mri_coordinate_systems_defined/#details-on-the-acpc-coordinate-system
        
        % read the dicom files
        mri = ft_read_mri([p.MRI_dicom(3).folder, filesep, p.MRI_dicom(3).name]);
        
        % manually align the volume (from dicom file) to acpc coordinates
        cfg              = [];
        cfg.method       = 'interactive';
        cfg.coordsys     = 'acpc';
        mri_acpc         = ft_volumerealign(cfg, mri);
        
        % reslice the volumn into 3D 256x256x256
        % note that reslicing of the dicom file would lead to changes.
        cfg                 = [];
        cfg.resolution      = 1;
        cfg.dim             = [256 256 256];
        mri_resliced        = ft_volumereslice(cfg, mri_acpc);
        
        % save the transformation matrics to disk
        transform_vox2acpc = mri_acpc.transform;
        transform_vox2ctf  = mri_realigned.transform;
        transform_acpc2ctf = transform_vox2ctf/transform_vox2acpc;
        save( p.filePreprocMRI, 'transform_acpc2ctf','transform_vox2acpc','transform_vox2ctf', '-append');
        
        % save mri_acpc in mgz format (as freesurfer input)
        cfg           = [];
        cfg.filename  = fullfile(p.dirMriData, '4FreeSurfer', num2str(SubjectID), ['Subject',num2str(SubjectID)]);
        cfg.filetype  = 'mgz';
        cfg.parameter = 'anatomy';
        ft_volumewrite(cfg, mri_resliced);
        
        
        %% Strip the skull using FSL
        %{ 
        % Note that this is done because "one step which in our experience is
        % notorious for not being very robust in older versions of FreeSurfer is
        % automatic skull-stripping. Therefore, we used to advocate a hybrid
        % approach that uses SPM or FSL for an initial segmentation of the
        % anatomical MRI during the preparation." and thus the use of FSL.
        
        p.fileSkullstrip = fullfile(p.dirMriData, '4FreeSurfer', num2str(SubjectID), 'preproc', 'skullstrip');
        
        % FSL variables
        threshold  = 0.5;
        T          = inv(mri_acpc.transform);
        center     = round(T(1:3,4))';
        
        % name for the temporary nifti file
        temp = fullfile(p.dirMriData, 'nifti_tmp');
        
        % Convert to nifti temporarily and save;
        cfg             = [];
        cfg.filename    = temp;
        cfg.filetype    = 'mgz';%'nifti';
        cfg.parameter   = 'anatomy';
        ft_volumewrite(cfg, mri_acpc);
        
        % Create the FSL command-string
        str = ['/opt/fsl/5.0.9/bin/bet ',temp,'.nii ',temp];
        str = [str,'-R -f ',num2str(threshold),' -c ', num2str(center),' -g 0 -m -v'];
        
        % Call the FSL command-string
        system(str);
        
        % Read the FSL-based segmentation
        seg  = ft_read_mri([temp,'-R.nii.gz']);
        delete([temp,'.nii']);
        delete([temp,'-R.nii.gz']);
        delete([temp,'-R_mask.nii.gz']);
        
        % Save the FSL-based segmentation in .mgz
        cfg             = [];
        cfg.filename    = p.fileSkullstrip;
        cfg.filetype    = 'mgz';
        cfg.parameter   = 'anatomy';
        ft_volumewrite(cfg, seg);
        
        % Check the plot already now
        mri_skullstrip  = ft_read_mri([p.fileSkullstrip '.mgz']);
        cfg             = [];
        cfg.interactive = 'yes';
        ft_sourceplot(cfg, mri_skullstrip);
        %}
        %}
        
        
        %% Call FreeSurfer to reconstruct the cortical sheet
        cfg          = [];
        cfg.dirname  = fullfile(p.dirMriData, '4FreeSurfer',num2str(SubjectID));
        cfg.subjname = ['Subject',num2str(SubjectID)];
        
        qsubfeval('jy_batch_freesurfer', cfg, 1,...
            'memreq', 16*1024^3, 'timreq', 28*60^2, 'batchid', sprintf('freesurfer_%d', SubjectID));

        
        
    case step2 %check outputs from freesurfer and continue
        
        %% Check intermin outputs (e.g., segmenation).
        anatomy_preproc_dir = fullfile( p.dirMriData, '4FreeSurfer', num2str(SubjectID), ['Subject',num2str(SubjectID)] );
                
        t1               = fullfile(anatomy_preproc_dir, 'mri', 'T1.mgz'); % 'mri' needed?
        normalization2   = fullfile(anatomy_preproc_dir, 'mri', 'brain.mgz');
        white_matter     = fullfile(anatomy_preproc_dir, 'mri', 'wm.mgz');
        white_matter_old = fullfile(anatomy_preproc_dir, 'mri', 'wm_old.mgz');

        % Show T1
        mri             = ft_read_mri(t1);
        cfg             = [];
        cfg.interactive = 'yes';
        ft_sourceplot(cfg, mri);
        set(gcf, 'name', [num2str(SubjectID) ' ' 'T1'], 'numbertitle', 'off');

        % Show skullstripped image
        mri             = ft_read_mri(normalization2);
        cfg             = [];
        cfg.interactive = 'yes';
        ft_sourceplot(cfg, mri);
        set(gcf, 'name', [num2str(SubjectID) ' ' 'skull-stripped'], 'numbertitle', 'off');

        % Show white matter image
        mri             = ft_read_mri(white_matter);
        cfg             = [];
        cfg.interactive = 'yes';
        ft_sourceplot(cfg, mri);
        set(gcf, 'name', [num2str(SubjectID) ' ' 'white matter'], 'numbertitle', 'off');
        
        if exist(white_matter_old, 'file')
            mri            = ft_read_mri(white_matter_old);
            cfg            = [];
            cfg.interactive = 'yes';
            ft_sourceplot(cfg, mri);
            set(gcf, 'name', [num2str(SubjectID) ' ' 'white matter old'], 'numbertitle', 'off');            
        end
        
        
        %% Finish the preprocesing or cortical sheet
        % When working at the DCCN cluster, we need to first load the
        % hcp-workbench (type "module load hcp-workbench" in a newly opened
        % terminal session). And then, we can start matlab use matlab to
        % send job to cluster for parallel processing.
        
        cfg          = [];
        cfg.dirname  = fullfile(p.dirMriData, '4FreeSurfer',num2str(SubjectID));
        cfg.subjname = ['Subject',num2str(SubjectID)];
        
        qsubfeval('jy_batch_freesurfer', cfg, 2,...
            'memreq', 8*1024^3, 'timreq', 0.5*60^2, 'batchid', sprintf('workbench_%d', SubjectID));
        
        
        
    case step3 %construct leadfield and save
        
        datapath = fullfile(p.dirMriData, '4FreeSurfer',num2str(SubjectID), ['Subject',num2str(SubjectID)], 'workbench');
        filename = fullfile(datapath, ['Subject', num2str(SubjectID), '.L.midthickness.8k_fs_LR.surf.gii']);
        sourcemodel = ft_read_headshape( {filename, strrep(filename, '.L.', '.R.')} );
        
        load( p.filePreprocMRI, 'transform_acpc2ctf');
        
        sourcemodel = ft_transform_geometry( transform_acpc2ctf, sourcemodel );
        sourcemodel.inside = sourcemodel.atlasroi>0;
        sourcemodel        = rmfield( sourcemodel, 'atlasroi' );
        sourcemodel        = ft_convert_units( sourcemodel, 'mm' );

        load(p.filePreprocLocData, 'data_loc');
        load(p.fileHeadmodel, 'vol');
        
        cfg           = [];
        cfg.grid      = sourcemodel;
        cfg.headmodel = vol;
        cfg.grad      = data_loc.grad;
        leadfield     = ft_prepare_leadfield(cfg);

        figure(1); clf, hold on;
        ft_plot_sens(data_loc.grad, 'unit','mm');
        ft_plot_mesh(leadfield.pos(leadfield.inside,:), 'unit','mm');
        ft_plot_headmodel(vol, 'unit','mm', 'edgecolor', 'r', 'edgealpha',0.1, 'facecolor','r', 'facealpha',0.1);
        view([10, 20]);
        
        figure(2); clf, hold on;
        ft_plot_sens(data_loc.grad, 'unit','mm');
        ft_plot_mesh(leadfield.pos(leadfield.inside,:), 'unit','mm');
        ft_plot_headmodel(vol, 'unit','mm', 'edgecolor', 'r', 'edgealpha',0.1, 'facecolor','r', 'facealpha',0.1);
        view([-90, 45]);
        
        save( [ p.fileLeadfield, '_corticalsheet'], 'leadfield' );
        
end