function at_meanTraj(statarr)
% plots the eolution of volume and cell cycle progression for an average
% cell 

% masure variability along the cell cycle 
global datastat

% gene names used 
genes= {'WT' 'fkh1' 'hcm1' 'dpb3' 'ura7' 'sic1' 'cln1' 'cln2' 'swi4' 'whi5' 'fhh2' 'swe1' 'mrc1' 'rad27' 'tda3' 'clb5' 'cdh1' 'dia2' 'dbf2' 'cln3' 'clb2'  'sfp1' 'bck2' 'double' 'met' 'met' '10mM HU' '25mM HU' '50mM HU' 'audrey' 'cecilia' 'audrey' 'cecilia'};


p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

hf=figure('Color','w');

p=panel();

%display1=at_name('vbs','vbg2');
display2b=at_name('vbdiv','vbg1','vbs','vbg2','vbana');
display2=at_name('vdiv','vg1','vs','vg2','vana');
display3=at_name('tdiv','tg1','ts','tg2','tana');

display=[display2 display2b display3];

lab={'Overall','G1','s','G2','G2tot','ana'};

arrM=zeros(numel(statarr),numel(display));
arrD=zeros(numel(statarr),numel(display));
errM=zeros(numel(statarr),numel(display));
errD=zeros(numel(statarr),numel(display));

p.pack(1,length(statarr));

T={};

% col=colormap(jet(length(statarr)));
% cc=1;
% line([cc+0 cc+0],[0 2],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+1; hold on;
% line([cc+0 cc+0],[0 2],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+1; hold on;
% line([cc+0 cc+0],[0 2],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+1; hold on;
% line([cc+0 cc+0],[0 2],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+1; hold on;
% line([cc+0 cc+0],[0 2],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+1; hold on;
% line([cc+0 cc+0],[0 2],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+1; hold on;
% line([cc+0 cc+0],[0 2],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+1; hold on;
% 
% cc=0;
% line([0 8],[0.2+cc 0.2+cc],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+0.1; hold on;
% line([0 8],[0.2+cc 0.2+cc],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+0.1; hold on;
% line([0 8],[0.2+cc 0.2+cc],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+0.1; hold on;
% line([0 8],[0.2+cc 0.2+cc],'LineWidth',1,'LineStyle','--','Color','k');cc=cc+0.1; hold on;


for i=1:numel(statarr)
    
 p(1,i).select();
 
        
 [xd xm yd ym]=varia(statarr(i),display2,display2b,display3); 
     
    
 plot( xd,yd,'Color','b','Marker','.','MarkerSize',16); hold on
 plot( xm,ym,'Color','r','Marker','.','MarkerSize',16);

     
 text(10,10,genes{statarr(i)});
    % T{i}=genes{statarr(i)};
     

 ylim([0 150]);
xlim([0 120]);

end


% cc=0;
% rectangle('Position',[cc 0 1 0.1],'FaceColor','g'); text(cc+0.4,0.05,'S','Color','k','FontSize',16,'FontWeight','bold'); cc=cc+1;
% rectangle('Position',[cc 0 1 0.1],'FaceColor','y'); text(cc+0.2,0.05,'G2/M','Color','k','FontSize',16,'FontWeight','bold');cc=cc+1;
% rectangle('Position',[cc 0 1 0.1],'FaceColor','b'); text(cc+0.2,0.05,'Ana','Color','k','FontSize',16,'FontWeight','bold');cc=cc+1;
% rectangle('Position',[cc 0 1 0.1],'FaceColor','r'); text(cc+0.3,0.05,'G1','Color','k','FontSize',16,'FontWeight','bold');cc=cc+1;
% rectangle('Position',[cc 0 1 0.1],'FaceColor','g'); text(cc+0.4,0.05,'S','Color','k','FontSize',16,'FontWeight','bold'); cc=cc+1;
% rectangle('Position',[cc 0 1 0.1],'FaceColor','y'); text(cc+0.2,0.05,'G2/M','Color','k','FontSize',16,'FontWeight','bold');cc=cc+1;
% rectangle('Position',[cc 0 1 0.1],'FaceColor','b'); text(cc+0.2,0.05,'Ana','Color','k','FontSize',16,'FontWeight','bold');cc=cc+1;

%set(gca,'FontSize',16,'XTick',[]);

%xlabel('Cell cycle progression','FontSize',16);
%ylabel('CV(cell volume)','FontSize',16);



%breakInfo = breakyaxis([0.63 0.9]);
%legend(T,'FontSize',16);




function   [X_D X_M Y_D Y_M]=varia(i,display2,display2b,display3)

% calculate the increase in cell size as a function of cell size in various
% stages of the cell cycle. Returns slopes of these curves for D and M
% cells.
% init and ende are numbers that indicate the position of the cell cycle : 
% 0 : start
% 1 : g1
% 2 : s
% 3 : g2
% 4 : ana

% at_display_index : index of the stat file in at_display

% display : display results

% option : whether initial size refers to cell+bud or to bud only
% 0 : cell + bud
% 1 : bud only

global datastat


pix=i;

stats=datastat(pix).stats;
path=datastat(pix).path;

% fluo=at_name('fluo');
% fitfluo=at_name('fitfluo');
% volcell=at_name('volcell');
% volbud=at_name('volbud');
% 
% tim={'tg1','ts','tg2','tana'};

%ana=at_name('tdiv');
%g1=at_name('tg1');

M=find(stats(:,5)==1 & stats(:,6)==0);
D=find(stats(:,5)==0 & stats(:,6)==0); 

stats(:,display2)=stats(:,display2)+stats(:,display2b); % add bud size
%stats(:,display2(2:end))=stats(:,display2(2:end))-stats(:,display2(1:end-1)); % deltavolume

% plot delta volume

Y_D=stats(D,[ display2]); Y_D = mean(Y_D,1);
Y_M=stats(M,[ display2]); Y_M = mean(Y_M,1);

cf=1;

X_D=stats(D,[display3]); X_D = mean(X_D,1);
X_M=stats(M,[display3]); X_M = mean(X_M,1);

X_D=3*cumsum([0 X_D(2:end)]);
X_M=3*cumsum([0 X_M(2:end)]);



% funcd=@(x) (std(x,0,1)).^cf./mean(x,1);
% 
% bootstD_bud = bootstrp(1000,funcd,X_D_bud);
% bootstD_cell = bootstrp(1000,funcd,X_D_cell);
% 
% bootstM = bootstrp(1000,funcd,X_M);
% 
% %mean(bootstD,1)
% cfd_bud=std(bootstD_bud,0,1);
% cfd_cell=std(bootstD_cell,0,1);

%cfm=std(bootstM,0,1);

%color=colormap(jet(length([display1 display2])));


