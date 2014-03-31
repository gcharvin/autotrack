function at_diff(statarr,strarr)
global datastat
% compare different stat files

% statarr: array of index in at_display to compare
% strarr : cell array of string containing names of stat files

% highlights differences between selected stats


path=datastat(statarr(1)).path;
[path file ext]=fileparts(path);

display1=at_name('tdiv','tg1','ts','tg2','tana');
display2=at_name('vdiv','vg1','vs','vg2','vana');
display3=at_name('vbdiv','vbg1','vbs','vbg2','vbana');
display4=at_name('tbud','muunbud','mubud');
display=[display1 display2 display3 display4];

% now plot differrences nicely using traj

% colM=colorpic;
% 
% z=size(colM,1);
% rm=1:1:z*z;
% rm=reshape(rm,[z z]);

thr=0.3;

% colind=reshape(colM,[size(colM,1)*size(colM,1) 1 3]);
% colind=permute(colind,[1 3 2]);
% 
% colind=1-colormap(jet(z));

s=0.1;

r1=[1:-s:0 zeros(1,length(s:s:1))];
g1=[zeros(1,length(1:-s:0)) s:s:1];
b1=zeros(size(g1));

colind=[r1' g1' b1'];
colind=flipud(colind);
z=size(colind,1);

M={};

h=figure('Color','w','Position',[200 200 1200 500]);
cellwidth=20; spacing=1.2;


p=panel;
p.pack('h',{0.05 0.85 0.05 0.05});

p.fontsize=16;

p(2).pack('v',{1/2 1/2});
p(1).pack('v',{1/2 1/2});

for ii=0:1
    
    hlabel=p(1,ii+1).select();
    set(hlabel,'Visible','off');
    if ii==0
       text(0.5,0.5,'D','FontSize',20); 
    else
       text(0.5,0.5,'M','FontSize',20); 
    end
    line([2 2],[0.05 0.95],'Color','k');
    
    
    h_axis=p(2,ii+1).select();
    
    startX=0;
    startY=0;
    
for j=1:length(statarr)
    stats=datastat(statarr(j)).stats;
    M{j,1}=find(stats(:,5)==ii & stats(:,6)==0); % select D or Ms
    M{j,2}=strarr{j} ;
    
    T_M=stats(M{j,1},display);
    
    % plot total cell (M+B) size instead of M size
    T_M(:,6:10)=T_M(:,6:10)+T_M(:,11:15);
    
    
    avg{j}=mean(T_M,1);
    CV{j}=std(T_M,0,1)./avg{j};
    
    
    r1=(avg{j}./avg{1}-1);
    r1=min(r1,thr); r1=max(r1,-thr); 
    
    r1=max(1,round(z*0.5*(r1+thr)./thr));
    %r1=z*ones(1,length(r1));
    
    r2=(CV{j}./CV{1}-1); r2=min(r2,thr); r2=max(r2,-thr); r2=max(1,round(z*0.5*(r2+thr)./thr));
    %r2=1*ones(1,length(r2));
    
    rec=[]; cindex=[];
    for i=1:length(avg{j})
       
            
            
        rec(i,1)=cellwidth*(i-1);
        rec(i,2)=cellwidth*i;
        
        if j==1
           cindex(i)=(z+1)/2; 
        else
            %size(rm),r1(i),r2(i)
           %id=sub2ind(size(rm),r1(i),r2(i))
           cindex(i)= r1(i);
        end
        
         if i==11 
             cindex(i)=(z+1)/2; 
         end
          if i==12 
             cindex(i)=(z+1)/2; 
          end
         
    end
    startY=startY+spacing*cellwidth;
    %if j==1
        Traj(rec,'Color',colind,'colorindex',cindex,'tag',['Cell type:' strarr{j} '-' num2str(ii)],h,'width',cellwidth,'startX',startX,'startY',startY,'sepColor',[1 1 1],'sepwidth',2,'gradientWidth',0);
    %end
end

set(gca,'XTick',cellwidth*([0:1:length(display)-1]+0.5),'XTickLabel',at_name(display));
set(gca,'YTick',cellwidth*(spacing*[0:1:length(statarr)-1]+spacing),'YTickLabel',strarr);


axis equal tight

end

colormap(colind);
h_colorbar_axis = colorbar('peer', h_axis);

lab={};
for i=1:11;
   lab{i}=100*thr*(i-6)/(11-6); 
end

set(h_colorbar_axis,'YTick',0:0.1:1,'YTickLabel',lab);
ylabel(h_colorbar_axis,'Variations compared to WT (%)  ');

p(3).select(h_colorbar_axis);

p.de.margin=2;
%p(3).margin=[1 1 1 1]


f2=[path '/' file '-compare-synth.pdf'];    

myExportFig(f2,'-zbuffer');


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