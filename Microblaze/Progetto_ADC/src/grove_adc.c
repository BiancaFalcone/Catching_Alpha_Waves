/******************************************************************************
 *  Copyright (c) 2016, Xilinx, Inc.
 *  All rights reserved.
 * 
 *  Redistribution and use in source and binary forms, with or without 
 *  modification, are permitted provided that the following conditions are met:
 *
 *  1.  Redistributions of source code must retain the above copyright notice, 
 *     this list of conditions and the following disclaimer.
 *
 *  2.  Redistributions in binary form must reproduce the above copyright 
 *      notice, this list of conditions and the following disclaimer in the 
 *      documentation and/or other materials provided with the distribution.
 *
 *  3.  Neither the name of the copyright holder nor the names of its 
 *      contributors may be used to endorse or promote products derived from 
 *      this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 *  OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 *  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
 *  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 *  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *****************************************************************************/
/******************************************************************************
 *
 *
 * @file grove_adc.c
 *
 * IOP code (MicroBlaze) for grove ADC121C021.
 * Grove ADC is read only, and has IIC interface
 * Operations implemented:
 *  1. Simple, single read from sensor, and write to data area.
 *  2. Continuous read from sensor and log to data area.
 * Hardware version 1.2.
 * http://www.ti.com/lit/ds/symlink/adc121c021-q1.pdf
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who  Date     Changes
 * ----- --- ------- -----------------------------------------------
 * 1.00a cmc 04/06/16 release
 * 1.00b yrq 05/02/16 support 2 stickit sockets
 * 1.00c yrq 05/27/16 fix pmod_init()
 *
 * </pre>
 *
 *****************************************************************************/

#include "pmod.h"
#include "grove_adc.h"

/*
 * leggi 2 byte dall'ADC tramite I2C
 */
u32 read_adc(u8 reg){
   u8 data_buffer[2];
   u32 sample;
   
   data_buffer[0] = reg; // imposta il registro da leggere
   iic_write(0, IIC_ADDRESS, data_buffer, 1); // invia il registro da leggere
  
   iic_read(0, IIC_ADDRESS,data_buffer,2); // leggi il registro selezionato

   /* l'ADC ha una precisione di 12 bit
    * il primo byte ricevuto (data_buffer[0]) contiene i 4 bit piu' significativi,
    * da cui pulisco gli altri 4 con "& 0x0f"; quindi, shifto questi bit a sinistra
    * di b posizioni e aggiungo in fondo gli altri 8 bit meno significativi
    * (con | data_buffer[1]).
    */
   sample = ((data_buffer[0] & 0x0f) << 8) | data_buffer[1];
   return sample;
}


// Write a number of bytes to a Register
// Maximum of 2 data bytes can be written in one transaction
void write_adc(u8 reg, u32 data, u8 bytes){
   u8 data_buffer[3];
   data_buffer[0] = reg;
   if(bytes ==2){
      data_buffer[1] = data & 0x0f; // Bits 11:8
      data_buffer[2] = data & 0xff; // Bits 7:0
   }else{
      data_buffer[1] = data & 0xff; // Bits 7:0
   }
     
   iic_write(0, IIC_ADDRESS, data_buffer, bytes+1);

}


