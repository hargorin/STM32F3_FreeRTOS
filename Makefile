# ---------------------------------------------------------------------------
# Makefile for FreeRTOS projects on stm32f3discovery board 
# (c) 2020, Jan Stocker
# ---------------------------------------------------------------------------

TARGET:=FreeRTOS
# ---------------------------------------------------------------------------
# toolchain to use - if not in system search path, prefix toolchain with path!
# ---------------------------------------------------------------------------
TOOLCHAIN=arm-none-eabi-
CC=$(TOOLCHAIN)gcc
LD=$(TOOLCHAIN)gcc
OBJCOPY=$(TOOLCHAIN)objcopy
AS=$(TOOLCHAIN)as
AR=$(TOOLCHAIN)ar
GDB=$(TOOLCHAIN)gdb
SIZE=$(TOOLCHAIN)size

# Optimization level, can be [0, 1, 2, 3, s].
OPTLVL:=0 #Todo
DBG:=-g #Todo

# ---------------------------------------------------------------------------
# definition of project source files and directory structure
# ---------------------------------------------------------------------------
FREERTOS:=$(CURDIR)/FreeRTOS/FreeRTOS/Source
STARTUP:=$(CURDIR)/hardware
LINKER_SCRIPT:=$(CURDIR)/Utilities/STM32F303VCTx_FLASH.ld

INCLUDE=-I$(CURDIR)/hardware
INCLUDE+=-I$(FREERTOS)/include
INCLUDE+=-I$(FREERTOS)/portable/GCC/ARM_CM4F
INCLUDE+=-I$(CURDIR)/Libraries/CMSIS/Device/STM32F3xx/Include
INCLUDE+=-I$(CURDIR)/Libraries/CMSIS/Include
INCLUDE+=-I$(CURDIR)/Libraries/CMSIS/RTOS
INCLUDE+=-I$(CURDIR)/Libraries/STM32F3xx_HAL_Driver/Inc
INCLUDE+=-I$(CURDIR)/config

BUILD_DIR = $(CURDIR)/build
BIN_DIR = $(CURDIR)/binary

# vpath is used so object files are written to the current directory instead
# of the same directory as their source files
vpath %.c $(CURDIR)/Libraries/STM32F3xx_HAL_Driver/Src \
          $(CURDIR)/Libraries/syscall $(CURDIR)/hardware $(FREERTOS) \
          $(FREERTOS)/portable/MemMang $(FREERTOS)/portable/GCC/ARM_CM4F 

vpath %.s $(STARTUP)
ASRC=startup_stm32f303xc.s

# Project Source Files
SRC+=main.c

SRC+=stm32f3xx_it.c
SRC+=system_stm32f3xx.c
SRC+=syscalls.c

# FreeRTOS Source Files
SRC+=port.c
SRC+=list.c
SRC+=queue.c
SRC+=tasks.c
SRC+=event_groups.c
SRC+=timers.c
SRC+=heap_4.c

