function [x y theta] = at_cavity(frame,varargin)
global segmentation
% align cavity to model defined by at_grid

display=1;

%mode : 'coarse' : identifies group of cavity
%mode : 'fine' : fine tuning of cavity position

%s trategy : 
%1 - coarse mode with large screening in rotation - use coarse grid
%2 - tighter screening to refine rotation - use fine grid
%3 - tight screening without rotation

[xout, yout, xc, yc, w, h, orient]=at_grid; % buld cavity design

% if initial guess
if nargin==3
    %  [xout, yout]=rorateLine(xout,yout,init(3),1);
    %  xout=xout+init(1);
    %  yout=yout+init(2);
else
    init=[0 0 0];
end


imag1=phy_loadTimeLapseImage(segmentation.position,frame,1,'non');
imagstore=imag1;
%imag2=phy_loadTimeLapseImage(segmentation.position,400,1,'non');

%isub=imsubtract(imag2,imag1);
%figure, imshow(imag2,[]);

%level=graythresh(isub);
%isub=im2bw(isub,level);
%figure, imshow(isub,[]);

level=graythresh(imag1);
%imag1=im2bw(imag1,level);
%imag1=imerode(imag1,strel('disk',5));


%imag1=imgradient(imag1);


if display
    figure, imshow(imag1,[]); hold on; %line(xout,yout,'Color','g','LineWidth',2);
    
    
    % return;
end

%return;

% scale down images
sca=0.2;
imag1=imresize(imag1,sca);
%imag1=edge(imag1,'prewitt');

xout2=sca*xout;
yout2=sca*yout;

% xy translation
if strcmp(mode,'coarse')
    
    npoints=31;
    amp=70;
    res=2*amp/(npoints-1);
    val=sca*(-amp:res:amp);
    
    npoints2=11;
    amp=1;
    res=2*amp/(npoints-1);
    valt=-amp:res:amp;
    
else
    npoints=21;
    amp=10;
    res=2*amp/(npoints-1);
    val=sca*(-amp:res:amp);
    
    valt=0;
end

maxe=1e12;


%   valx=1*(-val/2+i)+sca*init(1); %translation x
%   valy=2*(-val/2+j)+sca*init(2); % translation y
%   valo=0.3*(-valt/2+k-1/2)+init(3); % rotation

%figure

cci=1;
ccj=1;

for i=val
    ccj=1;
    for j=val
        for k=valt
            [xt, yt]=rorateLine(xout2,yout2,k+init(3),sca);
            xt=xt+i+sca*init(1);
            yt=yt+j+sca*init(2);
            
            %figure, imshow(imag1,[]); hold on; line(xt,yt,'Color','r');
            
            %c=improfile(imag1,xt,yt);
            c=impixel(imag1,xt,yt);
            c=c(~isnan(c));
            score = sum(double(c));
            title([ num2str(i) ' - ' num2str(j) ' - ' num2str(score)]);
            %   pause
            % close
            
            if score<maxe(1)
                maxe(1)=score; %score
                maxe(3)=i+sca*init(1); % xshift
                maxe(2)=j+sca*init(2); % y shift
                maxe(4)=k+init(3); % same orientation
            end
            
            
        end
        p(cci,ccj)=score;
        ccj=ccj+1;
    end
     cci=cci+1;
end

maxe(2:3)=(maxe(2:3))/sca;

