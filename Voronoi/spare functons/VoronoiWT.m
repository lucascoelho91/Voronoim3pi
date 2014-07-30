function [V0, NI] = VoronoiWT(P0, p0,w0,wt,Bndry)
%Computes the voronoi region of the robot at p given the positions
%of all the other robots P 


%Constants
Limit = 10;
tol = 1e-6;
n = length(P0(:,1))-1;
p0 = p0';

%Find Distance and sort
D = P0 - ones(n+1,1)*p0;
D = sqrt(D(:,1).^2 + D(:,2).^2);
[D, I] = sort(D);

%Take p0 out of P0 and put in order of distance
P = P0(I(2:n+1),:);
N = I(2:n+1); %indices of neighbors in P0

% Re-arrange the weightings to match neighbor index
w = wt(I(2:n+1));


%Incremental Voronoi Comp

%Start with whole region Q
%V0 = [0 0; 0 1; 1 1; 1 0]; %unit square
V0 = Bndry; %Covex Boundary
l = length(V0(:,1));
V0 = [V0; V0(1,:)];
Lines = zeros(l,3);
for i = 1:l
    Lines(i,:) = GetLine(V0(i,:)', V0(i+1,:)');
end
V0 = V0(1:l,:);

i = 1;
NI = zeros(l,1);
d = Limit;
LSize = length(Lines(:,1));
VSize = length(V0(:,1));
%while there are still points, and a) the region is unbounded or b) the 
%farthest vertex is more than half the distance to the next point  

while i<=n && (2*d>D(i) || LSize>VSize)
    NI = [NI; N(i)]; %add index to neighbor list
    pi = P(i,:); %ith point
    %Line = VLine(pi', p0')'; %ith line 
    wi = w(i);
    Line = WLine(pi',p0',wi, w0)'; %ith line EDIT: using weighted formula
    Lines = [Lines; Line]; %Add Line to Lines
    %loop to find intersection points that are inside the half planes of
    %all Lines
    for j = 1:LSize
        Inpt = LineIntersect(Lines(j,:)', Line')'; %find intersection point j
        V0 = [V0; Inpt]; %Add Inpt to V0
        VSize = length(V0(:,1));
        %Test if any points are inside all half planes
        Test = Lines*[V0, ones(VSize,1)]'<=tol;    
        Test = cast(Test, 'double');      
        Test = prod(Test,1); %logical AND over the columns
        %Filter out all points not inside all half-planes
        [Test I] = sort(Test, 'descend');
        VSize = sum(Test);
        I = I(1:VSize);
        V0 = V0(I,:);
    end
    %Get rid of lines not containing any points in V0
    Test = abs(Lines*[V0, ones(VSize,1)]')>=tol'; %zero indicates a V0 point on a Line
    Test = cast(Test, 'double')';
    Test = prod(Test,1); %logical AND over the columns
    Test = 1-Test; %logical inverse
    %Filter
    [Test I] = sort(Test, 'descend');
    LSize = sum(Test);
    I = I(1:LSize);
    Lines = Lines(I,:);
    NI = NI(I); %filter out indices of non-Voronoi Neighbors 
    %max distance point in V0
    d = max(sqrt((V0(:,1)-p0(1)).^2 + (V0(:,2)-p0(2)).^2));
    %increment
    i = i+1;
end
%put V points in order
angle = atan2((V0(:,2)-p0(2)),(V0(:,1)-p0(1)));
[angle I] = sort(angle);
V0 = V0(I,:);

%Voronoi neighbor indices, put in order
%get rid of zeros
i = 1;
while ~isempty(NI) && NI(i) == 0
        NI = NI(2:length(NI));
end
Nangle = atan2((P0(NI,2)-p0(2)),(P0(NI,1)-p0(1)));
[Nangle I] = sort(Nangle);
NI = NI(I);

% %Plots
% figure(2)
% region = V0;
% if LSize==VSize
%      region = [region; region(1,:)];
% end
% hold on;
% plot(P(:,1), P(:,2), 'b.');
% axis([Bndry(1,1), Bndry(3,1), Bndry(1,2), Bndry(3,2)]);
% 
% plot(p0(1), p0(2), 'ro');
% plot(region(:,1), region(:,2), 'g-');
% plot(P0(NI,1), P0(NI,2), 'bo');
% hold off;
