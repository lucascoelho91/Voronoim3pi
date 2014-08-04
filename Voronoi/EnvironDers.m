function bot = EnvironDers(bot,Env)

% Solve the next time step within environmental coverage control
% simulation


n = Env.n;
ts = Env.tstep;


for i = 1:n
    % Find the position of the robot
    pi = [bot(i).x ; bot(i).y];
    [bot(i).Vi, bot(i).nb] = Voronoi_s(i,bot,Env);
    % Calculate new Mass and Centroid
    [bot(i).Mv, bot(i).Cv] = Centroids(Env,bot(i));
    % Implement control laws to calculate xdot and ydot
    bot(i) = poslaw(bot(i).id, bot);  % Will change bot(i).xdot, bot(i).ydot based on malicious property   
    % Update agent health
    bot(i).h = fi(bot(i))*bot(i).w0;
    
    if Env.wdot == 1 
        % Calculate wdot
        wsum = 0;
        nb = [bot(i).nb];
        for j = 1:length(nb)
            k = nb(j);
            if bot(j).valid == 1
                %pk = [bot(k).x ; bot(k).y];
                %qc = findqc(i,k,bot);
                %wk = bot(k).wt;
                
                %gami = gsense(pi, qc, bot(i).h);
                %gamj = gsense(pk, qc, bot(k).h);
                
                %gami = - bot(i).h;
                %gamj = - bot(j).h;
                %gamavg = (gami + gamj)/2;
                %wsum = wsum + (gami - gamavg);  
                
                fqi = gamafn(bot(i)) + robotTrust(bot(i));
                fqk = gamafn(bot(k)) + robotTrust(bot(k));
                fqvg = (fqi + fqk)/2;
                
                wsum = wsum + (fqi - fqvg);
            end
        end

%         for j = 1:length(nb)
%             k = nb(j);
%             if bot(j).valid == 1
%                 %qc = findqc(i,k,bot);
%                 gami = agent_health(bot(i));
%                 gamj = agent_health(bot(j));
%                 gamavg = (gami + gamj)/2;
%                 sumgama = gami - gamavg;
%                 wdif = wdiff(bot(i), bot(j), sumgama);
% %                 if(abs(sumgama)> abs(wdif))
% %                     wsum = wsum + sumgama;
% %                 else
% %                     wsum = wsum + wdif;
% %                 end
%                 wsum = wsum + sumgama + wdif;
%             end
%         end


        % Formula is wdot_i = -k/Mi * sum_{j in Ni} (gami - (gami+gamj)/2) 
        bot(i).wdot = -(bot(i).kw)*(1/bot(i).Mv)*(wsum)/2;
        bot(i).trust = gamafn(bot(i)) + robotTrust(bot(i));
        
    end
    
end



% Update positons and weightings

% Get positions
%[pBot, angBot] = getOptiTrackPoseEuler(Env.opti, Env.dispCtrl, Env.frame);


for i = 1:n
    % Update positions
    %bot(i).x = bot(i).x + bot(i).xdot*ts;
    %bot(i).y = bot(i).y + bot(i).ydot*ts;
    
    %bot(i).x = max(Env.stol, min(Env.bdr(3,1)-Env.stol, bot(i).x));
    %bot(i).y = max(Env.stol, min(Env.bdr(3,2)-Env.stol, bot(i).y));
%   
    %bot(i).x = pBot(1,i);
    %bot(i).y = pBot(2,i);
    
    if Env.SIMULATION
        p = bot(i).robot.getPose();
        bot(i).x = p(1);
        bot(i).y = p(2);
        bot(i).theta = p(3);
    else
        Env.opti = readOptitrack(Env.opti, Env.frame);
        bot(i).x = Env.opti.pose(1, i);
        bot(i).y = Env.opti.pose(2, i);
        bot(i).theta = Env.opti.pose(6, i);
    end

    bot(i).controller.setPose(bot(i).x, bot(i).y, bot(i).theta);
    bot(i).controller.controlSpeedDiff(bot(i).xdot, bot(i).ydot);
    
    
     if Env.SIMULATION
        p = bot(i).robot.getPose();
        bot(i).x = p(1);
        bot(i).y = p(2);
        bot(i).theta = p(3);
        bot(i).x = max(Env.stol, min(Env.bdr(3,1)-Env.stol, bot(i).x));
        bot(i).y = max(Env.stol, min(Env.bdr(3,2)-Env.stol, bot(i).y));
        bot(i).robot.setPose(bot(i).x, bot(i).y);
    end
        
    %Update weightings
    bot(i).wt = bot(i).wt + bot(i).wdot*ts;
    if bot(i).wt < bot(i).minwt
        bot(i).wt = bot(i).minwt;
        bot(i).valid = 0;
    else
        bot(i).valid = 1;
    end
    
    
    
    fprintf('Robot %d wd: %f dw: %f h: %f w0: %f fi: %f\n', i, bot(i).wt, bot(i).wdot, bot(i).h, bot(i).w0, fi(bot(i)));
    
    % Update cost
    bot(i).cost = intCost(Env,bot(i));
    
end
fprintf('\n');