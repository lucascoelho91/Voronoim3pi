function totalsim = StartSim()

% Environmental Simulation of Voronoi coverage control
% Uses structures to define robots in the field
% Flexibility to include adaptive weightings and malicious agents


%% Insert function defining environmental constants
close all; 
clear all;

%% paths to the parts of the program
addpath m3pi 
addpath Optitrack
addpath Voronoi

%% Simulation?
%%%%%%%%%%%%%%%%%%%%%%%%%%
    SIMULATION = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

    HUMAN = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%


%% NUMBER OF ROBOTS
n  = 3; 

%% size environment
sizeEnv = 6;

%% WEIGHTINGS
wt = ones(1,n);
% wt(7) = 2;
% wt(9) = 1.5;
% wt(2) = 2;

%% MALICIOUS
mal = zeros(1,n);   
% 0 = normal
% 1 = stay
% 2 = chase
% 3 = escape
% 4 = reduced speed (efficiency)
% 5 = K 
% mal(5) = 1; 
% mal(2) = 4;
mal(2) = 5;

%% efficiency
eff = ones(1, n);

% K
K = cell(n,1);
for i=1:n
    K{i} = zeros(2);
end

K{2} = [0.8 0;0 0.2];

%% SENSOR FUNCTION PARAMETERS
h = ones(1,n);

%% INITIAL POSITIONS
p0 = sizeEnv*rand(n,2);
t0 = -pi + rand(n, 1)*2*pi;

%% CONTROL GAIN
kp = 1;
kv = 0.4;
kw = 0.005;
d = 0.05;
tol = 0.2;


%% Define the environment
Env.n = n;
Env.bdr = [0 0; 0 sizeEnv; sizeEnv sizeEnv; sizeEnv 0];         % Bounding box
Env.axes = [min(Env.bdr(:,1)) max(Env.bdr(:,1)) min(Env.bdr(:,2)) max(Env.bdr(:,2))];
Env.peaks = [1 1; 5 5];                      % Peak of phi function ('gamma')
Env.strength = [100 ; 100];              % Strength ('alpha')
Env.offset = [0 ; 0];                     % offset
Env.stdev = [.2 ; .2]*max(max(Env.bdr));  % Standard Deviation ('beta')
Env.varphi = 0;                         % Variable phi function?
Env.stol = 0.2;   % barrier
Env.SIMULATION = SIMULATION;
Env.HUMAN = HUMAN

%% Also define the animation constants
Env.mov = 0;            % Write movi e using vidObj
Env.jpg = 0;            % Write movie as series of jpegs
Env.mname = 'variableweight';         % Movie name
Env.anim = 1;           % Animate?
Env.frames = [];        % Movie frames (for vidObj)
Env.tstep = .1;         % Time step size
Env.tspan = [0 50];     % Time span
Env.tplot = 50;         % Time to plot (not necessarily entire span)
Env.res = 5;            % Resolution for integration
Env.shade = 0;          % Robot to shade
Env.plot = 1;           % plot cost
Env.wdot = 1;           % calculate wdot


%% Optitrack variable
if ~SIMULATION
    Env.frame = 'XYZ+ Plane';
    Env.opti = optiTrackSetup(3000);
    Env.opti = readOptitrack(Env.opti, Env.frame);
end

%% Robot connection setup
if ~SIMULATION
    baudrate = 9600;
    port = '/dev/ttyUSB0';
    
    address(1) = ['40';'AE';'BB';'10'];
    address(2) = ['40';'AD';'59';'34'];
    
end

%% init robots
for i=1:n
    if i~= HUMAN
        if SIMULATION
            r(i) = simm3pi(p0(i, 1), p0(i, 2), t0(i), Env.tstep, d);
        else
            r(i) = m3pi(port, baudrate, address(i));
        end
        c(i) = m3piController(r(i), kv, kw, d, tol);
    end
end

% Distribute variables to the n robots
bot = struct(); % Create the empty structure

%% Robot initialization
for i = 1:n
    bot(i).id = i;              % Index
    bot(i).x = p0(i,1);         % x-Position
    bot(i).y = p0(i,2);         % y-Postion
    bot(i).theta = t0(i);       % theta
    bot(i).xdot = 0;            % x-Velocity
    bot(i).ydot = 0;            % y-Velocity
    bot(i).wt = wt(i);          % Weighting
    bot(i).w0 = wt(i);          % Pre defined weight
    bot(i).wdot = 0;            % Weighting change
    bot(i).mal = mal(i);        % Malicious control law (0 = normal)
    bot(i).nb = [];             % Neighbors (to be populated)
    bot(i).Vi = [];             % Boundary of cell points
    bot(i).kp = kp;             % Control gain (position)
    bot(i).kw = kw;             % Control gain (weights)
    bot(i).h = h(i);            % Sensor function health
    bot(i).cost = 0;            % Cost of agents region
    bot(i).Mv = 0;              % Mass
    bot(i).Cv = [];             % Centroid
    bot(i).valid = 1;           % Valid for the calculation of the wdot
    bot(i).minwt = 0.1;         % minimum wt
    bot(i).eff = eff(i);
    bot(i).K = K{i};
    if bot(i).mal ~= 0
        bot(i).clr = 'r';       % Plotting color (for animation) 
    else
        bot(i).clr = 'b';       
    end

    bot(i).robot = r(i);   %% robot
    bot(i).controller = c(i);
    
    if i ~= HUMAN
        if ~SIMULATION
            bot(i).x = opti.pose(1, i);
            bot(i).y = opti.pose(2, i);
            bot(i).theta = opti.pose(6, i);
        end
        bot(i).controller.setPose(bot(i).x, bot(i).y, bot(i).theta);
    end
end


%% MAKE A UNIFIED GROUP VARIABLE FOR TIME HISTORY
% Array size
sa = Env.tspan(2)/Env.tstep + 1;

group.x = zeros(sa,n);
group.y = zeros(sa,n);
group.wt = zeros(sa,n);
group.mal = zeros(sa,n);
group.cost = zeros(sa,n);
group.time = zeros(sa,1);
group.h = zeros(sa,n);

%% Fill in initial values

group.x(1,:) = [bot.x];
group.y(1,:) = [bot.y];
group.wt(1,:) = [bot.wt];
group.mal(1,:) = [bot.mal];
group.cost(1,:) = [bot.cost];
group.time(1,:) = 0; % Start a time vector
group.h(1,:) = [bot.h];

%[Env,bot,group] = EnvironSim(Env,bot,group);

%% Start the simulation!


[Env,bot,group] = EnvironSim_ISRR(Env,bot,group);

totalsim.env = Env;
totalsim.bot = bot;
totalsim.group = group;

% totalweight = 0;
% for i=1: n
%     fprintf('robot %d final weight: %f. final health: %f\n', i, totalsim.bot(i).wt, totalsim.bot(i).h);
%     totalweight = totalweight + totalsim.bot(i).wt;
% end

%fprintf('totalweight: %f\n', totalweight);


end


