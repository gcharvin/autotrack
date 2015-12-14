function at_corr
global datastat

p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;
path=datastat(pix).path;

[path file ext]=fileparts(path);

display1=at_name('tdiv','tg1','tbud','ts','tg2','tana');
display2=at_name('vdiv','vg1','vs','vg2','vana');
display3=at_name('vbdiv','vbg1','vbs','vbg2','vbana');
display4=at_name('mub','mb','asy');
display=[display1 display2 display3,display4];

M=find(stats(:,5)==1 & stats(:,6)==0);
D=find(stats(:,5)==0 & stats(:,6)==0);

%stats(:,display2)=stats(:,display2).^1.5*(0.073)^3; % real volume
%stats(:,display3)=stats(:,display3).^1.5*(0.073)^3; % real volume

%stats(:,display4(3))=stats(:,display4(3)).^1.5*(0.073)^3; % real volume
%stats(:,display4(1))= (stats(:,display2(2))-stats(:,display2(1)))./stats(:,display1(2)); % muunbud
%stats(:,display4(2))= (stats(:,display2(5))-stats(:,display2(3)))./(stats(:,display1(5))+stats(:,display1(6))); % mubud


%stats(:,display4)=stats(:,display4).^1.5*(0.073)^3; % real volume

%stats(:,display2)=stats(:,display3);
stats(:,display2)=stats(:,display2)+stats(:,display3); % add bud size
%stats(:,display2(2:end))=stats(:,display2(2:end))-stats(:,display2(1:end-1)); % deltavolume

%compute deltaV
%stats(:,display3)=stats(:,display2); 
%stats(:,display3(2:end))=stats(:,display3(2:end))-stats(:,display3(1:end-1)); % deltavolume

%% plot delta volume

X_D=stats(D,display);
X_M=stats(M,display);

% plot correlation between phase durations

     D=corrcoef(X_D);
     M=corrcoef(X_M);

    M(end+1,:)=0;
    M(:,end+1)=0;
    D(end+1,:)=0;
    D(:,end+1)=0;
    
    xedges = linspace(1,size(X_D,2)+1,size(X_D,2)+1);
    yedges = linspace(1,size(X_M,2)+1,size(X_M,2)+1);

  figure('Color','w','Position',[100 100 1000 500]);
  
  subplot(1,2,1);
  pcolor(xedges,yedges,M); colormap jet; h=colorbar ; axis square tight;
  set(h,'CLim',[-1 1])
  set(gca,'XTick',[1:1:size(X_M,2)]+0.5);
  set(gca,'XTickLabel',at_name(display));
  set(gca,'YTick',[1:1:size(X_M,2)]+0.5);
  set(gca,'YTickLabel',at_name(display));
  title('Mother Phase Correlations');

f2=[path '/' file '-corrM.pdf'];
%myExportFig(f2);

  %figure('Color','w','Position',[100 100 800 800]); 
  subplot(1,2,2);
  pcolor(xedges,yedges,D); colormap jet; h=colorbar ; axis square tight;
    set(h,'CLim',[-1 1])
  set(gca,'XTick',[1:1:size(X_D,2)]+0.5);
  set(gca,'XTickLabel',at_name(display));
  set(gca,'YTick',[1:1:size(X_D,2)]+0.5);
  set(gca,'YTickLabel',at_name(display));
  title('Daughter Phase Correlations');

f2=[path '/' file '-corrD.pdf'];
%myExportFig(f2);