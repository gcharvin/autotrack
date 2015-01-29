function at_setParameters

global timeLapse segmentation

disp('Setting processing parameters');

% default parameters values

%tcells1=[1 400 10000 50 0.35];
%tnucleus=[2 10 4000 1000];
%tmapping=[1 40 1 1 0 0];


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
    button = input('Input path for existing parameter file:', 's');
    if numel(button)~=0
       load(button); 
       timeLapse.autotrack.processing=processing;
       timeLapse.autotrack.timing=timing;
       return;
    end
else
    [FileName,PathName,FilterIndex] = uigetfile({'*.mat','Param file .mat'},'Select parameter file, otherwise press Cancel :',[]);
    
    if FileName==0
    else
        load(strcat(PathName,FileName));
        timeLapse.autotrack.processing=processing;
        timeLapse.autotrack.timing=timing;
        return;
    end
end

if usejava('jvm') && ~feature('ShowFigureWindows')
    disp('Cannot use a GUI to set parameter in this mode !');
end

segCellPar=[]; 
mapCellPar=[]; 
segNucleusPar=[]; 
mapNucleusPar=[]; 
segFociPar=[]; 
mapFociPar=[]; 

if ~isfield(timeLapse.autotrack,'processing') | numel(timeLapse.autotrack.processing)==0
%%% input parameter values|

processing=[];

processing.segCells=true;
processing.segCellsMethod='phy_segmentPhaseContrast';

processing.mapCells=true;
processing.mapCellsMethod='phy_mapCellsHungarian';

processing.segNucleus=false;
processing.segNucleusMethod='phy_segmentNucleus';

processing.mapNucleus=false;
processing.mapNucleusMethod='phy_mapCellsHungarian';

processing.segFoci=false;
processing.segFociMethod='phy_segmentFoci';

processing.mapFoci=false;
processing.mapFociMethod='phy_mapCellsHungarian';

processing.cellcycle=false;
processing.display=false;
processing.binning=2;
processing.cavity=[];

else
  processing=timeLapse.autotrack.processing;  
  
  if isfield(processing,'mapCellsPar')
     mapCellsPar=processing.mapCellsPar;
     processing=rmfield(processing,'mapCellsPar');
  else
     mapCellPar=[];
  end
   if isfield(processing,'segCellsPar')
     segCellPar=processing.segCellsPar;
     processing=rmfield(processing,'segCellsPar');
   else
      segCellsPar=[]; 
   end
   if isfield(processing,'segNucleusPar')
      segNucleusPar=processing.segNucleusPar;
     processing=rmfield(processing,'segNucleusPar');
   else
      segNucleusPar=[]; 
   end
   if isfield(processing,'mapNucleusPar')
     mapNucleusPar=processing.mapNucleusPar;
     processing=rmfield(processing,'mapNucleusPar');
   else
     mapNucleusPar=[];   
   end
   if isfield(processing,'segFociPar')
      segFociPar=processing.segFociPar;
     processing=rmfield(processing,'segFociPar');
   else
      segFociPar=[]; 
   end
   if isfield(processing,'mapFociPar')
      mapFociPar=processing.mapFociPar;
     processing=rmfield(processing,'mapFociPar');
   else
      mapFociPar=[]; 
   end
  
end


description{1}='Check if cells must be segmented';
description{end+1}='Specify cells segmentation function name';

description{end+1}='Check if cells must be mapped';
description{end+1}='Specify cells mapping function name';

description{end+1}='Check if nuclei must be segmented';
description{end+1}='Specify nuclei segmentation function name';

description{end+1}='Check if nuclei must be mapped';
description{end+1}='Specify nuclei mapping function name';

description{end+1}='Check if foci must be segmented';
description{end+1}='Specify foci segmentation function name';

description{end+1}='Check if foci must be mapped';
description{end+1}='Specify foci mapping function name';

description{end+1}='Check if cell cycle analysis must be performed';
description{end+1}='Check if you want to display the segmentation process';
description{end+1}='Enter binning for channel of nucleus';
description{end+1}='Enter the numbers of the cavity to be tracked. If no cavity, put []; if cavity are present but should not be tracked, put -1';
 

[hPropsPane,processing,OK] = at_propertiesGUI(0, processing,'Enter parameters for at_batch',description);

if OK==0
return;
end

if processing.segCells
    
    if numel(segCellPar)==0
   param=feval(processing.segCellsMethod);
    else
   param= segCellPar;    
    end
   param=feval(processing.segCellsMethod,param);
   processing.segCellsPar=param;
end

if processing.mapCells
   param=feval(processing.mapCellsMethod);
   param=feval(processing.mapCellsMethod,param);
   processing.mapCellsPar=param;
end

if processing.segNucleus
   param=feval(processing.segNucleusMethod);
   param=feval(processing.segNucleusMethod,param);
   processing.segNucleusPar=param;
end

if processing.mapNucleus
   param=feval(processing.mapNucleusMethod);
   param=feval(processing.mapNucleusMethod,param);
   processing.mapNucleusPar=param;
end

if processing.segFoci
   param=feval(processing.segFociMethod);
   param=feval(processing.segFociMethod,param);
   processing.segFociPar=param;
end

if processing.mapFoci
   param=feval(processing.mapFociMethod);
   param=feval(processing.mapFociMethod,param);
   processing.mapFociPar=param;
end


timeLapse.autotrack.processing=processing;

at_setParametersTiming();

timing=timeLapse.autotrack.processing;
processing=timeLapse.autotrack.timing;

save([timeLapse.realPath '/at_batch_processing_parameters.mat'],'processing','timing')



