function [Ui Un] = intpot(Env, boti)

% Calculates the utility [potential] of an agent at a given point
% Specify location of the agent in the input, which is useful for
% calculating potentials at new points.

res = Env.res;


V = boti.Vi;
pi = vertcat(boti.x,boti.y);        % Current state
pn = vertcat(boti.xn, boti.yn);     % New state
wi = boti.wt;

% Make rectangle for integration
xmax = max(V(:,1));
xmin = min(V(:,1));
ymax = max(V(:,2));
ymin = min(V(:,2));

% Integration step
xstep = (xmax-xmin)/res;
ystep = (ymax-ymin)/res;

% Integrate over loop to calculate the individual potential (aka utility)
Ui = 0;
Un = 0;
for x = xmin + xstep/2 : xstep : xmax-xstep/2
    for y = ymin + ystep/2 : ystep : ymax-ystep/2
        q = [x y]';
        if inpolygon(q(1),q(2),V(:,1), V(:,2))
            rhoq = Measure(Env,q);
            a = norm(q - pi)^2 - wi;
            b = norm(q - pn)^2 - wi;
            Ui = Ui + xstep*ystep*rhoq*a; % Current state
            Un = Un + xstep*ystep*rhoq*b; % New state
        end  
    end
end