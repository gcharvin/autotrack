function swap=at_mapCells(check)

% this function assigns numbers to cells based on nuclei objects.
% return swap array indicating events in which nucleus swapping between M
% and D occurs

global segmentation timeLapse


if nargin==0
    
parametres=segmentation.processing.parameters(4,9);
parametres=parametres{1,1};

pos=segmentation.position;

nm=segmentation.nucleusMapped;
cs=segmentation.cells1Segmented;

if nm~=cs
    disp('Number of mapped nuclei frames does not match the number of segmented cell frames');
    return;
end

ende=find(nm==1,1,'last');
starte=find(nm==1,1,'first');

%ende=30;
%starte=1;

frames=ende:-1:starte;

N=[segmentation.tnucleus.N];

for i=frames
    fprintf('.');
   %- i
    % get nuclei and cells coordinates
    nuclei=segmentation.nucleus(i,:);
    
    
    cells1=segmentation.cells1(i,:);
    nc=[cells1.n];
    
    % build a mask of cells
    
    n=[]; valcel=[];
    
    for k=1:numel(nuclei)
        
        ox=nuclei(k).ox;
        oy=nuclei(k).oy;
        
        if ox~=0
            
            % ox,oy
            n(k)=nuclei(k).n;
            
            for j=1:numel(cells1)
                
                if cells1(j).ox~=0
                    
                    if mean(inpolygon(ox,oy,cells1(j).x,cells1(j).y))>0
                        
                        valcel(k)=cells1(j).n(1);
                        
                    end
                end
            end
        end
    end
    
    %     if i==147
    %     n,valcel
    %     nc=[cells1.n]
    %     end
    assigned=zeros(1,length(cells1));
    cc=length(valcel);
    nc=[cells1.n];
    
    cc=1;
    cc2=max([segmentation.cells1.n]);
    
    % assign the nucleus number to cells that carry a defined nucleus
    % assign another number to the ones withou nuclei
    
    for l=nc
        %
        %a=cells1(cc)
        if cells1(cc).ox~=0
            %
            pix=find(valcel==l); % indices of nucleus who points towards cell l
            
            if numel(pix)>0
                %  if i==147 && n(pix)==56
                % a=segmentation.cells1(7457).n
                % 'ok',cc
                %  end
                pix=pix(1);
                cells1(cc).n=n(pix);
                
                % if i==147
                %a=segmentation.cells1(7457).n
                % end
                %l,N,n(pix)
                tpix=find(N==n(pix)); % determine if tnucleus is present for the first time on this frame
                
                if segmentation.tnucleus(tpix).detectionFrame<i % cell is set as  'assigned' only if the nucleus in it is not present for the first time. If not, then it needs to be mapped
                    assigned(cc)=1;
                end
                
            else
                %
                cells1(cc).n=cc2;
                cc2=cc2+1;
                %
            end
        end
        cc=cc+1;
    end
    
    if i==ende % first frame : take all the cells that were not assigned
        pix=find(assigned==0);
        cel0=cells1;
    else
        pix=find(assigned==0); % take all the cells that were not assigned
        pix2=find(assigned==1);
        
        cel1=cells1(pix);
        
        lastObjectNumber=max([segmentation.cells1.n]);
        
        % if i==147
        %   i,a=segmentation.cells1(147,44).n
        % end
        
        tempCells=phy_mapCellsHungarian(cel0,cel1,lastObjectNumber, parametres{2,2}, parametres{3,2},parametres{4,2},parametres{5,2},parametres{6,2});
        
        segmentation.cells1(i,:)=[cells1(pix2) tempCells];
        
        
        cel0=segmentation.cells1(i,:);
        
    end
end



fprintf('\n');
% end of loop on frames


segmentation.tcells1=phy_makeTObject(segmentation.cells1);
segmentation.cells1Mapped(starte:ende)=1;

NN=[segmentation.tnucleus.N];

