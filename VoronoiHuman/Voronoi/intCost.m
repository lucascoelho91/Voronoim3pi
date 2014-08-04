function Hi = intCost(Env,boti)
% Calculate the cost at a time step based on the configuration

res = Env.res;

V = boti.Vi;
pi = vertcat(boti.x, boti.y);
wi = boti.wt;

% Make rectangle for integration
xmax = max(V(:,1));
xmin = min(V(:,1));
ymax = max(V(:,2));
ymin = min(V(:,2));

% Integration step
xstep = (xmax-xmin)/res;
ystep = (ymax-ymin)/res;


% Integrate over loop to calculate cost
Hi = 0;
for x = xmin + xstep/2 : xstep : xmax-xstep/2
    for y = ymin + ystep/2 : ystep : ymax-ystep/2
        q = [x y]';
        if inpolygon(q(1),q(2),V(:,1), V(:,2))
            phiq = Measure(Env,q);
            a = norm(q - pi)^2 - wi;
            Hi = Hi + xstep*ystep*phiq*a;
        end
        
        
        
    end
end
