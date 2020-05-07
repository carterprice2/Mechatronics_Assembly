Project:      LAB1A_SC
Build Number: 0
Date:         Thu Sep 24 13:54:12 2015
Compiler:     ICC12
Version:      7.50


Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            text   C000   0072 =    114. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       C000  __start
       C053  _exit
       C055  _main
       C06B  spin
       C06D  __HC12Setup
       C072  __text_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             bss   0800   0003 =      3. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       0800  FIRST
       0800  __bss_start
       0801  SECOND
       0802  RESULT
       0803  __bss_end

Area                               Start  End    Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
               interrupt_vectors   0000   10000 =  65536. bytes (abs,ovr,rom)

Files Linked      [ module(s) ]

Y:\icc\lib\crt12ext.o	[ crt12ext.s ]
LAB1A_SC.o	[ LAB1A_SC.s ]
<library>	[ setup.c ]

User Global Definitions

init_sp = 0xbb0

Area Definitions

-btext:0xc000.0xffff
-bdata:0x800.0xffff

