function [fluo npeaks peak fitresult gof]=at_measureNucleusFluo(nucleus,img,hdisplay)
% measure fluo level using gaussian fit

global segmentation

warning off all;
xp=nucleus.ox;
yp=nucleus.oy;
siz=sqrt(nucleus.area/pi);
wsize=round(2*siz);

%figure, imshow(img,[]); hold on; line(nucleus.x,nucleus.y)

%wsize=12; % to be guessed base don pixel size later

xmin=max(xp-wsize,1);
xmax=min(xp+wsize,size(img,2));
ymin=max(yp-wsize,1);
ymax=min(yp+wsize,size(img,1));

subim=img(ymin:ymax,xmin:xmax);
warning on all;

%figure, imshow(subim,[]); hold on; line(nucleus.x-nucleus.ox+wsize,nucleus.y-nucleus.oy+wsize);
%return;

[x,y]=ind2sub(size(subim),1:size(subim,1)*size(subim,2));
z=subim(:);
x=x';
y=y';


ft = fittype( 'a + b*exp(-(x-c)^2/(2*d^2)-(y-e)^2/(2*d^2)) + f*exp(-(x-g)^2/(2*d^2)-(y-h)^2/(2*d^2))', 'indep', {'x', 'y'}, 'depend', 'z' );

opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [500 200 1 siz/2 1 200 1 1 ];
opts.StartPoint = [800 1500 wsize siz wsize 1500 wsize wsize];
opts.Upper = [1000 5000 2*wsize 2*siz 2*wsize 5000 2*wsize 2*wsize];
opts.Weights = zeros(1,0);
warning off all
[fitresult, gof] = fit( [x, y], z, ft, opts );
warning on all




% analyze distance between peaks

dist1=sqrt((fitresult.c-wsize)^2+(fitresult.e-wsize)^2); %dist to center
dist2=sqrt((fitresult.g-wsize)^2+(fitresult.h-wsize)^2); % dist to center
dist3=sqrt((fitresult.g-fitresult.c)^2+(fitresult.h-fitresult.e)^2); % distance between peaks


if dist3>3*fitresult.d
    npeaks=2;
    
    if dist1>dist2
        fluo=fitresult.d^2*(fitresult.f);
        peak=fitresult.f;
       % fluo=fitresult.f;
    else
        fluo=fitresult.d^2*(fitresult.b);
        peak=fitresult.b;
       % fluo=fitresult.b;
    end
    
else
    fluo=fitresult.d^2*(fitresult.b+fitresult.f);
    %fluo=fitresult.b+fitresult.f;
    peak=fitresult.b+fitresult.f;
    npeaks=1;
end

if nargin==3
   
figure(hdisplay); 
subplot(1,3,1); imshow(subim,[500 4500]); hold on; line(nucleus.x-nucleus.ox+wsize+1,nucleus.y-nucleus.oy+wsize+1,'Color','k','LineWidth',2) ;
subplot(1,3,2);
colormap(jet);
% Plot fit with data.
%figure( 'Name', 'Gaussian fit' );
h = plot3(x,y,z,'.','Color','k'); hold on; h2=plot(fitresult); set(h2,'FaceAlpha',0.4);
xlim([0 2*wsize]);
ylim([0 2*wsize]);
zlim([500 4500]);
set(gca,'FontSize',20);
%figure, imshow(subim,[]);  hold on; h=plot(fitresult);
%legend( h, 'untitled fit 1', 'z vs. x, y', 'Location', 'NorthEast' );
% Label axes
xlabel( 'x' );
ylabel( 'y' );
zlabel( 'z' );
grid on
view( 120, 15 );
title([num2str(npeaks) ' peak - fluo: ' num2str(round(fluo))]);

set(hdisplay,'Position',[100 100 1600 500],'Color','w');
end

