function collectTrainingSet(cavity,option,display,objecttype)
global segmentation

if strcmp(option,'new') % start new training dataset
    M=zeros(1,8);
    cc=1;
end

if strcmp(option,'append') % append from previous dataset
    [FileName,PathName] = uigetfile('*.mat','Select the .mat dataset');
    load([PathName FileName]);
    cc=size(M,1)+1;
end

[file,path] = uiputfile(['traineddata-' objecttype '.mat'],'Save file name');


%if nargin==0

%cc2=1;

for i=1:numel(segmentation.(['t' objecttype]))
    
    if segmentation.(['t' objecttype])(i).N==0
        continue
    end
    
    if numel(segmentation.(['t' objecttype])(i).Obj)<2
        continue
    end
    
    if numel(cavity) % if particular cavities need to be tracked
        pix=find(cavity==segmentation.(['t' objecttype])(i).Obj(1).Nrpoints);
        
        if numel(pix)==0
            continue;
        end
    end
    
    cav=segmentation.(['t' objecttype])(i).Obj(1).Nrpoints;
    
    
    for j=1:numel(segmentation.(['t' objecttype])(i).Obj)-1
        
        % filter cells in the ammped part of the cavity
        
        frame=segmentation.(['t' objecttype])(i).Obj(j).image;
        
        cavlist=[segmentation.ROI(frame).ROI.n];
        pix=find(cavlist==cav);
        
        orient=segmentation.ROI(frame).ROI(pix).orient;
        box=segmentation.ROI(frame).ROI(pix).box;
        
        oy=segmentation.(['t' objecttype])(i).Obj(j).oy;
        
        % set up filter to filter out cells leaving te cavity
        if orient==1
            filterpos = (box(2)+box(4)/5);
            if oy>filterpos;
               % 'ok'
            else
                continue % cell is not in mapped part of cavity
            end
            
        else
            filterpos = (box(2)+4*box(4)/5);
            if oy<filterpos
              %  'ok'
            else
               continue 
            end
        end
        
        % var at time j
        
        [ox,oy,area,meanint]=getvar(i,j,objecttype);
        
        if area==0;
            continue
        end
        
        % var at time j+1
        
        [ox2,oy2,area2,meanint2]=getvar(i,j+1,objecttype);
        
        if area==0;
            continue
        end
        
        
        %         if j==1
        %            % app(cc2,:)=[ox oy area meanint 1]; % cell appear
        %             cc2=cc2+1;
        %         end
        %
        %         if j==numel(segmentation.(['t' objecttype])(i).Obj)-1
        %             [ox3,oy3,area3,meanint3]=getvar(i,j+1);
        %            % app(cc2,:)=[ox3 oy3 area3 meanint3 -1]; % cell dissappear
        %             cc2=cc2+1;
        %         end
        %
        %         if j~=1 && j~=numel(segmentation.(['t' objecttype])(i).Obj)-1
        %           % app(cc2,:)=[ox oy area meanint 0]; % cell is there
        %            cc2=cc2+1;
        %         end
        
        % remove points where intensity decreases too much (prevents
        % mapping from non-cell to cell)
        if abs(meanint2-meanint)>400
            continue
        end
        
        M(cc,:)=[ox oy area meanint ox2-ox oy2-oy area2-area meanint2-meanint];
        cc=cc+1;
        
        % pause
        %if j==10
        %     return;
        % end
        
    end
    
end


save([path file],'M');


if display
    % visualize the N dimensionnal histogram using 2D hyperplans
    
    % plot dx,dy,darea,dint as a function of x,y,area,int
    
    nbins=2*[10 10 10 10 10 10 10 10]; %number of bins used for each variable
    labels={'X','Y','Area','Intensity','DX','DY','DArea','DIntensity'};
    
    figure;
    p=panel();
    p.pack(4,4);
    
    for i=1:4
        for j=5:8
            p(i,j-4).select(); % plotting dx as a function of x histogram
            xlabel(labels{i});
            ylabel(labels{j});
            
            dat=[M(:,i),M(:,j)];
            
            n=hist3(dat,[nbins(i) nbins(j)]);
            n1 = n';
            n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
            %
            xb = linspace(min(dat(:,1)),max(dat(:,1)),size(n,1)+1);
            yb = linspace(min(dat(:,2)),max(dat(:,2)),size(n,1)+1);
            %
            % figure;
            h = pcolor(xb,yb,log10(n1));
            % xlabel('Y position');
            % ylabel('Delta Y');
            colorbar
            
        end
    end
    
    
    figure;
    p=panel();
    p.pack(3,1);
    
    
    labels={'X','Area','Intensity'};
    ind=[1 3 4];
    
    for i=1:3
            p(i,1).select(); % plotting dx as a function of x histogram
            xlabel(labels{i});
            ylabel('Y');
            
            dat=[M(:,ind(i)),M(:,2)];
            
            n=hist3(dat,[nbins(i) nbins(j)]);
            n1 = n';
            n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
            %
            xb = linspace(min(dat(:,1)),max(dat(:,1)),size(n,1)+1);
            yb = linspace(min(dat(:,2)),max(dat(:,2)),size(n,1)+1);
            %
            % figure;
            h = pcolor(xb,yb,log10(n1));
            % xlabel('Y position');
            % ylabel('Delta Y');
            colorbar
            
    end
end



function [ox,oy,area,meanint]=getvar(i,j,objecttype)
global segmentation

%fprintf('----------')

ox=segmentation.(['t' objecttype])(i).Obj(j).ox;
oy=segmentation.(['t' objecttype])(i).Obj(j).oy;

cavity=segmentation.(['t' objecttype])(i).Obj(j).Nrpoints;

frame= segmentation.(['t' objecttype])(i).Obj(j).image;

if numel(segmentation.ROI)<frame
    area=0;
    meanint=0;
    return
end

if numel(segmentation.ROI(frame).ROI)==0
    area=0;
    meanint=0;
    return
end

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

area=segmentation.(['t' objecttype])(i).Obj(j).area/segmentation.processing.avgCells1.area;
meanint=segmentation.(['t' objecttype])(i).Obj(j).fluoMean(1)/segmentation.processing.avgCells1.inte;

%varint=segmentation.(['t' objecttype])(i).Obj(j).fluoVar(1);
%ecc=0;


