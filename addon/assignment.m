function assignment(cell0,cell1,pdfout,range,enable,maxObjNumber)

% perform hungarian assignment based on porbability of association and
% using hungarian method for assignement

% frame is necessary to find the position of the cavity

% buld cost matrix 

% TO DO : % infinite cost if cells are too separated to improve speed
% trajectory assignment based DONE
% cell smart renumbering for cells leaving the cavity in order to keep the
% number low enough : not done

if maxObjNumber==-1
display=1;
else
display=0;   
end

ind0=find([cell0.ox]~=0);
ind1=find([cell1.ox]~=0);


M=-Inf*ones(length(ind0),length(ind1));

varz=zeros(1,8);

if display
    figure; axis equal
end

for i=1:length(ind0)
    
    id=ind0(i);
    
    [x0, y0, area0, intensity0]=offsetCoordinates(cell0(id));

    if display
    line(cell0(id).x,-cell0(id).y,'Color','r');
    end
    
    for j=1:length(ind1)
        
        
        jd=ind1(j);
        [x1, y1, area1, intensity1]=offsetCoordinates(cell1(jd));
        
        dist = sqrt((x1-x0)^2+(y1-y0)^2); % distance between cells in pixels
        
        if dist > 7*sqrt(range(3)/pi) % if cells are well separated, don't compute proba
        coef=-300;
        else
        varz=[x0 y0 area0 intensity0 x1-x0 y1-y0 area1-area0 intensity1-intensity0];
        coef=log(computeProba(pdfout,range,enable,varz));
        end
        
        if coef>-60 % cutoff proba
        M(i,j)=coef;
        else
        M(i,j)=-Inf;    
        end
       
        
        if display
        if i==1
            line(cell1(jd).x+150,-cell1(jd).y,'Color','b');
        end
        end
        
    end
end

M=-M;

%M

[Matching,Cost] = Hungarian(M);

listi=[];
newborn=[];
for j=1:size(Matching,2)
   col=Matching(:,j);
   pix=find(col);
   jd=ind1(j);
   
   if numel(pix)
   
   id=ind0(pix);
   
   listi=[listi id]; % list of cells assigned correctly
   
   if maxObjNumber~=-1
   cell1(jd).n=cell0(id).n;
   end
   
   if display
       line([cell1(jd).ox+150 cell0(id).ox],[-cell1(jd).oy -cell0(id).oy],'Color','k');
       xpos=mean([cell1(jd).ox+150 cell0(id).ox]);
       ypos=mean([-cell1(jd).oy -cell0(id).oy]);
       
       text(xpos,ypos,num2str(M(pix,j)));
   end
   
   else % no match; cell is just born; assign new number
    newborn=[newborn jd];
    
    if display
        line(cell1(jd).x+150,-cell1(jd).y,'Color','g'); 
    end
    
   end
end

%newborn=unique(newborn);



for j=newborn
   %n=[cell1.n];
   if maxObjNumber~=-1 % non demo mode
   cell1(j).n=maxObjNumber+1;
   maxObjNumber=maxObjNumber+1;
   end
end


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
