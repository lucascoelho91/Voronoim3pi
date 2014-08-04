classdef m3pi < handle
   properties 
        portName     % port name (Linux: /dev/ttyUSB0, Windows: COM3)
        serialPort   % opened serial port
        address      % MAC address of the XBee board (usually the last 8 digits of the mac adderess, printed on the back of the receiver)
        baudrate     % baudrate of the connection
   end
   methods
       function robot = m3pi(portName, baudrate, address)
           robot.portName = portName;
           robot.baudrate = baudrate;
           robot.address = ['00';'13';'A2';'00'; address];
       end
       function connect(robot)
           robot.serialPort = serial(robot.portName, 'Baudrate', robot.baudrate);
           fopen(robot.serialPort);
       end
       
       function setSerialPort(robot, ser)
           robot.serialPort = ser;
       end
       
       function disconnect(robot)
           fclose(robot.serialPort);
       end
       
       function sendSpeed(robot, v, w)
           msg = sprintf('%1.2f/%1.2f', v, w);
           pckg = MakeTxPacket(robot.address, msg);
           fwrite(robot.serialPort, hex2dec(pckg), 'uint8');
       end
 
       function stop(robot)
           v = 0;
           w = 0;
           robot.sendSpeed(v, w);
       end
       
       function answer = getResp(robot)
           answer = fscanf(robot.serialPort, 'double');
       end
       
       function setPosition(robot, x, y, theta)
           robot.x = x;
           robot.y = y;
           robot.theta = theta;
       end
   end
   
end    