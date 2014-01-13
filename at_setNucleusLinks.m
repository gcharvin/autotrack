function mothers=at_setNucleusLinks
global timeLapse segmentation candarrstore narrstore scorearrstore

% new pedigree construction based on budnecks detection without using
% budneck mapping


% pedigree start frame can be different from movie start frame
%

%displayImage=segmentation.realImage;

channel=3;
object='nucleus';

phy_progressbar;

% set pedgigree settings

a=timeLapse.autotrack.position(segmentation.position).nucleusMapped;
pix=find(a);

if numel(a)==0
   disp('Nucleus were not mapped; Exiting...');
   return;
end

segmentation.pedigree.start= pix(1);
segmentation.pedigree.end= pix(end);
segmentation.pedigree.minDivisionTime=20;

a=[segmentation.nucleus(pix(1),:).n];
a=a(a~=0);

segmentation.pedigree.firstMCell= a;

for i=1:numel(a)
  segmentation.pedigree.firstCells{i}='';
end

% firstMCells

firstFrame=segmentation.pedigree.start;

cells=segmentation.(object)(firstFrame,:);
pix=find([cells.ox]~=0);
n=[cells.n];

firstMCell=n(pix);
firstCells=[];

minDivisionTime=20;%segmentation.pedigree.minDivisionTime;
exclude=firstMCell;

tcells=segmentation.(['t' object])  ;

% init parentage -
for i=1:numel(tcells)
    if tcells(i).N~=0
        tcells(i).setMother(0);
    end
    
end

% remove tobjct that are too short 
% except those at the end of the segmentation

filtre=[];
thr=3; %frames 
for i=1:numel(tcells)
   if numel(tcells(i).Obj)>=thr 
       filtre=[filtre i];
   else
      if tcells(i).Obj(end).image==segmentation.pedigree.end
          
       filtre=[filtre i];
      end
   end
end

tcells=tcells(filtre);
    
% sort tcells according to appearance timing;
order=[];
for i=1:numel(tcells)
    if numel(find(firstMCell==tcells(i).N))
           continue
    end
    
    if tcells(i).N~=0
        if tcells(i).mother==0
            if tcells(i).detectionFrame>=segmentation.pedigree.start && tcells(i).detectionFrame<segmentation.pedigree.end
                
               if ~numel(find(find(segmentation.discardImage)==tcells(i).detectionFrame))
                 
                pix=find(exclude==tcells(i).N);
                if  numel(pix)==0
                    order=[order; [i tcells(i).detectionFrame tcells(i).N]];
                end
               end
            end
        end
    end
    % i,a=order(i)
end


[narr sortindex]=sortrows(order,2);

% procedure to build pedigree :
% 1- list potential candidates for new daughters and rank them according to
% simple criteria; make most probable configuration

% loop :
% 2- build pedigree array
% 3- evaluate conflicts for specific cells
% 4- try all possible new configurations loop to 2

% assign daughters to their mothers


phy_progressbar;
pause(0.1);
    
    candarr=zeros(length(narr(:,1)),10);
    scorearr=zeros(length(narr(:,1)),10);
    
    
    
    for k=1:numel(narr(:,1))
        phy_progressbar(double(k)/numel(narr(:,1)));
        
        cindex=narr(k,1);

        fr=tcells(cindex).detectionFrame;
        
            cells1=segmentation.(object)(fr,:);
            ox=[cells1.ox]; 
            cells1=cells1(find(ox~=0));
            
            filtre2=[];
            for l=1:numel(cells1)
               if  numel(find(filtre==cells1(l).n))
                   filtre2=[filtre2 l];
               end
            end
            
            cells1=cells1(filtre2);


        targetCell=tcells(cindex).Obj(1);
 
        %score=zeros(1,max(narr(:,1)));
        score=zeros(1,max([tcells.N]));
        
       % targetCell.n
        
        [candidates dist]=findNeighbors(targetCell,cells1,65);
     %   tcells(cindex).N,candidates,dist
       
       
