# Orbuculum Trace
![image info](images/Orbtrace_Layout.png)

## General information’s
Only for **Linux** (Config for STM32H743 parallel trace)
(**Windows doesn’t work** with passthrough usb-devices with docker, it doesn’t work to use trace and debug parallel)


## Installation

- Install **Docker**

- Download **start_terminator_layout.sh** and **Dockerfile**. Place it in the same folder.

- Open **start_terminator_layout.sh** and change the marked line with the folder to your **file.elf**



    docker run -itd --privileged \ \
    -p 2000:2000/tcp \ \
    -v /dev/bus/usb:/dev/bus/usb \  
    **-v /home/birop/Downloads:/home/birop/Downloads \  <--this line**\
    --name orbtrace-container \ \
    Orbtrace

### Optional
You can also change your orbtrace setting for example (default = 4 lines parallel)
`xdotool type "docker exec -it ${CONTAINER_ID} bash -c 'orbuculum -O \"-T 4\" -m 500; exec bash'"`

## Start Docker
Navigate to the folder with the **Docker** and **start_terminator_layout.sh** and make:
```
sudo apt-get install xdotool
chmod +x start_terminator_layout.sh
./start_terminator_layout.sh
```

Wait (2min)\
Now you should see 5 screens:
- Blank terminal
- blackmagic
- orbuculum
- orbuculum docker
- gdb-multiarch

If you want more **orbuculum terminals** make:
`docker exec -it orbtrace-container bash`

## Enable ITM/DWT/ETM
#### (main.c)
To enable **ITM/DWT/ETM** add this to **main.c**
```
#define DBG_TER (*(volatile uint32_t *)0x5C000E00)

	__HAL_RCC_GPIOE_CLK_ENABLE(); //parallel tracing
  GPIO_InitTypeDef  GPIO_InitStruct;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
  GPIO_InitStruct.Pin = GPIO_PIN_2 | GPIO_PIN_3 | GPIO_PIN_4 | GPIO_PIN_5 | GPIO_PIN_6;
  GPIO_InitStruct.Alternate = GPIO_AF0_TRACE;
  HAL_GPIO_Init( GPIOE, &GPIO_InitStruct );


  RCC->APB4ENR |= (1 << 21);
  DBGMCU->CR |= DBGMCU_CR_DBG_TRACECKEN;
  DBG_TER |= (1 << 0);

ITM_SendChar(‘t‘);   // to send character ‘t‘ on ITM port
```

## Enable ITM/DWT/ETM
#### (gdb-terminal)
- Download **gdbtrace.init** place it to your Dockerfile 
- Add following lines to **Debugger console**

This setup was tested with the STM32H743. If you are using **other microcontrollers** you can download the **gdbtrace.init** from orbuculum. You also need to make some changes in the **gdbtrace.init** and your **Code**. 
```
source path/to/gdbtrace.init	
enableSTM32TRACE 4
dwtSamplePC 1
dwtSyncTap 3
dwtPostTap 1
dwtPostInit 1
dwtPostReset 10
dwtCycEna 1
ITMId 1
ITMGTSFreq 3
ITMTSPrescale 3
ITMTXEna 1
ITMSYNCEna 1
ITMEna 1

ITMTER 0 0x00000009

startETM

dwtTraceException 1
ITMTSEna 1
```


## Debug
You can either use the gdb-terminal in docker or STM32CubeIDE.

### Debugging with GDB-terminal
To start gdb-session make these commands in gdb-terminal:
```
file path/to/file.elf 
target extended-remote localhost:2000
set mem inaccessible-by-default off
monitor swd_scan
attach 1
load
```

### Debugging with STM32CubeIDE
To start debugging-session with STM32CubeIDE open new GDB Hardware Debugging and add your config like this:

![image info](images/STM32Cube_Config.png)

## Orbuculum clients
#### orbmortem (watch exact procedure of the program)

`orbmortem -P ETM4 -e path/to/file.elf`

- press h to halt
- press ? for info



#### orbtop (watch the workload of the individual tasks)
`orbtop -E -e path/to/file.elf `
#### orbcat (to watch ITM port like printf)
`orbcat -c 0,”%c”`

## Troubleshooting:
If blackmagic hangs up make: 
- 	Ctrl + c
- 	`blackmagic -v 5`

If permission error occurs, make:
	
`Sudo command`

For other Microcontrollers you need to make changes in **gdbtrace.init** and the commands for the **gdb-terminal**. You can get information’s from the [discord forum](https://discord.gg/P7FYThy) or on the [GitHub page orbuculum](https://github.com/orbcode/orbuculum).
