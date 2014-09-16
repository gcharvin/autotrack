function plotMappingTrainingSet(pdfout,range,M,spacez)



%%

Mout = [M(:,spacez(1)) M(:,spacez(2))];

xb = linspace(min(Mout(:,1)),max(Mout(:,1)),31);
yb = linspace(min(Mout(:,2)),max(Mout(:,2)),31);
%
% figure;

enable=zeros(1,4);
enable(spacez(2)-4)=1;
varz=zeros(1,8);

switch spacez(2)
    case 5
        if spacez(1)==1
            varz(3)=median(M(:,3));
        else
            varz(1)=median(M(:,1));
        end
        
    case 6
        if spacez(1)==2
            varz(3)=median(M(:,3));
        else
            varz(2)=median(M(:,2));
        end
        
    case 7
        if spacez(1)==3
            varz(4)=median(M(:,4));
        else
            varz(3)=median(M(:,3));
        end
        
    case 8
        if spacez(1)==3
            varz(4)=median(M(:,4));
        else
            varz(3)=median(M(:,3));
        end    
end

for i=1:length(xb)
    for j=1:length(yb)
        %p = evaluatePointsUnderPdf(pdee, [xb(i); 600;  yb(j)]);
        
        varz(spacez(1))=xb(i);
        varz(spacez(2))=yb(j);
        
        p=computeProba(pdfout,range,enable,varz);
        
        n1(i,j)=p;
    end
end

figure;

h = pcolor(xb,yb,log(n1'));
colorbar

return;