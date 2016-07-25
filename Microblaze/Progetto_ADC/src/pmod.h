/*
 * pmod.h
 * Common header file for all PMOD IOP applications
 * API and drivers for IIC, SPI
 * Includes address mappings, and API for GPIO, SPI and IIC,
 * IOP Switch pin mappings and configuration
 * 
 * 
 * Author: cmccabe
 * Version 1.0 19 Nov 2015
 *
 *
 */

#ifndef PMOD_H_
#define PMOD_H_

#include "xparameters.h"
#include "xspi.h"      /* SPI device driver */
#include "xspi_l.h"

// Memory map
// pmod 1
#define IIC_BASEADDR_1      XPAR_IIC_0_BASEADDR // base address of I2C
#define SPI_BASEADDR_1      XPAR_SPI_0_BASEADDR // base address of QSPI
#define SWITCH_BASEADDR_1    XPAR_MB_JB_MB1_PMOD_IO_SWITCH_IP_S00_AXI_BASEADDR // Base address of switch

// pmod 2
#define IIC_BASEADDR_2      XPAR_IIC_1_BASEADDR // base address of I2C
#define SPI_BASEADDR_2      XPAR_SPI_1_BASEADDR // base address of QSPI
#define SWITCH_BASEADDR_2    XPAR_MB_JC_MB2_PMOD_IO_SWITCH_IP_S00_AXI_BASEADDR // Base address of switch

// pmod 3
#define IIC_BASEADDR_3      XPAR_IIC_2_BASEADDR // base address of I2C
#define SPI_BASEADDR_3      XPAR_SPI_2_BASEADDR // base address of QSPI
#define SWITCH_BASEADDR_3    XPAR_MB_JD_MB3_PMOD_IO_SWITCH_IP_S00_AXI_BASEADDR // Base address of switch

// pmod 4
#define IIC_BASEADDR_4      XPAR_IIC_3_BASEADDR // base address of I2C
#define SPI_BASEADDR_4      XPAR_SPI_3_BASEADDR // base address of QSPI
#define SWITCH_BASEADDR_4    XPAR_MB_JE_MB4_PMOD_IO_SWITCH_IP_S00_AXI_BASEADDR // Base address of switch

#define GPIO             XPAR_GPIO_0_BASEADDR

#define MAILBOX_CMD_ADDR       (*(volatile u32 *)(0x00007FFC)) // command from A9 to MB

#define MAILBOX_DATA(x)        (*(volatile u32 *)(0x00007000 +((x)*4))) 
#define MAILBOX_DATA_PTR(x)    ( (volatile u32 *)(0x00007000 +((x)*4)))
 
#define MAILBOX_DATA_FLOAT(x)     (*(volatile float *)(0x00007000 +((x)*4))) 
#define MAILBOX_DATA_FLOAT_PTR(x) ( (volatile float *)(0x00007000 +((x)*4))) 


// Switch mappings used for IOP Switch configuration
#define GPIO_0 0x0
#define GPIO_1 0x1
#define GPIO_2 0x2
#define GPIO_3 0x3
#define GPIO_4 0x4
#define GPIO_5 0x5
#define GPIO_6 0x6
#define GPIO_7 0x7
#define SCL    0x8
#define SDA    0x9
#define SPICLK 0xa
#define MISO   0xb
#define MOSI   0xc
#define SS     0xd
#define BLANK  0xe

// SPI API
// Predefined Control signals macros found in xspi_l.h
#define SPI_INHIBIT (XSP_CR_TRANS_INHIBIT_MASK|XSP_CR_MANUAL_SS_MASK|XSP_CR_ENABLE_MASK|XSP_CR_MASTER_MODE_MASK)
#define SPI_RELEASE (XSP_CR_MANUAL_SS_MASK|XSP_CR_MASTER_MODE_MASK|XSP_CR_ENABLE_MASK)

void spi_init(u8 peripheral);
void spi_transfer(u8 peripheral, u8 numBytes, u8* readData, u8* writeData);

// IIC API
int iic_read(u8 peripheral, u32 addr, u8* buffer, u8 numbytes);
int iic_write(u8 peripheral, u32 addr, u8* buffer, u8 numbytes);

void delay_ms(u32 ms_count);

// Switch Configuration
void configureSwitch(u8 peripheral, char pin1, char pin2, char pin3, char pin4, char pin5, char pin6, char pin7, char pin8);

#endif /* PMOD_H_ */
