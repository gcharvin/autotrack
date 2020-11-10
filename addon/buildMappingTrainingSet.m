function buildMappingTrainingSet(objecttype)

%%  Multivariate kernel density estimation

%probability estimations: DX, DY, DA, DI are independent variables and
%processed as such
% P = P(DX) x P(DY) x P(DA) x P(DI)

% Ploss= to be estimated
% Pappear= to be estimated

%P(DX)=f(X,A); 
%P(DY)=f(Y,A); 
%P(DA)=f(A,I); 
%P(DA)=f(A,I);


    [FileName,PathName] = uigetfile('*.mat','Select the .mat training input dataset');
    load([PathName FileName]);
    
    [file,path] = uiputfile(['trainingSetTemp' objecttype '.mat'],'Save output file name');

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

if strcmp(objecttype,'Cells1')
pdfoutCells1=pdfout;
rangeCells1=range;
save([path file],'pdfoutCells1','rangeCells1');
end
if strcmp(objecttype,'Nucleus')
pdfoutNucleus=pdfout;
rangeNucleus=range;
save([path file],'pdfoutNucleus','rangeNucleus');
end

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

% function out=computeProba3(count,edges,val)
% 
% pix=[];
% for i=1:numel(val)
%    if val(i)< edges{i}(1)
%        out=0;
%        return;
%    end
%     if val(i)> edges{i}(end)
%        out=0;
%        return;
%     end
%     
%     pix(i)=find(edges{i}(:)-val(i)>=0,1,'first');
%    
% end
% 
% 
% linind=sub2ind(size(count), pix(1)-1,pix(2)-1,pix(3)-1);
% out=count(linind)/sum(count(:));
% 
% function out=computeProba4(count,edges,val)
% 
% pix=[];
% for i=1:numel(val)
%    if val(i)< edges{i}(1)
%        out=0;
%        return;
%    end
%     if val(i)> edges{i}(end)
%        out=0;
%        return;
%     end
%     
%     pix(i)=find(edges{i}(:)-val(i)>=0,1,'first');
%    
% end
% 
% linind=sub2ind(size(count), pix(1),pix(2),pix(3),pix(4));
% out=count(linind)/sum(count(:));


