function out=at_load(path)
% load project for autotrack analysis (automated trackeing of budding yeast
% cell cycle
global timeLapse segmentation


out=0;

if nargin==0
[FileName,PathName,FilterIndex] = uigetfile({'*.mat','Time Lapse project'},'Select time lapse project',[]);

if FileName==0
    return;
end

load(strcat(PathName,FileName));
else
 load(path);
 [PathName, FileName, ext] = fileparts(path);
 PathName, FileName
end

timeLapse.realPath=PathName;
timeLapse.realName=FileName;

disp(['TimeLapse project: ' FileName ' loaded succesfully']);

% create autotrack struc if does not exist
if ~isfield(timeLapse,'autotrack')
    
    disp(['Autotrack struct does not exist; create...']);
    
    timeLapse.autotrack=[];
    timeLapse.autotrack.position=[];
    nframes=timeLapse.numberOfFrames;
    
    for i=1:numel(timeLapse.position.list)
       timeLapse.autotrack.position(i).cells1Segmented=zeros(1,nframes);
       timeLapse.autotrack.position(i).nucleusSegmented=zeros(1,nframes);
       timeLapse.autotrack.position(i).cells1Mapped=zeros(1,nframes);
       timeLapse.autotrack.position(i).nucleusMapped=zeros(1,nframes);
    end
    
    %if ~isfield(timeLapse.autotrack,'processing')
   % at_setParameters;
   % end
   
end

out=1;

at_setParameters;

% display segmentation state
for i=1:numel(timeLapse.position.list)
    
   fraC=numel(find(timeLapse.autotrack.position(i).cells1Segmented));
   fraN=numel(find(timeLapse.autotrack.position(i).nucleusSegmented));
   
   mapC=numel(find(timeLapse.autotrack.position(i).cells1Mapped));
   mapN=numel(find(timeLapse.autotrack.position(i).nucleusMapped));
   
   disp(['Position ' num2str(i) ' : ' num2str(fraC) ' seg. frames (cells); ' num2str(fraN) ' seg. frames (nucleus); ' num2str(mapC) ' mapped frames (cells); ' num2str(mapN) ' mapped frames (nucleus); ']);
end






