function [out str]=at_checkOutlier(stats,a,mother,outlier)
% check is cell cycle event is an outlier

global timeLapse

out=0;

if numel(mother)==0
    mother=stats(a,5);
end
%chi2=stats(a,533);

if nargin==4
    tdiv=outlier.tdiv;
    tg1=outlier.tg1;
    ts=outlier.ts;
    tg2=outlier.tg2;
    tana=outlier.tana;
    chi=outlier.chi;
else
    tdiv=timeLapse.autotrack.timing.tdiv;
    tg1=timeLapse.autotrack.timing.tg1;
    ts=timeLapse.autotrack.timing.ts;
    tg2=timeLapse.autotrack.timing.tg2;
    tana=timeLapse.autotrack.timing.tana;
    chi=timeLapse.autotrack.timing.chi;
end


cc=15;
y=stats(a,cc:cc+100-1); pix2=y>0; y=y(pix2);
yfit=stats(a,cc+100:cc+200-1); yfit=yfit(pix2);
chi2=sum( (yfit-y).^2 ) / length(y);
chi2=chi2/max(y).^2;

if mother==0
    coef=1.5;
else
    coef=1;
end

% parameters in the set param timings functions
str=[];

if stats(a,10)< tdiv(1) || stats(a,10) > tdiv(2) out=1; %'ok1',b=stats(a,10)
    str=[str '-tdiv=' num2str(stats(a,10))];
end
if stats(a,11)< coef*tg1(1) || stats(a,11) > coef*tg1(2) out=1; %'ok2',b=stats(a,11)
    str=[str '-tg1=' num2str(stats(a,11))];
end
if stats(a,12)< ts(1) || stats(a,12) > ts(2) out=1; %'ok3',b=stats(a,12)
    str=[str '-ts=' num2str(stats(a,12))];
end
if stats(a,13)< tg2(1) || stats(a,13) > tg2(2) out=1; %'ok4',b=stats(a,13)
    str=[str '-tg2=' num2str(stats(a,13))];
end
if stats(a,14)< tana(1) || stats(a,14) > tana(2) out=1; %'ok5',b=stats(a,14)
    str=[str '-tana=' num2str(stats(a,14))];
end
if chi2> chi out=1; %chi2
    str=[str '-chi2=' num2str(chi2)];
end

% other constraints

%if stats(a,215)<= 0 out=1; %'ok1',b=stats(a,10)
%    str=[str '-tbud=' num2str(stats(a,215))];
%end

if stats(a,216)<= 0 out=1; %'ok1',b=stats(a,10)
    str=[str '-VCellDiv=' num2str(stats(a,216))];
end

if stats(a,217)<= 0 out=1; %'ok1',b=stats(a,10)
    str=[str '-VCellG1=' num2str(stats(a,217))];
end

if stats(a,218)<= 0 out=1; %'ok1',b=stats(a,10)
    str=[str '-VCellS=' num2str(stats(a,218))];
end

if stats(a,219)<= 0 out=1; %'ok1',b=stats(a,10)
    str=[str '-VCellG2=' num2str(stats(a,219))];
end

if stats(a,220)<= 0 out=1; %'ok1',b=stats(a,10)
    str=[str '-VCellA=' num2str(stats(a,220))];
end

%if stats(a,211)<= 0 out=1; %'ok1',b=stats(a,10)
%    str=[str '-V_Bud_Div=' num2str(stats(a,221))];
%end

%if stats(a,222)<= 0 out=1; %'ok1',b=stats(a,10)
%    str=[str '-V_Bud_G1=' num2str(stats(a,222))];
%end

%if stats(a,223)<= 0 out=1; %'ok1',b=stats(a,10)
%    str=[str '-VBudS=' num2str(stats(a,223))];
%end

if stats(a,224)<= 0 out=1; %'ok1',b=stats(a,10)
    str=[str '-VBudG2=' num2str(stats(a,224))];
end

if stats(a,225)<= 0 out=1; %'ok1',b=stats(a,10)
    str=[str '-VBudA=' num2str(stats(a,225))];
end

%if stats(a,531)<= 0 out=1; %'ok1',b=stats(a,10)
%    str=[str '-muunbud=' num2str(stats(a,531))];
%end

if stats(a,532)<= 0 out=1; %'ok1',b=stats(a,10)
    str=[str '-mubud=' num2str(stats(a,532))];
end
