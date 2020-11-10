function at_diff_age(statarr,strarr,variables,legende,ref,option)
global datastat
% compare different stat files

% statarr:  index in at_display to display
% strarr : string containing names of stat files
% variables : names of the variables to be plotted
% ref : index used as a ref for significance tests
% option : plot mean 

% highlights differences between selected stats

ndiv=8;
path=datastat(statarr(1)).path;
[path file ext]=fileparts(path);

display=[];
for i=1:length(variables)
  %  variables{i}
    display=[display at_name(variables{i})];
end


if nargin==4
    ref=1;
end

%display1=at_name('tdiv','tg1','ts','tg2','tana');
%display2=at_name('vdiv','vg1','vs','vg2','vana');
%display3=at_name('vbdiv','vbg1','vbs','vbg2','vbana');
%display4=at_name('tbud','mub','mb','asy');
%display=[display1 display2 display3 display4];

% now plot differrences nicely using traj

% colM=colorpic;
% 
% z=size(colM,1);
% rm=1:1:z*z;
% rm=reshape(rm,[z z]);

%<<<<<<< HEAD
%thr=1;
%=======
% if nargin>=2
% thr=0.3;
% end
%>>>>>>> eb515003feafedb671f020e74b54691ae0408bcd

% colind=reshape(colM,[size(colM,1)*size(colM,1) 1 3]);
% colind=permute(colind,[1 3 2]);
% 
% colind=1-colormap(jet(z));

s=0.01;

h=figure('Color','w','Position',[200 200 800 600]);

r1=[1:-s:0 zeros(1,length(s:s:1))];
g1=[zeros(1,length(1:-s:0)) s:s:1];
b1=zeros(size(g1));

