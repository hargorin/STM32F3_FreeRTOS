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
SRC+=stm32f3xx_it.c
SRC+=system_stm32f3xx.c
SRC+=main.c
SRC+=syscalls.c

# FreeRTOS Source Files
SRC+=port.c
SRC+=list.c
SRC+=queue.c
SRC+=tasks.c
SRC+=event_groups.c
SRC+=timers.c
SRC+=heap_4.c

# Standard Peripheral Source Files
# SRC+=misc.c
# SRC+=stm32f4xx_dcmi.c
# #SRC+=stm32f4xx_hash.c
# SRC+=stm32f4xx_rtc.c
# SRC+=stm32f4xx_adc.c
# SRC+=stm32f4xx_dma.c
# #SRC+=stm32f4xx_hash_md5.c
# SRC+=stm32f4xx_sai.c
# SRC+=stm32f4xx_can.c
# SRC+=stm32f4xx_dma2d.c
# #SRC+=stm32f4xx_hash_sha1.c
# SRC+=stm32f4xx_sdio.c
# SRC+=stm32f4xx_cec.c
# SRC+=stm32f4xx_dsi.c
# SRC+=stm32f4xx_i2c.c
# SRC+=stm32f4xx_spdifrx.c
# SRC+=stm32f4xx_crc.c
# SRC+=stm32f4xx_exti.c
# SRC+=stm32f4xx_iwdg.c
# SRC+=stm32f4xx_spi.c
# #SRC+=stm32f4xx_cryp.c
# SRC+=stm32f4xx_flash.c
# SRC+=stm32f4xx_lptim.c
# SRC+=stm32f4xx_syscfg.c
# #SRC+=stm32f4xx_cryp_aes.c
# SRC+=stm32f4xx_flash_ramfunc.c
# SRC+=stm32f4xx_ltdc.c
# SRC+=stm32f4xx_tim.c
# #SRC+=stm32f4xx_cryp_des.c
# #SRC+=stm32f4xx_fmc.c
# SRC+=stm32f4xx_pwr.c
# SRC+=stm32f4xx_usart.c
# #SRC+=stm32f4xx_cryp_tdes.c
# SRC+=stm32f4xx_fmpi2c.c
# SRC+=stm32f4xx_qspi.c
# SRC+=stm32f4xx_wwdg.c
# SRC+=stm32f4xx_dac.c
# SRC+=stm32f4xx_fsmc.c
# SRC+=stm32f4xx_rcc.c
# SRC+=stm32f4xx_dbgmcu.c
# SRC+=stm32f4xx_gpio.c
# SRC+=stm32f4xx_rng.c

# CDEFS=-DUSE_STDPERIPH_DRIVER
# CDEFS+=-DSTM32F3XX
# CDEFS+=-DSTM32F40_41xxx
# CDEFS+=-DHSE_VALUE=8000000
# CDEFS+=-D__FPU_PRESENT=1
# CDEFS+=-D__FPU_USED=1
# CDEFS+=-DARM_MATH_CM4

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