# HAL Source Files
SRC+=stm32f3xx_hal_adc.c
SRC+=stm32f3xx_hal_adc_ex.c
SRC+=stm32f3xx_hal.c
SRC+=stm32f3xx_hal_can.c
SRC+=stm32f3xx_hal_cec.c
SRC+=stm32f3xx_hal_comp.c
SRC+=stm32f3xx_hal_cortex.c
SRC+=stm32f3xx_hal_crc.c
SRC+=stm32f3xx_hal_crc_ex.c
SRC+=stm32f3xx_hal_dac.c
SRC+=stm32f3xx_hal_dac_ex.c
SRC+=stm32f3xx_hal_dma.c
SRC+=stm32f3xx_hal_exti.c
SRC+=stm32f3xx_hal_flash.c
SRC+=stm32f3xx_hal_flash_ex.c
SRC+=stm32f3xx_hal_gpio.c
SRC+=stm32f3xx_hal_hrtim.c
SRC+=stm32f3xx_hal_i2c.c
SRC+=stm32f3xx_hal_i2c_ex.c
SRC+=stm32f3xx_hal_i2s.c
SRC+=stm32f3xx_hal_i2s_ex.c
SRC+=stm32f3xx_hal_irda.c
SRC+=stm32f3xx_hal_iwdg.c
SRC+=stm32f3xx_hal_msp_template.c
SRC+=stm32f3xx_hal_nand.c
SRC+=stm32f3xx_hal_nor.c
SRC+=stm32f3xx_hal_opamp.c
SRC+=stm32f3xx_hal_opamp_ex.c
SRC+=stm32f3xx_hal_pccard.c
SRC+=stm32f3xx_hal_pcd.c
SRC+=stm32f3xx_hal_pcd_ex.c
SRC+=stm32f3xx_hal_pwr.c
SRC+=stm32f3xx_hal_pwr_ex.c
SRC+=stm32f3xx_hal_rcc.c
SRC+=stm32f3xx_hal_rcc_ex.c
SRC+=stm32f3xx_hal_rtc.c
SRC+=stm32f3xx_hal_rtc_ex.c
SRC+=stm32f3xx_hal_sdadc.c
SRC+=stm32f3xx_hal_smartcard.c
SRC+=stm32f3xx_hal_smartcard_ex.c
SRC+=stm32f3xx_hal_smbus.c
SRC+=stm32f3xx_hal_spi.c
SRC+=stm32f3xx_hal_spi_ex.c
SRC+=stm32f3xx_hal_sram.c
SRC+=stm32f3xx_hal_tim.c
#SRC+=stm32f3xx_hal_timebase_rtc_alarm_template.c
#SRC+=stm32f3xx_hal_timebase_rtc_wakeup_template.c
#SRC+=stm32f3xx_hal_timebase_tim_template.c
SRC+=stm32f3xx_hal_tim_ex.c
SRC+=stm32f3xx_hal_tsc.c
SRC+=stm32f3xx_hal_uart.c
SRC+=stm32f3xx_hal_uart_ex.c
SRC+=stm32f3xx_hal_usart.c
SRC+=stm32f3xx_hal_usart_ex.c
SRC+=stm32f3xx_hal_wwdg.c

# CDEFS=-DUSE_STDPERIPH_DRIVER
# CDEFS+=-DSTM32F3XX
# CDEFS+=-DSTM32F40_41xxx
# CDEFS+=-DHSE_VALUE=8000000
# CDEFS+=-D__FPU_PRESENT=1
# CDEFS+=-D__FPU_USED=1
# CDEFS+=-DARM_MATH_CM4
CDEFS =-DSTM32F3XX 
CDEFS+=-DUSE_HAL_DRIVER

MCUFLAGS=-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -fsingle-precision-constant -finline-functions -Wdouble-promotion -std=gnu99
COMMONFLAGS=-O$(OPTLVL) $(DBG) -Wall -ffunction-sections -fdata-sections
CFLAGS=$(COMMONFLAGS) $(MCUFLAGS) $(INCLUDE) $(CDEFS)

LDLIBS=-lm -lc -lgcc
LDFLAGS=$(MCUFLAGS) -u _scanf_float -u _printf_float -fno-exceptions -Wl,--gc-sections,-T$(LINKER_SCRIPT),-Map,$(BIN_DIR)/$(TARGET).map



OBJ = $(SRC:%.c=$(BUILD_DIR)/%.o)

$(BUILD_DIR)/%.o: %.c
	@echo [CC] $(notdir $<)
	@$(CC) $(CFLAGS) $< -c -o $@

all: $(OBJ)
	@echo [AS] $(ASRC)
	@$(AS) -o $(ASRC:%.s=$(BUILD_DIR)/%.o) $(STARTUP)/$(ASRC)
	@echo [LD] $(TARGET).elf
	@$(CC) -o $(BIN_DIR)/$(TARGET).elf $(LDFLAGS) $(OBJ) $(ASRC:%.s=$(BUILD_DIR)/%.o) $(LDLIBS)
	@echo [HEX] $(TARGET).hex
	@$(OBJCOPY) -O ihex $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).hex
	@echo [BIN] $(TARGET).bin
	@$(OBJCOPY) -O binary $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).bin

.PHONY: clean

clean:
	@echo [RM] OBJ
	@rm -f $(OBJ)
	@rm -f $(ASRC:%.s=$(BUILD_DIR)/%.o)
	@echo [RM] BIN
	@rm -f $(BIN_DIR)/$(TARGET).elf
	@rm -f $(BIN_DIR)/$(TARGET).hex
	@rm -f $(BIN_DIR)/$(TARGET).bin

flash:
	@st-flash write $(BIN_DIR)/$(TARGET).bin 0x8000000