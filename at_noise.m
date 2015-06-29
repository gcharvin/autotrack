function at_noise(index,leg)
global datastat

% plot 1) typical temporal trace for the longest lived cell
% 2) noise spectrum
% 3) noise integrated over high frequencies + fraction of outliers 

h=figure;
width=1000;
height=400;
set(h,'Color','w','Position',[100 100 width height]);
p = panel();

col={'r','b','g','m','c','y','k','r','b','g','m','c','y','k'};


cc=1;

p.pack('h',{0.55 0.15 0.15 0.15});
p.de.margin=20;


for i=index
    stats=datastat(i).stats;
    
    % plot temporal trace
    p(1).select(); 
    
%     longtrace=find(stats(:,4)==3);
%     id=stats(longtrace,3);
%     
%     longtrace=longtrace(longtrace>3);
%     
%     longtrace2=find(stats(longtrace-1,4)==2 & stats(longtrace-2,4)==1 & stats(longtrace-2,3)==stats(longtrace,3) & stats(longtrace-2,3)==stats(longtrace,3),1,'first');
%     
%      if numel(longtrace2)==0
%         warndlg('There is no cell in you experiment with at least 3 consecutive divisions : crappy data ???');  
%      end
%          
%     longtrace=longtrace(longtrace2);
%     
%    
%     
%     for j=longtrace-2:longtrace
%         fluo=at_name('fluo');
%         htb2=stats(j,fluo);
%         htb2=htb2(find(htb2~=0));
%         x=1:1:length(htb2); x=x+stats(j,7)+stats(j,8);
%         plot(x/20,htb2,'Color',col{cc}); hold on
%     end
        
    outliers=stats(:,6)~=0;
    
    cellsok=stats(~outliers,:);
    outliers=stats(outliers,:);
    
    
    frac(cc)=100*double(size(outliers,1))/(double(size(cellsok,1))+double(size(outliers,1)));
    
    mothers=find(cellsok(:,5)==1);
    
    div(cc)= 3*mean(cellsok(mothers,10));
    fluo=at_name('fluo');
    

    ftot=[];
    ytot=[];
    mtot=[];
    
    ftotout=[];
    ytotout=[];
    mtotout=[];
    
    for j=1:length(stats(:,1))
        htb2=stats(j,fluo);
        htb2=htb2(htb2~=0);
        htb2=(htb2-min(htb2))/(max(htb2)-min(htb2)); % normalization
        
        t=linspace(0,2*pi,length(htb2));
        
        htb2=htb2.*(1-cos(t)); % apodization
        
        [f,y]=computeSpectrum(htb2);
        
        if stats(j,6)==0
        ftot=[ftot f];
        ytot=[ytot y];
        mtot=[mtot mean(htb2)];
        else
        ftotout=[ftotout f];
        ytotout=[ytotout y];
        mtotout=[mtotout mean(htb2)];   
        end
    end
  
    [fmean, ampmean, ftot, ytot]=averagespectrum(ftot,ytot,mtot);
   % [fmeanout, ampmeanout, ftotout, ytotout]=averagespectrum(ftotout,ytotout,mtotout);
    
   if cc~=1
   %axes(h)
   end
   
   %p(2).select();
    loglog(fmean,ampmean,'Marker','o','MarkerSize',6,'Color',col{cc}); %,'LineStyle','none'); hold on
    hold on;
   set(gca,'XScale','log'); set(gca,'YScale','log');
    
   % loglog(fmeanout,ampmeanout,'Marker','x','MarkerSize',6,'Color',col{cc},'LineStyle','none'); hold on
   
   
   fsel=fmean(end-3:end);
   ampsel=ampmean(end-3:end);
   
   inte(cc)=trapz(fsel,ampsel);
   
   
    str{cc}=leg{cc};
    str2{3*cc-2}=leg{cc};
    str2{3*cc-1}=leg{cc};
    str2{3*cc}=leg{cc};
    
    %str{2*i}='';
  %  pause
   cc=cc+1;  
end

%p(1).select();
 %ylabel('HTB2-GFP fluo (A.U.)'); xlabel('Time (hours)');
 %legend(str2);
 
p(1).select();
 ylabel('Spectrum'); xlabel('Frequency (hours^-1)');
 legend(str);

p(2).select(); %integral of spectrum from 6 minutes to 30 minutes
h=bar(inte');
set(h,'faceColor','k');
set(gca,'XTickLabel',leg);
ylabel('HF noise');

p(3).select(); %integral of spectrum from 6 minutes to 30 minutes
h=bar(frac');
set(h,'faceColor','k');
set(gca,'XTickLabel',leg);
ylabel('% Outliers');

p(4).select(); %integral of spectrum from 6 minutes to 30 minutes
h=bar(div');
set(h,'faceColor','k');
set(gca,'XTickLabel',leg);
ylabel('Mother division time (min)');

function [fmean, ampmean, ftot, ytot]=averagespectrum(ftot,ytot,mtot)

   [ftot,ix]=sort(ftot);
    ytot=ytot(ix)/mean(mtot);
    
     fmean=[];
     ampmean=[];

    %scale=-1:0.05:1;
    %bin=10.^scale
    
    bin=logspace(-1,1,20);
    
     for k=1:length(bin)-1
         pix=ftot>bin(k) & ftot<bin(k+1);
%        temp=idx==k;
        fmean=[fmean mean(ftot(pix))];
        ampmean=[ampmean mean(ytot(pix))];
     end
     

function [f amp]=computeSpectrum(htb2)


Fs = 20;                    % Sampling frequency in hours-1
T = 1/Fs;                     % Sample time

L = length(htb2)*T;                     % Duratio of signal in seconds
%Npoints=round(L/T);
t = 0:T:(L-T);              % Time vector


NFFT = 2^nextpow2(length(t)); % Next power of 2 from length of y
Y = fft(htb2,NFFT)/length(t);
f = Fs/2*linspace(0,1,NFFT/2+1); 
amp=2*abs(Y(1:NFFT/2+1));


