function voronoiquickplot(group)


% Plot the configuration from group data after simulation

% End time for plot
tend = 15; % seconds
tf = tend/0.01 + 1;


x = group.x(tf,:);
y = group.y(tf,:);
p = vertcat(x,y);
P0 = p';
wt = group.wt(tf,:);
bndry = [0 0; 0 6; 6 6; 6 0];

figure;
hold on
for i = 1:10
   p0 = p(:,i);
   [V0,NI] = VoronoiWT(P0,p0,wt(i),wt,bndry);
   
   plot(V0(:,1),V0(:,2),'b-');
   plot(p0(1),p0(2),'bo');
   plot(p0(1),p0(2),'b.', 'MarkerSize',3);
end

labels = cellstr( num2str([1:10]') );  %' # labels correspond to their order
text(P0(:,1), P0(:,2), labels, 'VerticalAlignment','bottom','HorizontalAlignment','right')

gamma = [1 1; 5 5];
plot(gamma(:,1),gamma(:,2), 'rx');
axis([0 6 0 6]);

hold off

    
    
