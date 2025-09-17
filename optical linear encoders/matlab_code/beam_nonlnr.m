function [displ,Curvature,eps_o,QintM]=beam_nonlnr(L,h,bAvg,EMtrx,M_Tips,roh,FD,MD,EA,EIc,EIb)
global Bn1 Kn1 Bn2 Kn2 M J Nfreq BCtypeLeft BCtypeRight Neta
g=9.81; % Gravity (m/s^2)
II_beam=bAvg*h^3/12; %Moment of inertia m^4. This line is only for the natural freq calculation to check the code
A=bAvg*h;     %beam cross-section Area m^2
h_tip=1.35E-3;L_tip=5.6E-3; %Tip mass height and length
ro=roh*A; % Beam mass density kg/m
M_tip=M_Tips(1);
m_beam=ro*L; % distributed mass
j_2=ro/12*h^2; j_tip=M_tip/12*(L_tip^2); %Rotational momentum
%% The beam modes were calculated using BeamFreqMode.m based on Magrab, E. et al., An Engieer's Guide to MATLAB (2010)
Bn1=0; Kn1=0; Bn2=0; Kn2=0; M=M_tip/m_beam; J=j_tip/(m_beam*L^2);
Nfreq=1; Neta=1e3;
BCtypeLeft='clamped'; BCtypeRight='free';
[BetaL,Mshape]=BeamFreqMode;
%% Compute Natural frequency (hz) from geometry
fn_beam=(BetaL(1)^2*sqrt(EMtrx*II_beam/(ro*L^4)))/(2*pi); % Natural Frequency in (Hz)
fprintf('Natural freq. from geometry %6.4fHz\n',fn_beam);
n_mode=1; % Number of modes: maximum allowable is three modes
x=linspace(0,L,Neta);
Betan=BetaL/L; %Eigenvalues
% Calcuated the coef for the exact solution
Cn=(sin(BetaL)-sinh(BetaL)+BetaL*M*(cos(BetaL)-cosh(BetaL)))./...
    (cos(BetaL)+cosh(BetaL)-BetaL*M*(sin(BetaL)-sinh(BetaL)));
%Initialize the mode shapes matrix
Yi=zeros(n_mode,Neta);Yj=Yi;YLi=Yi;YLj=Yi; 
% Yd and ydd are the 1st and 2nd drevatives of modeshape, respectivly. 
Yddi=Yi;Yddj=Yj;Ydi=Yi;Ydj=Yj;
% Enter the integral for mode shape sqr from 0 to L from DEAModes.nb

Ys_sqr=0.023;dYs=202.08;       %Tip mass = 0.0 grams
%Ys_sqr=0.0026314;dYs=66.508;   %Tip mass = 0.040 grams
%Ys_sqr=0.0026089;dYs=67.042;   %Tip mass = 0.080 grams
%Ys_sqr=0.0026014;dYs=67.222;   %Tip mass =0.120 grams

%Normalize mode shape using mass;
dYL=Betan(1)*(-sin(Betan(1)*L)-sinh(Betan(1)*L)...
        +Cn(1)*(cos(Betan(1)*L)-cosh(Betan(1)*L)));
A_n=1/sqrt(ro*Ys_sqr+M_tip*((cos(BetaL)-cosh(BetaL))+Cn*...
        (sin(BetaL)-sinh(BetaL)))^2+j_tip*dYL^2+j_2*dYs);
