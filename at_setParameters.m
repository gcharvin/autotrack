function at_setParameters

global timeLapse segmentation

disp('Setting processing parameters');

% default parameters values

tcells1=[1 400 10000 50 0.35];
tnucleus=[2 10 4000 1000];
tmapping=[1 40 1 1 0 0];


if ~isfield(timeLapse.autotrack,'processing')
    timeLapse.autotrack.processing=[];
else
    if usejava('jvm') && ~feature('ShowFigureWindows')
        %     % use text-based alternative (input)
        button = input('Param already exist : change ? [Y]/[N]', 's');
        if strcmp(button,'N')
            return;
        end
        
    else
        % use GUI dialogs (questdlg)
        button = questdlg('Parameters already exist; Change ?','Please answer my question ','yes','no','no');
        
        if strcmp(button,'no')
            return;
        end
        
    end
    
end

% input param file
if usejava('jvm') && ~feature('ShowFigureWindows')
    button = input('Input path for existing parmeter file:', 's');
    if numel(button)~=0
       load(button); 
       timeLapse.autotrack.processing=processing;
       timeLapse.autotrack.timing=timing;
       return;
    end
else
    [FileName,PathName,FilterIndex] = uigetfile({'*.mat','Param file .mat'},'Select parameter file :',[]);
    
    if FileName==0
    else
        load(strcat(PathName,FileName));
        timeLapse.autotrack.processing=processing;
        timeLapse.autotrack.timing=timing;
        return;
    end
end



%%% cells1 segmentation
if isfield(timeLapse.autotrack.processing,'cells1')
    tcells1=timeLapse.autotrack.processing.cells1;
else
    
    timeLapse.autotrack.processing.cells1=tcells1;
end


if usejava('jvm') && ~feature('ShowFigureWindows')
    %     % use text-based alternative (input)
    
    answer{1} = input('Cells : channel ? ', 's');
    answer{2} = input('Cells : min size (pixels) ? ', 's');
    answer{3} = input('Cells : max size (pixels) ? ', 's');
    answer{4} = input('Cells : typical cell diameter (pixels) ? ', 's');
    answer{5} = input('Cells : threshold (0.15-0.35) ? ', 's');
    answer=cellfun(@str2num, answer, 'unif', 0);
    
else
    % use GUI dialogs (questdlg)
    
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
    
end


timeLapse.autotrack.processing.cells1=cell2mat(answer);


%%% nucleus segmentation


if isfield(timeLapse.autotrack.processing,'nucleus')
    tnucleus=timeLapse.autotrack.processing.nucleus;
else
    timeLapse.autotrack.processing.nucleus=tnucleus;
end

if usejava('jvm') && ~feature('ShowFigureWindows')
    % use text-based alternative (input)
    
    answer{1} = input('Nucleus : channel ? ', 's');
    answer{2} = input('Nucleus : min size (pixels) ? ', 's');
    answer{3} = input('Nucleus : max size (pixels) ? ', 's');
    answer{4} = input('Nucleus : threshold (fluo) ? ', 's');
    answer=cellfun(@str2num, answer, 'unif', 0);
    
else
    % use GUI dialogs (questdlg)
    
    defaultanswer=arrayfun(@num2str, tnucleus, 'unif', 0);
    
    prompt={'Channel',...
        'Min Size (pixels)',...
        'Max Size (pixels)',...
        'Threshold (fluo A.U.)'};
    
    name='Nucleus Par.';
    numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
    if numel(answer)==0 return; end
    
    answer=cellfun(@str2num, answer, 'unif', 0);
    
end


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


if usejava('jvm') && ~feature('ShowFigureWindows')
    % use text-based alternative (input)
    
    answer{1} = input('Mapping : peristence ? ', 's');
    answer{2} = input('Mapping : max distance ? ', 's');
    answer{3} = input('Mapping : allow cell shrink ? ', 's');
    answer{4} = input('Mapping : weight distance ? ', 's');
    answer{5} = input('Mapping : weight size ? ', 's');
    answer{6} = input('Mapping : filter ? ', 's');
    
    answer=cellfun(@str2num, answer, 'unif', 0);
    
else
    % use GUI dialogs (questdlg)
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
end

timeLapse.autotrack.processing.mapping=cell2mat(answer);

at_setParametersTiming();

timing=timeLapse.autotrack.processing;
processing=timeLapse.autotrack.timing;

save('parameters.mat','processing','timing')



