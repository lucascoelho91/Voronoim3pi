classdef m3piController < handle
    properties 
        m3pi   % m3pi robot class
        goalx  % x coordinate of the goal
        goaly  % y coordinate of the goal
        errx   % error in x
        erry   % error in y
        posex  % positon in x of the robot
        posey  % position in y of the robot
        theta  % orientation of the robot in radians
        
        vlinear  % linear speed
        wangular % angular speed
        
        kv   % linear speed constant for the speed controller
        kw   % angular speed constant for the speed controller 
        d    % d distance for the feedback linearization controller
        tol  % minimum distance to the goal for considering that the goal was reached
        
        maxv % max linear speed
        maxw % max angular speed
    end
        methods
            
            function robot = m3piController(m3, kvel, kwg, dp, tolp, maxvp, maxwp)
                
                %% DEFAULT PARAMETERS 
                if nargin < 7
                    maxvp = 0.5;
                end
                if nargin < 6 
                    maxwp = 0.5;
                end
                if nargin < 5 
                    tolp = 0.1;
                end
                if nargin < 4
                    dp = 0.1;
                end
                if nargin < 3
                    kwg = 1;
                end
                if nargin < 2
                    kvel = 1;
                end    
                %%
                robot.kw = kwg;
                robot.kv = kvel;
                robot.m3pi = m3;
                robot.d = dp;
                robot.tol = tolp;
                robot.maxv = maxvp;
                robot.maxw = maxwp;
            end
            
            function setPose(robot, x, y, t) % sets the position of the robot
                robot.posex = x;
                robot.posey = y;
                robot.theta = t;
                robot.errx = robot.goalx - robot.posex;
                robot.erry = robot.goaly - robot.posey;
            end
            
            function setGoal(robot, x, y) % set goal (feedback linearization)
                robot.goalx = x;
                robot.goaly = y;
                robot.errx = robot.goalx - robot.posex;
                robot.erry = robot.goaly - robot.posey;
            end
            
            function controlSpeed(robot) 
                %% Feedback Linearization Controller
                v = robot.kv*(cos(robot.theta)*robot.errx + sin(robot.theta)*robot.erry);
                w = robot.kw*(-sin(robot.theta)*robot.errx/robot.d + cos(robot.theta)*robot.erry/robot.d);
                
                
                %% if the speed is bigger than the maximum, sets to the maximum
                if abs(v) > robot.maxv
                    v = robot.maxv * v/abs(v);
                end
                if abs(w) > robot.maxw
                    w = robot.maxw * w/abs(w);
                end
                robot.m3pi.sendSpeed(v, w);
                robot.vlinear = v;
                robot.wangular = w;
            end
            
            function controlSpeedDiff(robot, xdot, ydot)
                %% point offset controller
               [v, w] = robot.xyTovw(xdot, ydot);
               v = robot.kv * v;
               w = robot.kw * w;
               if abs(v) > robot.maxv
                    v = robot.maxv * v/abs(v);
                end
                if abs(w) > robot.maxw
                    w = robot.maxw * w/abs(w);
                end
               robot.m3pi.sendSpeed(v, w);
               robot.vlinear = v;
               robot.wangular = w;
            end 
            
            function [v, w] = xyTovw(robot, xdot, ydot)
                %% transforms xdot ydot to v w
                p = [cos(robot.theta),         sin(robot.theta);
                        -sin(robot.theta)/robot.d, cos(robot.theta)/robot.d]* [xdot; ydot];
                w = p(2);
                v = p(1);
            end   
            
            function answer = goalReached(robot)
                %% checks if the robot has reached the radius around the goal
                if norm([robot.errx, robot.erry]) < robot.tol
                    answer = 1;
                else
                    answer = 0;
                end
            end
            
        end
        
end