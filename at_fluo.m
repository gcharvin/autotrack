function at_fluo(pos)
global segmentation

% computes fluo values within cells for pos

answer{1}='10';
answer{2}='10';

% compute fluo levels for cells and budnecks

object='cells1';


if nargin==0
    pos=0;
end

for k=pos
    
    if pos~=0
    at_openSeg(k);
    end
    
    segmentedFrames=find(segmentation.([object 'Segmented']));%all segemented frames
cells1=segmentation.(object);

disp(['Measure Fluorescence for pos:' num2str(segmentation.position) '.... Be patient !\n']);

c=0;
phy_progressbar;


%h=figure;

%for all segmented images do the analyse
for i=segmentedFrames
    
    % for i=117
    
    c=c+1;
    phy_progressbar(c/length(segmentedFrames));
    
    for l=1:size(segmentation.colorData,1)
        
        %read and scale the fluorescence image from appropriate channel
        
        if segmentation.discardImage(i)==0 % frame is good
            segmentation.frameToDisplay=i;
        else
            temp=segmentation.discardImage(1:i); % frame is discarded by user ; display previous frame
            segmentation.frameToDisplay=max(find(temp==0));
        end
        
        
        
        
        
        
        img=phy_loadTimeLapseImage(segmentation.position,segmentation.frameToDisplay,l,'non retreat');
        warning off all;
        img=imresize(img,segmentation.sizeImageMax);
        warning on all;
        
        imgarr(:,:,l)=img;
    end
    
    %create masks and get readouts
    masktotal=zeros(segmentation.sizeImageMax(1),segmentation.sizeImageMax(2));
    maskcyto=masktotal;
    %xtot=[];
    %ytot=[];
    
    for j=1:length(cells1(i,:))
        if cells1(i,j).n~=0 && ~isempty(cells1(i,j).x)
            mask = poly2mask(cells1(i,j).x,cells1(i,j).y,segmentation.sizeImageMax(1),segmentation.sizeImageMax(2));
            masktotal(mask)=1;
            
           % size(cells1(i,j).x)
            %xtot=[xtot cells1(i,j).x];
            %ytot=[ytot cells1(i,j).y];
        end
    end
    % figure, imshow(masktotal,[]);
%    khull = convhull(xtot,ytot);
 %   maskcyto = poly2mask(xtot(khull),ytot(khull),segmentation.sizeImageMax(1),segmentation.sizeImageMax(2));
%    maskcyto=imdilate(maskcyto,strel('disk',50));
%    maskcyto(masktotal==1)=0;
    
    %figure, imshow(maskcyto,[]);
    %return;
    
    
    for j=1:length(cells1(i,:))
        if cells1(i,j).n~=0 && ~isempty(cells1(i,j).x)
            mask = poly2mask(cells1(i,j).x,cells1(i,j).y,segmentation.sizeImageMax(1),segmentation.sizeImageMax(2));
            budmask=[];
            %             if length(cells1(i,j).budneck)~=0
            %                 budmask=zeros(segmentation.sizeImageMax(1),segmentation.sizeImageMax(2));
            %                 budmasksum=budmask;
            %             end
            cells1(i,j).fluoMean=[];
            cells1(i,j).fluoVar=[];
            cells1(i,j).fluoNuclMean=[];
            cells1(i,j).fluoCytoMean=[];
            
            for l=1:size(segmentation.colorData,1)
                % l
                     
                img=imgarr(:,:,l);
                valpix=img(mask);
%                valcyto=img(maskcyto);
                
                %if l==2
                %i,j
                %mean(valcyto)
                %mean(valpix)
                % end
                
                cells1(i,j).fluoMean(l)=mean(valpix);%-mean(valcyto);
                %  a=cells1(i,j).fluoMean(l)
                cells1(i,j).fluoVar(l)=var(double(valpix));%-mean(valcyto));
                
                [sorted idx]=sort(valpix,'descend');
                
                
                minpix=min(str2num(answer{1}),length(sorted));
                maxpix=min(str2num(answer{2}),length(sorted));
                %                 %length(sorted)
                if numel(sorted)~=0
                    cells1(i,j).fluoMin(l)=mean(sorted(end-minpix:end));%-mean(valcyto);
                    cells1(i,j).fluoMax(l)=mean(sorted(1:maxpix));%-mean(valcyto);
                else
                    cells1(i,j).fluoMin(l)=0;
                    cells1(i,j).fluoMax(l)=0;
                end
                %sorted
                %return;
                
                
                %    i,j  ,a=  cells1(i,j).budneck
                %                 if cells1(i,j).budneck~=0
                %                     for kl=1:length(cells1(i,j).budneck)
                %
                %
                %                         ind=cells1(i,j).budneck(kl);
                %                         fr=i-(budnecks(ind).Obj(1).image-1);
                %
                %                         if fr<=0 || fr>length(budnecks(ind).Obj)
                %                             continue
                %                         end
                %
                %                    %     budmask=poly2mask(budnecks(ind).Obj(fr).x,budnecks(ind).Obj(fr).y,segmentation.sizeImageMax(1),segmentation.sizeImageMax(2));
                %                    %     budmasksum= budmask | budmasksum;
                %
                %                     %    budnecks(ind).Obj(fr).fluoMean(l)=mean(img(budmasksum));
                %                     %    budnecks(ind).Obj(fr).fluoVar(l)=var(double(img(budmasksum)));
                %                     %    budnecks(ind).Obj(fr).fluoMin(l)=0;
                %                     %    budnecks(ind).Obj(fr).fluoMax(l)=0;
                %
                %                     %    cells1(i,j).fluoNuclMean(l)=mean(img(budmasksum));
                %                     %    cells1(i,j).fluoNuclVar(l)=var(double(img(budmasksum)));
                %                         cells1(i,j).fluoNuclMin(l)=0;
                %                         cells1(i,j).fluoNuclMax(l)=0;
                %
                %
                %                     end
                %
                %
                %
                %                     cytomask= budmask | mask;
                %                     pix= find(budmask);
                %
                %                     cytomask(pix)=0;
                %
                %                     % if j==4
                %                     % figure(h); imshow(cytomask,[0 1]); title(['frame' num2str(i) 'cell' num2str(j) ]);
                %                     %return;
                %                     % end
                %
                %                     cells1(i,j).fluoCytoMean(l)=mean(img(cytomask));
                %                     cells1(i,j).fluoCytoVar(l)=var(double(img(cytomask)));
                %                     cells1(i,j).fluoCytoMin(l)=0;
                %                     cells1(i,j).fluoCytoMax(l)=0;
                %                 else
                
                cells1(i,j).fluoNuclMean(l)=cells1(i,j).fluoMean(l);
                cells1(i,j).fluoNuclVar(l)=cells1(i,j).fluoVar(l);
                cells1(i,j).fluoNuclMin(l)=0;
                cells1(i,j).fluoNuclMax(l)=0;
                
                
                cells1(i,j).fluoCytoMean(l)=cells1(i,j).fluoMean(l);
                cells1(i,j).fluoCytoVar(l)=cells1(i,j).fluoVar(l);
                cells1(i,j).fluoCytoMin(l)=0;
                cells1(i,j).fluoCytoMax(l)=0;
                
                %end
                % in case nuclei are scored separately, this allows to quantify
                %    fluoCytoMean=0;
                %    fluoCytoVar=0;
                %    fluoCytoMin=0;
                %    fluoCytoMax=0;
                
            end
        end
    end
end
at_save;
end




