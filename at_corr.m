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
display4=at_name('muunbud','mubud');
display=[display1 display2 display3,display4];

M=find(stats(:,5)==1 & stats(:,6)==0);
D=find(stats(:,5)==0 & stats(:,6)==0);

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

  figure('Color','w','Position',[100 100 800 800]); 
  pcolor(xedges,yedges,M); colormap jet; colorbar ; axis square tight;
  set(gca,'XTick',[1:1:size(X_M,2)]+0.5);
  set(gca,'XTickLabel',at_name(display));
  set(gca,'YTick',[1:1:size(X_M,2)]+0.5);
  set(gca,'YTickLabel',at_name(display));
  title('Mother Phase Correlations');

f2=[path '/' file '-corrM.pdf'];
myExportFig(f2);

  figure('Color','w','Position',[100 100 800 800]); 
  pcolor(xedges,yedges,D); colormap jet; colorbar ; axis square tight;
  set(gca,'XTick',[1:1:size(X_D,2)]+0.5);
  set(gca,'XTickLabel',at_name(display));
  set(gca,'YTick',[1:1:size(X_D,2)]+0.5);
  set(gca,'YTickLabel',at_name(display));
  title('Daughter Phase Correlations');

f2=[path '/' file '-corrD.pdf'];
myExportFig(f2);