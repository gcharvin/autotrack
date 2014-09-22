function tassignement(pdfout,range,enable,objecttype)
global segmentation

% link trajectories in case of premature loss of cells during tracking

% cost matrix based on time between successive end and start
% conditions : 1) end must occur before start
% 2) physical distance between cells must be smaller than a threshold
% 3) proba based on cell position size and intensity



display=0;

% list all tobject starts and ends
D=[];
D.mat=[];
D.tcells=[];
D.link=[];


fprintf('Building list of tcells...\n');
for i=1:numel(segmentation.(['t' objecttype]))
    if segmentation.(['t' objecttype])(i).N==0
        continue
    end
    
    cavity=segmentation.(['t' objecttype])(i).Obj(1).Nrpoints;
    
    if numel(D)<cavity
        D(cavity).tcells=[];
    else
        
        % filter position of beginning of trajectory
        initcell=segmentation.(['t' objecttype])(i).Obj(1);
        
        [x0, y0, area0, intensity0]=offsetCoordinates(initcell);
        
        if y0>50 % filterpos
            continue
        end
        
        D(cavity).tcells=[D(cavity).tcells i]; % list all tcells to consider
    end
end

for k=1:numel(D) % loop on cavity number
   fprintf(['Gap closing for cavity : ' num2str(k) '\n']);
   
    M=-Inf*ones(length(D(k).tcells),length(D(k).tcells));
    
    
    for i=1:length(D(k).tcells) % start traj
        
          % if i>100
        %continue
           %end
        
        id=D(k).tcells(i);

        for j=1:length(D(k).tcells) % end traj

             %if j>100
             %   continue
             %end
           
            if i==j % cost +Inf for i==j
                continue
            end
            
            jd=D(k).tcells(j);
            
            st=segmentation.(['t' objecttype])(id).Obj(1).image;
            en=segmentation.(['t' objecttype])(jd).Obj(end).image;
            
            if st<=en % traj finishes after the start of the other : +Inf
                continue
            end
            if st-en>10 % traj finishes too early
                continue
            end
            
            [xst yst areast intensityst]=offsetCoordinates(segmentation.(['t' objecttype])(id).Obj(1));
            [xen yen areaen intensityen]=offsetCoordinates(segmentation.(['t' objecttype])(jd).Obj(end));
            
            
            dist=sqrt((yen-yst)^2 + (xen-xst)^2);
            
            if dist > 100 % cells are too far
                continue
            end
            
            varz=[xst yst areast intensityst xen-xst yen-yst areaen-areast intensityen-intensityst];
            coef=log(computeProba(pdfout,range,enable,varz));
            
            % put a penalty based on timings
            
            coef=coef-(st-en-1)*5;
            
            if coef>-80 % cutoff proba; %60
                M(i,j)=coef;
            else
                M(i,j)=-Inf;
            end
 
            
        end
    end

M=-M;

%M

%M=M(1:100,1:100);

[Matching,Cost] = Hungarian(M);

pos=[];
if display
    figure; 
    
    for i=1:size(M,1)
     id=D(k).tcells(i);
     st=segmentation.(['t' objecttype])(id).Obj(1).image;
     en=segmentation.(['t' objecttype])(id).Obj(end).image;
     rectangle('Position',[0+st 25*i en-st+1 20],'FaceColor','r');
     pos=[pos 25*i];
     text(segmentation.(['t' objecttype])(D(k).tcells(1)).Obj(1).image-20,25*i+10,num2str(id));
    end
    
    for j=1:size(Matching,2)
        col=Matching(:,j);
        pix=find(col);
        
        if numel(pix)
           % j,pix
        jd=D(k).tcells(j);
        id=D(k).tcells(pix);
        
        fprintf(['link: ' num2str(jd) ' - ' num2str(id) '\n']);
        
        x=segmentation.(['t' objecttype])(jd).Obj(end).image+1;
        
        line([x x],[pos(j) pos(pix)+20],'Color','g','LineWidth',2);
        end
    end
end

% extract links between cells
D(k).link=zeros(1,2);
cc=1;

   for j=1:size(Matching,2)
        col=Matching(:,j);
        pix=find(col);
        
        if numel(pix)
          
        jd=D(k).tcells(j);
        id=D(k).tcells(pix);
        
        D(k).link(cc,1)=jd;
        D(k).link(cc,2)=id;
        
        cc=cc+1;
        end
   end
    
end

% build celltraj object; 

celltraj=[];
celltraj.cavity=[];
celltraj.tcell=[];
celltraj.birth=[]; % 1: cell is born small; 0: cell is born big
celltraj.death=[]; % 1: cell dies in cavity; 0: 
celltraj.n=[];
celltraj.length=[];


cc=1;
fprintf('Building complete trajectories...\n');
for i=1:numel(segmentation.(['t' objecttype]))
    if segmentation.(['t' objecttype])(i).N==0
        continue
    end
   
    cavity=segmentation.(['t' objecttype])(i).Obj(1).Nrpoints;
    
    pix=find(D(cavity).link(:,2)==i); 
    
    if numel(pix) % this tcell is linked by another cavity
        
       prectcells= D(cavity).link(pix,1);
       
       ntraj=[celltraj.n];
       ncell=[celltraj.tcell];
       
       pix2=find(ncell==prectcells);
       
       if numel(pix2)
          ntraj=ntraj(pix2); 
          
          celltraj(ntraj).tcell=[celltraj(ntraj).tcell i];
          celltraj(ntraj).n=[celltraj(ntraj).n ntraj];
          celltraj(ntraj).length=celltraj(ntraj).length+length(segmentation.(['t' objecttype])(i).Obj);
       end
       
    else %new trajectory
        celltraj(cc).cavity=cavity;
        celltraj(cc).tcell=i;
        celltraj(cc).birth=0;
        celltraj(cc).death=0;
        celltraj(cc).n=cc;
        celltraj(cc).length=length(segmentation.(['t' objecttype])(i).Obj);
        cc=cc+1;
    end
    
    
end

saveCellTraj(celltraj,objecttype);



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

function saveCellTraj(celltraj,objecttype)
global segmentation timeLapse

celldat=celltraj;

fprintf(['Saving Celltraj for position: ' num2str(segmentation.position) '...\n']);
    
localpath=userpath;
localpath=localpath(1:end-1);
pos=segmentation.position;
if isunix
save([localpath '/' objecttype 'traj-autotrack.mat'],'celldat');
eval(['!mv ' [localpath '/' objecttype 'traj-autotrack.mat'] ' ' timeLapse.realPath timeLapse.pathList.position{pos} '/' objecttype 'traj-autotrack.mat']);
%
else
   save(fullfile(timeLapse.realPath,timeLapse.pathList.position{pos},['/' objecttype 'traj-autotrack.mat']),'celldat');
end

