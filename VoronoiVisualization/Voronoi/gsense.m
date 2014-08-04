function g = gsense(pi,qc,hi)

% Sensing function gamma(pi, qc)
% Health value of sensor determined by sensor quality
% g = norm(qc - pi)^2 - hi

g = norm(qc-pi)^2 - hi;

%g = hi*norm(qc - pi)^2;


end
