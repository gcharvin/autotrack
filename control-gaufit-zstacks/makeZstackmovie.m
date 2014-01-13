
%% add path for movie 

    javaaddpath('/Users/charvin/Documents/MATLAB/mysoft/philoCell/phyloCellv2.2/addon/ag/javitools.jar');

%% openproject path: 

global segmentation timeLapse

pat='/Users/charvin/Documents/Work/Data/movies/z-stack-nucleus-11-2013/z-stack_HTB2-GFP-pos1/z-stack_HTB2-GFP-pos1-ch1--/phyloCellTempFolder/';
at_load('/Users/charvin/Documents/Work/Data/movies/z-stack-nucleus-11-2013/z-stack_HTB2-GFP-pos1/z-stack_HTB2-GFP-pos1-ch1--/phyloCellTempFolder/tempProject1-project.mat');
at_openSeg(1);

cd(pat);


%% plot average fluo decay with z
global segmentation 

avg=zeros(length(segmentation.tnucleus),60);

cc=1;
for i=1:length(segmentation.tnucleus)
    n=length(segmentation.tnucleus(i).Obj);
    
    c=[segmentation.tnucleus(i).Obj.Mean]; % gaussian fit
    a=[segmentation.tnucleus(i).Obj.fluoMean];
    b=[segmentation.tnucleus(i).Obj.area];
    a=a.*b;
    
    %a=c;
    
    if length(a)<15
        continue
    end
    
    [pix ix]=max(a);
    
    avg(i,31-ix:31-ix+length(a)-1)=a'./a(ix);
    cc=cc+1;
    
end


cc

outm=zeros(1,60);
outd=zeros(1,60);

for i=1:60
    pix=find(avg(:,i)~=0);
    
    test=avg(pix,i);
    
   outm(i)=mean(test);
   outd(i)=std(test)/sqrt(length(test));
end

figure, errorbar(1:60,outm,outd);



%% create movie

contours=[];
contours.object='nucleus';
contours.color=[1 0 0];
contours.lineWidth=1;
contours.link=0;
contours.incells=[];
contours.channelGroup=[1];

timeLapse.list(1).setLowLevel=600;
timeLapse.list(1).setHighLevel=4000;

exportMontage('', 'tempProject1', 1, {'1 0 0 0'}, [], 0, segmentation, 'contours',contours)


%% load control movie (no z displacement)

global segmentation timeLapse

pat='/Users/charvin/Documents/Work/Data/movies/z-stack-nucleus-11-2013/control_analysis/';
at_load('/Users/charvin/Documents/Work/Data/movies/z-stack-nucleus-11-2013/control_analysis/1_plane-project.mat');

timeLapse.list(1).setLowLevel=600;
timeLapse.list(1).setHighLevel=4000;

at_openSeg(1);

cd(pat);

%% analysis fluo in control movie

at_setParameters
at_batch(1:30,1,'nucleus','mapnucleus','gaufit','display')

%% plot average fluo decay
global segmentation 

avg=zeros(length(segmentation.tnucleus),30);


for i=1:length(segmentation.tnucleus)
    n=length(segmentation.tnucleus(i).Obj);
    avg(i,1:n)=[segmentation.tnucleus(i).Obj.Mean]';
end

outm=zeros(1,30);
outd=zeros(1,30);

for i=1:30
    pix=find(avg(:,i)~=0);
    
    test=avg(pix,i);
    
   outm(i)=mean(test);
   outd(i)=std(test)/sqrt(length(test));
end

figure, errorbar(1:30,outm,outd);


