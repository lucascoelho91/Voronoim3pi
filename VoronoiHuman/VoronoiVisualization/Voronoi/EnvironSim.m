function [Env, bot, group] = EnvironSim(Env,bot,group)

% Updated Environmental Simulation function to incorporate structures


n = Env.n;

% INITIAL CONFIGURATION AND COST
%------------------------------------------
P0 = horzcat([bot.x]', [bot.y]');


for i=1:n
    % Find Voronoi Cell
    [V0,NI] = Voronoi_s(i,bot,Env);
    bot(i).Vi = V0;
    bot(i).nb = NI;
    % Find Centroid and Mass
    [Mv,Cv] = Centroids(Env,bot(i));
    bot(i).Mv = Mv;
    bot(i).Cv = Cv;
    % Find Cost
    Hi = intCost(Env,bot(i));
    bot(i).cost = Hi;
end

% Plot the initial configuration
hold on
for i =1:n
    plot(bot(i).x, bot(i).y,'Color',bot(i).clr, 'Marker', 'o');
    plot(bot(i).Cv, 'Color', bot(i).clr, 'Marker', '+');
    V = [bot(i).Vi];
    reg = vertcat(V,V(1,:));
    plot(reg(:,1),reg(:,2),'b-');
end

if Env.varphi == 1
    plot(Env.peaks(:,1),Env.peaks(:,2), 'rx', 'LineWidth', 2, 'MarkerSize',10);
end

