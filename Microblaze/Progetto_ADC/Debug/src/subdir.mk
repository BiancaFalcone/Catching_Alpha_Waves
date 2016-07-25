################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/Progetto_ADC.c \
../src/grove_adc.c \
../src/platform.c \
../src/pmod.c 

OBJS += \
./src/Progetto_ADC.o \
./src/grove_adc.o \
./src/platform.o \
./src/pmod.o 

C_DEPS += \
./src/Progetto_ADC.d \
./src/grove_adc.d \
./src/platform.d \
./src/pmod.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -I../../Progetto_ADC_bsp/mb_JB_mb_1/include -mlittle-endian -mcpu=v9.5 -mxl-soft-mul -Wl,--no-relax -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


