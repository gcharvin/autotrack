function varargout = at_montage(varargin)
% AT_MONTAGE MATLAB code for at_montage.fig
%      AT_MONTAGE, by itself, creates a new AT_MONTAGE or raises the existing
%      singleton*.
%
%      H = AT_MONTAGE returns the handle to a new AT_MONTAGE or the handle to
%      the existing singleton*.
%
%      AT_MONTAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AT_MONTAGE.M with the given input arguments.
%
%      AT_MONTAGE('Property','Value',...) creates a new AT_MONTAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before at_montage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to at_montage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help at_montage

% Last Modified by GUIDE v2.5 01-Dec-2014 15:30:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @at_montage_OpeningFcn, ...
                   'gui_OutputFcn',  @at_montage_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before at_montage is made visible.
function at_montage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to at_montage (see VARARGIN)

% Choose default command line output for at_montage
handles.output = hObject;

% reload previous global variable
global sequence

% Update handles structure
guidata(hObject, handles);

if ~isfield(sequence,'project')
    out=setupSequence();
end

if out==1
updateSequence(handles)
end



% UIWAIT makes at_montage wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function out=setupSequence
global segmentation timeLapse sequence

if numel(timeLapse)==0
    out=0;
    return;
end

sequence=[];
sequence.project.path=timeLapse.realPath; 
sequence.project.name=timeLapse.realName;
sequence.project.position=segmentation.position;

