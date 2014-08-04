clear all; close all;
%% Set optitrack

addpath '@timetic' 
frame = 'XYZ+ Plane';
opti = optiTrackSetup(3000);
%fclose(instrfind);
%% create robot instance
id_robot = 2;
r = m3pi('/dev/ttyUSB0', 9600, ['40';'AE';'BB';'10']);
r = m3pi('/dev/ttyUSB0', 9600, ['40';'AD';'59';'34']);

% maybe you will need to run this >> fclose(instrfind)
r.connect();

%% Create controller instance
kv = 0.4;
kw = 0.005;
d = 0.05;
tol = 0.2;

rate = 0.1;
rateplot = 0.5;
controltic = timetic;
plottic = timetic;

controller = m3piController(r, kv, kw, d, tol);

%% List of goals
goals = [[ 1, 2 ]; [3, 3]; [0, 1]; [2, 2]];

controller.setGoal(goals(1, 1), goals(1, 2));
ngoals = size(goals);
ngoals = ngoals(1);

opti = readOptitrack(opti,frame);

controller.setPose(opti.pose(1, id_robot), opti.pose(2, id_robot), opti.pose(6, id_robot));

figure
h = plot(opti.pose(1, id_robot), opti.pose(2, id_robot),'Marker', 'o', 'MarkerSize', 15);
hold on
h2 = plot(goals(1, 1), goals(1, 2), 'Marker', '+', 'Color', 'r');
axis([-1 5 -1 5]);
grid on
drawnow;
j=0;


tic(controltic);
tic(plottic);

%% Goals Loop
for i=1:ngoals
    if(i>2)
        controller.setGoal(goals(i, 1), goals(i, 2));
        set(h2, 'XData', goals(i, 1), 'YData', goals(i, 2)); 
        drawnow;
    end
    %% Position Loop
    while(controller.goalReached() == 0)
        opti = readOptitrack(opti,frame);
        %opti.pose
        controller.setPose(opti.pose(1, id_robot), opti.pose(2, id_robot),  opti.pose(6, id_robot));
        if(toc(controltic) > rate)
            controller.controlSpeedDiff();
            tic(controltic);
        end

       
        if(toc(plottic) > rateplot)
            fprintf('x: %1.2f  y: %1.2f  ang: %3.2f v: %1.2f  w: %1.2f\n', opti.pose(1, id_robot), opti.pose(2, id_robot), wrapToPi(opti.pose(6, id_robot)), controller.vlinear, controller.wangular);
             set(h, 'XData', opti.pose(1,id_robot),'YData',opti.pose(2,id_robot)); 
            drawnow;
            tic(plottic);
        end
    end
end

%% End 
r.stop();
r.disconnect();