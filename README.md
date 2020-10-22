# STM32F3_FreeRTOS
Setup STM32F303VC Discovery Board with FreeRTOS


### Setup

Requires an arm-none-eabi- set of gcc tools

    git clone --recursive https://github.com/hargorin/STM32F3_FreeRTOS.git
    git submodule update --init --recursive

### Build

    cd STM32F3_FreeRTOS
    make

### Program

Using [stlink](https://github.com/texane/stlink)

    {sudo} st-flash write build/stm32f3discovery-demo.bin 0x8000000

### Use

Connect to the USB USER port.

    {sudo} cat /dev/ttyACM0

### Debug

Using [stlink](https://github.com/texane/stlink).

In one terminal:

    {sudo} st-util
    
And another:

    arm-non-eabi-gdb build/stm32f3discovery-demo.elf
    
And then within GDB:

    > target extended-remote :4242
    ...
    > load
    ...
    
And you can debug with GDB as you would expect.

### Toolchain installation under ubuntu linux

    [Installation Guide](https://askubuntu.com/questions/1243252/how-to-install-arm-none-eabi-gdb-on-ubuntu-20-04-lts-focal-fossa)