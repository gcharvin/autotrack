function phy_mapCellBackwards(ende,starte)

% TO OD : cell numbering is not correct for small emerging cells. To be
% fixed later !!!

% however transfert of cell label from nucleus to cells works fine

global segmentation

parametres=segmentation.processing.parameters(1,9);
parametres=parametres{1,1};

frames=ende:-1:starte;

for i=frames
    fprintf('.');
    nuclei=segmentation.nucleus(i,:);
    
    
    ox=round([nuclei.ox]);
    oy=round([nuclei.oy]);
    n=[nuclei.n];
    
    pix=find(ox~=0);
    
    ox=ox(pix);
    oy=oy(pix);
    n=n(pix);
    
    cells1=segmentation.cells1(i,:);
    nc=[cells1.n];
    
    mask=zeros(size(segmentation.realImage(:,:,1)));
    
    for j=1:numel(cells1)
        
        masktemp=poly2mask(cells1(j).x,cells1(j).y,size(segmentation.realImage(:,:,1),1),size(segmentation.realImage(:,:,1),2));
        mask(masktemp)=cells1(j).n;
        
    end
    
    %figure, imshow(mask,[]); line(ox,oy,'Color','r','LineStyle','+'); %text(ox,oy+10,num2str());
    
   % size(mask)
   
    ind=sub2ind(size(mask),oy,ox);
    
    %ox(1),oy(1),n(1)
    
    %n
    valcel=mask(ind);
    
    assigned=zeros(1,length(cells1));
    
    cc=length(valcel);
    
    
     nc=[cells1.n];
%         
%     
cc=1;
cc2=max([segmentation.cells1.n]);
     for l=nc
%         
         if cells1(cc).ox~=0
%             
             pix=find(valcel==l);
%             
%             pix,n(pix),cells1(l).n
%             
             if numel(pix)>0
                 cells1(cc).n=n(pix);
                 assigned(cc)=1;
             else
%                 
                 cells1(cc).n=cc2;
                 cc2=cc2+1;
%                 
             end
         end
       cc=cc+1;  
     end
%     
%     %length(valcel)
   %  nc=[cells1.n]
%     segmentation.cells1(i,:)=cells1;
    

if i==ende
pix=find(assigned==0);
cel0=cells1;
else
pix=find(assigned==0);
cel1=cells1(pix); 

lastObjectNumber=max([segmentation.cells1.n]);
segmentation.cells1(i,pix)=phy_mapCellsHungarian(cel0,cel1,lastObjectNumber, parametres{2,2}, parametres{3,2},parametres{4,2},parametres{5,2},parametres{6,2});

cel0=segmentation.cells1(i,:);

end



end

fprintf('\n');



segmentation.tcells1=phy_makeTObject(segmentation.cells1);

segmentation.cells1Mapped(starte:ende)=1;


% this needs to be fixed

% for i=1:length(segmentation.tnucleus)
%     %if segmentation.tnucleus(i).detectionFrame<=ende && segmentation.tnucleus(i).detectionFrame>=starte
%      segmentation.tcells1(i).removeDaughter('ALL');   
%    for j=1:length(segmentation.tnucleus(i).daughterList)
%        %a=segmentation.tnucleus(i).daughterList(j)
%        %b=segmentation.tnucleus(i).divisionTimes(j)
%        segmentation.tcells1(i).addDaughter(segmentation.tnucleus(i).daughterList(j),[],segmentation.tnucleus(i).divisionTimes(j))
%        segmentation.tcells1(segmentation.tnucleus(i).daughterList(j)).setMother(i);
%    end
%    % end
% end