colind=[r1' g1' b1'];
colind=flipud(colind);

colind=colormap(jet(201));
z=size(colind,1);

M={};

cellwidth=20; spacing=1.2;

p=panel;


if nargin<=5
p.pack('h',{0.99 0.01});
else
p.pack('h',{0.75 0.25});   
p(2).pack(length(display),1);
end


%p(2).pack('v',{1/2 1/2});
%p(1).pack('v',{1/2 1/2});

p(1).pack(length(display),1);
p.fontsize=20;

%p

%return;

for k=1:length(display)
    
    p(1,k,1).select();
    
    Mstat={};
    Dstat={};
    
    Mavg=[];
    Davg=[];
    
    Merr=[];
    Derr=[];
    
    maxe=0;
    mine=1000;
    
    maxe2=0;
    mine2=1000;
    
%     hlabel=p(1,ii+1).select();
%     set(hlabel,'Visible','off');
%     if ii==0
%        text(0.5,0.5,'D','FontSize',20); 
%     else
%        text(0.5,0.5,'M','FontSize',20); 
%     end
%     line([2 2],[0.05 0.95],'Color','k');
%     
%     
%     h_axis=p(2,ii+1).select();
%     
%     startX=0;
%     startY=0;
   
strarr={};

for ii=1:ndiv
  strarr{ii}=num2str(ii-1);  
end


for j=1:ndiv
    stats=datastat(statarr).stats;
    
    M{j,1}=find(stats(:,4)==j & stats(:,6)==0); % select D or Ms
    
    if isempty(strarr)
        [pth fle ext]=fileparts(datastat(statarr).path);
        M{j,2}=fle;
    else
    M{j,2}=strarr ;
    end
    
    T_M=stats(M{j,1},display(k));
    
    
    if numel(strfind(cell2mat(at_name(display(k))),'t'))
       T_M=3*T_M; 
    end
    
    pk=sort(T_M);
    pk=pk(round(0.98*length(T_M)));
    
    mine=min(mine,min(T_M));
    maxe=max(maxe,pk);
    
    mine2=min(mine2,mean(T_M,1));
    maxe2=max(maxe2,mean(T_M,1));
    
   % if j==1
   %     T_M_REF=T_M;
   %     T_M_REF(:,6:10)=T_M_REF(:,6:10)+T_M_REF(:,11:15);
   % end
    
    % plot total cell (M+B) size instead of M size
    
   % T_M(:,6:10)=T_M(:,6:10)+T_M(:,11:15);

  
    
 
    %a=3*avg{j}
    %CV{j}=std(T_M,0,1)./avg{j};
    
    
%     r1=(avg{j}./avg{1})-1;
%     r1=min(r1,thr); r1=max(r1,-thr); 
%     
%    
%     
%     r1=max(1,round(z*0.5*(r1+thr)./thr));
%     %r1=z*ones(1,length(r1));
%     
%     r2=(CV{j}./CV{1}-1); r2=min(r2,thr); r2=max(r2,-thr); r2=max(1,round(z*0.5*(r2+thr)./thr));
%     %r2=1*ones(1,length(r2));
%     
%     rec=[]; cindex=[];
    


    Mstat{j}= T_M;
    Mavg(j)=mean(T_M,1);
    Merr(j)=std(T_M,1)/sqrt(length(T_M));

% lab=M(:,2);
% 
% set(gca,'YTick',cellwidth*(spacing*[0:1:length(statarr)-1]+spacing),'YTickLabel',lab);
% 
% if ii==0
%     set(gca,'XTick',[]);
% end

%axis equal tight

end

%col=[0.2 0.2 1 ; 1 0.2 0.2];


%%distributionPlot(Mstat)
%distributionPlot(Dstat,'histOri','right','color',col(1,:),'widthDiv',[2 2],'showMM',2)
distributionPlot(Mstat,'color',[0 0 0],'showMM',2)

 T_M_REF=Mstat{ref};
 T_D_REF=Mstat{ref};
for j=1:ndiv % plot significance
     if j~=ref
   
        T_M=Mstat{j};
        pval=testSignificance(T_M,T_M_REF);
        txt='';
        if pval==0.05 txt='*'; end 
        if pval==0.01 txt='**'; end 
        if pval==0.001 txt='***'; end
    
        text(j-0.25,4*maxe/5,txt,'Color',[1 0 0],'FontSize',30);   
     end
end
    

ylabel(legende{k});
xlim([0.5 length(strarr)+0.5]);
ylim([0 maxe])
set(gca,'XTickLabel',{});

if k==length(display)
    xlabel('Replicative age');
  % legend('D','M'); 
end

if nargin==6
p(2,k,1).select();

[bar_xtick,hb,he]=errorbar_groups([Mavg],[Merr],'FigID',gcf,'AxID',gca,'bar_width',0.5,'bar_colors',[0 0 0],'errorbar_width',1);

%errorbar(Davg,Derr,'Color',[0.2 0.2 0.7],'Marker','o','MarkerSize',6,'LineWidth',3,'LineStyle','none'); hold on; 
%errorbar(Mavg,Merr,'Color',[0.7 0.2 0.2],'Marker','o','MarkerSize',6,'LineWidth',3,'LineStyle','none'); hold on; 
%xlim([0.5 length(statarr)+0.5]);


ylim([10*floor(mine2/10) 10*ceil(maxe2/10)])
set(gca,'XTickLabel',{});

if k==length(display)
    xlabel('Replicative age');
  % legend('D','M'); 
end

end

end

p(1,length(display),1).select();
set(gca,'XTickLabel',strarr);

p(2,length(display),1).select();
set(gca,'XTickLabel',strarr,'XTick',1:length(strarr));


hText = xticklabel_rotate(1:length(strarr),90,strarr);

% set(gca,'XTick',cellwidth*([0:1:length(display)-1]+0.5),'XTickLabel',at_name(display));
% 
% colormap(colind);
% h_colorbar_axis = colorbar('peer', h_axis);
% 
% lab={};
% for i=1:11;
%    lab{i}=100*thr*(i-6)/(11-6); 
% end
% 
% set(h_colorbar_axis,'YTick',0:0.1:1,'YTickLabel',lab);
% ylabel(h_colorbar_axis,'Variations compared to WT (%)  ');
% 
% p(3).select(h_colorbar_axis);

p.de.margin=10;
p.marginleft=30;
p.marginbottom=20;
%p(3).margin=[1 1 1 1]


f2=[path '/' file '-compare-synth.pdf'];    

%myExportFig(f2,'-zbuffer');


function out=colorpic

s=0.25;

r1=[1:-s:0 zeros(1,length(s:s:1))];
g1=[zeros(1,length(1:-s:0)) s:s:1];
b1=zeros(size(g1));

b2=[1:-s:0 zeros(1,length(s:s:1))];
g2=[zeros(1,length(1:-s:0)) s:s:1];
r2=[zeros(1,length(1:-s:0)) s:s:1];

x=length(r1);

m=zeros(length(r1),length(r1),3);

alpha=1;

for i=1:size(m,1)
    for j=1:size(m,2)
        m(i,j,1)=sqrt(r1(i)^2+r2(j)^2)^alpha;
        m(i,j,2)=sqrt(g1(i)^2+g2(j)^2)^alpha;
        m(i,j,3)=sqrt(b1(i)^2+b2(j)^2)^alpha;
        
        %if sqrt((i-(x+1)/2)^2+(j-(x+1)/2)^2)>(x+1)/2
        %    m(i,j,1)=0;
        %    m(i,j,2)=0;
       %     m(i,j,3)=0;
        %end
    end
end

%figure, imshow(m);

out=m;

function pval=testSignificance(A,B)

val1=0.05; val2=0.01; val3=0.001;
h1 = kstest2(A,B,0.05);
h2 = kstest2(A,B,0.01);
h3 = kstest2(A,B,0.001);

%p = ranksum(A,B) % wilcoxon ranksum test

pval=0;

if h1
    pval=val1;
    if h2
        pval=val2;
        if h3
            pval=val3;
        end
    end
end


function pval=testSignificance(A,B)

val1=0.05; val2=0.01; val3=0.001;
h1 = kstest2(A,B,0.05);
h2 = kstest2(A,B,0.01);
h3 = kstest2(A,B,0.001);

%p = ranksum(A,B) % wilcoxon ranksum test

pval=0;

if h1
    pval=val1;
    if h2
        pval=val2;
        if h3
            pval=val3;
        end
    end
end

