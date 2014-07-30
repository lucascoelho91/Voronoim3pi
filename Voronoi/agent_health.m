function  h = agent_health(boti)

pi = [boti.x; boti.y];
pdi = [boti.xdot; boti.ydot];

optimal_control_law = boti.kp .* (boti.Cv - pi);

vec = norm(pdi)/norm(optimal_control_law);
ang = abs(dot(pdi, optimal_control_law)/((norm(pdi)*norm(optimal_control_law))));

%h =  min(vec, ang);

h =  1  - (norm(optimal_control_law - pdi)/norm(optimal_control_law));