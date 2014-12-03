function at_log(str,writestyle,pos,name)
% write log file for details about segmentation process
%writestyle : 'a' for append, 'w' for new file

global timeLapse segmentation



f=strcat(timeLapse.realPath,'/',timeLapse.pathList.position{pos},name,'-report.txt');


fid= fopen(f,writestyle);
fprintf(fid,'%s\r',str);
fclose(fid); 