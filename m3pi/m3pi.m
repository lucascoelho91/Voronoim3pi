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
           robot.address = ['00';'13';'A2';'00'; address]; % the first 4 bytes are pre definied based on the device, in this case, XBee
       end
       function connect(robot)
           robot.serialPort = serial(robot.portName, 'Baudrate', robot.baudrate);  % opens the serial port
           fopen(robot.serialPort);
       end
       
       function setSerialPort(robot, ser)
           robot.serialPort = ser;          % set the serial port, useful if the port is already open
       end
       
       function disconnect(robot)
           fclose(robot.serialPort);    % closes the connection with the port
       end
       
       function sendSpeed(robot, v, w)
           msg = sprintf('%1.2f/%1.2f', v, w);  
           pckg = MakeTxPacket(robot.address, msg);   % builds the data package
           fwrite(robot.serialPort, hex2dec(pckg), 'uint8'); % sends the package to the robot
       end
 
       function stop(robot)
           v = 0;
           w = 0;
           robot.sendSpeed(v, w);
       end
   end
   
end    