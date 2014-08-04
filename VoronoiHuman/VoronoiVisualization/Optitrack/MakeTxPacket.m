function packet =  MakeTxPacket(dest64, data_str)
% This function generates an API Transmit Request Packt
% INPUT: destination 64-bit address
% INPUT: RF data as a string
% OUTPUT: API Transmit Request Packet, in Hex
% EXAMPLE:
% -- dest64 = ['00';'13';'A2';'00';'40';'AB';'BB';'BA'];
% -- data_str = 'Hello World'

% Packet Header
start = '7E';

% Packet Frame Type and ID
ftype = '10';
fid = '01';

% 16-bit Destination Address
dest16 = ['FF';'FE'];

% Buffer Rate
br = '00';

% Options
opt = '00';

% Convert the data string into hex
data_pack = dec2hex(data_str);

% Combine packet for length and checksum
mid = [ftype ; fid ; dest64 ; dest16 ; br ; opt ; data_pack];

% Find the length in hex, then break into string
Lhex = dec2hex(length(mid),4);
Length = [Lhex(1:2) ; Lhex(3:4)];

% Sum the packet for the checksum
p1 = dec2hex(sum(hex2dec(mid)));

% Calculate the checksum
checksum = dec2hex(hex2dec('FF') - hex2dec(p1(end-1:end)));

% Combine the entire hex packet
packet = [start ; Length ; mid ; checksum];
