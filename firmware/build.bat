wdc816as -K supermon816.lst -L supermon816.asm -O supermon816.obj
wdc816as -K ROMBIOS816.LST -L -I.  ROMBIOS816.asm -O ROMBIOS816.obj
wdcln -V -HI -T -V -c9200 -u3000 supermon816.obj ROMBIOS816.obj -O ROMBIOS816.hex -LCC
hex2bin -R32K -d 0 -s 32768 -oROMBIOS816.bin ROMBIOS816.hex

