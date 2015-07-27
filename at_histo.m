function at_histo(option)
global datastat

p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;
path=datastat(pix).path;


if nargin==0
  option='MD'; % M/D plot  
end

[path file ext]=fileparts(path);

display1=at_name('tdiv','tg1','ts','tg2','tana');
display2=at_name('vdiv','vg1','vs','vg2','vana');
display3=at_name('vbdiv','vbg1','vbs','vbg2','vbana');
display4=at_name('tbud','mub','mb','asy');
display=[display1 display2 display3];

h=figure;
width=1000;
height=1000;
set(h,'Color','w','Position',[100 100 width height]);
p = panel();

p.pack('v',{3/4 []});
p(1).pack(3,5);
p(2).pack(1,length(display4));
%p(3).pack(1,5);
%p(4).pack(1,5);
%p(5).pack(1,3);
%p.select('all');
%p.identify()
%return;

p.fontsize=12;

maxen=zeros(1,3);
cc=1;

M={};

if strcmp(option,'MD')
    M{1,1}=find(stats(:,5)==1 & stats(:,6)==0);
    M{1,2}='M';
    M{2,1}=find(stats(:,5)==0 & stats(:,6)==0);
    M{2,2}='D';
else
    M{1,1}=find(stats(:,5)==0 & stats(:,6)==0);
    M{1,2}='Age0'; 
    
   for j=2:8   
    M{j,1}=find(stats(:,5)==1 & stats(:,6)==0 & stats(:,4)==j-1);
    M{j,2}=['Age' num2str(j-1)];   
   end
end


for k=1:3
for m = 1:5 
        p(1,k,m).select();
        
        ind=display(cc);
        str=at_name(ind);
        
        coef=1;
        if k==1
            coef=3;
        end
        
        for j=1:size(M,1)
            
            
        if k==2 % plot total cell (M+B) size instead of M size
        T_M{j}=coef*(stats(M{j,1},ind)+stats(M{j,1},ind+5));   
        else
        T_M{j}=coef*stats(M{j,1},ind);
        end
        
       % if k==1
       %    a=mean( T_M{j}) 
       % end
        
        leg1{j}=[M{j,2} '=' num2str(round(100*mean( T_M{j}))/100) '; CV=' num2str(round(100*std( T_M{j})/mean( T_M{j}))/100)];
        
        
        end
        
        [t n x]=nhist(T_M,'noerror','xlabel','','ylabel','','fsize',10,'binfactor',1,'minx',0,'samebins','numbers','legend',leg1,'color','qualitative');
        
        for j=1:size(M,1)
        maxen(k)=max(maxen(k),max(max(n{j})));
        end
        
        p(1,k,m).title(str);
        
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
        
        for j=1:size(M,1)
            
        
        if i==1
            coef=3; % timing in minutes
        else
           coef=1; 
        end
        
        %if i==4


%bb=num2str(round(100*mean( T_M{j}))/100)

        %end

        T_M{j}=coef*stats(M{j,1},ind);
        
        
        
      %  aa=mean( T_M{j})
        
        leg1{j}=[M{j,2} '=' num2str(round(100*mean( T_M{j}))/100) '; CV=' num2str(round(100*std( T_M{j})/mean( T_M{j}))/100)];
        
        end
        
        [t n x]=nhist(T_M,'noerror','xlabel','','ylabel','','fsize',10,'binfactor',1,'minx',0,'samebins','numbers','legend',leg1,'color','qualitative');
        
        for j=1:size(M,1)
        maxen=max(maxen,max(max(n{j})));
        end
        
        p(2,1,i).title(str);
        
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
         if i==4
            xlabel('Bud/M asymmetry');
        end
        cc=cc+1;
end

for i=1:length(display4)
        p(2,1,i).select();
        ylim([0 1.2*maxen]);
end


p.de.margin = 20;
p.margin = [23 20 12 12];

stratio=num2str(width/height);

f=[path '/' file '-timings' option '.svg'];
f2=[path '/' file '-timings' option '.pdf'];

%p.export(f2, '-pA4','-c1', ['-a' stratio], '-r300');

%myExportFig(f2);

%plot2svg(f); % problem with AI import
%eval(['!/usr/local/bin/rsvg-convert -f pdf -a ' f ' > ' f2]); %conversion
%is fine, but porblem with fonts in AI import

%eval(['!/Applications/Inkscape.app/Contents/Resources/script "' f '" --export-pdf="' f2 '"']);
% same proble as with rsvg-convert