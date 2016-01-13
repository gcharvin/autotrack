function at_linkCellNucleus
global segmentation timeLapse

arrN=-1*ones(length(segmentation.tcells1),timeLapse.numberOfFrames); % nuclei number in tcells object
arrI=arrN; % nuclei index in tcell object

%nuclei at interface : % nucleus number , cell list,  frame
% interface=[];
% interface.nucleus=[];
% interface.cell=[];
% interface.frame=[];
% 
% ifcount=1;


for i=1:length(segmentation.tcells1)
    fprintf('.');
   
   % i
    frames=[segmentation.tcells1(i).Obj.image];
    
    if numel(frames)==0
        continue
    end
     if numel(find(frames==0))
        continue
     end
    
    %i,frames,size(arrN)
    arrN(i,frames)=0;
    arrI(i,frames)=0;
    
    cc=1;
    for j=frames
        
        nucleus=segmentation.nucleus(j,:);
        cells1= segmentation.tcells1(i).Obj(cc);
        
        xc=cells1.x;
        yc=cells1.y;
        
        if numel(xc)==0
            continue
        end
        
        n=[]; score=[]; index=[];
        
        for k=1:length(nucleus)
            xn=nucleus(k).x;
            yn=nucleus(k).y;
            
            
            scorek=mean(inpolygon(xn,yn,xc,yc));
            
            if scorek>0.2 % nucleus is partly inside the cell
                n=[n nucleus(k).n];
                index=[index k];
                score=[score scorek];
            end 
        end
        if numel(n)
           
        [score pix]=sort(score,'descend'); % sort nuclei according to fraction of contour found in cell
        n=n(pix);
        index=index(pix);
        arrN(i,j)=n(1);
        arrI(i,j)=index(1);
        end
        cc=cc+1;
    end
end

segmentation.link=[];
segmentation.link.arrN=arrN;
segmentation.link.arrI=arrI;
fprintf('\n');