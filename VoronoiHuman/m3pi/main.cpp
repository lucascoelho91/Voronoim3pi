#include "mbed.h"
#include "XBee.h"
#include "m3pi.h"
#include <string>

m3pi pi;
XBee xbee(p28, p27); //tx,rx
//XBeeAddress64 remoteAddress(0x0013A200, 0x40AD58EE);  // Specify  XBee address
Serial pc(USBTX, USBRX);
DigitalOut led1(LED1);
DigitalOut led2(LED2);
//XBeeResponse response = XBeeResponse(); // create reusable response objects for responses we expect to handle
ZBRxResponse rx = ZBRxResponse();

int main()
{
    pi.cls(); //clear lcd
    xbee.begin(9600); //same baud rate as xbees
    while(true) {
        xbee.readPacket(); //check for packet
        if (xbee.getResponse().isAvailable()) { //got a packet
            if (xbee.getResponse().getApiId() == ZB_RX_RESPONSE) { // got a ZBRx packet
                xbee.getResponse().getZBRxResponse(rx);
                pi.locate(0,0);
                pi.printf("+");
                pi.locate(0,1);
               // string c="";
                string data="";
                for(int i=0; i< rx.getDataLength(); i++) {
                    //c=rx.getData(i);
                    data+=rx.getData(i);
                  //  pc.printf("%s\n",c);
                }
                pc.printf("%s\n",data);
                char *str;
                strcpy(str, data.c_str());
                char speed1[32], speed2[32];
                strcpy(speed1, strtok(str , "/"));
                strcpy(speed2, strtok(NULL, "/"));
                float lspeed=atof(speed1);
                float rspeed=atof(speed2);
                pi.left_motor(lspeed);
                pi.right_motor(rspeed);
            } 
            
            }
            else if (xbee.getResponse().isError()) {
                pi.locate(0,0);
                pi.printf("Error");
            }
    }
}