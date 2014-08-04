function boti = poslaw(id,bot)

% Update the movement to model malicious movement

boti = bot(id);

% Malicious characteristic
mal = boti.mal;
% Control gain
kp = boti.kp;

Cv = boti.Cv;
Mv = boti.Mv;
x = boti.x;
y = boti.y;
eff = boti.eff;
pi = [x; y];


%MALICIOUS KEY
% 1 = stay
% 2 = chase


if mal == 0
    % Standard move-to-centroid controller
    xdot = kp*(Cv(1) - x);
    ydot = kp*(Cv(2) - y);
    
    
elseif mal == 1
    % Malicious agent can't move
    xdot = 0;
    ydot = 0;
        
    
elseif mal == 2
    % Chase one of its neighbors
    
    %%%% ADD NEIGHBORS TO INPUT %%%%%%
    if id == 2
        % IF robot 2, chase 1
        xdot = kp*(bot(1).x - x);
        ydot = kp*(bot(1).y - y);
    else
        % Not robot 2, chase 2
        xdot = kp*(bot(2).x - x);
        ydot = kp*(bot(2).y - y);
    end
    
elseif mal == 3
    % Escape the environment. Run away!
    xdot = -.2*kp*(Cv(1) - x);
    ydot = -.2*kp*(Cv(1) - y);
    
elseif mal == 4
    xdot = eff*kp*(Cv(1) - x);
    ydot = eff*kp*(Cv(2) - y);  

elseif mal == 5
    pdot = kp*(Cv - pi) + kp*boti.K*(Cv - pi);
    xdot = pdot(1);
    ydot = pdot(2);
end

% Update the velocities for bot
boti.xdot = xdot;
boti.ydot = ydot;