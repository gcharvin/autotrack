function at_plotHistoCompare(statarr,strarr)
global datastat
% compare different stat files

% statarr: array of index in at_display to compare
% strarr : cell array of string containing names of stat files


path=datastat(statarr(1)).path;
[path file ext]=fileparts(path);

display1=at_name('tdiv','tg1','ts','tg2','tana');
display2=at_name('vdiv','vg1','vs','vg2','vana');
display3=at_name('vbdiv','vbg1','vbs','vbg2','vbana');
display4=at_name('tbud','mub','mb','asy');
display=[display1 display2 display3];


for ii=1:2
        
h=figure;
width=1000;
height=1000;
set(h,'Color','w','Position',[100 100 width height]);
p = panel();

p.pack('v',{3/4 []});
p(1).pack(3,5);
p(2).pack(1,length(display4));

p.fontsize=12;

maxen=zeros(1,3);
cc=1;

M={};


   for j=1:length(statarr) 
    stats=datastat(statarr(j)).stats;
    M{j,1}=find(stats(:,5)==ii-1 & stats(:,6)==0); % select D or Ms
    M{j,2}=strarr{j} ;  
   end



for k=1:3
for m = 1:5 
        p(1,k,m).select();
        
        ind=display(cc);
        str=at_name(ind);
        
        if ii==1
           str=[cell2mat(str) '-D'];
        else
           str=[cell2mat(str) '-M']; 
        end
        
        coef=1;
        if k==1
            coef=3;
        end
        
        for j=1:size(M,1)
        stats=datastat(statarr(j)).stats;
            
        if k==2 % plot total cell (M+B) size instead of M size
        T_M{j}=coef*(stats(M{j,1},ind)+stats(M{j,1},ind+5));   
        else
        T_M{j}=coef*stats(M{j,1},ind);
        end
        
        leg1{j}=[M{j,2} '=' num2str(round(10*mean( T_M{j}))/10) '; CV=' num2str(round(100*std( T_M{j})/mean( T_M{j}))/100)];

        end
        
        [t n x]=nhist(T_M,'noerror','xlabel','','ylabel','','fsize',10,'binfactor',1,'minx',0,'samebins','numbers','legend',leg1,'color','qualitative');
        
        for j=1:size(M,1)
        maxen(k)=max(maxen(k),max(max(n{j})));
        end
        
        
        if m==1
            ylabel('# Events');
        else
            set(gca, 'yticklabel', {});
        end
        if m==3 && k==1
            xlabel('Time (min)');
        end
        if m==3 && k==2
            xlabel('Area (pixels)');
        end
        if m==3 && k==3
            xlabel('Area (pixels)');
        end
        
        if size(M,1)==2 % plot significance 
           pval=testSignificance(T_M{1},T_M{2});
           if pval~=0  
              % round([min(mean(T_M{1}),mean(T_M{2})) max(mean(T_M{1}), mean(T_M{2}))+2])
              if pval==0.05 txt='*'; end
              if pval==0.01 txt='**'; end
              if pval==0.001 txt='***'; end
              str=[str ' - ' txt];
            %sigstar({round([min(median(T_M{1}),median(T_M{2})) max(median(T_M{1}), median(T_M{2}))+0.1*max(median(T_M{1}), median(T_M{2}))])},pval); 
           else
              str=[str ' - ns']; 
           end
        end
        
        p(1,k,m).title(str);
        
        cc=cc+1;
    end
end

for n=1:3
for m = 1:5 % set y axis limits
        p(1,n,m).select();
        ylim([0 1.2*maxen(n)]);
    end
end

maxen=0;


for i=1:length(display4) % display tbud, muunbud and mubud and asy
p(2,1,i).select();
        
        ind=display4(i);
        str=at_name(ind);
        
         if ii==1
           str=[cell2mat(str) '-D'];
        else
           str=[cell2mat(str) '-M']; 
         end
        
        for j=1:size(M,1)
        stats=datastat(statarr(j)).stats;   
            
        if i==1
            coef=3; % timing in minutes
        end
        T_M{j}=coef*stats(M{j,1},ind);

        
        leg1{j}=[M{j,2} '=' num2str(round(100*mean( T_M{j}))/100) '; CV=' num2str(round(100*std( T_M{j})/mean( T_M{j}))/100)];
        
        end
        
        [t n x]=nhist(T_M,'noerror','xlabel','','ylabel','','fsize',10,'binfactor',1,'minx',0,'samebins','numbers','legend',leg1,'color','qualitative');
        
        for j=1:size(M,1)
        maxen=max(maxen,max(max(n{j})));
        end
        
        
        if i==1
            ylabel('# Events');
        else
            set(gca, 'yticklabel', {});
        end
        
        if i==1
            xlabel('Time (min)');
        end
        if i==2
            xlabel('Growth rate (pixels/fr)');
        end
        if i==3
            xlabel('Growth rate (pixels/fr)');
        end
        
         if size(M,1)==2 % plot significance 
           pval=testSignificance(T_M{1},T_M{2});
           if pval~=0  
              % round([min(mean(T_M{1}),mean(T_M{2})) max(mean(T_M{1}), mean(T_M{2}))+2])
              if pval==0.05 txt='*'; end
              if pval==0.01 txt='**'; end
              if pval==0.001 txt='***'; end
              str=[str ' - ' txt];
            %sigstar({round([min(median(T_M{1}),median(T_M{2})) max(median(T_M{1}), median(T_M{2}))+0.1*max(median(T_M{1}), median(T_M{2}))])},pval); 
           else
              str=[str ' - ns']; 
           end
        end
        
        p(2,1,i).title(str);
        
        cc=cc+1;
end

for i=1:length(display4)
        p(2,1,i).select();
        ylim([0 1.2*maxen]);
end


p.de.margin = 20;
p.margin = [23 20 12 12];

stratio=num2str(width/height);

%f=[path '/' file '-timings' option '.svg'];

if ii==1
f2=[path '/' file '-compare-D.pdf'];
else
f2=[path '/' file '-compare-M.pdf'];    
end

%p.export(f2, '-pA4','-c1', ['-a' stratio], '-r300');

%myExportFig(f2);
end
        


% 
% 
% function plotHisto(A,B,sca,option)
% 
% if nargin==4
% [t n x]=nhist({sca*A,sca*B},'noerror','xlabel','Time (min)','ylabel',option,'fsize',20,'binfactor',1,'minx',0,'samebins','numbers');
% else
% [t n x]=nhist({sca*A,sca*B},'noerror','xlabel','Time (min)','ylabel','','fsize',20,'binfactor',1,'minx',0,'samebins','numbers');   
% end
% 
% %text(mean(sca*A+1),max(n{1}),'WT','Color',[0.3 0. 1],'FontSize',20);
% %text(mean(sca*B+1),max(n{2}),'whi5','Color',[1 0. 0.3],'FontSize',20);
% 
% 
% pval=testSignificance(A,B)
% if pval~=0
%     
%     sigstar({sca*round([min(median(A),median(B)) max(median(A), median(B))+2])},[pval]); 
%     
%     eff=(mean(A)-mean(B))./mean(B);
%     title({['WT: ' num2str(round(mean(sca*B))) ' min'],['whi5:' num2str(round(mean(sca*A))) 'min'],['\Delta=' num2str(round(100*eff)) '%']});
% else
%     title({['WT: ' num2str(round(mean(sca*B))) ' min'],['whi5: ' num2str(round(mean(sca*A))) 'min']});
% end




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


