% DEA Beam Model
% ***************************************************

%%
clear all; close all, clc; 
set(0,'DefaultAxesFontName', 'Ariel');set(0,'DefaultAxesFontSize', 12); set(gcf,'color','w');
%% ***********************************************************************
% Layers in the dielectric elastomer actuator:
% Extract the device parameters from the xlsx input file: 
DeviceParam=xlsread('Input_Data.xlsx','DeviceBaTiO3','C1:C30');
% All geometries are in units of m if not specified:
l_beam=DeviceParam(1);
% Layer 1: Passive Layer
lp= DeviceParam(2);bp=DeviceParam(3);tp=DeviceParam(4);rohp=DeviceParam(5);
% Layer 3: Active dielectric elastomer with BaTiO3 
le=DeviceParam(7);be=DeviceParam(8);te=DeviceParam(9); %ep_r=DeviceParam(10);
rohe= DeviceParam(11);nu=DeviceParam(18);
ep_o=8.85e-12; % units are in F/m 
% Layer 2: Bottom Hydrogel electrode 
lh1=DeviceParam(13);	bh1=DeviceParam(14);th1=DeviceParam(15);
% Layer 4: Top Hydrogel electrode
lh2=lh1;bh2=bh1;th2= DeviceParam(16); rohh=DeviceParam(17);
%Hyperlastic material constitutive model using Neo-Hookean Energy
C10e=DeviceParam(24);C01e=0;
Eeo=6*(C10e+C01e); Ee=Eeo;  
C10h=DeviceParam(25);C01h=0;
Eho=6*(C10h+C01h); Eh1=Eho;Eh2=Eho;  
C10p=DeviceParam(26);C01p=0;
Epo=6*(C10p+C01p); Ep=Epo;  

%%
ep_r=6.87; % For Dielectric layer; Using a compensation factor of ~ 1.65, ep_r=6.87 was used; for the case of without compensation factor, ep_r=4.16 should be used.
% *************************************************************************
% Neutral axis position and layers distance with respect to nuetural axis
N=5; % Counter for sumations, number of layers= N-1
L=[lp lh1 le lh2];b=[bp bh1 be bh2]; Layer=[0 tp th1 te th2]; E=[Ep Eh1 Ee Eh2];Roh=[rohp rohh rohe rohh];
MTip=0.0; bAvg=mean(b);LAvg=lp;
[RohBeam,tTotal,VolFractions]=RohMixture(b,Roh,Layer);
% Use the function NeuturalAxis(N,b,E,Layer) 
[neutAxis,z]=NeuturalAxis(N,b,E,Layer);
%% Solve for mid-plan strain and bending curvature for dielectric elastomer actuator: 
%Maximum actuator strain (or free strain) in the direction 1 is
V_lim=[10 5500]; dV=20;
Vol=(V_lim(1):(V_lim(2)-V_lim(1))/dV:V_lim(2));
i_count=dV+1;
%Intialize materials properties: 
eps=zeros(i_count,1); defl=eps; 
FD=eps; MD=eps;EA=eps;EIc=eps; EIb=eps;QintM=eps;epsNorm=eps;
for ii =1:i_count
    %Calculate stiffness matrix constants Using K_matrix
    E=[Ep Eh1 Ee Eh2];
    %Electromechanical strain
    Delta=nu*ep_o*ep_r/Ee*Vol(ii)^2/(te)^2
    d31(ii)=nu*ep_o*ep_r/Ee*Vol(ii)/te %used in Abaqus
    Deltacheck=d31(ii)*Vol(ii)/te  
    % Composite Stiffness constants 
    [EALayer,EIbLayer,EIcLayer]=EStiffness(N,E,b,z); 
    % Rule of mixture to estimate eigenvalues:
    EMtrx=EMixture(VolFractions,E);
    % The induce force and moment due to active dielectric layer are:
    FD(ii)=EALayer(3)*Delta; MD(ii)=-EIcLayer(3)*Delta;
    % Sum the stifness constants
    EA(ii)=sum(EALayer);EIc(ii)=sum(EIcLayer); EIb(ii)=sum(EIbLayer);
    % Obtain the displacement
    [defl(ii),Curvature,eps_o,QintM(ii)]=beam_nonlnr(LAvg,tTotal,bAvg,EMtrx,MTip,RohBeam,FD(ii),MD(ii),EA(ii),EIc(ii),EIb(ii));
    eps(ii)=eps_o(1,1)-Curvature(1,1)*z(1,end)-Delta;
    epsNorm(ii)=eps(ii)/Delta;
    lam=eps(ii)+1;
    Eh1=Eho/3*((lam-lam^(-2))/(lam-1)); Eh2=Eh1;
    Ee=Eeo/3*((lam-lam^(-2))/(lam-1)) %used in Abaqus 
    Ep=Epo/3*((lam-lam^(-2))/(lam-1)); 
