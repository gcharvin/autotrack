function at_ROI(roiarr,pos,move)
global segmentation timeLapse

% pos is the position for which ROI needs to be defined
% roiarr is an array of the form [left1 top1 width1 height1; left2 top2 width2 height2; ...]

% if only one position is selected, then you can choose the location of the
% ROI

% move : 1 if ROI needs to be moved manually, otherwise 0

if numel(pos)==0   
  position=1:1:length(timeLapse.position.list);
else
  position=pos;
end

for pos=position

at_openSeg(pos);
at_log(['Open position for ROI definition - position : ' num2str(pos)],'a',pos,'batch');

if numel(segmentation)==0
  errordlg('No segmentation is loaded; use : at_ROI(roiarr,pos) to load a position');
  return;
end
        
out=0;

if ischar(roiarr)
    if strcmp(roiarr,'aging-nikon')
% nikon + multiaging cavity
na=13;
roiarr=zeros(na,4);
roiarr(:,3)=130;
roiarr(:,4)=400;
roiarr(:,2)=1;
roiarr(:,1)=1:145:na*145;
roiarr=vertcat(roiarr,roiarr+repmat([75 400 0 0],size(roiarr,1),1));
    end
    if strcmp(roiarr,'delete')
      segmentation.ROI =[];
      
       if nargin==2
            at_save;
       end
   
      return;
    end
end


%if numel(position)==1
img=phy_loadTimeLapseImage(segmentation.position,1,1,'nonretreat');

figure, imshow(img,[]);

title(['Position :' num2str(pos)]);


    
   % [xcenter, ycenter] = ginput(1);

   xi=[];
   yi=[];
   
   for i=1:size(roiarr,1)
    width=roiarr(i,3);
    height=roiarr(i,4);  
    x0 = roiarr(i,1)+width/2; 
    y0 = roiarr(i,2)+height/2; 
 
    xi=[xi x0-width/2 x0-width/2 x0+width/2 x0+width/2 x0-width/2];
    yi=[yi y0-height/2 y0+height/2 y0+height/2 y0-height/2 y0-height/2];
   end
    
   
   
    roi_handler = line(xi,yi,'LineWidth',2,'Color','red'); 
    
    
    if move
disp(' '); disp('Select the position of the ROI!');
    drawnow;
    
    roi_text=text(x0-height/2,y0-width/2-20,[num2str(round(x0-height/2)) ', ' num2str(round(y0-width/2))],'Color','r');
    
    userdata.roiarr = roiarr;
    userdata.x0 = x0;
    userdata.y0 = y0;
    
    set(roi_handler,'userdata',userdata);
  
    % set the roisize
    disp(' '); disp('Define the desired position moving the mouse.'); 
    
    disp('Double click to finalize the ROI!');disp(' '); 
    
    set(gcf,'WindowButtonMotionFcn',['change_position(',num2str(roi_handler,20),',',num2str(roi_text,20),')']);
    set(gcf,'WindowButtonDownFcn','complete_radius'); 
    waitfor(gcf,'WindowButtonMotionFcn');
    drawnow; 
    
   out= get(roi_handler,'userdata');
   
   roiarrout=out.roiarr;
   roiarrout(:,1)=roiarrout(:,1)+out.x0;
   roiarrout(:,2)=roiarrout(:,2)+out.y0;
   
   close;
    else
    disp('Press any key to continue with next position!');disp(' '); 
    pause
    close
   roiarrout=roiarr; 
end

   for k=1:length(roiarrout,1)
   segmentation.ROI(k).box=round(roiarrout(k,:));
   
        segmentation.ROI(k).BW=[];
        segmentation.ROI(k).orient=0;
   end
        
   timeLapse.autotrack.position(segmentation.position).ROI=segmentation.ROI;
   %close; 
   %pause(0.5);
   %if nargin==2
   at_save;
   %end
   
end
   
    %
% Sub-function - change_radius
% -----------------------------------------------------------------------
function change_position(roi_handler,roi_text) 
     
userdata = get(roi_handler,'userdata'); 

roiarr = userdata.roiarr;

current_pts = get(gca,'CurrentPoint'); 
current_pt = current_pts(1,1:2); 

x0=current_pt(1);%-xcenter
y0=current_pt(2);%-ycenter
    
xt=x0;%-roiarr(1,3)/2;
yt=y0;%-roiarr(1,4)/2;

xi=[];
yi=[];
   
for i=1:size(roiarr,1)
    width=roiarr(i,3);
    height=roiarr(i,4);  
    x1 = x0+roiarr(i,1)+width/2-roiarr(1,1); 
    y1 = y0+roiarr(i,2)+height/2-roiarr(1,2); 
 
    xi=[xi x1-width/2 x1-width/2 x1+width/2 x1+width/2 x1-width/2];
    yi=[yi y1-height/2 y1+height/2 y1+height/2 y1-height/2 y1-height/2];
    
    %roiarr(i,1)=x1-width/2;
    %roiarr(i,2)=y1-height/2;
   end
    
 
userdata.roiarr=roiarr;
userdata.x0=x0;
userdata.y0=y0;

set(roi_handler,'Xdata',xi,'Ydata',yi);
set(roi_handler,'userdata',userdata); 
set(roi_text,'Position',[xt yt-20],'String',[num2str(round(xt)) ', ' num2str(round(yt))]);
drawnow;
mouseclick = get(gcf,'SelectionType'); 
   
%
% Sub-function - complete_radius
% -----------------------------------------------------------------------
function complete_radius
mouseclick = get(gcf,'SelectionType'); 
if strcmp(mouseclick,'open') 
    set(gcf,'WindowButtonMotionFcn','');
    set(gcf,'WindowButtonDownFcn',''); 
end




