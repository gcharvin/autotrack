function at_check
% check lost nuclei

% - list nuclei that are not present on last frame
% - list nuclei that leave the field of view that are on the edge
% - list nuclei that have lost frames

% put the result in the log file

global segmentation timeLapse

cSeg1=find(segmentation.nucleusSegmented);
featname='nucleus';

warningDisparitionCells=[];



for i=1:length(segmentation.(['t' featname]))
    if segmentation.(['t' featname])(i).N~=0
        if segmentation.(['t' featname])(i).lastFrame<cSeg1(end)
            warningDisparitionCells=[warningDisparitionCells i];
        end
    end
end


len=zeros(1,length(segmentation.(['t' featname])));
warningDisparitionFrames=zeros(1,length(segmentation.(['t' featname])));

for i=1:length(segmentation.(['t' featname]))
    if segmentation.(['t' featname])(i).N~=0
        len(i)=segmentation.(['t' featname])(i).lastFrame-segmentation.(['t' featname])(i).detectionFrame+1;
        warningDisparitionFrames(i)=segmentation.(['t' featname])(i).lastFrame;
    end
end

if ~isempty(warningDisparitionCells)
    str={['The folowing cells are not present on the last segmented frame(',num2str(cSeg1(end)),'): ']};
    for i=1:length(segmentation.(['t' featname]))
        if len(i)~=0 && any(warningDisparitionCells==i)
            str=[str;[num2str(i),' - frame:',num2str(warningDisparitionFrames(i)),' - length:' ,num2str(len(i))]];
        end
    end
 disp(str);
end

lostCells=[];
str={'The folowing cells have lost frames: '};
for i=1:length(segmentation.(['t' featname]))
    if segmentation.(['t' featname])(i).N~=0
        frames=segmentation.(['t' featname])(i).lostFrames;
        if ~isempty(frames)
            lostCells=[lostCells i];
            str=[str;[num2str(i),'- frames :' ,num2str(frames)]];
        end
    end
end
if ~isempty(lostCells)
    disp(str);
end



if isempty(warningDisparitionCells)&&isempty(lostCells)
    warndlg('Cells are OK','OK');
end

a=unique([warningDisparitionCells lostCells]);

str=[num2str(length(segmentation.tnucleus)) ' nuclei tracked;' num2str(length(a)) ' lost nuclei: Success rate: ' num2str(100* (length(segmentation.tnucleus)-length(a))/length(segmentation.tnucleus)) '%'];
disp(str);


