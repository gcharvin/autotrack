function newROI=at_mapROI(ROI,oldROI)
% map ROI for cavity using greddy algorithm

dist=zeros(length(ROI),length(oldROI));


for i=1:length(ROI)
    for j=1:length(oldROI)
        
        boxi=ROI(i).box;
        xi=boxi(1)+boxi(3)/2;
        yi=boxi(2)+boxi(4)/2;
        
        boxj=oldROI(j).box;
        xj=boxj(1)+boxj(3)/2;
        yj=boxj(2)+boxj(4)/2;
        
        dist(i,j)=sqrt( (xi-xj)^2 + (yi-yj)^2);
    end
end

[sortedDist ix]=sort(dist(:));

%attrib=ones(1,length(oldROi));

newROI=struct('box',[],'BW',[],'orient',[],'n',[]);

cc=1;
for k=1:length(sortedDist)
    
    if sortedDist(k)>50
        break;
    end
    
    ind=ix(k); % index of item in dist matrix
    
    [i j]=ind2sub(size(dist),ind);
    
    newROI(cc)=ROI(i);
    newROI(cc).n=oldROI(j).n;
    
    cc=cc+1;
    
end
