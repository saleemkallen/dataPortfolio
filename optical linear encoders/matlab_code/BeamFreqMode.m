function [BetaL, Mshape]=BeamFreqMode
global Bn1 Kn1 Bn2 Kn2 M J Nfreq BCtypeLeft BCtypeRight Neta
syms a1 a2 b1 b2 x K1 K2 B1 B2 Mm Jj et
%x is Beta*L in Meirovitch's Book Principles and Techniques of Vibrations
z1=b1*b2*(a1+a2)+b1-b2;
z2=a1*a2*(b1-b2)-a1-a2;
z3=a1*a2+b1*b2;
z4=1-a1*a2*b1*b2;
z5=a2*b2-a1*b1;
z6=a1*b2-a2*b1;

chareqn=z1*(cos(x)*sinh(x)+sin(x)*cosh(x))...
    +z2*(cos(x)*sinh(x)-sin(x)*cosh(x))...
    -2*z3*sin(x)*sinh(x)+z4*(cos(x)*cosh(x)-1)...
    +z5*(cos(x)*cosh(x)+1)+2*z6*cos(x)*cosh(x);
Q=(cosh(x)+cos(x))/2;
S=(cosh(x)-cos(x))/2;
R=(sinh(x)+sin(x))/2;
T=(sinh(x)-sin(x))/2;
Cn=(a2*R+(a2*b1-1)*S-b1*T)/(R-(a1+a2)*Q+a1*a2*T);
Qo=(cosh(et*x)+cos(et*x))/2;
So=(cosh(et*x)-cos(et*x))/2;
Ro=(sinh(et*x)+sin(et*x))/2;
To=(sinh(et*x)-sin(et*x))/2;

%The mode shape is:
Wn=Cn*(Qo-a1*To)+Ro+b1*So;
switch BCtypeLeft
    case 'clamped'
        chareqn=limit(limit(chareqn/a1,a1,inf)/b1,b1,inf);
        Cnb1=(a2*S-T)/(R-(a1+a2)*Q+a1*a2*T);
        Wn=limit(Cnb1*(Qo-a1*To)+So,a1,inf);
    case 'hinged'
        chareqn=limit(limit(chareqn/a1,a1,inf),b1,B1/x);
        Wn=limit(limit(Wn,a1, inf),b1,B1/x);
    case 'free'
        chareqn=limit(limit(chareqn,b1,B1/x),a1,K1/x^3);
        Wn=limit(limit(Wn,b1,B1/x),a1,K1/x^3);
end
switch BCtypeRight
    case 'clamped'
        chareqn=limit(limit(chareqn/a2,a2,inf)/b2,b2,inf);
        Wn=limit(Wn,a2,inf);
        ul=1.7*pi;
    case 'hinged'
        chareqn=limit(limit(chareqn/a2,a2,inf),b2,-B2/x);
        Wn=limit(Wn,a2,inf);
        ul=1.7*pi;
    case 'free'
        chareqn=limit(limit(chareqn,b2,-B2/x+Jj*x^3),a2,K2/x^3-Mm*x);
        Wn=limit(Wn,a2,K2/x^3-Mm*x);
        if length(BCtypeLeft)==4
            ul=10000*1.7*pi;
        else
            ul=pi;
        end
end
charist=inline(vectorize(chareqn),'x','K1','K2','B1','B2','Mm','Jj');
modes=inline(vectorize(Wn),'x','et','K1','K2','B1','B2','Mm','Jj');
ll=0.01*pi;
eta=linspace(0,1,Neta);
opt=optimset('Display','off');
BetaL=zeros(1,Nfreq);
Mshape=zeros(Nfreq,Neta);
for k=1:Nfreq
    BetaL(k)=fzero(charist,[ll,ul],opt,Kn1,Kn2,Bn1,Bn2,M,J);
    ll=pi*(BetaL(k)/pi+0.1);
    ul=pi*(BetaL(k)/pi+1.2);
    z=modes(BetaL(k),eta,Kn1,Kn2,Bn1,Bn2,M,J);
    Mshape(k,:)=z/max(abs(z));
end

        
        



