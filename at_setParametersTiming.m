function at_setParametersTiming()
global timeLapse datastat

% default parameters values

tdiv=[15 80];
tg1=[3 25];
ts=[3 20];
tg2=[3 25];
tana=[2 10];
chi=1e8;

if ~isfield(timeLapse.autotrack,'timing')
    timeLapse.autotrack.timing=[];
end


if isfield(timeLapse.autotrack.timing,'tdiv')
    tdiv=timeLapse.autotrack.timing.tdiv;
    tg1=timeLapse.autotrack.timing.tg1;
    ts=timeLapse.autotrack.timing.ts;
    tg2=timeLapse.autotrack.timing.tg2;
    tana=timeLapse.autotrack.timing.tana;
    chi=timeLapse.autotrack.timing.chi;
else
    timeLapse.autotrack.timing.tdiv=tdiv;
    timeLapse.autotrack.timing.tg1=tg1;
    timeLapse.autotrack.timing.ts=ts;
    timeLapse.autotrack.timing.tg2=tg2;
    timeLapse.autotrack.timing.tana=tana;
    timeLapse.autotrack.timing.chi=chi;
end

defaultanswer={num2str(tdiv),num2str(tg1),num2str(ts),num2str(tg2),num2str(tana),num2str(chi)};

prompt={'Min/Max Tdiv (frames)',...
    'Min/Max TG1 (frames)',...
    'Min/Max TS (frames)',...
    'Min/Max TG2 (frames)',...
    'Min/Max Tana (frames)',...
    'Max Chi2'};

name='Timing Par.';
numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
if numel(answer)==0 return; end


timeLapse.autotrack.timing.tdiv=str2num(answer{1});
timeLapse.autotrack.timing.tg1=str2num(answer{2});
timeLapse.autotrack.timing.ts=str2num(answer{3});
timeLapse.autotrack.timing.tg2=str2num(answer{4});
timeLapse.autotrack.timing.tana=str2num(answer{5});
timeLapse.autotrack.timing.chi=str2num(answer{6});


% adjust outlier based on timing

if numel(datastat)==0
    return;
end

coef=1;

for i=1:numel(datastat)
stats=datastat(i).stats;


pix=find( stats(:,10) >= timeLapse.autotrack.timing.tdiv(1) ...
        & stats(:,10) <= timeLapse.autotrack.timing.tdiv(2) ...
        & stats(:,11) >= coef*timeLapse.autotrack.timing.tg1(1) ...
        & stats(:,11) <= coef*timeLapse.autotrack.timing.tg1(2) ...
        & stats(:,12) >= timeLapse.autotrack.timing.ts(1) ...
        & stats(:,12) <= timeLapse.autotrack.timing.ts(2) ...
        & stats(:,13) >= timeLapse.autotrack.timing.tg2(1) ...
        & stats(:,13) <= timeLapse.autotrack.timing.tg2(2) ...
        & stats(:,14) >= timeLapse.autotrack.timing.tana(1) ...
        & stats(:,14) <= timeLapse.autotrack.timing.tana(2) );
    
    stats(:,6)=1;
    
    cc=15; pax=[];
    for j=1:length(pix)
        y=stats(j,cc:cc+100-1); y=y(y>0);
        yfit=stats(j,cc+100:cc+200-1); yfit=yfit(yfit>0);
        chi2=sum( (yfit-y).^2 ) / length(y);
        
        
        if chi2<= timeLapse.autotrack.timing.chi
        pax=[pax pix(j)];
        end
    end
   % pax
    stats(pax,6)=0;
    
    
    datastat(i).stats=stats;
end

%global at_displayHandles

%at_updateDisplay(at_displayHandles);


%if chi2> timeLapse.autotrack.timing.chi out=1; %chi2
%end

%chi2=sum( (y2-y).^2 ) / length(y);