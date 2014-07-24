function at_noise(index,leg)
global datastat


figure; %loglog(ftot,ytot,'LineStyle','None','Marker','.','MarkerSize',6); hold on; 

col={'r','b','g','m','c','y','k'};

cc=1;


for i=index
    stats=datastat(i).stats;
    
    
    outliers=stats(:,6)~=0;
    
    cellsok=stats(~outliers,:);
    outliers=stats(outliers,:);
    
    fluo=at_name('fluo');
    

    ftot=[];
    ytot=[];
    mtot=[];
    
    ftotout=[];
    ytotout=[];
    mtotout=[];
    
    for j=1:length(stats(:,1))
        htb2=stats(j,fluo);
        
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
    [fmeanout, ampmeanout, ftotout, ytotout]=averagespectrum(ftotout,ytotout,mtotout);
    
    loglog(fmean,ampmean,'Marker','o','MarkerSize',6,'Color',col{cc},'LineStyle','none'); hold on
    loglog(fmeanout,ampmeanout,'Marker','x','MarkerSize',6,'Color',col{cc},'LineStyle','none'); hold on
   
    str{2*i-1}=leg{i};
    str{2*i}='';
  %  pause
   cc=cc+1;  
end

 ylabel('Spectrum'); xlabel('Frequency (hours^-1)');
 legend(str);


function [fmean, ampmean, ftot, ytot]=averagespectrum(ftot,ytot,mtot)

   [ftot,ix]=sort(ftot);
    ytot=ytot(ix)/mean(mtot);
    
     fmean=[];
     ampmean=[];

    scale=-1:0.02:1;
    bin=10.^scale;
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


