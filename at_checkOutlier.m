function [out str]=at_checkOutlier(stats,a,mother)
global timeLapse

out=0;

if nargin==2
mother=stats(a,5);
end
%chi2=stats(a,533);


cc=15;
        y=stats(a,cc:cc+100-1); pix2=y>0; y=y(pix2);
        yfit=stats(a,cc+100:cc+200-1); yfit=yfit(pix2);
        chi2=sum( (yfit-y).^2 ) / length(y);

if mother==0
    coef=1.5;
else
    coef=1;
end

%a
str=[];
if stats(a,10)< timeLapse.autotrack.timing.tdiv(1) || stats(a,10) > timeLapse.autotrack.timing.tdiv(2) out=1; %'ok1',b=stats(a,10)
    str=['tdiv=' num2str(stats(a,10))];
end
if stats(a,11)< coef*timeLapse.autotrack.timing.tg1(1) || stats(a,11) > coef*timeLapse.autotrack.timing.tg1(2) out=1; %'ok2',b=stats(a,11)
    str=['tg1=' num2str(stats(a,11))];
end
if stats(a,12)< timeLapse.autotrack.timing.ts(1) || stats(a,12) > timeLapse.autotrack.timing.ts(2) out=1; %'ok3',b=stats(a,12)
    str=['ts=' num2str(stats(a,12))];
end
if stats(a,13)< timeLapse.autotrack.timing.tg2(1) || stats(a,13) > timeLapse.autotrack.timing.tg2(2) out=1; %'ok4',b=stats(a,13)
   str=['tg2=' num2str(stats(a,13))];
end
if stats(a,14)< timeLapse.autotrack.timing.tana(1) || stats(a,14) > timeLapse.autotrack.timing.tana(2) out=1; %'ok5',b=stats(a,14)
    str=['tana=' num2str(stats(a,14))];
end
if chi2> timeLapse.autotrack.timing.chi out=1; %chi2
    str=['chi2=' num2str(chi2)];
end