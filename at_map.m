function nstore2=at_map(objecttype,cc,nstore2,i,cavity)


global segmentation timeLapse


if nargin==4
    if cc>1
        
        nstore2=max(nstore2, max([segmentation.(objecttype)(i-1,:).n]));
        
        temp=segmentation.discardImage(1:i-1); % frame is discarded by user ; display previous frame
        trackFrame=find(temp==0,1,'last');
        
        cell0=segmentation.(objecttype)(trackFrame,:);
        cell1=segmentation.(objecttype)(i,:);
        
        
        if strcmp(objecttype,'cells1')
         param=timeLapse.autotrack.processing.mapCellsPar;
        
        [segmentation.(objecttype)(i,:) OK]=feval(timeLapse.autotrack.processing.mapCellsMethod,cell0,cell1,nstore2,param);
        end
        if strcmp(objecttype,'nucleus')
         param=timeLapse.autotrack.processing.mapNucleusPar;
        
        [segmentation.(objecttype)(i,:) OK]=feval(timeLapse.autotrack.processing.mapNucleusMethod,cell0,cell1,nstore2,param);
        end
        %[segmentation.(objecttype)(i,:) ~]=phy_mapCellsHungarian(cell0,cell1,nstore2,param);
        
        
        fprintf('.');
    end
end

if nargin==5
    nstore2=0;
    nROI=segmentation.ROI;

     if cc==1 % renumber the cells , but no mapping
 
%         cells=segmentation.(objecttype)(i,:);
%         Nr= [cells.Nrpoints];
%         
%         
%         for ii=1:max(Nr)
%             pix=find(Nr==ii);
%             dd=1;
%             for j=pix;
%                 cells(j).n= ii*10000+dd;
%                 dd=dd+1;
%             end
%         end
        
        fprintf('.');
    else % map the cells cavity by cavity
        
        temp=segmentation.discardImage(1:i-1); % frame is discarded by user ; display previous frame
        trackFrame=find(temp==0,1,'last');
        

        cell0=segmentation.(objecttype)(trackFrame,:); % mapped
        totcells=segmentation.(objecttype)(1:trackFrame,:); totcells=totcells(:); ntot=[totcells(:).Nrpoints]; maxn=[totcells(:).n]; maxObjNumber=max(maxn);

        cell1=segmentation.(objecttype)(i,:); % not mapped
        
       % parametres=segmentation.processing.parameters{4,9};
        
        Nr0= [cell0.Nrpoints];
        Nr1= [cell1.Nrpoints];
        
%         if cavity.cavity==0
%             cavity.cavity=1:numel(segmentation.ROI(i).ROI);
%         end
        
        % first rename cell0 for input
        for iik=1:numel(segmentation.ROI(i).ROI) 
            
            ii=segmentation.ROI(i).ROI(iik).n;
            
           
           % if numel(find(cavity.cavity==ii))==0
           %     continue
           % end
            
            fprintf('.');
                 
            %if ii~=7 %test mapping on cavity 19
            %   continue
            %end

            pix0=find(Nr0==ii); % cells in cavity i
            cell0tomap=cell0(pix0);
            
            totcellsN=find(ntot==ii); % all cells in time in cavity
            ntoti=totcells(totcellsN);
            
%             if numel([ntoti.n])==0
%             maxObjNumber=ii*10000;
%             
%             else
%             maxObjNumber=max([ntoti.n]);
%             end
            
            
            
            % remove cells too close to exit of cavity using cavity
            % orientation
            
            %size(segmentation.ROI), size(segmentation.ROI(i).ROI)
            
            orient=segmentation.ROI(i).ROI(iik).orient; 
            box=segmentation.ROI(i).ROI(iik).box;
            oy=[cell0tomap.oy];
            
            % set up filter to filter out cells leaving te cavity
            if orient==1
            filterpos = (box(2)+1.5*box(4)/5);
            pix=find(oy>filterpos);
            else
            filterpos = (box(2)+3.5*box(4)/5); 
            pix=find(oy<filterpos);
            end
              
            cell0tomap=cell0tomap(pix);
            
            
            
            pix1=find(Nr1==ii); % cells in cavity i
            cell1tomap=cell1(pix1);
            
           % pp=[cell1tomap.n]
           % cell1tomap
            %cell1tomap=phy_mapCellsHungarian( cell0tomap, cell1tomap,maxObjNumber,parametres{2,2}, parametres{3,2},parametres{4,2},parametres{5,2},0);
            %cavity,
            
            
            if strcmp(objecttype,'cells1')
                param=timeLapse.autotrack.processing.mapCellsPar;
                
                [cell1tomap OK]=feval(timeLapse.autotrack.processing.mapCellsMethod,cell0tomap,cell1tomap,maxObjNumber,param);
            end
            
            if strcmp(objecttype,'nucleus')
                param=timeLapse.autotrack.processing.mapNucleusPar;
                
                [cell1tomap OK]=feval(timeLapse.autotrack.processing.mapNucleusMethod,cell0tomap,cell1tomap,maxObjNumber,param);
            end
        
            maxObjNumber=max(max([cell1tomap.n]),maxObjNumber);
            
           % pp=[cell1tomap.n]
            
            %assignment(cell0tomap,cell1tomap,cavity.pdfout,cavity.range,[1 1 1 1],maxObjNumber);
            
            % cell1tomap
            %for k=1:numel(cell1tomap)
            %    cell1tomap(k).n=ii*1000+cell1tomap(k).n;
            %end
        end 
    end
end

fprintf('\n');