sequence.handles=[];
sequence.param={'1200 800', '1', '', '1', num2str(timeLapse.numberOfFrames'),'5'};

inte=str2num(sequence.param{5})-str2num(sequence.param{4})+1;
inte=round(inte/str2num(sequence.param{6}));

sequence.param(end+1)={num2str(str2num(sequence.param{4}):inte:str2num(sequence.param{5}))};
sequence.param(end+1)={num2str([1 1 timeLapse.list(1).videoResolution(1) timeLapse.list(1).videoResolution(2)])};

sequence.param=sequence.param';

sequence.display=cell(5,6);

for i=1:numel(timeLapse.list)
    sequence.display{i,1}=true;
    sequence.display{i,2}=timeLapse.list(i).ID;
    sequence.display{i,3}=num2str(i);
    sequence.display{i,4}='';
    sequence.display{i,5}=true;
    sequence.display{i,6}=false;
end

sequence.display{1,6}=true;

sequence.channel=cell(1,6);

rgb=[1 1 1; 0 1 0; 1 0 0];

for i=1:numel(timeLapse.list)
    sequence.channel{i,1}=i;
    sequence.channel{i,2}=num2str(rgb(i,:));
    sequence.channel{i,3}=round(timeLapse.list(i).setLowLevel);
    sequence.channel{i,4}=round(timeLapse.list(i).setHighLevel);
    sequence.channel{i,5}=false;
    sequence.channel{i,6}=timeLapse.list(i).binning;
end

sequence.contour=cell(1,5);
rgb=[1 0 0; 1 1 0; 0 1 1];
typ={'cells1','nucleus','foci'};

for i=1:3
    sequence.contour{i,1}=typ{i};
    sequence.contour{i,2}=num2str(rgb(:,i));
    sequence.contour{i,3}=num2str(1);
    sequence.contour{i,4}='';
    sequence.contour{i,5}=false;
end

out=1;


function updateSequence(handles,option)
global sequence

set(handles.tableparameter,'Data',sequence.param);
set(handles.tabledisplay,'Data',sequence.display);
set(handles.tablechannel,'Data',sequence.channel);
set(handles.tablecontour,'Data',sequence.contour);



% --- Outputs from this function are returned to the command line.
function varargout = at_montage_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function quit(handles)
close(handles);

% --- Executes on button press in saveMontageAs.
function saveMontageAs_Callback(hObject, eventdata, handles)
% hObject    handle to saveMontageAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveMontage.
function saveMontage_Callback(hObject, eventdata, handles)
% hObject    handle to saveMontage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in openMontage.
function openMontage_Callback(hObject, eventdata, handles)
% hObject    handle to openMontage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in newMontage.
function newMontage_Callback(hObject, eventdata, handles)
% hObject    handle to newMontage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in tabledisplay.
function tabledisplay_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tabledisplay (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global sequence
sequence.display=get(hObject,'Data');
updateSequence(handles)

% --- Executes when entered data in editable cell(s) in tablechannel.
function tablechannel_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tablechannel (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global sequence
sequence.channel=get(hObject,'Data');
updateSequence(handles)

% --- Executes when entered data in editable cell(s) in tablecontour.
function tablecontour_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tablecontour (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global sequence
sequence.contour=get(hObject,'Data');
updateSequence(handles);


% --- Executes on button press in makeMovie.
function makeMovie_Callback(hObject, eventdata, handles)
% hObject    handle to makeMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in tableparameter.
function tableparameter_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tableparameter (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

global sequence
sequence.param=get(hObject,'Data');
updateSequence(handles)


% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sequence

sequence.param=get(handles.tableparameter,'Data');
sequence.display=get(handles.tabledisplay,'Data');
sequence.channel=get(handles.tablechannel,'Data');
sequence.contour=get(handles.tablecontour,'Data');


% generate panel structure

pix=~cellfun(@isempty,sequence.display(:,1));
pix=cellfun(@mean,sequence.display(pix,1));

nlin= str2num(sequence.param{2,1}) * sum(pix);
ncol= ceil(str2num(sequence.param{6,1})/str2num(sequence.param{2,1}));
nframes= str2num(sequence.param{6,1});
nch= sum(pix);

% generate figure;

a=str2num(sequence.param{1,1});
roi=str2num(sequence.param{8,1});

sequence.handles=figure('Color','w','Position',[50 50 1*a(1) a(1)*roi(4)*nlin/(roi(3)*ncol)]);

% generate panel

p=panel();
p.de.margin=0;
p.pack(nlin,ncol);
p.fontsize=24;

cc=0;
cd=0;

nimages=str2num(sequence.param{7,1});

% get channels settings

for i=1:size(sequence.channel,1)
    if i==1

       ch=struct('number',i,'rgb',str2num(sequence.channel{i,2}),'binning',sequence.channel{i,6},'limits',[sequence.channel{i,3} sequence.channel{i,4}]);
    else
       ch(i)=struct('number',i,'rgb',str2num(sequence.channel{i,2}),'binning',sequence.channel{i,6},'limits',[sequence.channel{i,3} sequence.channel{i,4}]);
    end
end

% get contours settings

for i=1:size(sequence.contour,1)
    if i==1
       cont=struct('object',sequence.contour{i,1},'color',str2num(sequence.contour{i,2}),'lineWidth',str2num(sequence.contour{i,3}),'link',double(sequence.contour{i,5}),'incells',str2num(sequence.contour{i,4}),'cycle',[]);
    else
       cont(i)=struct('object',sequence.contour{i,1},'color',str2num(sequence.contour{i,2}),'lineWidth',str2num(sequence.contour{i,3}),'link',double(sequence.contour{i,5}),'incells',str2num(sequence.contour{i,4}),'cycle',[]);
    end
end


% load images and contours

for i=1:nframes
    
    if cd>=ncol
        cc=cc+nch;
        cd=1;
        
    else
        cd=cd+1;
    end
    
    for j=1:nch 
        
      dich=str2num(sequence.display{j,3});
      dico=str2num(sequence.display{j,4});
      tim=double(sequence.display{j,6});
      
      if tim>0
         tim=24;
      else
         tim=[]; 
      end
      
      [hf h]=phy_showImage('frames',nimages(i),'ROI',roi,'channels',ch(dich),'timestamp',tim,'contours',cont(dico),'tracking',[]);

      p(j+cc,cd).select(h);  
      
        if cd==1
         ylabel(sequence.display(j,2)) 
        end

      close(hf);
    end
     
end

p.de.margin=0;

p(1,1).marginleft=15;
