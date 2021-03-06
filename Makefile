# ---------------------------------------------------------------------------
# Makefile for FreeRTOS projects on stm32f3discovery board 
# (c) 2020, Jan Stocker
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# toolchain to use - if not in system search path, prefix toolchain with path!
# ---------------------------------------------------------------------------
TOOLCHAIN=arm-none-eabi-
CC=$(TOOLCHAIN)gcc
OBJCOPY=$(TOOLCHAIN)objcopy
SIZE=$(TOOLCHAIN)size

# ---------------------------------------------------------------------------
# definition of project source files and directory structure
# ---------------------------------------------------------------------------

# define where to create the elf and map output files
TARGET = build/main

# source folders
MAIN_DIR 								= .
FREERTOS_DIR						= FreeRTOS/FreeRTOS/Source
STM32F3_HAL_DIR 				= STM32CubeF3/Drivers/STM32F3xx_HAL_Driver
STM32F3_DISCOVERY_DIR		= STM32CubeF3/Drivers/BSP/STM32F3-Discovery
CMSIS_DIR								= system/CMSIS
DIAG_DIR								= system/diag
NEWLIB_DIR							= system/newlib

# build gcc options for include search paths
INCLUDES = \
-I$(MAIN_DIR)/inc \
-I$(FREERTOS_DIR)/include \
-I$(FREERTOS_DIR)/portable/GCC/ARM_CM4F \
-I$(STM32F3_HAL_DIR)/Inc \
-I$(STM32F3_DISCOVERY_DIR)/ \
-I$(CMSIS_DIR)/ \
-I$(DIAG_DIR)/inc

# source files in each source folders
MAIN_SRCS = \
main.c

# STM32F3_DISCOVERY_SRCS = \
# ili9341.c \
# l3gd20.c \
# stm32f429i_discovery.c \
# stm32f429i_discovery_eeprom.c \
# stm32f429i_discovery_gyroscope.c \
# stm32f429i_discovery_io.c \
# stm32f429i_discovery_lcd.c \
# stm32f429i_discovery_sdram.c \
# stm32f429i_discovery_ts.c \
# stm32f4xx_hal_timebase_tim.c \
# stm32f4xx_it.c \
# stmpe811.c \
# system_stm32f4xx.c \
# ts_calibration.c 

# STM32F3_HAL_SRCS = \
# stm32f4xx_hal.c \
# stm32f4xx_hal_cortex.c \
# stm32f4xx_hal_dma.c \
# stm32f4xx_hal_dma2d.c \
# stm32f4xx_hal_flash.c \
# stm32f4xx_hal_gpio.c \
# stm32f4xx_hal_i2c.c \
# stm32f4xx_hal_iwdg.c \
# stm32f4xx_hal_ltdc.c \
# stm32f4xx_hal_pwr.c \
# stm32f4xx_hal_rcc.c \
# stm32f4xx_hal_rcc_ex.c \
# stm32f4xx_hal_rtc_ex.c \
# stm32f4xx_hal_sdram.c \
# stm32f4xx_hal_spi.c \
# stm32f4xx_hal_tim.c \
# stm32f4xx_hal_tim_ex.c \
# stm32f4xx_ll_fmc.c \
# stm32f4xx_hal_uart.c

NEWLIB_SRCS = \
_exit.c \
_sbrk.c \
_startup.c \
_syscalls.c \
assert.c 

FREERTOS_SRCS = \
portable/GCC/ARM_CM4F/port.c \
croutine.c \
event_groups.c \
list.c \
queue.c \
stream_buffer.c \
tasks.c \
timers.c \
portable/MemMang/heap_1.c


SRCS = \
$(MAIN_SRCS:%=$(MAIN_DIR)/src/%) \
$(FREERTOS_SRCS:%=$(FREERTOS_DIR)/%) \
$(STM32F3_HAL_SRCS:%=$(STM32F3_HAL_DIR)/Src/%) \
$(STM32F3_DISCOVERY_SRCS:%=$(STM32F3_DISCOVERY_DIR)/%) \
$(CMSIS_SRCS:%=$(CMSIS_DIR)/%) \
$(DIAG_SRCS:%=$(DIAG_DIR)/src/%) \
$(NEWLIB_SRCS:%=$(NEWLIB_DIR)/%) 

OBJS = $(SRCS:.c=.o)

# ---------------------------------------------------------------------------
# Compiler and linker flags
# ---------------------------------------------------------------------------

