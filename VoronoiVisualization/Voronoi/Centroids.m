function [Mv, Cv] = Centroids(Env,boti)
% Calculate the centroid of a region V parameterized by K'*a. Uses
% numerical descritization of region to evaluate the centroid integrals.


res = Env.res;
V = boti.Vi;
p = vertcat(boti.x, boti.y);

%make rectangular domain to contain region
xmax = max(V(:,1));
xmin = min(V(:,1));
ymax = max(V(:,2));
ymin = min(V(:,2));

%integration step
xstep = (xmax-xmin)/res;
ystep = (ymax-ymin)/res;
%integration loop to calc M, intxphi, intyphi
Mv = 0;
Lv = [0 0]';
Jv = 0;
for x = xmin+xstep/2:xstep:xmax-xstep/2
    for y = ymin+ystep/2:ystep:ymax-ystep/2
        q = [x y]';
        if inpolygon(q(1), q(2), V(:,1), V(:,2))
            phiq = Measure(Env,q);
            Mv = Mv + xstep*ystep*phiq;
            Lv = Lv + xstep*ystep*phiq*q;
            Jv = Jv + xstep*ystep*phiq*(norm(q - p)^2);
        end
    end
end

Cv = Lv/Mv;


if Mv == 0
    figure(1);
%     hold on;
%     plot(V(:,1), V(:,2), 'r-');
%     hold off;
    'Calculated zero mass over Voronoi region.'
end
