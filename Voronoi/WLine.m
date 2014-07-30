function Line = WLine(pi, p0, wi,w0);
%returns the parameters for the line [a b]*q+c = 0
%perp to pi-p0 and passing through 1/2(pi+p0).  Used for
%calculating voronoi regions.

%EDIT: Converted to Weighted line function (from VLine) to calculate the
%perpendicular line of pi-p0 passing through {1/2(pi+p0) +w0 - wi}


s = pi-p0;
a = s(1);
b = s(2);
c = -1/2*(pi'*pi-p0'*p0 + w0 - wi);
Line = [a b c]';