% if strcmp(mode,'fine')
%     % scale down images
%     sca=0.5;
%     imag1=imresize(imag1,sca);
%     xout2=sca*xout;
%     yout2=sca*yout;
%     xo=1000*sca;
%     yo=1000*sca;
%
%     %figure, imshow(imag1,[]);
%     %line(xout2,yout2);
%     %return;
%
%     width=200*sca;
%     xmin=200*sca;
%     ymin=650*sca;
%
%     [w h]=size(imag1);
%
%     crop1=imag1(ymin:ymin+width-1,xmin:xmin+width-1);
%     crop2=imag1(w-ymin-width+1:w-ymin,h-xmin-width+1:h-xmin);
%     crop3=imag1(ymin:ymin+width-1,h-xmin-width+1:h-xmin);
%     crop4=imag1(w-ymin-width+1:w-ymin,xmin:xmin+width-1);
%
%     %   figure, imshow(crop1,[]); hold on;
%     %   figure, imshow(crop2,[]); hold on;
%     %   figure, imshow(crop3,[]); hold on;
%     %   figure, imshow(crop4,[]); hold on;
%
%     %xout2=xout2-xmin;
%     %yout2=yout2-ymin;
%
%     %figure, imshow(crop1,[]); hold on; line(xout2,yout2);
%     %return;
%
%     val=10;
%     maxe=-1e10;
%
%     for i=1:val
%         for j=1:val
%             for k=1:val
%                 valx=2*(-val/2+i) %translation x
%                 valy=2*(-val/2+j) % translation y
%                 valo=0.1*(-val/2+k) % rotation
%
%                 [xt, yt]=rorateLine(xout2,yout2,valo,sca);
%                 xt=xt+valx;
%                 yt=yt+valy;
%                 score=0;
%
%                 x1=xt-xmin; y1=yt-ymin;
%                 pix=x1>=-0.2*width & x1<=1.2*width & y1>=-0.2*width & y1<=1.2*width;
%                 x1=x1(pix); y1=y1(pix);
%
%                 c=impixel(crop1,x1,y1); c=c(~isnan(c)); score = score+sum(c);
%
%                 x2=xt-(h-xmin-width+1); y2=yt-(w-ymin-width+1);
%                 pix=x2>=-0.2*width & x2<=1.2*width & y2>=-0.2*width & y2<=1.2*width;
%                 x2=x2(pix); y2=y2(pix);
%
%                 %figure, imshow(crop2,[]); hold on; line(x2,y2);
%                 %return;
%
%                 c=impixel(crop1,x2,y2); c=c(~isnan(c)); score = score+sum(c);
%
%                 x3=xt-(h-xmin-width+1); y3=yt-(ymin);
%                 pix=x3>=-0.2*width & x3<=1.2*width & y3>=-0.2*width & y3<=1.2*width;
%                 x3=x3(pix); y3=y3(pix);
%
%                 c=impixel(crop1,x3,y3); c=c(~isnan(c)); score = score+sum(c);
%
%                 x4=xt-xmin; y4=yt-(w-ymin-width+1);
%                 pix=x4>=-0.2*width & x4<=1.2*width & y4>=-0.2*width & y4<=1.2*width;
%                 x4=x4(pix); y4=y4(pix);
%
%                 c=impixel(crop1,x4,y4); c=c(~isnan(c)); score = score+sum(c);
%
%                 if score>maxe(1)
%                     maxe(1)=score; %score
%                     maxe(3)=valx; % xshift
%                     maxe(2)=valy; % y shift
%                     maxe(4)=valo; % same orientation
%                 end
%
%                 % p(i,j)=score;
%             end
%         end
%     end
%
%     maxe(2:3)=maxe(2:3)/sca;
% end

xbias=0;
[xt, yt]=rorateLine(xout,yout,maxe(4),1);
xt=xt+maxe(3)-xbias;
yt=yt+maxe(2);

if display
    %line(xout,yout,'LineWidth',1,'Color','b');
    line(xt,yt,'LineWidth',2,'Color','r');
end

BW=poly2mask(xt,yt,size(imagstore,1),size(imagstore,2));
im=mat2gray(imagstore);
BW=imerode(BW, strel('Disk',6));

if display
    figure, imshow(im + BW, []); hold on;
end


[xt, yt]=rorateLine(xc,yc,maxe(4),1);
xt=xt+maxe(3)-xbias;
yt=yt+maxe(2);


cc=1;
segmentation.ROI=[];
segmentation.ROI=struct('box',[],'BW',[]);

for l=1:length(xt)
    if round(xt(l)-w/2) >= 1 && round(xt(l)+w/2)<size(BW,2)
        ROI=[round(xt(l)-w/2) round(yt(l)-h/2) round(w) round(h)];
        segmentation.ROI(cc).box=ROI;
        segmentation.ROI(cc).BW=BW(round(yt(l)-h/2):round(yt(l)-h/2)+round(h)-1,round(xt(l)-w/2):round(xt(l)-w/2)+round(w)-1);
        segmentation.ROI(cc).orient=orient(l);
        cc=cc+1;
        
        if display
            if orient(l)==1
            line([xt(l)-w/2 xt(l)-w/2 xt(l)+w/2 xt(l)+w/2 xt(l)-w/2],[yt(l)-h/2 yt(l)+h/2 yt(l)+h/2 yt(l)-h/2 yt(l)-h/2],'Color','r');
            else
            line([xt(l)-w/2 xt(l)-w/2 xt(l)+w/2 xt(l)+w/2 xt(l)-w/2],[yt(l)-h/2 yt(l)+h/2 yt(l)+h/2 yt(l)-h/2 yt(l)-h/2],'Color','b');  
            end
        end
    end
end

figure, pcolor(p);

x=maxe(3);
y=maxe(2);
theta=maxe(4);

function [xout, yout]=rorateLine(x,y,ang,sca)

theta=-ang*pi/180;
R=[cos(theta) -sin(theta); sin(theta) cos(theta)];

xo=1000*sca;
yo=1000*sca;

xc=(x-xo);
yc=(y-yo);

Vr= R*[xc ; yc];

xout=Vr(1,:)+xo;
yout=Vr(2,:)+yo;


