function at_mapCellsNucleus(arrN,arrI,channel)
global segmentation timeLapse

% arg : array that links nucleus and cells from at_linkCellNucleus

arr=-1*ones(length(segmentation.tcells1),timeLapse.numberOfFrames); % nuclei index in tcells object




for i=1:length(segmentation.tcells1)
    fprintf('.');
    frames=[segmentation.tcells1(i).Obj.image];
    
    cc=1;
    
    info=[];
    info.n=0;
    info.i=0;
    
    
    link=[];
    link.n=[];
    link.frame=[];
    link.i=[];
    
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

            if numel(ic)
                link.frame=[link.frame ; j];
                link.n=[link.n ; ic];
                link.i=[link.i ; arrN(ic,j)];
            end

        end
        segmentation.tcells1(i).mothers=link;
        cc=cc+1;
    end
    
    % use fluo values to determine division timings precisely for the cells 
     
    % find neighbor nucleus and guess the mother cell undergoing division
    
    %     % determine if nucleus numbers are shared by other cells
    %     bins=0:1:max(arrN(i,:));
    %     h=hist(arrN(i,:),bins);
    %     h=h(2:end);
    %     pix=h~=0;
    %     h=h(pix) % frequency of nuclei that are present in cell j
    %     bins=bins(2:end);     
    %     bins=bins(pix) % list of nuclei that are present in cell i
    %     n=setdiff(arrN(i,:),[-1 0]);
    %    for k=n
    %    end
    
   
    
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