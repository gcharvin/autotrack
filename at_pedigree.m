
function [hf ha hc]=at_pedigree(plotType,object,minmax,channel,feature,cellindex,logscale)
% plot pedigree
% plotType : 0: links, 1: timings, 2: fluo

global segmentation timeLapse

if nargin==1
   minmax=[500 1200];    
end

segmentation.pedigree.plotType=plotType;
segmentation.pedigree.makeType=1;
segmentation.pedigree.minmax=minmax;
segmentation.pedigree.orientation=0;
segmentation.pedigree.cellindex=cellindex;
segmentation.pedigree.channel=channel; %timeLapse.autotrack.processing.nucleus(1);
segmentation.pedigree.object=object;
segmentation.pedigree.feature=feature;
segmentation.pedigree.log=logscale;

varargin={};

if numel(segmentation.pedigree.cellindex)~=0
    varargin{end+1}='cellindex' ;
    varargin{end+1}=segmentation.pedigree.cellindex;
end

varargin{end+1}='mode';
varargin{end+1}=segmentation.pedigree.plotType;

if segmentation.pedigree.plotType==2
    varargin{end+1}=[segmentation.pedigree.minmax segmentation.pedigree.channel];
end

if segmentation.pedigree.orientation
    varargin{end+1}='vertical';
end

if segmentation.pedigree.log
    varargin{end+1}='log';
end

varargin{end+1}='object';
varargin{end+1}=segmentation.pedigree.object;

varargin{end+1}='feature';
varargin{end+1}=segmentation.pedigree.feature;

[hf ha hc]=phy_plotPedigree(varargin{:});