%         return;
%
%  BW=poly2mask(xout,yout,size(imag1,1),size(imag1,2));
%  %BW(100:300,500:600)=1;
%
%  BW=imresize(BW,0.25);
%
%  %BW=edge(BW);
%
% % offx=3; offy=4;
%  BW2=poly2mask(xout,yout,size(imag1,1),size(imag1,2));
%  %BW2(100+offy:300+offy,500+offx:600+offx)=1;
%  BW2=imresize(BW2,0.25);
%
%  ang=2.2;
%
% BW2=imrotate(BW2,ang,'crop');
% %BW2 = circshift(BW2,[offy offx]);
%
%  %BW2=edge(BW2);
%
%  %BW=imdilate(BW,strel('disk',2));
% %imag1=BW2;
%
%  imag1=imresize(imag1,0.25);
%
% %
%  %imag2=phy_loadTimeLapseImage(12,315,1,'non'); imag2=imresize(imag2,0.25);
% %
% % figure, imshow(imag1+imag2,[]);
%
% %
% % imag1=uint8(zeros(200,200));
% % imag1(50:60,50:60)=1;
% % imag1(150:160,50:60)=1;
% %
% % global img;
% % imag1=img;
% % %imag2=imrotate(imag1,5,'crop');
% % imag2=circshift(imag1,[5 10]);
% % %
%
%  figure, imshow(0.5*double(imag1)+0.*double(BW),[]); hold on
%  %return;
%
%  [xshift,yshift ,angleout]=findRotation(uint16(imag1),uint16(BW))
% %xshift=offx;
% %yshift=offy;
%
% %xout=xout+xshift;
% %yout=yout+yshift;
%
%  theta=-angleout*pi/180;
%  R=[cos(theta) -sin(theta); sin(theta) cos(theta)];
%
%  %xo=mean(xout);
%  %yo=mean(yout);
%
%  xo=1000;
%  yo=1000;
%
%  xc=0.25*(xout-xo);
%  yc=0.25*(yout-yo);
%
%  Vr= R*[xc ; yc];
%
%  xr=Vr(1,:)+0.25*xo-(xshift-500);
%  yr=Vr(2,:)+0.25*yo+yshift;
%
%  line(xr,yr,'LineWidth',2);
%
%
% return;
%
%
% transform = 'translation';
%
%
% % parameters for ECC and Lucas-Kanade
% par = [];
% par.levels =    3;
% par.iterations = 15;
% par.transform = transform;
%
% [ECCWarp]=iat_ecc(imag1,BW,par)
%
% %[ECCWarp]=iat_eccIC(imag1,BW,par)
%
% %[LKWarp]=iat_LucasKanade(imag1,BW,par)
%
% %size(ECCWarp)
% %ECCWarp(1,3)=0;ECCWarp(2,3)=0;
%
% %line(0.25*xout+ECCWarp(1,3),0.25*yout+ECCWarp(2,3),'LineWidth',2);
%
% line(0.25*xout+ECCWarp(1),0.25*yout+ECCWarp(2),'LineWidth',2);
%
% %ECCWarp=[1 0 ECCWarp(1); 0 1 ECCWarp(2)];
%
% %
% % % Compute the warped image and visualize the error
% % [wimageECC, supportECC] = iat_inverse_warping(imag1, ECCWarp, par.transform, 1:size(BW,2),1:size(BW,1));
% %
%
%
%
%
% % %plot the warped image
% % figure;imshow(uint8(wimageECC)); title('Warped image by ECC', 'Fontsize', 14);
%
%
%
% % draw mosaic
% %ECCMosaic = iat_mosaic(double(imag1),double(BW),[ECCWarp; 0 0 1]);
%
% %figure;imshow(uint16(ECCMosaic),[]);title('Mosaic after ECC','Fontsize',14);
%
%
% % --> align each image on a predifined grid
%
%
% function [xshift yshift angleout]=findRotation(im,im2)
%
% angle=-5:0.25:5;
%
%     %pim = polartrans(im, siz, 5*siz);
%     %pim2 = polartrans(im2, siz, 5*siz);
%
%    %warning off all;
%    %im=imresize(im,2);
%    %im2=imresize(im2,2);
%    %warning on all;
%        anglecorr=[];
%     xshift=[];
%     yshift=[];
%
%     for i=angle % angle
%
%         imtest=imrotate(im2,i,'nearest','crop');
%         co2=ifft2(fft2(double(im)).*conj(fft2(double(imtest))))/(4*4*pi*pi);
%         [C I]=max(co2);
%         [D J]= max(C);
%         bestx=J;
%         besty=I(J) ;
%
%         xshift=[xshift bestx];
%         yshift=[yshift besty];
%
%         anglecorr=[anglecorr D];
%
%     end
%
%     %anglecorr,xshift,yshift
%     [anglemax imax]=max(anglecorr);
%
%     xshift=xshift(imax)-1;
%     yshift=yshift(imax)-1;
%
%     %im2save=imrotate(im2save,theta-theta2+the,'nearest','crop');
%     %im2save=imrotate(im2save,angle(imax)+anglein,'nearest','crop');
%
%     %xt=  mod(xshift(imax)+siz/2,siz)-siz/2-1;
%     %yt=  mod(yshift(imax)+siz/2,siz)-siz/2-1;
%
%     xt=0;
%     yt=0;
%     xstore=0;
%     ystore=0;
%
%    % im2save = circshift(im2save,[xt+xstore yt+ystore]);
%
%     %im2save=
%
%     angleout=angle(imax);
%
%     %xstore=xstore+xt;
%     %ystore=ystore+yt;

