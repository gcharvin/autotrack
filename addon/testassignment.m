function testassignment(frames,cavity,pdfout,range)
global segmentation

enable=[1 1 1 1]; % sometimes problems with intensities ... to be fixed

%ncav=[segmentation.ROI(frame).ROI.n]
%pix=find(ncav==cavity)
%cav=pix; % find real id for cavity

%fprintf('');
for frame=frames
    fprintf('.');
    
cell0=segmentation.cells1(frame,:);
pix0=find([cell0.Nrpoints]==cavity);

if numel(pix0)==0
  break;    
end

cell0=cell0(pix0);


%ncav=[segmentation.ROI(frame+1).ROI.n];
%pix=find(ncav==cavity);
%cav=pix; % find real id for cavity

cell1=segmentation.cells1(frame+1,:);
pix1=find([cell1.Nrpoints]==cavity);
cell1=cell1(pix1);

ind0=find([cell0.ox]~=0);
ind1=find([cell1.ox]~=0);

%ind0
%%%% thid filter should be removed once integrated in at_batch
ind0r=[]; % filter cells outside of cavity



            
%             % set up filter to filter out cells leaving te cavity
%             if orient==1
%             filterpos = (box(2)+box(4)/5);
%             pix=find(oy>filterpos);
%             else
%             filterpos = (box(2)+4*box(4)/5); 
%             pix=find(oy<filterpos);
%             end


for i=1:length(ind0)
    [x0, y0, area0, intensity0]=offsetCoordinates(cell0(ind0(i)));
    
     if y0>120 % filterpos
         continue
     end
     
     ind0r=[ind0r ind0(i)];
end
ind0=ind0r;
%%%%%%%%%%%

cell0=cell0(ind0);

if numel(pix1)==0
  break;    
end

assignment(cell0,cell1,pdfout,range,enable,-1); %demo mode
end
fprintf('\n');



function [ox oy area intensity]=offsetCoordinates(celltemp)
global segmentation


%fprintf('----------')

ox=    celltemp.ox;
oy=    celltemp.oy;

cavity=celltemp.Nrpoints;

frame= celltemp.image;

ncav=[segmentation.ROI(frame).ROI.n];
pix=find(ncav==cavity);
cavity=pix;

orient=segmentation.ROI(frame).ROI(cavity).orient;
box=segmentation.ROI(frame).ROI(cavity).box;
n=segmentation.ROI(frame).ROI(cavity).n;

cx=box(1)+box(3)/2;
cy=box(2)+box(4)/2;

if orient==0
    oy=oy-cy;
else
    oy=-(oy-cy);
end

ox=ox-cx;

%pause

area=celltemp.area;
intensity=celltemp.fluoMean(1);


