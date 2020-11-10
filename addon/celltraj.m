function varargout = celltraj(varargin)
% CELLTRAJ MATLAB code for celltraj.fig
%      CELLTRAJ, by itself, creates a new CELLTRAJ or raises the existing
%      singleton*.
%
%      H = CELLTRAJ returns the handle to a new CELLTRAJ or the handle to
%      the existing singleton*.
%
%      CELLTRAJ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CELLTRAJ.M with the given input arguments.
%
%      CELLTRAJ('Property','Value',...) creates a new CELLTRAJ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before celltraj_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to celltraj_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help celltraj

% Last Modified by GUIDE v2.5 12-Sep-2014 11:48:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @celltraj_OpeningFcn, ...
                   'gui_OutputFcn',  @celltraj_OutputFcn, ...
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


% --- Executes just before celltraj is made visible.
function celltraj_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to celltraj (see VARARGIN)
global celldat

% Choose default command line output for celltraj
handles.output = hObject;

% Update handles structure


if length(varargin)~=0
celldat=varargin{1};
end

guidata(hObject, handles);


% UIWAIT makes celltraj wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if numel(celldat)
refreshDisplay(handles)
end

function refreshDisplay(handles)
global celldat segmentation
  
cutoff=str2num(get(handles.cutoff,'String'));
        
pix=find([celldat.length]>=cutoff);

mat={};
cc=1;
for i=pix
    mat(cc,1)={celldat(i).cavity};
    mat(cc,2)={celldat(i).length};
    mat(cc,3)={num2str(celldat(i).tcell)};
    mat(cc,4)={celldat(i).birth};
    mat(cc,5)={celldat(i).death};
    mat(cc,6)={segmentation.tcells1(celldat(i).tcell(end)).lastFrame} ;
    mat(cc,7)={i} ;
    cc=cc+1;
end

%handles
set(handles.table,'Data',mat);
set(handles.table,'ColumnName',{'Cavity' 'Length' 'Tcells' 'Birth' 'Death' 'Last' ,'Index'});
set(handles.table,'ColumnWidth',{40 50 300 40 40 40 40});
set(handles.table,'ColumnEditable',logical([0 0 1 0 0 0 0]));

% --- Outputs from this function are returned to the command line.
function varargout = celltraj_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function cutoff_Callback(hObject, eventdata, handles)
% hObject    handle to cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cutoff as text
%        str2double(get(hObject,'String')) returns contents of cutoff as a double

refreshDisplay(handles)

% --- Executes during object creation, after setting all properties.
function cutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in table.
function table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


if numel(eventdata.Indices)>0
    ind= eventdata.Indices(1); % line selected in the table
    
    if eventdata.Indices(2)~=3
    plotTraj(handles,ind)
    end
end


function plotTraj(handles,ind)


global segmentation celltrajsel

mat=get(handles.table,'Data');

tcells=str2num(mat{ind,3});

celltrajsel=tcells(end);

ha=figure('Position',[800 100 800 600],'Color','w');

p=panel;
p.fontsize=20;
r=5.5;
p.pack('v',{[] 1/r 1/r 1/r 1/r 1/r});
p.de.margin=5;
p.marginleft=30;
p.margintop=20;
p.marginbottom=30;


% plotting the sequence of tobjects
p(1).select();

xmin=10000;
xmax=-10000;
for i=1:length(tcells)
   st=segmentation.tcells1(tcells(i)).Obj(1).image;
   en=segmentation.tcells1(tcells(i)).Obj(end).image;
   
   xmin=min(xmin,st);
   xmax=max(xmax,en);
   cc=mod(i,2);
   if cc==0 col=[1 0.8 0.8];
   else col=[0.8 0.8 1];
   end
   rectangle('Position',[st 0 en-st+1 20],'FaceColor',col);
   text((st+en)/2,10,num2str(tcells(i)));
end

xlim([xmin xmax+1]);
set(gca,'YTick',[],'XTickLabel',{});
title(['Cavity : ' num2str(mat{ind,1})]);

% plotting the position in cavity
p(2).select();

x=[];
vol=[];

for i=1:length(tcells)
   x=[x segmentation.tcells1(tcells(i)).Obj.image];
   
   temp=[];
   for j=1:length(segmentation.tcells1(tcells(i)).Obj)
   [ox oy area intensity]=offsetCoordinates(segmentation.tcells1(tcells(i)).Obj(j));
   temp=[temp oy];
   end
   
   vol=[vol temp];
end

plot(x,vol,'Color','k','LineWidth',2);
set(gca,'XTickLabel',{})
ylabel('Y Position');

xlim([xmin xmax+1]);
ylim([-200 200])

% plotting cell area
p(3).select();

x=[];
vol=[];

for i=1:length(tcells)
   x=[x segmentation.tcells1(tcells(i)).Obj.image];
   vol=[vol segmentation.tcells1(tcells(i)).Obj.area];
end

plot(x,vol,'Color','k','LineWidth',2);
ylabel('Area');
set(gca,'XTickLabel',{})

xlim([xmin xmax+1]);
%ylim([-0 5000])


% how many fluo channels ? 
fluo=length(segmentation.tcells1(tcells(i)).Obj(1).fluoMean);

if fluo>=1
% plotting fluoChannel 1
p(4).select();

x=[];
vol=[];

for i=1:length(tcells)
   x=[x segmentation.tcells1(tcells(i)).Obj.image];
   
   temp=[segmentation.tcells1(tcells(i)).Obj.fluoMean];
   temp=temp(1:fluo:end);
   vol=[vol temp];
   
