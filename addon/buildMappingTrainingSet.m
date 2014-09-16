function [pdfout range]=buildTrainingSet(Min,appin)

% build matrix showing changes in cell features after basic mapping //
% fixing cells

% matrix format :

% ox oy area meanint dox doy darea dmeanint

% then perform a multivariate density estimation to guess proba of changes


display=0;

if nargin==0
M=zeros(1,8);
app=zeros(1,5);

global segmentation

cc=1;

cc2=1;

for i=1:numel(segmentation.tcells1)
    
    if segmentation.tcells1(i).N==0
        continue
    end
    
    if numel(segmentation.tcells1(i).Obj)<2
        continue
    end
    
    for j=1:numel(segmentation.tcells1(i).Obj)-1
        
        % var at time j
        
        [ox,oy,area,meanint]=getvar(i,j);
        
        % var at time j+1
        
        [ox2,oy2,area2,meanint2]=getvar(i,j+1);
        
        if j==1
            app(cc2,:)=[ox oy area meanint 1]; % cell appear
            cc2=cc2+1;
        end
        
        if j==numel(segmentation.tcells1(i).Obj)-1
            [ox3,oy3,area3,meanint3]=getvar(i,j+1);
            app(cc2,:)=[ox3 oy3 area3 meanint3 -1]; % cell dissappear
            cc2=cc2+1;
        end
        
        if j~=1 && j~=numel(segmentation.tcells1(i).Obj)-1
           app(cc2,:)=[ox oy area meanint 0]; % cell is there
           cc2=cc2+1; 
        end
        
        M(cc,:)=[ox oy area meanint ox2-ox oy2-oy area2-area meanint2-meanint];
        cc=cc+1;
        
       % pause
        %if j==10
       %     return;
       % end
        
    end
    
end
else
    M=Min;
    app=appin;
end


%% second step : Multivariate kernel density estimation

%probability estimations: DX, DY, DA, DI are independent variables and
%processed as such
% P = P(DX) x P(DY) x P(DA) x P(DI)

% Ploss= to be estimated
% Pappear= to be estimated

%P(DX)=f(X,A); 
%P(DY)=f(Y,A); 
%P(DA)=f(A,I); 
%P(DA)=f(A,I);

