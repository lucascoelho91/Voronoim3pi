clear all
close all

fclose(instrfind);
r = m3pi('/dev/ttyUSB0', 9600, ['40';'AD';'58';'EE']);

r.connect();

r.stop();
r.disconnect();
fclose(instrfind);


r = m3pi('/dev/ttyUSB0', 9600, ['40';'AD';'59';'34']);
r.connect();

r.stop();
r.disconnect();
fclose(instrfind);

r = m3pi('/dev/ttyUSB0', 9600, ['40';'86';'B5';'15']);
r.connect();

r.stop();
r.disconnect();
fclose(instrfind);