% To check linear versus nonlinear. for linear set holder = 0. for nonlinear
% holder =1. 
holder=1;
%% Mode shapes calculations
for i=1:n_mode
    %Mode Shapes
    Yi(i,:)=A_n*((cos(Betan(i)*x)-cosh(Betan(i)*x))+Cn(i)*...
        (sin(Betan(i)*x)-sinh(Betan(i)*x)));
    YLi(i,:)=A_n*((cos(Betan(i)*L)-cosh(Betan(i)*L))+Cn(i)*...
        (sin(Betan(i)*L)-sinh(Betan(i)*L)));
    %first Derivative of mode shapes
    Ydi(i,:)=A_n*Betan(i)*(-sin(Betan(i)*x)-sinh(Betan(i)*x)...
        +Cn(i)*(cos(Betan(i)*x)-cosh(Betan(i)*x)));
    YdLi(i,:)=A_n*Betan(i)*(-sin(Betan(i)*L)-sinh(Betan(i)*L)...
        +Cn(i)*(cos(Betan(i)*L)-cosh(Betan(i)*L)));
    %Second Derivative of mode shapes
    Yddi(i,:)=A_n*Betan(i)^2*(-cosh(Betan(i)*x)-cos(Betan(i)*x)...
        +Cn(i)*(-sinh(Betan(i)*x)-sin(Betan(i)*x)));
    %Intergral of the Y' square obtained from Mathematica
    %file: Simb_ModeShape.nb
    I_Yd(i,:)=A_n^2/4*Betan(i)*(4*Cn(i)+4*Cn^2*x*Betan(i)+...
        2*Cn(i)*cos(2*Betan(i)*x)+2*Cn(i)*cosh(2*Betan(i)*x)-...
        4*(Cn(i)^2-1)*cosh(Betan(i)*x).*sin(Betan(i)*x)+...
        (Cn(i)^2-1)*sin(2*Betan(i)*x)-4*cos(Betan(i)*x).*(2*Cn(i)*cosh(Betan(i)*x)+...
        (1+Cn(i)^2)*sinh(Betan(i)*x))+sinh(2*Betan(i)*x)+Cn(i)^2*sinh(2*Betan(i)*x));
    %Sub the lenght L into the above equation:
    I_YdL(i,:)=A_n^2/4*Betan(i)*(4*Cn(i)+4*Cn^2*L*Betan(i)+...
        2*Cn(i)*cos(2*Betan(i)*L)+2*Cn(i)*cosh(2*Betan(i)*L)-...
        4*(Cn(i)^2-1)*cosh(Betan(i)*L).*sin(Betan(i)*L)+...
        (Cn(i)^2-1)*sin(2*Betan(i)*L)-4*cos(Betan(i)*L).*(2*Cn(i)*cosh(Betan(i)*L)+...
        (1+Cn(i)^2)*sinh(Betan(i)*L))+sinh(2*Betan(i)*L)+Cn(i)^2*sinh(2*Betan(i)*L));
    %Intergral of the Y'^2 square obtained from Mathematica
    %file: Simb_ModeShape.nb
    I_Yd_sq(i,:)=A_n^2/4*Betan(i)*(2*Cn(i)*(2+2*Cn*Betan(i)*x+cos(2*Betan(i)*x))+...
        2*Cn(i)*cosh(2*Betan(i)*x)+4*cosh(Betan(i)*x).*(-2*Cn(i)*cos(Betan(i)*x)-...
        (-1+Cn(i)^2)*sin(Betan(i)*x))+(-1+Cn(i)^2)*sin(2*Betan(i)*x)-...
        4*(1+Cn(i)^2)*cos(Betan(i)*x).*sinh(Betan(i)*x)+sinh(2*Betan*x)+...
        Cn(i)^2*sinh(2*Betan(i)*x));
    %Sub the lenght L into the above equation:
    I_Yd_sqL(i,:)=A_n^2/4*Betan(i)*(2*Cn(i)*(2+2*Cn*Betan(i)*L+cos(2*Betan(i)*L))+...
        2*Cn(i)*cosh(2*Betan(i)*L)+4*cosh(Betan(i)*L).*(-2*Cn(i)*cos(Betan(i)*L)-...
        (-1+Cn(i)^2)*sin(Betan(i)*L))+(-1+Cn(i)^2)*sin(2*Betan(i)*L)-...
        4*(1+Cn(i)^2)*cos(Betan(i)*L).*sinh(Betan(i)*L)+sinh(2*Betan*L)+...
        Cn(i)^2*sinh(2*Betan(i)*L));
    %Intergral of the Y'^4 square obtained from Mathematica
    %file: Simb_ModeShape.nb
    I_Yd_4(i,:)=A_n^4/160*Betan(i)^3*(5*Cn(i)^2*(-6+Cn(i)^2)*sin(4*x*Betan(i))-...
        16*sin(3*x*Betan(i)).*((1-12*Cn(i)^2+3*Cn(i)^4)*cosh(x*Betan(i))-8*Cn(i)*sinh(x*Betan(i)))+...
        16*cos(3*x*Betan(i)).*(2*Cn(i)*(3-5*Cn(i)^2)*cosh(x*Betan(i))-(-3+6*Cn(i)^2+Cn(i)^4)*sinh(x*Betan(i)))+...
        20*sin(2*x*Betan(i)).*(3*(-1-4*Cn(i)^2+Cn(i)^4)*cosh(2*x*Betan(i))+4*Cn(i)*(-3*Cn(i)+2*Cn(i)^3-...
        3*sinh(2*x*Betan(i))))+60*cos(2*x*Betan(i)).*(4*Cn(i)^3*cosh(2*x*Betan(i))+(-1+4*Cn(i)^2+...
        Cn(i)^4)*sinh(2*x*Betan(i)))-16*sin(x*Betan(i)).*(30*Cn(i)^2*(-1+Cn(i)^2)*cosh(x*Betan(i))+...
        (-3-6*Cn(i)^2+Cn(i)^4)*cosh(3*x*Betan(i))-8*Cn(i)*sinh(3*x*Betan(i)))+16*cos(x*Betan(i)).*...
        (-60*Cn(i)^3*cosh(x*Betan(i))-2*Cn(i)*(3+5*Cn(i)^2)*cosh(3*x*Betan(i))-30*Cn(i)^2*(1+Cn(i)^2)*...
        sinh(x*Betan(i))-(1+3*Cn(i)^2*(4+Cn(i)^2))*sinh(3*x*Betan(i)))+5*(-24*x*Betan(i)+...
        72*Cn(i)^3*(1+Cn(i)*x*Betan(i))+32*Cn(i)*(-1+2*Cn(i)^2)*cos(2*x*Betan(i))+4*Cn(i)*(-1+Cn(i)^2)*...
        cos(4*x*Betan(i))+16*sin(2*x*Betan(i))+sin(4*x*Betan(i))+16*sinh(2*x*Betan(i))+...
        sinh(4*x*Betan(i)))+5*Cn(i)*(32*(1+2*Cn(i)^2)*cosh(2*x*Betan(i))+4*(1+Cn(i)^2)*cosh(4*x*Betan(i))+...
        16*Cn(i)*(3+2*Cn(i)^2)*sinh(2*x*Betan(i))+Cn(i)*(6+Cn(i)^2)*sinh(4*x*Betan(i))));
    for j=1:n_mode
        %Orth. Mode shapes
        Yj(j,:)=A_n*((cos(Betan(j)*x)-cosh(Betan(j)*x))+Cn(j)*...
            (sin(Betan(j)*x)-sinh(Betan(j)*x)));
        YLj(j,:)=A_n*((cos(Betan(j)*L)-cosh(Betan(j)*L))+Cn(j)*...
            (sin(Betan(j)*L)-sinh(Betan(j)*L)));
        %first Derivative of mode shapes
        Ydj(j,:)=A_n*Betan(j)*(-sin(Betan(j)*x)-sinh(Betan(j)*x)...
            +Cn(j)*(cos(Betan(j)*x)-cosh(Betan(j)*x)));
        YdLj(j,:)=A_n*Betan(j)*(-sin(Betan(j)*L)-sinh(Betan(j)*L)...
        +Cn(j)*(cos(Betan(j)*L)-cosh(Betan(j)*L)));
        %Second Derivative of mode shapes
        Yddj(j,:)=A_n*Betan(j)^2*(-cosh(Betan(j)*x)-cos(Betan(j)*x)...
            +Cn(j)*(-sinh(Betan(j)*x)-sin(Betan(j)*x)));