%       if targetCell.n==119
%           %  candidates, dist
%           % return; 
%        %
%         end
       % return;
        
        %rule 1 : identify neighbor cells
        %  return;
        
        if numel(candidates)==0
            continue
        end
        
        score(candidates)=1./dist'; 
        [candidates dist]=scoreDiv(tcells,candidates,fr,channel,minDivisionTime); 
        score(candidates)=score(candidates)+1;%./dist;
        
      %  score
        
        [ord ind]=sort(score,'descend');
       % ord
        
        pix=find(ord==0,1,'first');
       % k
        candarr(k,1:pix-1) =ind(1:pix-1);
        scorearr(k,1:pix-1)=ord(1:pix-1);  
        
       % break
    end
    
   % candarr
    phy_progressbar(1);
    pause(0.1);
    
    candarrstore=candarr;
    scorearrstore=scorearr;
    narrstore=narr;
    

problems=1;
energy=0;
cc=1;


%narr,candarr,scorearr
%[narr(:,3) candarr(:,:)]

% detect and fix problems based on timings

listDau=[];

firstFrame=find(segmentation.cells1Mapped,1,'first'); %remove -1 ?

    mothers=buildTree(narr,candarr,tcells);
    problems=checkBadTimings(mothers,minDivisionTime,firstFrame)
    

for i=1:numel(mothers)
    n=[tcells.N];
    list=mothers(i).daughterList;
    detect=mothers(i).budTimes;
    %tcells(i).setMother(0);
    
    for j=1:numel(list)
        dau=list(j);
        %n(i);
        
        if numel(find(tcells(i).daughterList==dau))==0
            pix=find(n==dau);
            tcells(pix).setMother(n(i));
            tcells(i).addDaughter(dau,[],tcells(pix).detectionFrame); %add a new daughter to the mother
        end
    end
end


%b=tcells(1)



function  mothers=buildTree(narr,candarr,tcells)

mothers.daughterList=[];
mothers.budTimes=[];
mothers.detectionFrame=[];
mothers.n=[];

for i=1:numel(tcells)
    
    mothers(i).daughterList=tcells(i).daughterList;
    mothers(i).budTimes=tcells(i).budTimes;
    
    %if numel(tcells(i).budTimes)~=0
    %    if tcells(i).budTimes(1)==0
    %        mothers(i).budTimes(1)=startframe;
    %    end
    %end
    
    mothers(i).detectionFrame=tcells(i).detectionFrame;
    mothers(i).n=tcells(i).N;
end

n=[tcells.N];

for i=1:length(narr(:,1))
    if candarr(i,1)~=0

        ind=find(n==candarr(i,1));
        %ind=narr(i,3);
        
        mothers(ind).daughterList=[mothers(ind).daughterList narr(i,3)];
        mothers(ind).budTimes=[mothers(ind).budTimes narr(i,2)];
    end
end

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
    

 %   out
%out=unique(out)

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


function out=checkBadTimings(mothers,minDivisionTime,startframe)

out=[];

indmothers=[mothers.n];

for i=1:numel(mothers)
    
    
    if numel(mothers(i).budTimes)==0
        continue
    end
    
    % first detect timings issues with daughter cells
    timings=[mothers(i).detectionFrame mothers(i).budTimes];
    delta=timings(2:end)-timings(1:end-1);
    
    sh=0;
    
    % if i==7
    %   a=  mothers(i).detectionFrame
    %   startframe
    % end
    
    if mothers(i).detectionFrame==startframe % cell is present on the first frame
        sh=1;
       
        pix=find(indmothers==mothers(i).daughterList(1));
        if mothers(pix).detectionFrame==startframe % cell has daughter on the first frame
            sh=2;
        end
    end
    
    
    %a=mothers(i)
    if numel(delta)<1+sh
        continue
    end
    
    % startframe
    
    
    pix=[];
    if sh==0
        if delta(1)<1.25*minDivisionTime  % daughter cell timings
            pix=1;
        end
    else
        sh=sh-1;
    end
    
    pix2=find(delta(2+sh:end)<minDivisionTime); % mother cell timing
    pix=[pix pix2+sh+1];
    
    
    % if i==7
    %     sh,delta,pix,a=mothers(i).daughterList
    % end
    
    
    for j=1:numel(pix)
        if pix(j)~=1
            %j,pix(j),a=mothers(i).budTimes
            %  'ok1'
            
            out=[out; [indmothers(i) mothers(i).daughterList(pix(j)) mothers(i).daughterList(pix(j)-1)]];
        else
            % 'ok2'
            out=[out; [indmothers(i) mothers(i).daughterList(pix(j)) mothers(i).daughterList(pix(j))]];
        end
    end
end







