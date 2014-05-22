function varargout = at_display(varargin)
% AT_DISPLAY MATLAB code for at_display.fig
%      AT_DISPLAY, by itself, creates a new AT_DISPLAY or raises the existing
%      singleton*.
%
%      H = AT_DISPLAY returns the handle to a new AT_DISPLAY or the handle to
%      the existing singleton*.
%
%      AT_DISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AT_DISPLAY.M with the given input arguments.
%
%      AT_DISPLAY('Property','Value',...) creates a new AT_DISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before at_display_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to at_display_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help at_display

% Last Modified by GUIDE v2.5 27-Mar-2014 15:31:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @at_display_OpeningFcn, ...
    'gui_OutputFcn',  @at_display_OutputFcn, ...
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


% --- Executes just before at_display is made visible.
function at_display_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to at_display (see VARARGIN)

% Choose default command line output for at_display
global at_displayHandles

handles.output = hObject;

%format scater plots

str=at_name([10:14 215:230 531 532 533]);

set(handles.scatter1,'String',str);
set(handles.scatter1,'Value',1);
set(handles.scatter2,'String',str);
set(handles.scatter1,'Value',2);

str={};
str{1}='Time'; str{2}='HTB2 fluo';

set(handles.scatter3,'String',str);
set(handles.scatter3,'Value',2);
set(handles.scatter4,'String',str);
set(handles.scatter4,'Value',1);


updateDisplay(handles);

at_displayHandles=handles;


set(handles.statlist,'Max',2,'Min',0);
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes at_display wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = at_display_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in scatter1.
function scatter1_Callback(hObject, eventdata, handles)
% hObject    handle to scatter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scatter1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scatter1

val1=get(hObject,'Value');
val2=get(handles.scatter2,'Value');

str1=get(hObject,'String');
str2=get(handles.scatter2,'String');

str1=str1{val1};
str2=str2{val2};

mtable=handles.table;
jUIScrollPane = findjobj(mtable);
jUITable = jUIScrollPane.getViewport.getView;

row = jUITable.getSelectedRow + 1; % Java indexes start at 0
if row~=0
    plotStat(str1,str2,handles,row);
else
    plotStat(str1,str2,handles);
end

function plotStat(str1,str2,handles,sel)
global datastat;

p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;

ind1=at_name(str1);
ind2=at_name(str2);

%ind2,val2
dt1=stats(:,ind1);
dt2=stats(:,ind2);

%if val1>22 % plot total cel volume
%   dt1=stats(:,ind+val1-10)+stats(:,ind+val1-15);
%end
%if val2>22 % plot total cel volume
%   dt2=stats(:,ind2+val2-10)+stats(:,ind2+val2-15);
%end


axes(handles.scatterplot);

if ~strcmp(str1,str2)
    M=find(stats(:,5)==1 & stats(:,6)==0);
    %OM=find(stats(:,6)==0);
    %iM=intersect(M,OM);
    
    dt2M=dt2(M); dt1M=dt1(M);
    
    D=find(stats(:,5)==0 & stats(:,6)==0);
    %OD=find(stats(:,6)==0);
    %iD=intersect(D,OD);
    dt2D=dt2(D); dt1D=dt1(D);
    
    str='';
    
    if numel(dt2M)~=0
        h1=plot(dt2M,dt1M,'Color','r','Marker','.','MarkerSize',15,'LineStyle','none'); hold on;
        xlabel(str2); ylabel(str1);
        cM=corrcoef(dt2,dt1);
        if size(cM,2)>=2
            str=[str 'Corr M: ' num2str(cM(1,2))];
        end
        
        set(h1,'ButtonDownFcn',{@plothit,handles});
    end
    
    str=[ str ' - '];
    
    if numel(dt2D)~=0
        h2=plot(dt2D,dt1D,'Color','b','Marker','.','MarkerSize',15,'LineStyle','none'); hold on;
        set(h2,'ButtonDownFcn',{@plothit,handles});
        cD=corrcoef(dt2D,dt1D);
        if size(cD,2)>=2
            str=[str 'Corr D: ' num2str(cD(1,2))];
        end
    end
    
    if nargin==4
        dt1p=stats(sel,ind1);
        dt2p=stats(sel,ind2);
        h3=plot(dt2p,dt1p,'Color','k','Marker','.','MarkerSize',25,'LineStyle','none'); hold off
        
    end
    
    title(str);
    
    hold off;
    
