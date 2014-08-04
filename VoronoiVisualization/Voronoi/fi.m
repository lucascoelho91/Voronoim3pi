function f = fi(boti)

p = [boti.x; boti.y];
Cv = boti.Cv;

%w = -2*(Cv - p)'*boti.K*(Cv - p);

f = ( 1/2 - norm(boti.K));