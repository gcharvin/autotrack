function at_setParametersTiming(all)
global timeLapse datastat at_displayHandles

%'all' : set this argument to apply the parameters to all items in the
%datastat

% default parameters values

tdiv=[15 100];
tg1=[0 100];
ts=[0 100];
tg2=[0 100];
tana=[2 10];
chi=0.01;

if isfield(timeLapse,'autotrack')
    
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
end

if numel(datastat)
   for i=1:numel(datastat)
       if nargin==0
      if datastat(i).selected==0
          continue
      end
       end
       
      if ~isfield(datastat(i),'outlier') | numel(datastat(i).outlier)==0
          datastat(i).outlier.tdiv=tdiv;
          datastat(i).outlier.tg1=tg1;
          datastat(i).outlier.ts=ts;
          datastat(i).outlier.tg2=tg2;
          datastat(i).outlier.tana=tana;
          datastat(i).outlier.chi=chi;
      else
          tdiv=datastat(i).outlier.tdiv;
          tg1=datastat(i).outlier.tg1;
          ts=datastat(i).outlier.ts;
          tg2=datastat(i).outlier.tg2;
          tana=datastat(i).outlier.tana;
          chi=datastat(i).outlier.chi;
      end
   end
end


if usejava('jvm') && ~feature('ShowFigureWindows')
    % use text-based alternative (input)
    
    answer{1} = input('Timings : Min/Max Tdiv (frames) ', 's');
    answer{2} = input('Timings : Min/Max TG1 (frames) ', 's');
    answer{3} = input('Timings : Min/Max TS (frames) ', 's');
    answer{4} = input('Timings : Min/Max TG2 (frames) ', 's');
    answer{5} = input('Timings : Min/Max Tana (frames)', 's');
    answer{6} = input('Timings : Max Chi2', 's');
    
else
    % use GUI dialogs (questdlg)
    
defaultanswer={num2str(tdiv),num2str(tg1),num2str(ts),num2str(tg2),num2str(tana),num2str(chi)};

prompt={'Min/Max Tdiv (frames)',...
    'Min/Max TG1 (frames)',...
    'Min/Max TS (frames)',...
    'Min/Max TG2 (frames)',...
    'Min/Max Tana (frames)',...
    'Max Chi2'};

name='Timing Par.';
numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
end

if numel(answer)==0 return; end

if isfield(timeLapse,'autotrack')
timeLapse.autotrack.timing.tdiv=str2num(answer{1});
timeLapse.autotrack.timing.tg1=str2num(answer{2});
timeLapse.autotrack.timing.ts=str2num(answer{3});
timeLapse.autotrack.timing.tg2=str2num(answer{4});
timeLapse.autotrack.timing.tana=str2num(answer{5});
timeLapse.autotrack.timing.chi=str2num(answer{6});
end

if numel(datastat)
   for i=1:numel(datastat)
       
       if nargin==0
      if datastat(i).selected==0
          continue
      end   
       end
       
          datastat(i).outlier.tdiv=str2num(answer{1});
          datastat(i).outlier.tg1=str2num(answer{2});
          datastat(i).outlier.ts=str2num(answer{3});
          datastat(i).outlier.tg2=str2num(answer{4});
          datastat(i).outlier.tana=str2num(answer{5});
          datastat(i).outlier.chi=str2num(answer{6});
   end
end

% adjust outlier based on timing

if numel(datastat)==0
    return;
end

for i=1:numel(datastat)
    if nargin==0
    if datastat(i).selected==0
        continue
    end
    end
    
stats=datastat(i).stats;

coef=1;

if numel(stats)==0
    continue
end


for j=1:size(stats,1)
    stats(j,6)=0;
    mother=stats(j,5);
    a=j;
    

[out str]=at_checkOutlier(stats,a,mother,datastat(i).outlier);   
    
if out==1
   stats(j,6)=1;
end

end
    
    datastat(i).stats=stats;
end

if isfield(at_displayHandles,'figure1')
    if ishandle(at_displayHandles.figure1)
at_display
    end
end


%if chi2> timeLapse.autotrack.timing.chi out=1; %chi2
%end

%chi2=sum( (y2-y).^2 ) / length(y);