else
    
    M=find(stats(:,5)==1 & stats(:,6)==0);
    dt1M=dt1(M);
    
    D=find(stats(:,5)==0 & stats(:,6)==0);
    dt1D=dt1(D);
    
    %hist(dt1M,20,'FaceColor','r'); hold on;
    % hist(dt1D,20,'FaceColor','r');
    leg1=['Mean: ' num2str(round(mean(dt1M))) ';  COV= ' num2str(round(100*std(dt1M)/mean(dt1M))/100)];
    leg2=['Mean: ' num2str(round(mean(dt1D))) ';  COV= ' num2str(round(100*std(dt1D)/mean(dt1D))/100)];
    
    [t n x]=nhist({dt1M,dt1D},'noerror','xlabel',str2,'ylabel','# Events','fsize',12,'binfactor',1,'minx',0,'samebins','numbers','legend',{leg1,leg2});
    
    %xlim([0 max(max(dt1D),max(dt1M))]);
    
    xlabel(str2);
    title('');
end


function plothit(hObject, eventdata, handles)

p = get(gca,'CurrentPoint');
p = p(1,1:2);

plotTime(p,handles);


function plotTime(p,handles)
global datastat

val1=get(handles.scatter1,'Value');
val2=get(handles.scatter2,'Value');

pix=[datastat.selected];
pix=find(pix==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;
outlier=datastat(pix).outlier;

ind=9; ind2=9;
if val1>5
    ind=15+199-5;
end
if val2>5
    ind2=15+199-5;
end

dt1=stats(:,ind+val1);
dt2=stats(:,ind2+val2);

if val1>22 % plot total cel volume
    dt1=stats(:,ind+val1-10)+stats(:,ind+val1-15);
end
if val2>22 % plot total cel volume
    dt2=stats(:,ind2+val2-10)+stats(:,ind2+val2-15);
end

if val1>=27 % plot mu
    dt1=stats(:,531+val1-27);
end
if val2>=27 % plot mu
    dt2=stats(:,531+val2-27);
end

[mi ix]=min(abs(dt2-p(1)));

plotTimePoint(ix,stats,handles,outlier);

function plotTimePoint(ix,stats,handles,outlier)

lin=stats(ix,15:15+99);
lin=lin(find(lin~=0));

fi=stats(ix,15+100:15+199);
fi=fi(find(fi~=0));

vc=stats(ix,31+200:31+299);
pix=find(vc~=0);
vc=vc(pix);

vb=stats(ix,31+300:31+399);
vb=vb(pix);

v=stats(ix,31+400:31+499);
v=v(pix);

%x=stats(ix,8:9);

x=stats(ix,8)  ;
x=x+stats(ix,7);

axes(handles.timeplot);

plot(x+(1:length(lin))-1,lin,'Color','k','LineWidth',2); hold on

plot(x+(1:length(fi))-1,fi,'Color','r','LineWidth',2,'LineStyle','--'); hold off;

ylabel('HTB2 fluo');

[out str]=at_checkOutlier(stats,ix,[],outlier);
if out==1
    % str
    title(str);
end

axes(handles.timeplot2);

plot(x+(1:length(vc))-1,vc,'Color','k','LineWidth',2); hold on

plot(x+(1:length(vb))-1,vb+vc,'Color','r','LineWidth',2);

plot(x+(1:length(v))-1,v/max(v)*max(vc+vb),'Color','g','LineWidth',2); hold off

ylabel('Cell size');
xlabel('Time (frames)');

%mtable = uitable('Parent',gcf)
mtable=handles.table;
jUIScrollPane = findjobj(mtable);
jUITable = jUIScrollPane.getViewport.getView;

%row = jUITable.getSelectedRow + 1 % Java indexes start at 0
%col = jUITable.getSelectedColumn + 1

jUITable.setRowSelectionAllowed(0);
jUITable.setColumnSelectionAllowed(0);
jUITable.changeSelection(ix-1,0, false, false);





% --- Executes during object creation, after setting all properties.
function scatter1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scatter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scatter2.
function scatter2_Callback(hObject, eventdata, handles)
% hObject    handle to scatter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scatter2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scatter2

val2=get(hObject,'Value');
val1=get(handles.scatter1,'Value');

str2=get(hObject,'String');
str1=get(handles.scatter1,'String');

str1=str1{val1};
str2=str2{val2};

mtable=handles.table;
jUIScrollPane = findjobj(mtable);
jUITable = jUIScrollPane.getViewport.getView;

row = jUITable.getSelectedRow + 1; % Java indexes start at 0
if row~=0
    plotStat(str1,str2,handles,row);
else
    plotStat(str1,str2,handles);
end



% --- Executes during object creation, after setting all properties.
function scatter2_CreateFcn(hObject, eventdata, ~)
% hObject    handle to scatter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in outlier.
function outlier_Callback(hObject, eventdata, handles)
% hObject    handle to outlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of outlier
global datastat;

mtable=handles.table;
jUIScrollPane = findjobj(mtable);
jUITable = jUIScrollPane.getViewport.getView;

row = jUITable.getSelectedRow + 1;
col = jUITable.getSelectedColumn + 1;

pix=[datastat.selected];
pix=find(pix==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;

if get(hObject,'Value')
    stats(row,6)=1;
else
    stats(row,6)=0;
end

datastat(pix).stats=stats;

updateDisplay(handles);

%set(hObject,'Value',0);

%row = jUITable.getSelectedRow + 1 % Java indexes start at 0
%col = jUITable.getSelectedColumn + 1

mtable=handles.table;
jUIScrollPane = findjobj(mtable);
jUITable = jUIScrollPane.getViewport.getView;
jUITable.setRowSelectionAllowed(0);
jUITable.setColumnSelectionAllowed(0);
jUITable.changeSelection(row-1,0, false, false);


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global datastat timeLapse

p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;
path=datastat(pix).path;
outlier=datastat(pix).outlier;

if strcmp(path(1),'-')
    defpath=datastat(1).path;
    [defpath file]=fileparts(defpath);
    [file,path] = uiputfile('*.mat','Save stats file as',defpath);
    path=[path file];
    datastat(pix).path=path;
    updateDisplay(handles);
end
at_export(stats,path,outlier);



% --- Executes on button press in pool.
function pool_Callback(hObject, eventdata, handles)
% hObject    handle to pool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastat

val=get(handles.statlist,'Value');

if numel(val)<=1
    errordlg('you must select at least 2 items in the list');
    return;
end

stats=[];
for i=1:numel(val)
    stats=[stats ; datastat(val(i)).stats];
end

n=numel(datastat)+1;
datastat(n).stats=stats;
datastat(n).path=['-pool' num2str(n)];
datastat(n).selected=1;
datastat(n).outlier=datastat(val(1)).outlier;

updateDisplay(handles);


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastat

[FileName,PathName,FilterIndex] = uigetfile({'*.mat','Stat file'},'Select Stat File',[]);

if FileName==0
    return;
end

load(strcat(PathName,FileName));

if numel(datastat)==0
    datastat.stats=[];
    datastat.path=[];
    datastat.selected=[];
    datastat.outliser=[];
    n=1;
else
    n=numel(datastat)+1;
end



datastat(n).stats=stats;
datastat(n).path=strcat(PathName,FileName);
datastat(n).selected=1;

if exist('outlier','var')
    datastat(n).outlier=outlier;
else
    at_setParametersTiming;
end

updateDisplay(handles);

function updateDisplay(handles)
global datastat

if numel(datastat)==0
    return;
end

str={};
for i=1:numel(datastat)
    str{i}=datastat(i).path;
end

p=[datastat.selected];
pix=find(p==1,1,'first');

if numel(pix)==0
    return;
end

set(handles.statlist,'String',str);
set(handles.statlist,'Value',pix);


% format table
dt=datastat(pix).stats;
dt=[round(dt(:,1:14)) round(dt(:,15+200:30+200)) round(dt(:,31+500:32+500))];

set(handles.table,'Data',dt);
set(handles.table,'ColumnWidth',{40 25 30 30 30 30 45 45 30 40  40 40 40 60   70 70 70 70 70 70 70 70 70 70 70 70 70 70 70 70 70 70})
% str{1}='ID'; str{2}='Pos'; str{3}='Cell'; str{4}='Div'; str{5}='M/D'; str{6}='Out';
% str{7}='1st F'; str{8}='Detect'; str{9}='Start'; str{10}='Div';
% str{11}='G1'; str{12}='S'; str{13}='G2/M'; str{14}='AnaCyt';
%
%
% str{15}='TBud';
% str(16:20)={'V_Cell_div','V_Cell_G1','V_Cell_S','V_Cell_G2/M','V_Cell_Anacyt'};
% str(21:25)={'V_Bud_div','V_Bud_G1','V_Bud_S','V_Bud_G2/M','V_Bud_Anacyt'};
% str(26:30)={'V_Nucl_div','V_Nucl_G1','V_Nucl_S','V_Nucl_G2/M','V_Nucl_Anacyt'};
% str(31:32)={'mu unbud','mu bud'};

str=at_name([1:14 215:230 531 532]);

set(handles.table,'ColumnName',str);

totcells=size(dt,1);
pix=length(find(dt(:,6)==1));

set(handles.info,'String',[num2str(totcells) ' cells;' num2str(pix) ' outliers; ' num2str(round(100*(totcells - pix)/totcells)) '% good']);

% plot scatter1 vs scatter2

val1=get(handles.scatter1,'Value');
val2=get(handles.scatter2,'Value');

str1=get(handles.scatter1,'String');
str2=get(handles.scatter2,'String');

str1=str1{val1};
str2=str2{val2};

plotStat(str1,str2,handles);

% --- Executes on selection change in statlist.
function statlist_Callback(hObject, eventdata, handles)
% hObject    handle to statlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns statlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from statlist
global datastat

val=get(hObject,'Value');

if numel(val)>1
    return;
end

for i=1:numel(datastat)
    datastat(i).selected=0;
end
datastat(val).selected=1;

updateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function statlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scatter3.
function scatter3_Callback(hObject, eventdata, handles)
% hObject    handle to scatter3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scatter3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scatter3


% --- Executes during object creation, after setting all properties.
function scatter3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scatter3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scatter4.
function scatter4_Callback(hObject, eventdata, handles)
% hObject    handle to scatter4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scatter4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scatter4


% --- Executes during object creation, after setting all properties.
function scatter4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scatter4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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




% --- Executes on mouse press over axes background.
function scatterplot_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to scatterplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected cell(s) is changed in table.
function table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global datastat

pix=[datastat.selected];
pix=find(pix==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;
outlier=datastat(pix).outlier;

if numel(eventdata.Indices)>0
    ind= eventdata.Indices(1);
    
    st=stats(ind,6);
    set(handles.outlier,'Value',st);
    
    plotTimePoint(ind,stats,handles,outlier);
    
    
    val1=get(handles.scatter1,'Value');
    val2=get(handles.scatter2,'Value');
    
    str1=get(handles.scatter1,'String');
    str2=get(handles.scatter2,'String');
    
    str1=str1{val1};
    str2=str2{val2};
    
    plotStat(str1,str2,handles,ind);
end


% --- Executes on button press in histo.
function histo_Callback(hObject, eventdata, handles)
% hObject    handle to histo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


at_histo();



% --- Executes on button press in displayTraj.
function displayTraj_Callback(hObject, eventdata, handles)
% hObject    handle to displayTraj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global datastat timeLapse


p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;
ind=9;

mtable=handles.table;
jUIScrollPane = findjobj(mtable);
jUITable = jUIScrollPane.getViewport.getView;

row = jUITable.getSelectedRow + 1;

if row==0
    return;
end

lin=stats(row,15:15+99);
lin=lin(find(lin~=0));

fi=stats(row,15+100:15+199);
fi=fi(find(fi~=0));


x=stats(row,8)  ;
x=x+stats(row,7);

figure;

sca=double(timeLapse.interval/60);

%mine=0.8*min(min(lin),min(fi));
%maxe=1.2*max(max(lin),max(fi));

%sca=1;

plot(sca*(x+(1:length(lin))-1),lin,'Color','r','LineWidth',3); hold on
plot(sca*(x+(1:length(fi))-1),fi,'Color','k','LineWidth',3,'LineStyle','--');

%xlim([sca*x sca*(x+length(lin)-1)]);
set(gca,'FontSize',20);
xlabel('Time (min)','Fontsize',20);
ylabel('Histone Content (A.U.) ','Fontsize',20);
set(gcf,'Color','w','Position',[100 100 800 300]);

ax=axis;
mine=ax(3);
maxe=ax(4);

offset=stats(row,7);

if stats(row,5)==0
   offset=offset-2; 
end
    

x0=[0 0 stats(row,9)-stats(row,8) stats(row,9)-stats(row,8) 0]; x0=x0+stats(row,8)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x0,y1,ones(1,length(x0)),'FaceColor','b');
alpha(h1,0.1);

x1=[0 0 stats(row,11) stats(row,11) 0]; x1=x1+stats(row,9)+offset; y1=[mine maxe maxe mine mine];

h1=patch(sca*x1,y1,ones(1,length(x1)),'FaceColor','r');
alpha(h1,0.1);

x2=[0 0 stats(row,12) stats(row,12) 0]; x2=x2+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x2,y1,ones(1,length(x2)),'FaceColor','g');
alpha(h1,0.1);

x3=[0 0 stats(row,13) stats(row,13) 0]; x3=x3+stats(row,12)+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x3,y1,ones(1,length(x3)),'FaceColor','y');
alpha(h1,0.1);

x4=[0 0 stats(row,14) stats(row,14) 0]; x4=x4+stats(row,13)+stats(row,12)+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x4,y1,ones(1,length(x4)),'FaceColor','b');
alpha(h1,0.1);

xlim(sca*[stats(row,8)+offset stats(row,14)+stats(row,13)+stats(row,12)+stats(row,11)+stats(row,9)+offset]);


% PLOT DATA AS A MATRIX


% --- Executes on button press in corr.
function corr_Callback(hObject, eventdata, handles)
% hObject    handle to corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

at_corr();


% --- Executes on button press in age.
function age_Callback(hObject, eventdata, handles)
% hObject    handle to age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
at_histo('age');
