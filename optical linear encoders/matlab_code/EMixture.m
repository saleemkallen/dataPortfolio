function [EBeam]=EMixture(VolFractions,E)
% EMixture returns Youngs modulus in the
% longitudinal direction for beam. 

%Calculate the effective modulus
EBeam = dot(E,VolFractions);
end