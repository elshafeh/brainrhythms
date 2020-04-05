function [outstat, posmask, negmask] = jy_permutationtest4tempgenmat( cfg0, X1, X2 )
% This function performs cluster-based permutation tests for the temporal
% generalization matrices.
% 
% INPUT: 
%   cfg0: configuration for ft_freqstatistics.
%   X1  : an tTrain-by-tTest-by-nSubj matrix for condition 1.
%   X2  : an tTrain-by-tTest-by-nSubj matrix for condition 2.
%
% OUTPUT:
%   outstat: see fieldtrip ft_freqstatistics for details.
%   posmask: an T-by-T logical matrix for significant positive cluster(s).
%   negmask: an T-by-T logical matrix for significant negative cluster(s).
% 
% JY (March 2020)
% 

if sum( size(X1) - size(X2) )
    error( 'Error: size(X1) has to be the same as size(X2)!' );
end

cfg0.traintime        = ft_getopt( cfg0, 'traintime', linspace(0, 1, size( X1, 1) ) ); 
cfg0.testtime         = ft_getopt( cfg0, 'testtime', linspace(0, 1, size( X1, 2) ) );
cfg0.stattimewin      = ft_getopt( cfg0, 'stattimewin', cfg0.traintime);

tvectrain = cfg0.traintime;
tvectest  = cfg0.testtime;
idx1train = find( abs(tvectrain-cfg0.stattimewin(1)) == min(abs(tvectrain-cfg0.stattimewin(1))) );
idx2train = find( abs(tvectrain-cfg0.stattimewin(2)) == min(abs(tvectrain-cfg0.stattimewin(2))) );
idx1test  = find( abs(tvectest-cfg0.stattimewin(1)) == min(abs(tvectest-cfg0.stattimewin(1))) );
idx2test  = find( abs(tvectest-cfg0.stattimewin(2)) == min(abs(tvectest-cfg0.stattimewin(2))) );

s           = [];
s.freq      = cfg0.traintime;
s.time      = cfg0.testtime;
s.label     = {'fake'};
s.dimord    = 'subj_chan_freq_time';%'subj_chan_freq_time';
s.cfg       = [];

s1           = s;
s1.powspctrm = permute( X1, [3,4,1,2] );
% s1.cfg       = cfg0.fakecfg;

s2           = s;
s2.powspctrm = permute( X2, [3,4,1,2] );
% s2.cfg       = cfg0.fakecfg;

cfg0.statistic        = ft_getopt( cfg0, 'statistic', 'ft_statfun_depsamplesT');
cfg0.correctm         = ft_getopt( cfg0, 'correctm', 'cluster');
cfg0.clusterstatistic = ft_getopt( cfg0, 'clusterstatistic', 'maxsum' );
cfg0.clusteralpha     = ft_getopt( cfg0, 'clusteralpha', 0.05);
cfg0.clustertail      = ft_getopt( cfg0, 'clustertail', 0 );
cfg0.tail             = ft_getopt( cfg0, 'tail', cfg0.clustertail );
cfg0.alpha            = ft_getopt( cfg0, 'alpha', 0.05 );
cfg0.numrandomization = ft_getopt( cfg0, 'numrandomization', 10000 );
cfg0.method           = ft_getopt( cfg0, 'method', 'montecarlo');

nsubj = size( X1, 3 );


cfg      = [];
cfg.uvar = 1; %row 1 of cfg.design contains the subject info
cfg.ivar = 2; %row 2 of cfg.design contains the condition info
cfg.design(cfg.uvar,:) = repmat( 1:nsubj, [1,2] );
cfg.design(cfg.ivar,:) = [ ones(1,nsubj), ones(1,nsubj)+1 ];

cfg.method           = cfg0.method;
cfg.statistic        = cfg0.statistic;
cfg.correctm         = cfg0.correctm;
cfg.clusterstatistic = cfg0.clusterstatistic;
cfg.clusterthreshold = 'parametric'; 
cfg.clusteralpha     = cfg0.clusteralpha;
cfg.clustertail      = cfg0.clustertail;
cfg.tail             = cfg0.tail;
cfg.alpha            = cfg0.alpha;
cfg.numrandomization = cfg0.numrandomization;
cfg.avgoverfreq      = 'no';
cfg.frequency        = cfg0.stattimewin; %'all';
cfg.avgovertime      = 'no';
cfg.latency          = cfg0.stattimewin; %'all';
outstat = ft_freqstatistics( cfg, s1, s2 ); %s1 - s2.

% check clusters
negmask = false( numel(cfg0.traintime), numel(cfg0.testtime) );
if isfield( outstat, 'negclusters' ) & ~isempty( outstat.negclusters )
    sigN = [ outstat.negclusters(:).prob ];
    if sum( sigN < outstat.cfg.alpha ) > 0
        idxN     = find( sigN < outstat.cfg.alpha );
        negmask0 = false( size(outstat.stat) );
        for ii = idxN
            negmask0 = negmask0 | (outstat.negclusterslabelmat==ii);
        end
    negmask0 = squeeze( negmask0 );
    
    negmask(idx1train:idx2train, idx1test:idx2test) = negmask0;
    end
end

posmask = false( numel(cfg0.traintime), numel(cfg0.testtime) );
if isfield( outstat, 'posclusters') & ~isempty( outstat.posclusters )
    sigP = [ outstat.posclusters(:).prob ];
    
    if sum( sigP < outstat.cfg.alpha ) > 0
        idxP     = find( sigP < outstat.cfg.alpha );
        posmask0 = false( size(outstat.stat) );
        for ii = idxP
            posmask0 = posmask0 | (outstat.posclusterslabelmat==ii);
        end
        posmask0 = squeeze( posmask0 );
        
        posmask(idx1train:idx2train, idx1test:idx2test) = posmask0;
    end
end
    



end