/*
 * PMOD API functions
 * IIC, SPI, and IOP switch configuration functions
 * 
 * Author: cmccabe
 * Version 1.0 19 Nov 2015
 *
 */

#include "pmod.h"

/* indirizzi base di I2C, SPI e crossbar: gli indirizzi per PMOD1-4
 * corrispondono agli elementi 0-3 degli array
 */
u32 SPI_BASE[4] = {SPI_BASEADDR_1, SPI_BASEADDR_2, SPI_BASEADDR_3, SPI_BASEADDR_4};
u32 I2C_BASE[4] = {IIC_BASEADDR_1, IIC_BASEADDR_2, IIC_BASEADDR_3, IIC_BASEADDR_4};
u32 SWITCH_BASE[4] = {SWITCH_BASEADDR_1, SWITCH_BASEADDR_2, SWITCH_BASEADDR_3, SWITCH_BASEADDR_4};

// ora bisogna specificare anche il numero di periferica (0-3)
void spi_transfer(u8 peripheral, u8 numBytes, u8* readData, u8* writeData)
{
   u8 i; // Byte counter
   u32 BaseAddress = SPI_BASE[peripheral];

   Xil_Out32(BaseAddress+XSP_SSR_OFFSET, 0xfe); // CS Low
   Xil_Out32(BaseAddress+XSP_CR_OFFSET, SPI_INHIBIT ); // Disable transactions (inhibit master)

   // Write SPI
   for(i=0;i< numBytes; i++){
      Xil_Out32(BaseAddress+XSP_DTR_OFFSET, writeData[i]);  // Data Transfer Register (FIFO)
   }

   Xil_Out32(BaseAddress+XSP_CR_OFFSET, SPI_RELEASE);    // Enable transactions

   while(((Xil_In32(BaseAddress+XSP_SR_OFFSET) & 0x04)) != 0x04);
   delay_ms(1);

   // Read SPI
   for(i=0;i< numBytes; i++){
      readData[i] = Xil_In32(BaseAddress+XSP_DRR_OFFSET); // Data Read Register (FIFO)
   }
   Xil_Out32(BaseAddress+XSP_SSR_OFFSET, 0xff);   // CS de-select

}

// anche qui, specificare il numero di periferica (0-3)
void spi_init(u8 peripheral)
{
   u32 Control;
   u32 BaseAddress = SPI_BASE[peripheral];;

   // Reset SPI
   XSpi_WriteReg(BaseAddress, XSP_SRR_OFFSET, 0xa);
   // Master mode
   Control = Xil_In32(BaseAddress+XSP_CR_OFFSET);
   Control |= XSP_CR_MASTER_MODE_MASK; // Master Mode
   Control |= XSP_CR_ENABLE_MASK; // Enable SPI
   Control |= XSP_INTR_SLAVE_MODE_MASK; // Slave select manually
   Control |= XSP_CR_TRANS_INHIBIT_MASK; // Disable Transmitter
   Xil_Out32(BaseAddress+XSP_CR_OFFSET, Control);
}

// anche qui, aggiunto il numero di periferica (0-3)
int iic_read(u8 peripheral, u32 addr, u8* buffer, u8 numbytes)
{
    u32 rxCnt = 0;
    u32 timeout = 0xffff;
    u32 BaseAddress = I2C_BASE[peripheral];

    // Set RX FIFO Depth to numbytes+1 (addrbyte + numbytes)
    Xil_Out32((BaseAddress + 0x120), numbytes+1);
    
    // Reset TX FIFO
    Xil_Out32((BaseAddress + 0x100), 0x002);
    
    // Enable IIC Core
    Xil_Out32((BaseAddress + 0x100), 0x001);
    delay_ms(1);

    // Transmit 7-bit address and Read bit
    Xil_Out32((BaseAddress + 0x108), (0x101 | addr << 1));
    
    // Program IIC Core to read numbytes bytes
    // and issue a STOP bit afterwards
    Xil_Out32((BaseAddress + 0x108), 0x200 + numbytes);
    

    while(rxCnt < numbytes) {

      // Wait for data to be available in RX FIFO
      while((Xil_In32(BaseAddress + 0x104) & 0x40) && (timeout--));

      if(timeout==-1)
	return rxCnt;

      // Read data 
      buffer[rxCnt] = Xil_In32(BaseAddress + 0x10c) & 0xff;

      rxCnt++;
      delay_ms(1);

    }

    return rxCnt;

}

// anche qui, aggiunto il numero di periferica (0-3)
int iic_write(u8 peripheral, u32 addr, u8* buffer, u8 numbytes)
{
    u32 txCnt = 0;
    u32 txWord = 0;
    u32 timeout = 0xffff;
    u32 BaseAddress = I2C_BASE[peripheral];

   // Reset TX FIFO
    Xil_Out32((BaseAddress + 0x100), 0x002);
    
    // Enable IIC Core
    Xil_Out32((BaseAddress + 0x100), 0x001);
    delay_ms(1);
    
    // Transmit 7-bit address and Write bit
    Xil_Out32((BaseAddress + 0x108), (0x100 | addr << 1));
    
    // Transmit data      
    while((txCnt < numbytes) && (timeout > 0)) {

      timeout = 0xffff;
      
      // Put the Tx data into the Tx FIFO (last word gets STOP bit)      
      if (txCnt == numbytes - 1)
	txWord = (0x200 | buffer[txCnt]);
      else
	txWord = buffer[txCnt];
      
      Xil_Out32((BaseAddress + 0x108),txWord);

      while ( (Xil_In32(BaseAddress + 0x104) & 0x80) == 0x00 && (timeout--));

      if(timeout==-1)
	return txCnt;

      txCnt++;
    }

    delay_ms(1);
    return txCnt;
}


void delay_ms(u32 ms_count)
{
   u32 count;
   for (count = 0; count < ((ms_count * 2500) + 1); count++)
   {
      asm("nop");
   }
}


/*
 * Switch Configuration
 * 8 input chars, each representing the connection for 1 PMOD pin
 * Only the least significant 4-bits for each input char is used
 *
 * Configuration is done by writing a 32 bit value to the switch.
 * The 32-bit value represents 8 x 4-bit values concatenated; One 4-bit value to configure each PMOD pin.
 * PMOD pin 8 = bits [31:28]
 * PMOD pin 7 = bits [27:24]
 * PMOD pin 6 = bits [23:20]
 * PMOD pin 5 = bits [19:16]
 * PMOD pin 4 = bits [15:12]
 * PMOD pin 3 = bits [11:8]
 * PMOD pin 2 = bits [7:4]
 * PMOD pin 1 = bits [3:0]
 * e.g. Write GPIO 0 - 7 to PMOD 1-8 => switchConfigValue = 0x76543210
 */
// anche qui, aggiunto il numero di periferica (0-3) come parametro iniziale
void configureSwitch(u8 peripheral, char pin1, char pin2, char pin3, char pin4, char pin5, char pin6, char pin7, char pin8){
   u32 switchConfigValue;
   u32 BaseAddress = SWITCH_BASE[peripheral];

   // Calculate switch configuration value
   switchConfigValue = (pin8<<28)|(pin7<<24)|(pin6<<20)|(pin5<<16)|(pin4<<12)|(pin3<<8)|(pin2<<4)|(pin1);

   Xil_Out32(BaseAddress+0x4,0x00000000); // isolate switch by writing 0 to bit 31
   Xil_Out32(BaseAddress, switchConfigValue); // Set pin configuration
   Xil_Out32(BaseAddress+0x4,0x80000000); // Re-enable Swtch by writing 1 to bit 31
}
