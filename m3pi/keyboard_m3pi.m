% Close all existing ports (in case it was improperly closed) 

%fclose(instrfind); 

clear all
close all
clc

speedL = 0.2;
speedW = 0.2;

% %fclose(instrfind);
r = m3pi('/dev/ttyUSB0', 9600, ['40';'AE';'BB';'10']);
r2 = m3pi('/dev/ttyUSB0', 9600, ['40';'AD';'59';'34']);


r.connect();

r2.setSerialPort(r.serialPort);


%Print a command
rc = r;
c = 0;
while(c ~= 'p')
    c = getkey();
    if c == 'w'
        rc.sendSpeed(speedL, 0);
    elseif c == 'a'
        rc.sendSpeed(0, speedW);
    elseif c == 's'
        rc.sendSpeed(-speedL, 0);
    elseif c == 'd'
        rc.sendSpeed(0, -speedW);
    elseif c == 'x'
        rc.stop();
    elseif c == 't'
        speedL = speedL*1.1
    elseif c == 'g'
        speedL = speedL*0.9
    elseif c == 'c'
        speedW = speedW*1.1
    elseif c == 'v'
        speedW = speedW*0.9
    elseif c == '1'
        rc = r;
    elseif c== '2' 
        rc = r2;
    end
end
        
r.stop();
r2.stop();
r.disconnect();

fclose(instrfind);        