function [RohBeam,tTotal,VolFractions]=RohMixture(b,Roh,Layer)


t=Layer(2:end); AreaCross=b.*t; AreaTotal=sum(AreaCross);tTotal=sum(Layer);
%Calculate volume fractions
VolFractions=AreaCross/AreaTotal;
RohBeam = dot(Roh,VolFractions);
end