end
%%
Data=xlsread('Input_Data.xlsx','Data','M4:O25');
% Column lable 
Col=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
% UMN Experimental Results for dielectric elastomer actuator
V_BaTiO3=Data(1:22,Col(1))'; disp_BaTiO3=1000*Data(1:22,Col(2))';

figure(1); hold on ; grid;
%Model nonlinear E-B beam Model 
xlim([0,6]); ylim([0,13000])
plot(Vol/1000,defl*1E6,'--b')
%UMN  experimental results  
plot(V_BaTiO3/1000,disp_BaTiO3,'or')
xlabel('Voltage, (kV)');ylabel('Displacement, (\mum)');
legend('Model','Exp.','Location','NorthWest')
hold off 
%%
figure(2); grid;
hold on 

[hAx, hLine1, hLine2]=plotyy(Vol/1000,EIb/EIb(1),Vol/1000,FD*1000);
xlabel('Voltage, (kV)')
ylabel(hAx(1),'Change in Structural Stiffness');
ylabel(hAx(2),'Blocked Force, (mN)');
hold off
EIb_device=EIb;
EIb_device_N=EIb/EIb(1);
FD_Device=FD;

%% Solve for mid-plan strain and bending curvature for dielectric elastomer actuator with varying thickness: 
%Maximum actuator strain (or free strain) in the direction 1 is
V_lim=[10 5500]; dV=20;
Vol=(V_lim(1):(V_lim(2)-V_lim(1))/dV:V_lim(2));
i_count=dV+1;
%Intialize materials properties: 
te_lim=[0.5*te 1.5*te]; dte=20;
teOp=(te_lim(1):(te_lim(2)-te_lim(1))/dte:te_lim(2));
t_count=length(teOp);
deflOp=zeros(i_count,t_count);
teTobeam=zeros(t_count);
for tt=1:t_count
Layer=[0 tp th1 teOp(tt) th2];
[RohBeam,tTotal,VolFractions]=RohMixture(b,Roh,Layer);
% Use the function NeuturalAxis(N,b,E,Layer) 
[neutAxis,z]=NeuturalAxis(N,b,E,Layer);
teTobeam(tt)=teOp(tt)/sum(Layer);
eps=zeros(i_count,1);  Curvature=eps; FD=eps; MD=eps;
EA=eps;EIc=eps; EIb=eps;QintM=eps;
for ii =1:i_count
    %Calculate stiffness matrix constants Using K_matrix
    E=[Ep Eh1 Ee Eh2];
    %Electromechanical strain
    Delta=nu*ep_o*ep_r/Ee*Vol(ii)^2/(teOp(tt))^2;
    % Composite Stiffness constants 
    [EALayer,EIbLayer,EIcLayer]=EStiffness(N,E,b,z); 
    %Rule of mixture to estimate eigenvalues:
    EMtrx=EMixture(VolFractions,E);
    % The induce force and moment due to active dielectric layer are:
    FD(ii)=EALayer(3)*Delta; MD(ii)=-EIcLayer(3)*Delta;
    % Sum the stifness constants
    EA(ii)=sum(EALayer);EIc(ii)=sum(EIcLayer); EIb(ii)=sum(EIbLayer);
    % Obtain the displacement
    [deflOp(ii,tt),Curvature,eps_o,QintM(ii)]=beam_nonlnr(LAvg,tTotal,bAvg,EMtrx,MTip,RohBeam,FD(ii),MD(ii),EA(ii),EIc(ii),EIb(ii));
    eps(ii)=eps_o(1,1)-Curvature(1,1)*z(1,end)-Delta;
    lam=eps(ii)+1;
    Eh1=Eho/3*((lam-lam^(-2))/(lam-1)); Eh2=Eh1;
    Ee=Eeo/3*((lam-lam^(-2))/(lam-1)); 
    Ep=Epo/3*((lam-lam^(-2))/(lam-1)); 
end
end
%%
figure (3) 
hold on
%grid
p1=plot(Vol/1000,deflOp(:,1)*1E3,'-b');
for tt=2: length(teOp-1)
    p2=plot(Vol/1000,deflOp(:,tt)*1E3,'--k'); 
end
p3=plot(Vol/1000,deflOp(:,end)*1E3,'-r');
p4=plot(Vol/1000,deflOp(:,11)*1E3,'-c');
xlabel('Voltage, (kV)');ylabel('Displacement, (mm)');
legend([p1(1),p4(1),p2(1),p3(1)],'t_e=0.5t_{e,exp}','t_e=t_{e,exp}','0.5t_{e,exp}<t_e<1.5t_{e,exp}','t_e=1.5t_{e,exp}','Location','NorthWest')
hold off



