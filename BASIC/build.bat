wdc816as  -K DBASIC816.lst  -L DBASIC816.asm -O DBASIC816.obj
wdcln -V -HM28 -T -V DBASIC816.obj -O DBASIC816.s28
wdcln -V -HI -T -V DBASIC816.obj -O DBASIC816.hex
hex2bin -R32K -d 0 -s 32768 -oDBASIC816.bin DBASIC816.hex