% Add data labels
labels = cellstr( num2str([1:n]') );  %' # labels correspond to their order
text(P0(:,1), P0(:,2), labels, 'VerticalAlignment','bottom','HorizontalAlignment','right')
axis(Env.axes);
hold off

% TIME SIMULATION
%--------------------------------------------

t = Env.tspan(1);
ti = t;
tf = Env.tspan(2);
tstep = Env.tstep;


% Animation?
if Env.anim == 1
    figure();
    hold on
    if Env.mov == 1
        set(figure(2), 'Position', [50, 50, 1024, 768]);
    end
    time = title(strcat('time = ', num2str(t,'%.1f'),'s'));
    set(time,'EraseMode','xor');
    h = zeros(n);
    cvs = zeros(n);
    txt = zeros(n);
    for i = 1:n
        disp(bot(i).Cv(1));
        disp(bot(i).Cv(2));
        h(i) = plot(bot(i).x,bot(i).y, 'Color', bot(i).clr,'Marker','o');
        cvs(i) = plot(bot(i).Cv(1), bot(i).Cv(2), 'Color', bot(i).clr, 'Marker', '+');
        txt(i) = text(bot(i).x, bot(i).y, labels(i), 'EraseMode', 'xor', 'VerticalAlignment','bottom','HorizontalAlignment','right');
    end
    if Env.varphi == 1
        plot(Env.peaks(:,1),Env.peaks(:,2), 'rx', 'LineWidth', 2, 'MarkerSize',10);
    end
    
    axis(Env.axes);
    hold off
end

% Find the new data over time 

Hsum = zeros(size([group.time]));
Hsum(1) = sum([bot.cost]);
tx = 2; % Time index counter
tstamp = datestr(now); % Date for jpegs
tstamp(15) = ';';
tstamp = [tstamp(13:17) ' ']; % Consdense to start time

t = ti;

simgo = 'run';

while strcmp(simgo,'run') == 1 && t < tf
    
    % Calculate new x,y,wt for each robot
    bot = EnvironDers(bot,Env);
    


    % Check that no one violates boundary constraints
    if max([bot.x]) > max(Env.bdr(:,1)) || min([bot.x]) < min(Env.bdr(:,1))
        simgo = 'stop';
    elseif max([bot.y]) > max(Env.bdr(:,2)) || min([bot.y]) < min(Env.bdr(:,1))
        simgo = 'stop';
    end    
    
  
    % Update group data
    group.x(tx,:) = [bot.x];
    group.y(tx,:) = [bot.y];
    group.wt(tx,:) = [bot.wt];
    group.mal(tx,:) = [bot.mal];
    group.cost(tx,:) = [bot.cost];
    group.time(tx,:) = t; % Start a time vector
    group.h(tx,:) = [bot.h];
    Hsum(tx) = sum([bot.cost]);
    
    
    
    
    
    
    % Update animation
    if Env.anim == 1
        hold on
        title(strcat('time = ', num2str(t,'%.1f'),'s'));
        for i = 1:n
            set(h(i), 'XData',bot(i).x,'YData',bot(i).y, 'Color', bot(i).clr); 
            set(cvs(i), 'XData',bot(i).Cv(1),'YData',bot(i).Cv(2)); 
            set(txt(i), 'Position', [bot(i).x bot(i).y], 'String', labels(i));
        end
        drawnow;
        
        if Env.mov == 1
            % Movie writer
            f1 = getframe(2);
            Env.frames = [Env.frames; f1];
            
       end
        
        if Env.jpg == 1
            name = ['./Frames/' tstamp num2str(tx) '.jpg'];
            print('-djpeg','-r300',name);
        end
        
        hold off
    end

    
    % Update time index
    tx = tx + 1;
    t = t+tstep;

end


    % Code for movie writer
    colormap('default');
    if Env.mov == 1
        vidObj = VideoWriter(Env.mname, 'MPEG-4');
        open(vidObj);
        writeVideo(vidObj, Env.frames);
        close(vidObj);   
    end


    
% If the function terminated, need to cut back the data    
    
    
    
    
% Plot final configuration
figure;
hold on
for i =1:n
    plot(bot(i).x, bot(i).y,'Color',bot(i).clr, 'Marker', 'o');
    V = [bot(i).Vi];
    reg = vertcat(V,V(1,:));
    plot(reg(:,1),reg(:,2),'b-');
end
Px = [group.x];
Py = [group.y];
P0 = horzcat( Px(end,:)', Py(end,:)');

if Env.varphi == 1
    plot(Env.peaks(:,1),Env.peaks(:,2), 'rx', 'LineWidth', 2, 'MarkerSize',10);
end

labels = cellstr( num2str([1:n]') );  %' # labels correspond to their order
text(P0(:,1), P0(:,2), labels, 'VerticalAlignment','bottom','HorizontalAlignment','right')
hold off




% End time for plot
if strcmp(simgo,'stop') == 1
    tf = t/Env.tstep + 1;
else
    tf = Env.tplot/Env.tstep + 1;
end


% Generate a cost plot
figure;
hold on
plot(group.time(1:tf),Hsum(1:tf));
xlabel('Time (sec)');
ylabel('Cost');
hold off



% Generate a plot of weightings
figure;
hold on
plot(group.time(1:tf), group.wt(1:tf,1), 'g');
plot(group.time(1:tf), group.wt(1:tf,2:n),'b');
xlabel('Time (sec)');
ylabel('Weights (w_i)');
hold off

figure;
hold on
diff = group.wt - group.h;
plot(group.time(1:tf), diff(1:tf,1:n),'b');
xlabel('Time (sec)');
ylabel('w_i - h_i');
hold off


figure;
V = [bot(3).Vi];
fill(V(:,1),V(:,2),[0.803921580314636 0.878431379795074 0.968627452850342]);
hold on
for i =1:n
    plot(bot(i).x, bot(i).y,'Color',bot(i).clr, 'Marker', 'o');
    V = [bot(i).Vi];
    reg = vertcat(V,V(1,:));
    plot(reg(:,1),reg(:,2),'b-');
end
Px = [group.x];
Py = [group.y];
P0 = horzcat( Px(end,:)', Py(end,:)');

if Env.varphi == 1
    plot(Env.peaks(:,1),Env.peaks(:,2), 'rx', 'LineWidth', 2, 'MarkerSize',10);
end

labels = cellstr( num2str([1:n]') );  %' # labels correspond to their order
text(P0(:,1), P0(:,2), labels, 'VerticalAlignment','bottom','HorizontalAlignment','right')
axis(Env.axes)

hold off





