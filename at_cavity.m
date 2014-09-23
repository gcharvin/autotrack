function [x y theta ROI outgrid] = at_cavity(frame,varargin)
global segmentation
% align cavity to model defined by at_grid

% parse arguments

display = getOption(varargin, 'display'); 
range = getOptionValue(varargin, 'range'); % mandatory arg
npoints = getOptionValue(varargin, 'npoints'); % mandatory arg
rotation = getOptionValue(varargin, 'rotation');
init = getOptionValue(varargin, 'init');
scale = getOptionValue(varargin, 'scale');
grid = getOptionValue(varargin, 'grid');

%s trategy : 
%1 - coarse mode with large screening in rotation - use coarse grid
%2 - tighter screening to refine rotation - use fine grid
%3 - tight screening without rotation

if numel(grid)==0
x0=[0 0     1      8    9  9 mean([9 16])  16];
y0=[0 -20   -37   -37     -20   0        1       0 ];% works great
else
x0=grid(1,:);
y0=grid(2,:);
end


[xout, yout, xc, yc, w, h, orient]=at_grid(x0,y0);


% if initial guess

if numel(init)==0
    init=[0 0 0];
end
if numel(scale)==0
    sca=0.2;
else
    sca=scale;  
end

if numel(rotation)==0
    rotation=0;
end


imag1=phy_loadTimeLapseImage(segmentation.position,frame,1,'non');
imagstore=imag1;

%sca=0.5;
%imag1=imresize(imag1,sca);

%x=[]; y=[]; theta=[]; ROI=[]; outgrid=[];
[imag1 ang]=detectLines(imag1);

%if numel(init)==0
%    init=[0 0 ang];
%end

%return;
if display
    figure, imshow(imag1,[]); hold on; line(xout,yout,'Color','g','LineWidth',2);
end

imag1=imresize(imag1,sca);

%return;

%imag1=edge(imag1,'prewitt');

xout2=sca*xout;
yout2=sca*yout;

% xy translation
    
    amp=range;
    res=2*amp/(npoints-1);
    val=sca*(-amp:res:amp);
    
    if npoints==1
       val=0; 
    end

% rotation
    amp=rotation;
    res=2*amp/(npoints-1);
    valt=-amp:res:amp;
    
    if rotation==0
        valt=0;
    end
    

maxe=1e12;

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
            %title([ num2str(i) ' - ' num2str(j) ' - ' num2str(score)]);
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

[xt, yt]=rorateLine(xout,yout,maxe(4),1);
xt=xt+maxe(3);
yt=yt+maxe(2);

if display % display grid as was used to fit align on the image
    %line(xout,yout,'LineWidth',1,'Color','b');
    line(xt,yt,'LineWidth',2,'Color','r');
end

% new grid used to create the mask
moy=(x0(3)+x0(4))/2;
x0=[0  0     1      5.5    6.5  6.5 mean([6.5 16])  16];
y0=[0 -20   -35   -35     -20   0        2.5       0 ];% works great
moy2=(x0(3)+x0(4))/2;

[xout, yout, xc, yc, w, h, orient]=at_grid(x0,y0);
[xt, yt]=rorateLine(xout,yout,maxe(4),1);

shift= 0.985*(moy-moy2)/0.10833; % shift is due to differences in size of cavities

xt=xt+maxe(3)+shift;
yt=yt+maxe(2);

BW=poly2mask(xt,yt,size(imagstore,1),size(imagstore,2));
im=mat2gray(imagstore);
BW=imerode(BW, strel('Disk',3));
outgrid=[xt; yt];

if display
    figure, imshow(im + BW, []); hold on;
end

[xt, yt]=rorateLine(xc,yc,maxe(4),1);
xt=xt+maxe(3)+shift;
yt=yt+maxe(2);


cc=1;
ROI=[];
ROI=struct('box',[],'BW',[]);

for l=1:length(xt)
    if round(xt(l)-w/2) >= 1 && round(xt(l)+w/2)<size(BW,2)-1 % remove cavitites that are too close to the edges
        ROItemp=[round(xt(l)-w/2) round(yt(l)-h/2) round(w) round(h)];
        ROI(cc).box=ROItemp;
        %ROI(cc).BW=BW(round(yt(l)-h/2):round(yt(l)-h/2)+round(h)-1,round(xt(l)-w/2):round(xt(l)-w/2)+round(w)-1);
        ROI(cc).orient=orient(l);
        ROI(cc).n=cc; % id of the cavity
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

if display && rotation==0
if npoints>1
    figure, pcolor(p);
end
end

x=maxe(3);
y=maxe(2);
theta=maxe(4);

function [BW ang]=detectLines(imag1)

level=graythresh(imag1);
BW=im2bw(imag1,level);
%figure, imshow(BW,[]);
BW=imclose(BW,strel('disk',20));
BW=bwareaopen(BW,100);
%figure, imshow(BW,[]);

L=bwlabel(~BW);
%figure, imshow(L,[0 5]);
stats=regionprops(L,'Area','Perimeter','Extent','Orientation');

a=[stats.Orientation];

bins=0:1:1000;
hi=hist(L(size(L,1)/2:size(L,1)/2,1:size(L,1)),bins);
[pix ix]=max(hi);

BW=~(L==ix-1);

ang=a(ix-1);


% BW=edge(BW,'canny');
% 
% figure, imshow(BW,[]);
% 
% [H,T,R] = hough(BW);
% %figure, imshow(H,[],'XData',T,'YData',R,...
%            % 'InitialMagnification','fit');
% %xlabel('\theta'), ylabel('\rho');
% %axis on, axis normal, hold on;
% 
% P  = houghpeaks(H,200,'threshold',ceil(0.01*max(H(:))));
% x = T(P(:,2)); y = R(P(:,1));
% %plot(x,y,'s','color','white');
% 
% % Find lines and plot them
% lines = houghlines(BW,T,R,P,'FillGap',20,'MinLength',50);
% figure, imshow(imag1,[]), hold on
% max_len = 0;
% 
% Pmean=0; cc=0; h=[];
% 
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
%    
%    len=sqrt((xy(2,2)-xy(1,2))^2+(xy(2,1)-xy(1,1))^2);
%    
%    %if len>200
%    P = atan2(xy(2,2)-xy(1,2),xy(2,1)-xy(1,1));
%    cc=cc+1;
%    Pmean = Pmean+ 180*P/pi;
%    h=[h P*180/pi];
%    %end
% end
% 
% Pmean=Pmean/cc
% 
% figure, hist(h,20);

% highlight the longest line segment
%plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue');

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


function value = getOption(map, key)
value = 0;

for i = 1:1:numel(map)
    if strcmp(map{i}, key)
        value = 1;
        
        return
    end
end

function value = getOptionValue(map, key)
value = [];

for i = 1:1:numel(map)
    if strcmp(map{i}, key)
        value = map{i+1};
        
        return
    end
end

