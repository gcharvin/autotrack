function [peak area bckgrd]=at_measureNucleusFluo(nucleus,img,binning,hdisplay)

% binning = 2 if fluo image is already binned 2x2 (but nucleus contours are
% not)

%[fluo npeaks peak fitresult gof]=at_measureNucleusFluo(nucleus,img,hdisplay)
% measure fluo level using by performing integration of pixels in the image

%gaussian fit

global segmentation

warning off all;
xp=nucleus.ox/binning;
yp=nucleus.oy/binning;
siz=sqrt(nucleus.area/pi)/binning;
wsize=round(2*siz);

%figure, imshow(img,[]); hold on; line(nucleus.x,nucleus.y)

%wsize=12; % to be guessed base don pixel size later

xmin=max(xp-wsize,1);
xmax=min(xp+wsize,size(img,2));
ymin=max(yp-wsize,1);
ymax=min(yp+wsize,size(img,1));


subim=img(ymin:ymax,xmin:xmax);

%figure(hdisplay); 
%colormap jet;
%imshow(subim,[500 4500]);

% find image background
nb=0:50:10000;
hi=hist(subim(:),nb);
[histmax backpix]=max(hi);
backpix=nb(backpix);

% integrat pixel intensity for varying contour size

sca=1:0.2:5;
cc=1; val=0; pixn=0;
sizsubim=size(subim);

%tic
for i=sca
   xc=i*(nucleus.x/binning-nucleus.ox/binning)+nucleus.ox/binning;
   yc=i*(nucleus.y/binning-nucleus.oy/binning)+nucleus.oy/binning;
   
   xc=xc-nucleus.ox/binning+wsize+1;
   yc=yc-nucleus.oy/binning+wsize+1;
   
   %figure(hdisplay); 
   %colormap jet;
   %imshow(subim,[500 4500]); hold on; line(xc,yc,'Color','k','LineWidth',2) ;
   
   BW=poly2mask(xc,yc,sizsubim(1),sizsubim(2));
   pix=BW==1;

   val(cc)=sum(subim(pix));   
   pixn(cc)=sum(pix(:));
   
   cc=cc+1;
end

 piw=find(pixn>0.9*max(pixn),1,'first');
 
 p=polyfit(pixn(piw:end),val(piw:end),1);
 f=pixn.*p(1);
 
 thr=0.9;
 pix=find(val-f>=thr*max(val-f),1,'first'); % find number of pixels such that 90% of pixels of total signal is integrated
 
 peak=(val(pix)-f(pix));
 area=pixn(pix);
 bckgrd=p(1);
 
%toc;

%f = polyval(p,sca.*sca);

if nargin==4
figure(hdisplay);
 plot(pixn,val,'lineStyle','.'); hold on; plot(pixn,f,'Color','r');
end

% % gaussian fit based on two gaussian - curve fitting
% 
% warning on all;
% 
% %figure, imshow(subim,[]); hold on; line(nucleus.x-nucleus.ox+wsize,nucleus.y-nucleus.oy+wsize);
% %return;
% 
% [x,y]=ind2sub(size(subim),1:size(subim,1)*size(subim,2));
% z=subim(:);
% x=x';
% y=y';
% 
% 
% ft = fittype( 'a + b*exp(-(x-c)^2/(2*d^2)-(y-e)^2/(2*d^2)) + f*exp(-(x-g)^2/(2*d^2)-(y-h)^2/(2*d^2))', 'indep', {'x', 'y'}, 'depend', 'z' );
% 
% 
% opts = fitoptions( ft );
% opts.Display = 'Off';
% opts.Lower = [500 200 1 siz/2 1 200 1 1 ];
% opts.StartPoint = [800 1500 wsize siz wsize 1500 wsize wsize];
% opts.Upper = [1000 5000 2*wsize 2*siz 2*wsize 5000 2*wsize 2*wsize];
% opts.Weights = zeros(1,0);
% 
% tic;
% warning off all
% [fitresult, gof] = fit( [x, y], z, ft, opts );
% warning on all
% toc;

