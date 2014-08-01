classdef simm3pi < handle
    properties
        timestep 
        x
        y
        theta
        
        l
    end
    methods
        
        function r = simm3pi(xo, yo, tho, ts, lp)
            r.timestep = ts;
            r.x = xo;
            r.y = yo;
            r.theta = tho;
            r.l = lp;
        end
        
        function sendSpeed(r, v, w)
            xv = cos(r.theta);
            yv = sin(r.theta);

            r.x = r.x + xv*v*r.timestep;
            r.y = r.y + yv*v*r.timestep;
            r.theta = wrapToPi(r.theta + w*r.timestep);
        end
        
        function p = getPose(r)
            p = [r.x, r.y, r.theta];
        end
        function [v, w] = xyTovw(robot, xdot, ydot)
            p = [cos(robot.theta),         sin(robot.theta);
                    -sin(robot.theta)/robot.l, cos(robot.theta)/robot.l]* [xdot; ydot];
            w = p(2);
            v = p(1);
        end
        
        function p = SetPose(r, xp, yp)
            r.x = xp;
            x.y = yp;
        end
        

    end
end
