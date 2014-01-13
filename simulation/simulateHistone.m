function simulateHistone(mattime,initnonmat,initmat)
% simulate histone synthesis (mattime is in minutes)


param=[];

param.kprod=1;
param.kmature=log(2)/mattime; % minute timescale
param.divtime=87; % minutes
param.sphase=30; % min
param.sphasestart=22; % min

dt=0.1;
nsteps=3*param.divtime/dt;

prod=zeros(1,param.divtime/dt);
prod(1:param.sphasestart/dt-1)=0;
prod(param.sphasestart/dt:(param.sphasestart+param.sphase)/dt-1)=1;
prod((param.sphasestart+param.sphase)/dt:param.divtime/dt)=0;

prod=repmat(prod,[1 3]); % to fix
prod=prod(1:nsteps);

time=0:dt:dt*(nsteps-1);



A=zeros(1,nsteps); % unmatured p
B=zeros(1,nsteps); % matured p

A(1)=initmat;
B(1)=initnonmat;

%return;

 for i=2:nsteps

     k1=fprime(A(i-1),B(i-1),prod(i-1),param);
     k2=fprime(A(i-1)+dt/2*k1(1),B(i-1)+dt/2*k1(2),prod(i-1),param);
     k3=fprime(A(i-1)+dt/2*k2(1),B(i-1)+dt/2*k2(2),prod(i-1),param);
     k4=fprime(A(i-1)+dt*k3(1)  ,B(i-1)+dt*k3(2) ,prod(i-1),param);
     
     d=dt*(k1/6+k2/3+k3/3+k4/6);
    
    A(i)=A(i-1)+d(1);
    B(i)=B(i-1)+d(2);

    if mod(i*dt,param.divtime)==0
A(i)=A(i)/2;
B(i)=B(i)/2;
    end

     
 end
 
 
 figure; %subplot(2,1,1);
plot(time,prod,'LineWidth',2); hold on;

line([param.divtime param.divtime],[0 300],'Color','k','LineStyle','--');
line([2*param.divtime 2*param.divtime],[0 300],'Color','k','LineStyle','--');
line([3*param.divtime 3*param.divtime],[0 300],'Color','k','LineStyle','--');

set(gca,'FontSize',20);
ylim([-0.1 1.1]);
set(gcf,'Color','w','Position',[100 100 800 200]);
xlabel('Time (min)');
ylabel('Synth. rate');

 figure; %subplot(2,1,2);
 plot(time,A,'Color','k'); hold on; plot(time,B,'Color','r','LineWidth',2);
 str(1,:)='HTB2 ';
 str(2,:)='HTB2*';
 set(gca,'FontSize',20);
 
 line([param.divtime param.divtime],[0 300],'Color','k','LineStyle','--');
line([2*param.divtime 2*param.divtime],[0 300],'Color','k','LineStyle','--');
line([3*param.divtime 3*param.divtime],[0 300],'Color','k','LineStyle','--');

%ylim([-0.1 1.1]);
set(gcf,'Color','w','Position',[100 100 800 250]);
xlabel('Time (min)');
ylabel('Histone content');

ylim([0 60]);

 legend(str);
 %set(gca,'YScale','log');
 
 
 function out=fprime(A,B,prod,param)
     
     da= param.kprod*prod - param.kmature*A;

     db= param.kmature*A;

     out=[da; db];
     