% % altenrative using lsqnonlin
% 
% I=subim;%assume gray scale, not RGB
% [n,m]=size(I);%assumes that I is a nxm matrix
% [X,Y]=meshgrid(1:n,1:m);%your x-y coordinates
% x(:,1)=X(:); % x= first column
% x(:,2)=Y(:); % y= second column
% f=I(:); % your data f(x,y) (in column vector)
% %--- now define the function in terms of x
% %--- where you use x(:,1)=X and x(:,2)=Y
% fun = @(c,x) c(1)+c(2)*exp(-((x(:,1)-c(3))/(sqrt(2)*c(4))).^2-((x(:,2)-c(5))/(sqrt(2)*c(4))).^2)+ c(6)*exp(-((x(:,1)-c(7))/(sqrt(2)*c(4))).^2-((x(:,2)-c(8))/(sqrt(2)*c(4))).^2); 
% 
% 
% %ft = fittype( 'a + b*exp(-(x-c)^2/(2*d^2)-(y-e)^2/(2*d^2)) + f*exp(-(x-g)^2/(2*d^2)-(y-h)^2/(2*d^2))'
% 
% 
% %--- now solve with lsqcurvefit
% options=optimset('TolX',1e-20);
% c0=[800 1500 wsize siz wsize 1500 wsize wsize];%start-guess here
% 
% tic;
% cc=lsqcurvefit(fun,opts.StartPoint,x,f,opts.Lower,opts.Upper,options)
% toc;
% Ifit=fun(cc,x); %your fitted gaussian in vector
% Ifit=reshape(Ifit,[n m]);%gaussian reshaped as matrix
% 
% figure; 
% h = plot3(x,y,z,'.','Color','k'); hold on; 
% %h2=surf(X,Y,Ifit); set(h2,'FaceAlpha',0.4);
% xlim([0 2*wsize]);
% ylim([0 2*wsize]);
% zlim([500 4500]);


% % analyze distance between peaks ( 2 gaussians fit)
% 
% dist1=sqrt((fitresult.c-wsize)^2+(fitresult.e-wsize)^2); %dist to center
% dist2=sqrt((fitresult.g-wsize)^2+(fitresult.h-wsize)^2); % dist to center
% dist3=sqrt((fitresult.g-fitresult.c)^2+(fitresult.h-fitresult.e)^2); % distance between peaks
% 
% 
% if dist3>3*fitresult.d
%     npeaks=2;
%     
%     if dist1>dist2
%         fluo=fitresult.d^2*(fitresult.f);
%         peak=fitresult.f;
%        % fluo=fitresult.f;
%     else
%         fluo=fitresult.d^2*(fitresult.b);
%         peak=fitresult.b;
%        % fluo=fitresult.b;
%     end
%     
% else
%     fluo=fitresult.d^2*(fitresult.b+fitresult.f);
%     %fluo=fitresult.b+fitresult.f;
%     peak=fitresult.b+fitresult.f;
%     npeaks=1;
% end
% 
% if nargin==3
%    
% figure(hdisplay); 
% subplot(1,3,1); imshow(subim,[500 4500]); hold on; line(nucleus.x/binning-nucleus.ox/binning+wsize+1,nucleus.y/binning-nucleus.oy/binning+wsize+1,'Color','k','LineWidth',2) ;
% subplot(1,3,2);
% colormap(jet);
% % Plot fit with data.
% %figure( 'Name', 'Gaussian fit' );
% h = plot3(x,y,z,'.','Color','k'); hold on; 
% h2=plot(fitresult); set(h2,'FaceAlpha',0.4);
% xlim([0 2*wsize]);
% ylim([0 2*wsize]);
% zlim([500 4500]);
% set(gca,'FontSize',20);
% %figure, imshow(subim,[]);  hold on; h=plot(fitresult);
% %legend( h, 'untitled fit 1', 'z vs. x, y', 'Location', 'NorthEast' );
% % Label axes
% xlabel( 'x' );
% ylabel( 'y' );
% zlabel( 'z' );
% grid on
% view( 120, 15 );
% title([num2str(npeaks) ' peak - fluo: ' num2str(round(fluo))]);
% 
% set(hdisplay,'Position',[100 100 1600 500],'Color','w');
% end

