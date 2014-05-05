function at_setParameters

global timeLapse segmentation

disp('Setting processing parameters');

% default parameters values

tcells1=[1 400 10000 50 0.35];
tnucleus=[2 10 4000 1000];
tmapping=[1 40 1 1 0 0];


if ~isfield(timeLapse.autotrack,'processing')
   timeLapse.autotrack.processing=[]; 
end
 


%%% cells1 segmentation
if isfield(timeLapse.autotrack.processing,'cells1')   
    tcells1=timeLapse.autotrack.processing.cells1;
else 
    
    timeLapse.autotrack.processing.cells1=tcells1;
end

defaultanswer=arrayfun(@num2str, tcells1, 'unif', 0);

prompt={'Channel',...
        'Min Size (pixels)',...
        'Max Size (pixels)',...
        'Typical cell diameter (pixels)',...
        'Threshold (0.15-0.35)'};
    
name='Cell Par.';
numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
if numel(answer)==0 return; end

answer=cellfun(@str2num, answer, 'unif', 0);
timeLapse.autotrack.processing.cells1=cell2mat(answer);


%%% nucleus segmentation
if isfield(timeLapse.autotrack.processing,'nucleus')   
    tnucleus=timeLapse.autotrack.processing.nucleus;
else 
    timeLapse.autotrack.processing.nucleus=tnucleus;
end

defaultanswer=arrayfun(@num2str, tnucleus, 'unif', 0);

prompt={'Channel',...
        'Min Size (pixels)',...
        'Max Size (pixels)',...
        'Threshold (fluo A.U.)'};
    
name='Nucleus Par.';
numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
if numel(answer)==0 return; end

answer=cellfun(@str2num, answer, 'unif', 0);
timeLapse.autotrack.processing.nucleus=cell2mat(answer);

%%% mapping parameters
if isfield(timeLapse.autotrack.processing,'mapping')   
    tmapping=timeLapse.autotrack.processing.mapping;
    
    if numel(tmapping)==4
       tmapping=[tmapping; 0; 0];  % for old projects
    end
else 
    timeLapse.autotrack.processing.mapping=tmapping;
end

defaultanswer=arrayfun(@num2str, tmapping, 'unif', 0);

prompt={'Persistence NOT USED',...
        'Max Distance',...
        'Allow Cell Shrink',...
        'Weight Distance', ...
        'Weight Size', ...
        'Filter'};
    
name='Mapping Par.';
numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
if numel(answer)==0 return; end

answer=cellfun(@str2num, answer, 'unif', 0);
timeLapse.autotrack.processing.mapping=cell2mat(answer);

at_setParametersTiming();





