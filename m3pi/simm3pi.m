classdef simm3pi < handle
    properties
        timestep     %timestep considered to simulate the motion of the robot
        x            %x position
        y            % y position
        theta        % angle    
    end
    methods
        
        function r = simm3pi(xo, yo, tho, ts)
            r.timestep = ts;
            r.x = xo;
            r.y = yo;
            r.theta = tho;
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
        
        function setPose(r, xp, yp)
            r.x = xp;
            r.y = yp;
        end
        

    end
end
