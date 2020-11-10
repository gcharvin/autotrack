function str=at_checksum(val)
% convert checksum value to project string to load


pth=mfilename('fullpath');

[pth fil]=fileparts(pth);

load([pth '/checksum.mat']);

pix=find(chk==val);

str={};
cc=1;
for i=pix
    
    str{cc}=nam{i};
    cc=cc+1;
end

