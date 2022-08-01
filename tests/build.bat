wdc816as  -K SCRM816.lst  -L SCRM816.asm -O SCRM816.obj
wdcln -V -HM28 -T -V SCRM816.obj -O SCRM816.s28
wdcln -V -HI -T -V SCRM816.obj -O SCRM816.hex
hex2bin -R32K -d 0 -s 32768 -oSCRM816.bin SCRM816.hex


wdc816as  -K TEST9918.lst  -L TEST9918.asm -O TEST9918.obj
wdcln -V -HM28 -T -V TEST9918.obj -O TEST9918.s28
REM wdcln -V -HI -T -V TEST9918.obj -O TEST9918.hex
REM hex2bin -R32K -d 0 -s 32768 -oTEST9918.bin TEST9918.hex


wdc816as  -K CON9918.lst  -L CON9918.asm -O CON9918.obj
wdcln -V -HM28 -T -V CON9918.obj -O CON9918.s28
REM wdcln -V -HI -T -V CON9918.obj -O CON9918.hex
REM hex2bin -R32K -d 0 -s 32768 -oCON9918.bin CON9918.hex

wdc816as  -K TESTDSKY.lst  -L TESTDSKY.asm -O TESTDSKY.obj
wdcln -V -HM28 -T -V TESTDSKY.obj -O TESTDSKY.s28
REM wdcln -V -HI -T -VTESTDSKY.obj -O TESTDSKY.hex
REM hex2bin -R32K -d 0 -s 32768 -oTESTDSKY.bin TESTDSKY.hex

wdc816as  -K TESTIEC.lst  -L TESTIEC.asm -O TESTIEC.obj
wdcln -V -HM28 -T -V TESTIEC.obj -O TESTIEC.s28
REM wdcln -V -HI -T -VTESTIEC.obj -O TESTIEC.hex
REM hex2bin -R32K -d 0 -s 32768 -oTESTIEC.bin TESTIEC.hex

wdc816as  -K TESTKBD.lst  -L TESTKBD.asm -O TESTKBD.obj
wdcln -V -HM28 -T -V TESTKBD.obj -O TESTKBD.s28
REM wdcln -V -HI -T -V TESTKBD.obj -O TESTKBD.hex
REM hex2bin -R32K -d 0 -s 32768 -oTESTKBD.bin TESTKBD.hex

wdc816as  -K TESTSND.lst  -L TESTSND.asm -O TESTSND.obj
wdcln -V -HM28 -T -V TESTSND.obj -O TESTSND.s28
