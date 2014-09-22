function test_cavity_alignment


% rough alignment on first frame // default grid

%[x y theta ROI] = at_cavity(1,'range',70,'rotation',1,'npoints',31,'scale',0.2,'display')


% new grid

x=-18.66;
y=65.3;
theta=0.66;

x0=[0  0     1      8      9   9  mean([9 16])  16];
y0=[0 -20   -37   -37     -20   0        1       0 ];% works great
grid=[x0; y0];

xout=[]; yout=[];

for i=1:10

 tic;   
% fine alignement with rotation
%'fine1'
[x y theta ROI] = at_cavity(i,'range',30,'rotation',0.2,'npoints',9, 'init',[x y theta],'scale',0.2);
%'fine2'
% fine alignement without rotation

[x y theta ROI] = at_cavity(i,'range',10,'npoints',15, 'init',[x y theta],'scale',1);%,'grid',grid);

xout=[xout x];
yout=[yout y];

toc;
end

figure, plot(xout);
figure, plot(yout);
