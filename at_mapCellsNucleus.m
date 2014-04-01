function at_mapCellsNucleus(channel)
global segmentation timeLapse

% arg : array that links nucleus and cells from at_linkCellNucleus


if isfield(segmentation,'link')
arrN=segmentation.link.arrN;
arrI=segmentation.link.arrI;
else
 errordlg('could not find link between cells and nuclei: run at_linkCellNucleus again');   
end

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
    info.status=0;
    
    
    link=[];
    link.n=[];
    link.frame=[];
    link.i=[];
    link.type=[];
    
   % virginD=1;
    
    for j=frames
        
        info.n=arrN(i,j);
        info.i=arrI(i,j);
        info.fluo=0;
        info.area=0;
        info.status=0;
        
        if info.i~=0
            info.fluo=segmentation.nucleus(j,info.i).fluoMean(channel);
            info.area=segmentation.nucleus(j,info.i).area;
        end
        
        
        
        
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
                link.n=[link.n ; ic(1)]; % cell number that shares nucleus with corresponding cell
                link.i=[link.i ; arrN(ic,j)]; % nucleus number that is shared
                link.type=[link.type ; 0]; % shared nucleus
                % link
                info.status=2; % shared nucleus
                
               
                            
            else % if not, then check when first nucleus appears and identify mother nucleus
                ind=arrI(i,j);
                
                info.status=1; %  1 nucleus in cell
                
                
                if j>frames(1)
                    if arrN(i,j)~=0 && arrN(i,j-1)==0 %&& virginD==1 % should work only for the first time (virginD)
                        
                        [candidates dist]=findNeighbors(segmentation.nucleus(j,ind),segmentation.nucleus(j,:),65); % find neighbors
                        candidates=candidates(candidates>0);
                        dist=dist(candidates>0);
                        [out,dist2]=scoreDiv(segmentation.tnucleus,candidates,j,channel,20); % use nucleus fluo to alleviate ambiguity
                        
                       % virginD=0;
                        
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
                            
                            if numel(pix)
                                pix=pix(1);
                            
                            link.frame=[link.frame ; j];
                            link.n=[link.n ; pix]; % cell number is likely the mother of current cell
                            link.i=[link.i ; candidates(1)]; % nucleus number that is in mother cell
                            link.type=[link.type ; 1]; % event : nucleus number is close to mother nucleus
                            
                            end
                        end
                    end
                end
            end
        end
        
        % assign nucleus data to cell that contains nucleus
        segmentation.tcells1(i).Obj(cc).Mean=info;
        segmentation.tcells1(i).mothers=link;
        cc=cc+1;
        
    end
    
    
end

firstSeg=find(segmentation.cells1Segmented,1,'first');

for i=1:length(segmentation.tcells1)
    link=segmentation.tcells1(i).mothers;
    fr=segmentation.tcells1(i).detectionFrame; % cell is born after first frame
    
    if arrN(i,fr)<=0 & numel(link.n)% cell does not have a nucleus when born, therefore can be linked to a mother cell
        %i,link.n,link.frame
        [C ia ic]=unique(link.n);
        
        
        link.frame=link.frame(ia);
        link.n=link.n(ia);
        link.i=link.i(ia);
        link.type=link.type(ia);
        
        % sort links according to frame appearence
        [frz ixz]=sort(link.frame);
        link.n=link.n(ixz);
        link.frame=link.frame(ixz);
        link.i=link.i(ixz);
        link.type=link.type(ixz);
        
        
        dat=[segmentation.tcells1(i).Obj.Mean];
        area=[dat.area];
        fluo=[dat.fluo];
        status=[dat.status];
        
        % if M+D has shared nucleus --> non divided : status=2
        divided=ones(1,length(dat));
        pix=find(status==2);
        divided(pix)=0;
        
        % if M+D has only one nucleus --> non divided  sum(arrN for mother
        % and daughter cells) : if ==1 then one nucleus
        
        nucD=arrN(i,:);
        nucM=arrN(link.n(1),:);
        
        nucDi=arrI(i,:);
        nucMi=arrI(link.n(1),:);
        
        frame=1:1:length(arrN(1,:));
        
        pix=find(arrN(i,:)>=0);
        nucD=nucD(pix);
        nucM=nucM(pix);
        frame=frame(pix);
        
        nucDi=nucDi(pix);
        nucMi=nucMi(pix);
        
        pix=find(nucD>0);
        nucD2=nucD;
        nucD(pix)=1;
        pix=find(nucM>0);
        nucM2=nucM;
        nucM(pix)=1;
        
        nuctot=nucD+nucM;
        pix=find(nuctot<2);
        divided(pix)=0;
        
        
        % if M+D has 2 nuclei but with distance smaller than few pixels
        % --> non divided
        
        pix=find(nuctot==2 & status~=2); % want to exclude shared nuclei in this analysis
        
        for k=1:length(pix)
            indD=nucDi(pix(k));
            indM=nucMi(pix(k));
            fram=frame(pix(k));
            
            P1=[]; P2=P1;
            P1.x=segmentation.nucleus(fram,indM).x;
            P1.y=segmentation.nucleus(fram,indM).y;
            P2.x=segmentation.nucleus(fram,indD).x;
            P2.y=segmentation.nucleus(fram,indD).y;
            
            warning off all
            d=min_dist_between_two_polygons(P1,P2);
            warning on all
            
            if d<10 % distance smaller than 10 pixels
                divided(pix(k))=0;
            end
        end
        
        [l n]=bwlabel(divided);
        pix=length(nucD);
        for k=1:n
            ll=l==k;
            if length(divided(ll))>=3 % if more than 3 frames with distance larger than x pixels ; cell is certainly divided
                pix=find(ll,1,'first');
                break
            end
        end
        
        division=pix+segmentation.tcells1(i).detectionFrame-1;
        
        % otherwise divided
       % if i==36
       %  figure, subplot(2,1,1); plot(status,'b*'); title(num2str(i));
        %subplot(2,1,2); plot(divided,'b*');
        %
        %pause
        %close
      %  pix,division
       % end
        
        segmentation.tcells1(i).setMother(link.n(1));
        segmentation.tcells1(link.n(1)).addDaughter(i,fr,division);
        segmentation.tcells1(i).birthFrame=division;
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

out=[];
distout=[];

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
    
    if numel(x1p)==0
        dist=[dist 10000];
        continue
    end
    
    if numel(x2p)==0
        dist=[dist 10000];
        continue
    end
    
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
    if numel(pix)==0
        continue
    end
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