% The modal mass is just for check the code for debuging.  

        ModalMass(i,j)=ro*trapz(x,Yi(i,:).*Yj(j,:))+M_tip*YLi(i,end).*YLj(j,end)+...
            j_tip*YdLi(i,end).*YdLj(j,end)+j_2*trapz(x,Ydi(i,:).*Ydj(j,:));
        kle(i,j)=EA*trapz(x,Ydi(i,:).*Ydj(j,:));
        klb(i,j)=EIb*trapz(x,Yddi(i,:).*Yddj(j,:));
        klc=EIc*trapz(x,Ydi(i,:).*Yddj(j,:));
        Qext(i,j)=M_tip*g*I_Yd_sqL(i,end);
        knc(i,j)=holder*(1/2*EIc*trapz(x,(Ydi(i,:).*Ydj(j,:)).*(Yddi(i,:))));
        knD(i,j)=holder*abs(3/2*MD*trapz(x,(Ydi(i,:).*Ydj(j,:)).*(Yddi(i,:))));
        knb(i,j)=holder*(2*EIb*trapz(x,(Yddi(i,:).*Yddj(j,:)).*(Ydi(i,:).*Ydj(j,:))));
    end
    QintF=abs(FD*trapz(x,Ydi(i,:)));
    QintM=abs(MD*trapz(x,Yddj(j,:)));
end
%% Solve for generlized coord 
Omg=sqrt(klb/ModalMass);
fprintf('Check natural freq. from mode shape %6.4fHz\n',Omg/(2*pi));
fprintf('Check modal mass %6.4f kg/kg\n',ModalMass);

% Displacement in the x direction
eqn1 = @(y1) kle*y1-QintF;
q1=fsolve(eqn1,0.01); 
eps_o= abs(q1*fliplr(Ydi));

% Displacement in the z direction
eqn2 = @(y2) klb*y2+knb*y2^3-knD*y2^2-QintM;
q2=fsolve(eqn2,0.01); 

displ=abs(q2*Yi(1,end));
Curvature=q2*Yddi+(0.5*q2^3*Yddi.*Ydi.^2);







