function at_plotHistoCompare(stats1,stats2)
% plot histogram for a given stat file


ind=9;

% construct histograms

figure; 

M1=find(stats1(:,5)==1 & stats1(:,6)==0);
D1=find(stats1(:,5)==0 & stats1(:,6)==0);

M2=find(stats2(:,5)==1 & stats2(:,6)==0);
D2=find(stats2(:,5)==0 & stats2(:,6)==0);


T_D1=stats1(D1,ind+1);
T_M1=stats1(M1,ind+1);
G1_D1=stats1(D1,ind+2);
G1_M1=stats1(M1,ind+2);
S_D1=stats1(D1,ind+3);
S_M1=stats1(M1,ind+3);
G2_D1=stats1(D1,ind+4);
G2_M1=stats1(M1,ind+4);
A_D1=stats1(D1,ind+5);
A_M1=stats1(M1,ind+5);

T_D2=stats2(D2,ind+1);
T_M2=stats2(M2,ind+1);
G1_D2=stats2(D2,ind+2);
G1_M2=stats2(M2,ind+2);
S_D2=stats2(D2,ind+3);
S_M2=stats2(M2,ind+3);
G2_D2=stats2(D2,ind+4);
G2_M2=stats2(M2,ind+4);
A_D2=stats2(D2,ind+5);
A_M2=stats2(M2,ind+5);

sca=3;

subplot(2,5,1); plotHisto(T_D2,T_D1,sca,'Daughter Events #')
subplot(2,5,2); plotHisto(G1_D2,G1_D1,sca)
subplot(2,5,3); plotHisto(S_D2,S_D1,sca)
subplot(2,5,4); plotHisto(G2_D2,G2_D1,sca)
subplot(2,5,5); plotHisto(A_D2,A_D1,sca)

subplot(2,5,6); plotHisto(T_M2,T_M1,sca,'Mother Events #')
subplot(2,5,7); plotHisto(G1_M2,G1_M1,sca)
subplot(2,5,8); plotHisto(S_M2,S_M1,sca)
subplot(2,5,9); plotHisto(G2_M2,G2_M1,sca)
subplot(2,5,10); plotHisto(A_M2,A_M1,sca)


N_D1=length(T_D1)
N_M1=length(T_M1)
N_D2=length(T_D2)
N_M2=length(T_M2)


set(gcf,'Position',[100 100 1500 400],'Color','w');
pause(0.1);
refresh


function plotHisto(A,B,sca,option)

if nargin==4
[t n x]=nhist({sca*A,sca*B},'noerror','xlabel','Time (min)','ylabel',option,'fsize',20,'binfactor',1,'minx',0,'samebins','numbers');
else
[t n x]=nhist({sca*A,sca*B},'noerror','xlabel','Time (min)','ylabel','','fsize',20,'binfactor',1,'minx',0,'samebins','numbers');   
end

%text(mean(sca*A+1),max(n{1}),'WT','Color',[0.3 0. 1],'FontSize',20);
%text(mean(sca*B+1),max(n{2}),'whi5','Color',[1 0. 0.3],'FontSize',20);


pval=testSignificance(A,B)
if pval~=0
    
    sigstar({sca*round([min(median(A),median(B)) max(median(A), median(B))+2])},[pval]); 
    
    eff=(mean(A)-mean(B))./mean(B);
    title({['WT: ' num2str(round(mean(sca*B))) ' min'],['whi5:' num2str(round(mean(sca*A))) 'min'],['\Delta=' num2str(round(100*eff)) '%']});
else
    title({['WT: ' num2str(round(mean(sca*B))) ' min'],['whi5: ' num2str(round(mean(sca*A))) 'min']});
end




function pval=testSignificance(A,B)

val1=0.05; val2=0.01; val3=0.001;
h1 = kstest2(A,B,0.05);
h2 = kstest2(A,B,0.01);
h3 = kstest2(A,B,0.001);

%p = ranksum(A,B) % wilcoxon ranksum test

pval=0;

if h1
    pval=val1;
    if h2
        pval=val2;
        if h3
            pval=val3;
        end
    end
end


