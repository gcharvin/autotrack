function [fr arr arr2]=at_testNucleusFluo(nucleusindex,frames,channel,display)
% check that sigma gaussian increase linsearly with time == size of nucleus
% whereas gaussian height is related to histone content
% however, since nucleus moves in 3D, it is better to integrate sigma since
% the total energy in the gaussian may be constant whatever the focus point
% is

global segmentation


arr=[]; fr=[]; arr2=[]; bac=[];
  
tnucleus=segmentation.tnucleus(nucleusindex);
tfra=[tnucleus.Obj.image];

[fra ia ib]=intersect(frames,tfra);

 
if display
 hdisplay=figure;
end

tic; 
for i=1:length(ib)
   
   
    obfra=ib(i);
    fra=frames(ia(i));
    
 nucleus=tnucleus.Obj(obfra);
 img=phy_loadTimeLapseImage(segmentation.position,fra,channel,'non retreat'); % channel 


[fluo area bckgrd]=at_measureNucleusFluo(nucleus,img,2);

arr=[arr fluo];
bac=[bac bckgrd];
arr2=[arr2 nucleus.area*nucleus.fluoMean(2)];
fr=[fr fra];



% if display
%     
% subplot(1,3,3); plot(fr,arr/1000,'Color','b','LineWidth',2,'Marker','o');
% xlim([frames(1) frames(end)+1]);
% ylim([0 200]);
% set(gca,'FontSize',20);
% xlabel('Time (frames)');
% ylabel('Total fluo (A.U)')
% %pause(0.3);
% 
% % image export
% % strname=num2str(i);
% % 
% %         while numel(strname)<6
% %         strname=['0' strname];
% %         end
% %     
% %         f=exist('movietemp');
% %         if f~=7
% %            mkdir('movietemp'); 
% %         end
% %         
% %         str=['movietemp/frame-' strname '.png'];
% %     
% %         myExportFig(str);
% 
% %clf(hdisplay);
% end

%close;
end

toc
% movie export
% if display
% 
% framerate=10;
% encoder='mjpeg'; % mpeg4
% 
% ax=get(hdisplay,'Position');
% %ax(3)=1600;
% %ax(4)=500;
% %close
% 
% eval(['!/usr/local/bin/mencoder "mf://movietemp/*.png" -mf fps=' num2str(framerate) ' -o test.avi  -ovc lavc -lavcopts vcodec=' encoder ' -oac copy -vf scale=' num2str(round(ax(3))) ':' num2str(round(ax(4)))]); 
% end

figure, plot(fr,arr); figure; plot(fr, arr2,'Color','r'); figure, plot(fr,bac,'Color','g');