# switch off compiler optimisation by selecting -O0 only for gdb debugging, otherwise use -O2 or -Os for common speed or size optimisation
#CFLAGS += -O0 -g3 -DDEBUG
CFLAGS += -Os -g3 -DDEBUG 

CFLAGS += -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 
CFLAGS += -DSTM32F30x -DUSE_HAL_DRIVER -DHSE_VALUE=8000000 
CFLAGS += -std=gnu11 
CFLAGS += -Wall -Wextra -fmessage-length=0 
CFLAGS += -fsigned-char -ffunction-sections -fdata-sections -ffreestanding -fno-move-loop-invariants
CFLAGS += $(INCLUDES) 
CFLAGS += -MMD -MP -MF dep/$(@F:%.o=%.d) -MT$(@)

#CFLAGS += -DUSE_FULL_ASSERT -DTRACE -DOS_USE_TRACE_SEMIHOSTING_DEBUG # deactivated because semihosting trace_printf() seems not to work reliable


LDFLAGS = -L ldscripts -T mem.ld -T libs.ld -T sections.ld
LDFLAGS += -Wl,-Map,$(TARGET).map -o$(TARGET).elf
LDFLAGS += -nostartfiles -Xlinker --gc-sections --specs=nano.specs 
LDFLAGS += -u _printf_float # needed on newlib to enable printf float ("%f") support 
LDFLAGS += -u uxTopUsedPriority  # uxTopUsedPriority is used by openocd to let gdb show FreeRTOS threads (see rule gdbserver)

#LDFLAGS += -nostdlib # add only you may use this if nothing at all of newlib is used
#LDFLAGS = -Xlinker --no-gc-sections # try this if gdb debugger crashes (gdb might crash with openocd flag '-rtos auto' as well!)   


# ---------------------------------------------------------------------------
# Rules for programming and gdbserver via OpenOCD 
# Remark: on Windows Win-USB driver needs to be installed eg. by 'zadig' or by stlink driver zip
# ---------------------------------------------------------------------------

OPENOCD = openocd
#OPENOCD = /opt/openocd-0.10.0-201701241841/bin/openocd

#OOCD_INIT  = -f board/stm32f429discovery.cfg
OOCD_INIT  = -f board/stm32f429disc1.cfg
OOCD_INIT  += -c "telnet_port 3334" # redefined because default of 4444 conflicts on some windows systems
OOCD_INIT  += -c init
OOCD_INIT  += -c "reset init"
#OOCD_INIT += -c "targets"

#OOCD_FLASH = -c "reset halt" # some cpus needs a 'reset halt' before flashing 
OOCD_FLASH += -c "flash write_image erase $(TARGET).elf"
OOCD_FLASH += -c "verify_image $(TARGET).elf"
OOCD_FLASH += -c "reset run"
OOCD_FLASH += -c shutdown

  
flash: $(TARGET).elf
	$(OPENOCD)  $(OOCD_INIT) $(OOCD_FLASH)


gdbserver:
	$(OPENOCD)  $(OOCD_INIT) # -c "stm32f4x.cpu configure -rtos auto"  # Warning: '-c ... -rtos auto' enables gdb/FreeRTOS task list support which might crash openocd on Windows! 


killgdbserver:
ifdef windir
	taskkill /IM $(OPENOCD).exe /F
else
	killall openocd
endif

# ---------------------------------------------------------------------------
# build rules
# ---------------------------------------------------------------------------

all: $(TARGET).elf size flash 

$(OBJS) : %.o : %.c
	@echo Compiling $< ...
	$(CC) -c $(CFLAGS) $< -o $@ 2>&1


$(TARGET).elf : $(OBJS)
	@echo  Linking $(PWD)/$@ ...
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) $(LDFLAGS)  2>&1


#$(TARGET).bin : $(TARGET).elf
# @echo Extracting $< ...
# $(OBJCOPY) $(TARGET).elf -O binary $(TARGET).bin


size: $(TARGET).elf
	$(SIZE) -B $(TARGET).elf


clean:
	rm $(OBJS) dep/* $(TARGET).elf $(TARGET).map

# ---------------------------------------------------------------------------
# reading of dependency files and definition of phony targets
# ---------------------------------------------------------------------------
ifdef windir
-include  $(shell mkdir dep 2> nul)  $(wildcard dep/*)
else
-include  $(shell mkdir -p dep)  $(wildcard dep/*)
endif

.PHONY : all clean size flash gdbserver killgdbserver
# ---------------------------------------------------------------------------
