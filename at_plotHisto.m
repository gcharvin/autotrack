function at_plotHisto()
% plot histogram for a given stat file

global datastat


p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;
ind=9;

% construct histograms

figure; 

M=find(stats(:,5)==1 & stats(:,6)==0);
D=find(stats(:,5)==0 & stats(:,6)==0);

T_D=stats(D,ind+1);
T_M=stats(M,ind+1);
G1_D=stats(D,ind+2);
G1_M=stats(M,ind+2);
S_D=stats(D,ind+3);
S_M=stats(M,ind+3);
G2_D=stats(D,ind+4);
G2_M=stats(M,ind+4);
A_D=stats(D,ind+5);
A_M=stats(M,ind+5);

sca=3;


subplot(1,5,1); plotHisto(T_D,T_M,sca,'Events #')
subplot(1,5,2); plotHisto(G1_D,G1_M,sca)
subplot(1,5,3); plotHisto(S_D,S_M,sca)
subplot(1,5,4); plotHisto(G2_D,G2_M,sca)
subplot(1,5,5); plotHisto(A_D,A_M,sca)


N_D=length(T_D)
N_M=length(T_M)


set(gcf,'Position',[100 100 1500 400],'Color','w');
pause(0.1);
refresh


function plotHisto(A,B,sca,option)

if nargin==4
[t n x]=nhist({sca*A,sca*B},'noerror','xlabel','Time (min)','ylabel',option,'fsize',20,'binfactor',1,'minx',0,'samebins','numbers');
else
[t n x]=nhist({sca*A,sca*B},'noerror','xlabel','Time (min)','ylabel','','fsize',20,'binfactor',1,'minx',0,'samebins','numbers');   
end

text(mean(sca*A+1),max(n{1}),'D','Color',[0.3 0. 1],'FontSize',20);
text(mean(sca*B+1),max(n{2}),'M','Color',[1 0. 0.3],'FontSize',20);


pval=testSignificance(A,B)
if pval~=0
    
    sigstar({sca*round([min(median(A),median(B)) max(median(A), median(B))+2])},[pval]); 
    
    eff=(mean(A)-mean(B))./mean(B);
    title({['M=' num2str(round(mean(sca*B))) ' min'],['D=' num2str(round(mean(sca*A))) 'min'],['\Delta=' num2str(round(100*eff)) '%']});
else
    title({['M=' num2str(round(mean(sca*B))) ' min'],['D=' num2str(round(mean(sca*A))) 'min']});
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


