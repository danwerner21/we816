
# WE816
The WE816 is a 16-bit 65816 based system with 512K of System RAM, 96K of System ROM, 32K of video RAM, a TMS9918 graphics processor and an AY-3-8910 Sound chip.  The system runs a custom version of BASIC and supports commodore compatible IEC disk drives.

EhBASIC by Lee Davison was ported to the 65816 CPU on the WE816 computer.   It is designed to allow a full 64K bank for BASIC code and variables with the BASIC interpreter running in a totally different bank. Full documentation on the basic intrepreter can be found in the support folder

![System](Support/images/case13.jpg)
![System](Support/images/boardset2.jpg)


---


## To Do:

* RTC Hardware (fixed needs PCB created and tested)

* BIOS RTC Code

* Basic Access to RTC

* Fix Video RAM paging

* Document BIOS Calls


---


## What is included in this repo?
As of this time, the repo includes

1. The WE816 Mainboard PCB Kicad design and Gerber files
2. The source code and binaries for the WE816 BASIC interpreter
3. The source code and binaries for the WE816 BIOS firmware
4. The source code and binaries for several hardware test programs
5. The logic equasions for the 3 GALs
6. **OpenSCAD and STL files for a 3d printed case


![Mainboard](Support/images/mainboard.jpg)
![Assembled](Support/images/boardset1.jpg)

---


## Known Bugs

 * Note that the Real Time clock circuit on the 8/5/2021 .85 verson of the board is broken and will not work.  The schematic in this repo has been updated to a working version, but this board still has U12 Pin 6 & 7  connected to CB1 & 2 of U36 which has a broken shift register implementation.   I was under the mistaken impression that the shift register bug had been corrected on the WDC version of the 6522, but this is not the case.

### System Jumpers

![jumpers](Support/images/Jumpers.jpg)

Jumper P9 -- stereo channel mixer

 *  no jumpers, channel a left, channel c right, channel b left and right
 *  1-2 and 2-3 , channel a,b,c mixed to left and right

Jumper K1 - SRAM chip selection

 * 1&2 - 512K chip used (AS6C4008)
 * 2&3 - 128K chip used (AS6C1008)

Jumper K2 - ROM chip selection

 * 1&2 - 27c256 chip used
 * 2&3 - 29c256 chip used

Jumper K3 - ROM size

 * 1&2 - 16K rom page 0 memory map @ $C000
 * 2&3 - 32K rom page 0 memory map @ $8000

Power P1

 * 1- NC
 * 2-GND
 * 3-GND
 * 4-+5VDC 2A Regulated

Reset P2

 * NO Switch (Short to put system in reset)

Jumper J1, Interrupt Select

* 1&8 UART Interrupt enabled
* 2&7 VIA 1 Interrupt enabled
* 3&6 VIA 2 Interrupt enabled
* 4&5 TMS9918 Interrupt enabled

![interrupt](Support/images/interrupt.png)

![expansion](Support/images/expansion.png)

![keyboard](Support/images/keyboard.png)

![serial](Support/images/serial.png)


---

## Bill Of Materials

### Mainboard

Quantity|Ref|Value|Part
--------|--------|----|--------
1|BT2||CR2032 COIN CELL HOLDER
2|C1,C46|22 uF|Radial Electrolytic Capacitor
5|C13,C22,C25,C26,C32|1.0 uF|Radial Electrolytic Capacitor
35|C2,C4,C5,C7-C12,C14-C18,C20,C21,C23,C28-C31,C33-C42,C48,C53-C56|0.1 uF|Film/Ceramic Capacitor
3|C3,C51,C52|10 uF|Radial Electrolytic Capacitor
2|C43,C44|33 pF|Ceramic Capacitor
1|C47|220 uF|Radial Electrolytic Capacitor
3|C49,C50|270 uF|Ceramic Capacitor
1|D2|BICOLOR LED|LED
|J1|2x4|Pin header
2|J2,J3|DB9_Male|DB9 Male Connector
|J4|IEC PORT|DIN 5 pin Connector
|J5|2x8|Pin header
1|J6|2x20|Pin header
|J7|1x3|Pin header
|J8|RCA Jack|RCA Jack
|J9|3.5mm stereo Jack|3.5mm stereo Jack
|K1|1x3|Pin header
1|K2|1x3|Pin header
1|K3|1x3|Pin header
|L1|INDUCTOR (BEAD)|Ferrite Bead
|P1|POWER|SBC-rescue:CONN_4-6x0x-6U-cache
|P2|1x2|SBC-rescue:CONN_2-6x0x-6U-cache
1|P3|4MHZ OSC|1/2 can osc
1|P4|1.8432 OSC|1/2 can osc
|P5|2x5|Pin Header
|P9|2x2 |Pin Header
1|Q2|2N3904|NPN Transistor
1|R1|10|Resistor
3|R10,R11,R12|1000|Resistor
5|R2,R13-R16|10K|Resistor
1|R3|100|Resistor
4|,R5,R17-19|1K|Resistor
1|R6|0|Resistor
1|R7|470|Resistor
2|R8,R9|75|Resistor
2|RR1,RR3|4700|6 pin Resistor Net
1|RR2|1000|6 pin Resistor Net
1|RR4|4700|9 pin Resistor Net
2|RV1,RV2|4700|Trim Pot
1|U1|74LS06N|IC
1|U10|16C550|IC
1|U12|DS1302|IC
|U13|MAX232|IC
1|U14|27C512|IC
2|U15,U17|GAL16V8|IC
1|U16|GAL20V8|IC
1|U19|74LS244|IC
|U2|6c4008|IC
1|U25|TMS9918|IC
3|U26-U28|74LS574|IC
1|U29|74LS04|IC
1|U3|74LS32|IC
|U30|62256|IC
1|U32|74LS393|IC
1|U34|AY-3-8910|IC
2|U36,U37|W65C22NxP|IC
1|U38|7406|IC
1|U4|658C16|IC
1|U5|27C256|IC
1|U7|74LS14|IC
1|U8|74LS373|IC
5|U9,U18,U20,U21,U23|74LS245|IC
1|X1|CRYSTAL 32.768 KHz|Crystal
1|X2|10.7 MHz|Crystal



### Keyboard
The Keyboard used in the WE816 is identical to the keyboard used in Sergey Kiselev's MSX compatible OMEGA computer.  See the Schematics, PCB layout and build instructions
[here](https://github.com/skiselev/omega/blob/master/Keyboard.md)



### Case
The case in the following images is a 3D print manufactured by the 3D print service offered by JLCPCB.com.  The case was originally designed to be 3D printed by a FDM printer such as the Anycubic Chiron.   It was originally intended that threaded inserts be melted into the stand off posts so the diameter of the holes were sized accordingly.  If a printing service (such as JLCPCB) is used that uses resin printing, it is necessary to slightly drill out the holes in the stand offs so that threaded inserts can be glued in.   It should also be noted that the design tolerances are quite tight and variations in printing can mean that some slight adjusting may be needed in order to get a good fit.

A 12V to 5V converter can be seen in the image that was added into the case in order to convert the 12V power input to the 5B required by the main board.

![System](Support/images/case1.jpg)
![System](Support/images/case3.jpg)
![System](Support/images/case5.jpg)
![System](Support/images/case7.jpg)
![System](Support/images/case9.jpg)

### Questions?

If there are any questions, I can be reached at vic2020Dan at gmail dot com.


---