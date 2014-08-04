function fixplots(group)

% Fixes plots that were messed up

t = 0:.01:100;

tf = 1501;

cost = [group.cost];
Hsum = zeros(tf,1);
for i = 1:tf
    Hsum(i) = sum(cost(i,:));
end



figure;
hold on
plot(t(1:tf), Hsum(1:tf));
xlabel('Time (sec)');
ylabel('Cost');
hold off


figure;
hold on
plot(t(1:tf), group.wt(1:tf,1),'g');
plot(t(1:tf), group.wt(1:tf,2:10),'b');
xlabel('Time (sec)');
ylabel('Weights (w_i)');
hold off