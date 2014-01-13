function at_mapCells()

% this function assigns numbers to cells based on nuclei objects.

% TO OD : cell numbering is not correct for small emerging cells. To be
% fixed later !!!

global segmentation timeLapse

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
            if cells1(cc).ox~=0
                %
                pix=find(valcel==l); % indices of nucleus who points towards cell l

                if numel(pix)>0
                  %  if i==147 && n(pix)==56
                   % a=segmentation.cells1(7457).n
                  % 'ok',cc
                  %  end
                    
                    cells1(cc).n=n(pix);
                    
                    % if i==147
                    %a=segmentation.cells1(7457).n
                   % end
                    
                    tpix=find(N==n(pix)); % determine if tnucleus is present for the first frame
                    
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
    
    

                  %  a=segmentation.cells1(7457).n
%return;
                    
    
    segmentation.tcells1=phy_makeTObject(segmentation.cells1);
%    segmentation.cells1Mapped(starte:ende)=1;
    
    
    % this needs to be fixed
    
    NN=[segmentation.tnucleus.N];
    
    for j=1:length(segmentation.tcells1)
        %if segmentation.tnucleus(i).detectionFrame<=ende && segmentation.tnucleus(i).detectionFrame>=starte
       segmentation.tcells1(j).removeDaughter('ALL');
         
       N=segmentation.tcells1(j).N;
       
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
    
    %TO DO :  force link between nucleus and bud when correcting segmentation
    %problems by hand
    
    % TO DO : 
    
