/*
 * grove_adc.h
 *
 *  Created on: Jun 16, 2016
 *      Author: polimi
 */

#ifndef GROVE_ADC_H_
#define GROVE_ADC_H_

/*
 * l'ADC e' mappato all'indirizzo 0x50
 * reference manual, sezione "I2C Address Setting"
 */
#define IIC_ADDRESS 0x50

// VRef = Va measured on the board
#define V_REF 3.10

/*
 * registri ADC
 * datasheet ADC, pag. 18
 */
#define REG_ADDR_RESULT        0x00 // registro dove leggere il risultato
#define REG_ADDR_ALERT         0x01
#define REG_ADDR_CONFIG        0x02
#define REG_ADDR_LIMITL        0x03
#define REG_ADDR_LIMITH        0x04
#define REG_ADDR_HYST          0x05
#define REG_ADDR_CONVL         0x06
#define REG_ADDR_CONVH         0x07

u32 read_adc(u8 reg);

void write_adc(u8 reg, u32 data, u8 bytes);

#endif /* GROVE_ADC_H_ */
