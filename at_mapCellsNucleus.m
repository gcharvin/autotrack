function at_mapCellsNucleus(arrN,arrI,channel)
global segmentation timeLapse

% arg : array that links nucleus and cells from at_linkCellNucleus

arr=-1*ones(length(segmentation.tcells1),timeLapse.numberOfFrames); % nuclei index in tcells object


for i=1:length(segmentation.tcells1)
    fprintf('.');
    frames=[segmentation.tcells1(i).Obj.image];
   
    if segmentation.tcells1(i).N~=0
        segmentation.tcells1(i).setMother(0);
        segmentation.tcells1(i).removeDaughter('ALL');
    end
    
    cc=1;
    
    info=[];
    info.n=0;
    info.i=0;
    
    
    link=[];
    link.n=[];
    link.frame=[];
    link.i=[];
    link.type=[];
    
    for j=frames
        
        info.n=arrN(i,j);
        info.i=arrI(i,j);
        info.fluo=0;
        info.area=0;
        
        if info.i~=0
            info.fluo=segmentation.nucleus(j,info.i).fluoMean(channel);
            info.area=segmentation.nucleus(j,info.i).area;
        end
        
        
        % assign nucleus data to cell that contains nucleus
        segmentation.tcells1(i).Obj(cc).Mean=info;
        
        % determine if nucleus numbers are shared by other cells, which
        % indicates a clear link between cells
        
        if info.n>0
            %cros=arrN(:,max(frames(1),j-2):min(frames(end),j+2));
            cros=arrN(:,j);
            
            ic=find(cros==info.n);
            pix=find(ic~=i);
            ic=ic(pix);

            if numel(ic) % another cell has the same nucleus number; nucleus is in between cells
                link.frame=[link.frame ; j];
                link.n=[link.n ; ic]; % cell number that shares nucleus with corresponding cell
                link.i=[link.i ; arrN(ic,j)]; % nucleus number that is shared
                link.type=[link.type ; 0]; % shared nucleus
               % link
            else % if not, then check when first nucleus appears and identify mother nucleus
                if j>frames(1)
                   if arrN(i,j)~=0 && arrN(i,j-1)==0
                       ind=arrI(i,j);
                       
                       
                     [candidates dist]=findNeighbors(segmentation.nucleus(j,ind),segmentation.nucleus(j,:),65); % find neighbors
                     [out,dist2]=scoreDiv(segmentation.tnucleus,candidates,j,channel,20); % use nucleus fluo to alleviate ambiguity
                     
                     dist=1./dist;
                     for l=1:length(out)
                        pixo=find(candidates==out(l));
                        if numel(pixo)
                           dist(pixo)=dist(pixo)+1;
                        end
                     end
                     
                     if numel(candidates)
                     [idist pix]=sort(dist,'descend');
                     candidates=candidates(pix); % nucleus number
                     pix=find(arrN(:,j)==candidates(1)); % find cell that contains found nucleus
                     
                      link.frame=[link.frame ; j];
                      link.n=[link.n ; pix]; % cell number is likely the mother of current cell
                      link.i=[link.i ; candidates(1)]; % nucleus number that is in mother cell
                      link.type=[link.type ; 1]; % event : nucleus number is close to mother nucleus
                     end
                   end
                end
            end
        end
        segmentation.tcells1(i).mothers=link;
        cc=cc+1;

    end
    
 
end

firstSeg=find(segmentation.cells1Segmented,1,'first');

for i=1:length(segmentation.tcells1)
    link=segmentation.tcells1(i).mothers;
    
    
    fr=segmentation.tcells1(i).detectionFrame; % cell is born after first frame
        
    if arrN(i,fr)<=0 & numel(link.n)% cell does not have a nucleus when born, therefore can be linked to a mother cell
        [C ia ic]=unique(link.n);
        
       
         link.frame=link.frame(ia);
         link.n=link.n(ia);
         link.i=link.i(ia);
         link.type=link.type(ia);
         
         dat=[segmentation.tcells1(i).Obj.Mean];
         area=[dat.area];
         fluo=[dat.fluo];
         
         figure, plot(area.*fluo,'r*'); title(num2str(i));
         pause
         close
         
         segmentation.tcells1(i).setMother(link.n(1));
         segmentation.tcells1(link.n(1)).addDaughter(i,fr,[]);
    end 
   %end
end

% determine parentage based on shared nuclei

% frames=[segmentation.tcells1(1).Obj.image];
% info=[segmentation.tcells1(1).Obj.Mean];
%
% area=[info.area];
% fluo=[info.fluo];
%
% figure, plot(frames, fluo.*area);


fprintf('\n');