% copy daughters from nucleus to cells
for j=1:length(segmentation.tcells1)
    %if segmentation.tnucleus(i).detectionFrame<=ende && segmentation.tnucleus(i).detectionFrame>=starte
    segmentation.tcells1(j).removeDaughter('ALL');
    
    N=segmentation.tcells1(j).N;
    
    if N==0
        continue
    end
    
    pix=find(NN==N);
    
    if length(pix)==0
        continue
    end
    %NNpix=NN(pix);

    for i=1:length(segmentation.tnucleus(pix).daughterList)
        %a=segmentation.tnucleus(pix).daughterList(j)
        %b=segmentation.tnucleus(pix).divisionTimes(j)
        segmentation.tcells1(j).addDaughter(segmentation.tnucleus(pix).daughterList(i),[],segmentation.tnucleus(pix).divisionTimes(i))
        segmentation.tcells1(segmentation.tnucleus(pix).daughterList(i)).setMother(N);
    end
    % end
end

end


swap=[];
% check nuclei swapping events based on cell contours
for i=1:length(segmentation.tnucleus)
    firstframe=segmentation.tnucleus(i).detectionFrame;
    
    
    if segmentation.tcells1(i).detectionFrame==firstframe
        % this is suspicious : the cell is born at the same frame as the
        % nucleus; let's check the volume of its mother
        
        %i
        mother=segmentation.tcells1(i).mother;
        
        if mother~=0
        cD=segmentation.tcells1(i).Obj(1).area;
        
        fra=[segmentation.tcells1(mother).Obj.image];
        pix=find(fra==firstframe);
        
        if numel(pix)~=0 & pix>1
        
           
        cM1=segmentation.tcells1(mother).Obj(pix-1).area;
        cM2=segmentation.tcells1(mother).Obj(pix).area;
        
        d1=(cD-cM1)/cM1;
        d2=(cM2-cM1)/cM1;
        
        if abs(d1)<0.1 && d2<-0.1
            swap=[swap ; i mother firstframe];
        end
        end
        end
        
    end
end


tobj=segmentation.tnucleus;

% swap tnuclei
for k=1:size(swap,1)
    
        % 'okfrom'
        
        n1= swap(k,1);
        n2= swap(k,2);
        
        %collect n1 cells and delete from n1 tobject
        c=0;
        objectMoved1=phy_Object;
        
        % length(segmentation.selectedTObj.Obj)
        
        for i=1:length(tobj(n1).Obj)
            if tobj(n1).Obj(i).image>=swap(k,3)
                tobj(n1).Obj(i).n=n2;
                %tobj(n2).addObject(segmentation.selectedTObj.Obj(i));
                c=c+1;
                objectMoved1(c)=tobj(n1).Obj(i);
            end
        end
        for i=1:c
            tobj(n1).deleteObject(objectMoved1(i),'only from tobject');
        end
        
        %collect n2 cells and delete from n2 tobject
        c=0;
        objectMoved2=phy_Object;
        
        %length(tobj(n2).Obj)
        
        for i=1:length(tobj(n2).Obj)
            if tobj(n2).Obj(i).image>=swap(k,3)
                tobj(n2).Obj(i).n=n1;
                %tobj(n2).addObject(segmentation.selectedTObj.Obj(i));
                c=c+1;
                objectMoved2(c)=tobj(n2).Obj(i);
                
            end
        end
        for i=1:c
            tobj(n2).deleteObject(objectMoved2(i),'only from tobject');
        end
        
        tobj(n2).addObject(objectMoved1);
        tobj(n1).addObject(objectMoved2);
        
        
        % sort frames
        
        minFrame=sort([tobj(n2).Obj.image]);
        %pix=find(minFrame,1,'first');
        %minFrame=max(1,minFrame(pix)-1);
        tobj(n2).lastFrame=max(minFrame);
        
        minFrame=sort([tobj(n1).Obj.image]);
        %pix=find(minFrame,1,'first');
        %minFrame=max(1,minFrame(pix)-1);
        tobj(n1).lastFrame=max(minFrame);
        
        
        segmentation.tnucleus=tobj;

end

if numel(swap)
    swap
fprintf('Nuclei swap events were detected; You MUST run at_setNuclearLinks again and then this function one more time with no argument !\n');
end
        
%TO DO :  force link between nucleus and bud when correcting segmentation
%problems by hand - how to do that ???

