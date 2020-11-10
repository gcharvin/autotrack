function value=at_name(varargin)
% return variable name or stat index in stat file

out={};
cc=0;
cc=cc+1; out{cc}='checksum';
cc=cc+1; out{cc}='pos';
cc=cc+1; out{cc}='id';
cc=cc+1; out{cc}='division';
cc=cc+1; out{cc}='mother';
cc=cc+1; out{cc}='outlier';
    
cc=cc+1; out{cc}='detect';
cc=cc+1; out{cc}='fitstart';
cc=cc+1; out{cc}='cyclestart';
    
cc=cc+1; out{cc}='tdiv';
cc=cc+1; out{cc}='tg1';
cc=cc+1; out{cc}='ts';
cc=cc+1; out{cc}='tg2';
cc=cc+1; out{cc}='tana';
    
cc=cc+1; out(cc:cc+99)={'fluo'};
cc=cc+100; out(cc:cc+99)={'fitfluo'};
    

cc=cc+100; out{cc}='tbud';

% cell (excluding bud)
cc=cc+1; out{cc}='vdiv';
cc=cc+1; out{cc}='vg1';
cc=cc+1; out{cc}='vs';
cc=cc+1; out{cc}='vg2';
cc=cc+1; out{cc}='vana';
    
cc=cc+1; out{cc}='vbdiv';
cc=cc+1; out{cc}='vbg1';
cc=cc+1; out{cc}='vbs';
cc=cc+1; out{cc}='vbg2';
cc=cc+1; out{cc}='vbana';

cc=cc+1; out{cc}='vndiv';
cc=cc+1; out{cc}='vng1';
cc=cc+1; out{cc}='vns';
cc=cc+1; out{cc}='vng2';
cc=cc+1; out{cc}='vnana';
    
cc=cc+1; out(cc:cc+99)={'volcell'};
cc=cc+100; out(cc:cc+99)={'volbud'};
cc=cc+100; out(cc:cc+99)={'volnuc'};

cc=cc+100; out{cc}='mub';
cc=cc+1; out{cc}='mb';
cc=cc+1; out{cc}='asy';

% cell volume including bud
cc=cc+1; out{cc}='vcdiv';
cc=cc+1; out{cc}='vcg1';
cc=cc+1; out{cc}='vcs';
cc=cc+1; out{cc}='vcg2';
cc=cc+1; out{cc}='vcana';

% variation of volume during cell cycle

cc=cc+1; out{cc}='dvdiv';
cc=cc+1; out{cc}='dvg1';
cc=cc+1; out{cc}='dvs';
cc=cc+1; out{cc}='dvg2';
cc=cc+1; out{cc}='dvana';

cc=cc+1; out{cc}='strainID';  

if strcmp(class(varargin{1}),'char')
value = getMapValue(varargin,out);
else
value=out(varargin{1});
end




function value = getMapValue(map,out)
value = [];

for i = 1:1:numel(map)
    for j=1:numel(out)
    if strcmp(map{i}, out{j})
        value = [value j];
    end
    end
end
