function qc = findqc(i,j,bot)

% finds the "midpoint" along the boundary of pi and pj with their
% respective weights wi and wj



% Position and weights
pi = [bot(i).x ; bot(i).y];
pj = [bot(j).x ; bot(j).y];
wi = bot(i).wt;
wj = bot(j).wt;


% Find the total distance between pi and pj, as if it was new x-vec
xn = norm(pj - pi);
% Find the x-coord of qc, in the new-x frame (new-y = 0)
xq = (norm(pj-pi)^2 + wi - wj)/(2*norm(pj-pi));

% Find the fraction of the distance along new-x qc is
frac = xq/xn;

% Translate qc into base frame coordinate
qc = frac*(pj-pi) + pi;


end
