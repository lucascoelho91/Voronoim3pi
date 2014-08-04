function w = widot(boti)

p = [boti.x; boti.y];
Cv = boti.Cv;

%w = -2*(Cv - p)'*boti.K*(Cv - p);

w = (Cv - p)'*((Cv - p) - boti.K*(Cv - p))/norm(Cv - p);