function [out distout]=findNeighbors(targetCell,cellsin,dist)

mx=[cellsin.ox];
mx=repmat(mx',[1 size(mx,2)]);
mx=mx-mx';

my=[cellsin.oy];
my=repmat(my',[1 size(my,2)]);
my=my-my';

sz=sqrt(mean([cellsin.area]));

d=sqrt(mx.^2+my.^2);
pix=d<dist;
pix=pix & tril(ones(size(d)),-1);

[row,col] = find(pix);

if numel(pix)==0
    out=[];
    return
end

nc=[cellsin.n];
val= find(nc==targetCell.n);

%find(col==val)
%find(row==val)

pix=[find(col==val) ; find(row==val)];

col=col(pix);
row=row(pix);

n=length(row);
%
fuse=[];
dist=[];
%

%row,col
% find min distances between cells
for i=1:n
    
    x1=cellsin(row(i)).x;
    if size(x1,1)~=1
    x1=x1';
    end
        
    x2=cellsin(col(i)).x;
    if size(x2,1)~=1
    x2=x2';
    end
    
    y1=cellsin(row(i)).y;
    if size(y1,1)~=1
    y1=y1';
    end
    
    y2=cellsin(col(i)).y;
    if size(y2,1)~=1
    y2=y2';
    end
    
    %row(i)
    % line(cellsin(row(i)).x,cellsin(row(i)).y,'Color','r','Marker','o');
    
    x1p=repmat(x1',[1 size(x1,2)]);
    x2p=repmat(x2',[1 size(x2,2)]);
    
    x=x1p-x2p';
    
    y1p=repmat(y1',[1 size(y1,2)]);
    y2p=repmat(y2',[1 size(y2,2)]);
    y=y1p-y2p';
    
    d=sqrt(x.^2+y.^2);
    %
    %row(i),min(min(d))
    
    %pix=d<20;
    %pix=pix & ~diag(ones(1,size(d,1))) ;%tril(ones(size(d)),-1);
    
    %pix=find(pix);
    
   % if numel(pix)>0
        %fuse=[fuse i];
        dist=[dist min(d(:))];
   % end
end


out=[];
distout=[];


    for i=1:n
    %val,row(fuse(1))
    if row(i)==val
        out=[out ; col(i)];
        distout=[distout; dist(i)];
    else
        out=[out ; row(i)];
        distout=[distout; dist(i)];
    end
    end
    

    out=nc(out);
    
    
    
function [out,dist]=scoreDiv(tcells1,candidates,fr,channel,minDivisionTime)

out=[];
dist=[];

n=[tcells1.N];

for i=1:length(candidates)
   %i,candidates(i)
   pix=find(n==candidates(i));
   fluo=[tcells1(pix).Obj.fluoMean];
   fluo=reshape(fluo,length(tcells1(pix).Obj(1).fluoMean),[]);
   fluo=fluo(channel,:);
   
   fluo2=[tcells1(pix).Obj.area];
   
  % size(fluo)size(fluo2)
   fluo=fluo.*fluo2;
   fluo=smooth(fluo,6);
   %figure, plot(fluo)
   
   fluo=-diff(fluo);
   
   %length(fluo)
   minDiv=min(minDivisionTime,length(fluo)-1);
   
   %%% added to prevent bug on length
   if length(fluo)<minDivisionTime
       continue;
   end

  % warning off all
   %[pksmax locmax]=findpeaks(-fluo,'minpeakdistance',minDiv,'minpeakheight',5000); % to be set properly after normalization
  % warning on all;
   
   
  % to be troubleshooted because fpeak has neve been used before in this
  % function
  % Alternatively, use the findpeaks function that requires the signal
  % processing toolbox
  
 % figure, plot(fluo)
    peak=fpeak(1:1:length(fluo),fluo,20,[0 length(fluo) 70000 Inf]); % better function than matlab's fpeak
    locmax=peak(:,1)'+1;
   
%    if candidates(i)==19 || candidates(i)==48 %|| candidates(i)==78
%       first= tcells1(candidates(i)).detectionFrame-1;
%       fra=1:1:length(fluo);
%       fra=fra+first;
%   % figure,plot(fra,fluo); %hold on; plot(locmax,,'Color','r');
%    title(num2str(candidates(i)));
 %  end
  %return;
  %a=candidates(i)
  % fr
  % locmax+tcells1(candidates(i)).detectionFrame-1
   
   d=min(abs(locmax+tcells1(pix).detectionFrame-1-fr));
   
   if d<=2
      out=[out candidates(i)]; 
      if d==0
          d=0.5;
      end
      
      dist=[dist d];
   end
end