M_X = [M(:,1) M(:,3) M(:,5)]; % X, A, DX  space
pdf_DX=estimatePDF(M_X');

M_Y = [M(:,2) M(:,3) M(:,6)]; % Y, A, DY  space
pdf_DY=estimatePDF(M_Y');

M_A = [M(:,4) M(:,3) M(:,7)]; % I, A, DA  space
pdf_DA=estimatePDF(M_A');

M_I = [M(:,4) M(:,3) M(:,7)]; % I, A, DI  space
pdf_DI=estimatePDF(M_I');

pdfout=[pdf_DX pdf_DY pdf_DA pdf_DI];

range(1)=(max(M(:,1))-min(M(:,1)))/20;
range(2)=(max(M(:,2))-min(M(:,2)))/20;
range(3)=(max(M(:,3))-min(M(:,3)))/20;
range(4)=(max(M(:,4))-min(M(:,4)))/20;

%%%%%

% count=[];
% 
% nbins=[10 10 10 10 10 10 10 10]; %number of bins used for each variable
% labels={'X','Y','Area','Intensity','DX','DY','DArea','DIntensity'};
% 
% %[count edges mid loc] = histcn(M, 10,10,10,10,10,10,10,10);
% 
% 
% M_A = [M(:,3) M(:,4) M(:,7)]; % A, I, DA  space
% [count edges mid loc] = histcn(M_A, 10,10,10);
% P_DA = computeProba3(count,edges,[1000 700 0]);
% 
% M_I = [M(:,3) M(:,4) M(:,8)]; % A, I, DI  space
% [count edges mid loc] = histcn(M_I, 10,10,10);
% P_DI = computeProba3(count,edges,[1000 700 0]);
% 
% M_X = [M(:,1) M(:,3) M(:,5)]; % X, A, I, DX  space
% [count edges mid loc] = histcn(M_X, 10,10,10);
% P_DX = computeProba3(count,edges,[-10 800 -10]);
% 
% M_Y = [M(:,2) M(:,3) M(:,6)]; % Y, A, I, DY  space
% [count edges mid loc] = histcn(M_Y, 10,10,10);
% P_DY = computeProba3(count,edges,[0 800 0]);
% 
% 
% %P=P_DA*P_DI*P_DX*P_DY
% 
% 
% if display
% %% visualize the N dimensionnal histogram using 2D hyperplans
% 
% % plot dx,dy,darea,dint as a function of x,y,area,int
% figure;
% p=panel();
% p.pack(4,4);
% 
% for i=1:4
%     for j=5:8
%        p(i,j-4).select(); % plotting dx as a function of x histogram
%        xlabel(labels{i});
%        ylabel(labels{j});
%        
%        dat=[M(:,i),M(:,j)];
%        
%        n=hist3(dat,[nbins(i) nbins(j)]);
%  n1 = n'; 
%  n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0; 
% % 
%  xb = linspace(min(dat(:,1)),max(dat(:,1)),size(n,1)+1);
%  yb = linspace(min(dat(:,2)),max(dat(:,2)),size(n,1)+1);
% % 
% % figure; 
%  h = pcolor(xb,yb,log10(n1));
% % xlabel('Y position');
% % ylabel('Delta Y');
%  colorbar
%        
%     end
% end
% 
% end





% dat=[M(:,2),M(:,5)];
% n=hist3(dat,[20 20]);
% n1 = n'; 
% n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0; 
% 
% xb = linspace(min(dat(:,1)),max(dat(:,1)),size(n,1)+1);
% yb = linspace(min(dat(:,2)),max(dat(:,2)),size(n,1)+1);
% 
% figure; 
% h = pcolor(xb,yb,log10(n1));
% xlabel('Y position');
% ylabel('Delta Y');
% colorbar


% pix=find(app(:,7)==1);
% appear=app(pix,:);
% figure, hist(appear(:,3),20);
% title('Appearing cells');
% 
% pix=find(app(:,7)==-1);
% appear=app(pix,:);
% figure, hist(appear(:,3),20);
% title('Dissappearing cells');

%figure, 

function pdf_out=estimatePDF(dat)

prescaling = 1 ;
if prescaling
    [ Mu, T] = getDataScaleTransform( dat ) ;
    dat = applyDataScaleTransform( dat, Mu, T ) ;    
end

N_init = size(dat,1)*2;  % how many samples will you use for initialization?
kde = executeOperatorIKDE( [], 'input_data', dat(:,1:N_init),'add_input' );

Dth = 0.02 ; % set the compression value (see the paper [1] for better idea about what value to use)
kde = executeOperatorIKDE( kde, 'compressionClusterThresh', Dth ) ;

% not you can add one sample at a time...
%figure(1) ; clf ;


for i = N_init+1 : size(dat,2) 
   % 'ok'
    tic
    kde = executeOperatorIKDE( kde, 'input_data', dat(:,i), 'add_input'  ) ;
    t = toc ; 
    % print out some intermediate results
    msg = sprintf('Samples: %d ,Comps: %d , Last update time: %f ms\n', i , length(kde.pdf.w), t*1000 ) ;
    fprintf(msg)
    %title(msg) ; drawnow ;
end 
 
% your gaussian mixture model:
pdf_out = kde.pdf ;

% if you have prescaled your data, you will have to inverse the scaling of
% the estimated oKDE to project it back into the original space of your
% data. Note that from this point on, you can not update your pdf -- you
% will have to continue to update the KDE and inverse scaling again...
if prescaling    
  pdf_out = applyInvScaleTransformToPdf( pdf_out, Mu, T ) ;  
end

function out=computeProba3(count,edges,val)

pix=[];
for i=1:numel(val)
   if val(i)< edges{i}(1)
       out=0;
       return;
   end
    if val(i)> edges{i}(end)
       out=0;
       return;
    end
    
    pix(i)=find(edges{i}(:)-val(i)>=0,1,'first');
   
end


linind=sub2ind(size(count), pix(1)-1,pix(2)-1,pix(3)-1);
out=count(linind)/sum(count(:));

function out=computeProba4(count,edges,val)

pix=[];
for i=1:numel(val)
   if val(i)< edges{i}(1)
       out=0;
       return;
   end
    if val(i)> edges{i}(end)
       out=0;
       return;
    end
    
    pix(i)=find(edges{i}(:)-val(i)>=0,1,'first');
   
end

linind=sub2ind(size(count), pix(1),pix(2),pix(3),pix(4));
out=count(linind)/sum(count(:));


function [ox,oy,area,meanint,varint,ecc]=getvar(i,j)
global segmentation 

%fprintf('----------')

ox=segmentation.tcells1(i).Obj(j).ox;
oy=segmentation.tcells1(i).Obj(j).oy;

cavity=segmentation.tcells1(i).Obj(j).Nrpoints;

frame= segmentation.tcells1(i).Obj(j).image;

ncav=[segmentation.ROI(frame).ROI.n];
pix=find(ncav==cavity);
cavity=pix;

orient=segmentation.ROI(frame).ROI(cavity).orient;
box=segmentation.ROI(frame).ROI(cavity).box;
n=segmentation.ROI(frame).ROI(cavity).n;

cx=box(1)+box(3)/2;
cy=box(2)+box(4)/2;

if orient==0
    oy=oy-cy;
else
    oy=-(oy-cy);
end

ox=ox-cx;

%pause

area=segmentation.tcells1(i).Obj(j).area;
meanint=segmentation.tcells1(i).Obj(j).fluoMean(1);
varint=segmentation.tcells1(i).Obj(j).fluoVar(1);
ecc=0;


