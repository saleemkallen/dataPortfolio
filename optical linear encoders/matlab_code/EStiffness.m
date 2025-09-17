function [EA,EIb,EIc]=EStiffness(N,E,b,z) 
    % allocate memory
    EA=zeros(N,1);EIb=EA; EIc=EA;
for ii=1:(N-1)
    % Stiffness due to extension
    EA(ii) = E(ii)*b(ii)*(z(ii+1)-z(ii));
    % Coupling stiffness parameter
    EIc(ii) = -0.5*E(ii)*b(ii)*((z(ii+1))^2-(z(ii))^2);
    % Bending stiffness parameter
    EIb(ii) = E(ii)/3*b(ii)*((z(ii+1))^3-(z(ii))^3);
end
end
