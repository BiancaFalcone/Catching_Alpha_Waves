#include "pmod.h"
#include "microblaze_sleep.h"
#include "grove_adc.h"
#include "xil_io.h"
#include "xparameters.h"
#include "xgpio_l.h"

#define MAILBOX ((volatile unsigned*)0x00007000)
#define BASEADDR XPAR_SWSLEDS_GPIO_BASEADDR
#define SWITCH_OFFSET XGPIO_DATA_OFFSET
#define LED_OFFSET XGPIO_DATA2_OFFSET

void maschera(u8*);
void lampeggio(u8*);

int main()
{
	u32 adc_raw_value;
	u8 iop_pins[8], mask=0;
	u32 scl, sda;

	MAILBOX[0]=0;
	MAILBOX[1]=0;
	MAILBOX[2]=0;
	MAILBOX[3]=0;
	MAILBOX[4]=0;


	// Initialize the default switch
	configureSwitch(0, GPIO_0, GPIO_1, SDA, SDA, GPIO_4, GPIO_5, SCL, SCL);

	// Reset, set Tconvert x 32 (fconvert 27 ksps)
	write_adc(REG_ADDR_CONFIG, 0x20, 1);


	scl = 7; // scl pin
	sda = 3; // sda pin

	// standard config
	iop_pins[0] = GPIO_0;
	iop_pins[1] = GPIO_1;
	iop_pins[2] = GPIO_2;
	iop_pins[3] = GPIO_3;
	iop_pins[4] = GPIO_4;
	iop_pins[5] = GPIO_5;
	iop_pins[6] = GPIO_6;
	iop_pins[7] = GPIO_7;

	// applica configurazione custom
	iop_pins[scl] = SCL;
	iop_pins[sda] = SDA;

	// configura la crossbar
	configureSwitch(0, iop_pins[0], iop_pins[1], iop_pins[2],
				   iop_pins[3], iop_pins[4], iop_pins[5],
				   iop_pins[6], iop_pins[7]);
	xil_printf ("Bellaaaaaa!\n");
	maschera(&mask);
	MAILBOX[3]=15;
	while(MAILBOX[4]!=4){

		if (MAILBOX[2]==0){
			if ((MAILBOX[0]==1)){
					adc_raw_value = read_adc(REG_ADDR_RESULT);
					MAILBOX[1]=adc_raw_value;
					MAILBOX[2]=1;
			}
		}
	}

	lampeggio(&mask);
	xil_printf ("Frrrnuto!\n");

	return 0;
}
void maschera(u8 *mask){
	u8 value;
	int i;

	do{
		value = Xil_In8(BASEADDR+SWITCH_OFFSET);
		for(i=0;i<4;i++){
		*mask=(*mask|((value&(1<<i))));
		}
		if(*mask<15)
	   		Xil_Out8(BASEADDR+LED_OFFSET, *mask);

		else
			lampeggio(mask);

	}while (value!=15);
}
void lampeggio(u8 *mask){
	int i;
	   		for (i=0;i<3;i++){
				Xil_Out8(BASEADDR+LED_OFFSET, *mask);
	   			MB_Sleep(250);
	   			Xil_Out8(BASEADDR+LED_OFFSET, 0);
	  	  		MB_Sleep(250);
			}

}