end

plot(x,vol,'Color','k','LineWidth',2);
ylabel('PH intensity');


xlim([xmin xmax+1]);
ylim([500 1500])

if fluo==1 
    xlabel('Time (frames)'); 
else
    set(gca,'XTickLabel',{}); 
end
end


if fluo>=2
% plotting fluoChannel 1
p(5).select();

x=[];
vol=[];

for i=1:length(tcells)
   x=[x segmentation.tcells1(tcells(i)).Obj.image];
   
   temp=[segmentation.tcells1(tcells(i)).Obj.fluoMean];
   temp=temp(2:fluo:end);
   vol=[vol temp];
   
end

plot(x,vol,'Color','k','LineWidth',2);
ylabel('Channel 2');


xlim([xmin xmax+1]);
ylim([700 2000])
if fluo==2 
    xlabel('Time (frames)'); 
else
    set(gca,'XTickLabel',{}); 
end
end

if fluo>=3
% plotting fluoChannel 2
p(6).select();

x=[];
vol=[];

for i=1:length(tcells)
   x=[x segmentation.tcells1(tcells(i)).Obj.image];
      temp=[segmentation.tcells1(tcells(i)).Obj.fluoVar];
      temp2=[segmentation.tcells1(tcells(i)).Obj.fluoMean];
   temp=temp(3:3:end);
   temp2=temp2(3:fluo:end);
   %temp2=1;
   vol=[vol sqrt(temp)./temp2];
end

plot(x,vol,'Color','k','LineWidth',2);
xlabel('Time (frames)');
ylabel('mCh');

xlim([xmin xmax+1]);
ylim([0 0.3])
if fluo==3 
    xlabel('Time (frames)');
else
    set(gca,'XTickLabel',{}) ;
end

end
% plotting daughters of cell of interest

test=tcells(1);


frames=[segmentation.tcells1(test).Obj.image];

tr=[];
tr.x=[];
tr.a=[];
tr.n=[];

cc=1;
for i=frames
  % find potential daughters  
    cells=segmentation.cells1(i,:);
    cav=[cells.Nrpoints];
    
    pix=find(cav==mat{ind,1}); % cells in cavity
    
    cells=cells(pix);
    
    n=[cells.n];
    ci=find(n==segmentation.tcells1(test).N);
    cell0=cells(ci);
    
    % find cells in neighborhood
    
    x=[cells.ox]; 
    y=[cells.oy];
    
    dist=sqrt((x-cell0.ox).^2+(y-cell0.oy).^2);
    
    pix=find(dist<50); % & dist>0);
    
    cells=cells(pix);
    
    for j=1:numel(cells) % list all cells and plot the size= f(frames)
        n=[tr.n];
        
        pix=find(n==cells(j).n);
        
        if numel(pix)
        tr(pix).x=[tr(pix).x i];
        tr(pix).a=[tr(pix).a cells(j).area];
        
        else
        tr(cc).x=i;
        tr(cc).a=cells(j).area;
        tr(cc).n=cells(j).n;
        cc=cc+1;
        end    
    end      
end

h2=figure('Position',[800 100 800 600],'Color','w');
objects=allchild(ha);
copyobj(get(ha,'children'),h2);
close(ha);

% figure; 
% for i=1:numel(tr)
%     
%     plot(tr(i).x,tr(i).a,'Color','r'); hold on;
% end

%


function [ox oy area intensity]=offsetCoordinates(celltemp)
global segmentation


%fprintf('----------')

ox=    celltemp.ox;
oy=    celltemp.oy;

cavity=celltemp.Nrpoints;

frame= celltemp.image;

ncav=[segmentation.ROI(frame).ROI.n];
pix=find(ncav==cavity);
cavity=pix;

orient=segmentation.ROI(frame).ROI(cavity).orient;
box=segmentation.ROI(frame).ROI(cavity).box;
n=segmentation.ROI(frame).ROI(cavity).n;

cx=box(1)+box(3)/2;
cy=box(2)+box(4)/2;

if orient==0
    oy=oy-cy;
else
    oy=-(oy-cy);
end

ox=ox-cx;

%pause

area=celltemp.area;
intensity=celltemp.fluoMean(1);



% --- Executes on button press in saveCellTraj.
function saveCellTraj_Callback(hObject, eventdata, handles)
% hObject    handle to saveCellTraj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global segmentation celldat timeLapse



fprintf(['Saving Celltraj for position: ' num2str(segmentation.position) '...\n']);
    

if numel(userpath)==0
    localpath=pwd;
else
localpath=userpath;
localpath=localpath(1:end-1);
end

pos=segmentation.position;
objecttype='cells1';

if isunix
save([localpath '/' objecttype 'traj-autotrack.mat'],'celldat');
eval(['!mv ' [localpath '/' objecttype 'traj-autotrack.mat'] ' ' timeLapse.realPath timeLapse.pathList.position{pos} '/' objecttype 'traj-autotrack.mat']);
%
else
   save(fullfile(timeLapse.realPath,timeLapse.pathList.position{pos},['/' objecttype 'traj-autotrack.mat']),'celltraj');
end


% --- Executes when entered data in editable cell(s) in table.
function table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


global celldat

if numel(eventdata.Indices)>0
    ind= eventdata.Indices(1); % line selected in the table
    
    if eventdata.Indices(2)==3
        m=get(handles.table,'Data');
        id=m{ind,7};
       str=eventdata.NewData
       celldat(id).tcell=str2num(str);
    end
end
