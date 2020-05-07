Project:      Lab3
Build Number: 0
Date:         Sat Oct 31 17:19:08 2015
Compiler:     ICC12
Version:      7.09.00


Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            text   C000   0755 =   1877. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       C000  __start
       C053  _exit
       C055  _main
       C750  __HC12Setup
       C755  __text_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             bss   0800   0035 =     53. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       0800  BACKflag
       0800  __bss_start
       0801  DPTR
       0803  FIRSTCH
       0804  DLINE1
       0805  DLINE2
       0806  L1
       0807  L2
       0808  F1flag
       0809  F2flag
       080A  DIGITflag
       080B  BUFFER
       0811  POINTER
       0813  COUNT
       0814  FIRSTdig
       0815  TEMP
       0816  COUNT2
       0817  RESULT
       0819  TICKS_1
       081B  COUNT_1
       081D  DONE_1
       081E  TICKS_2
       0820  COUNT_2
       0822  DONE_2
       0823  t1state
       0824  t2state
       0825  t3state
       0826  t4state
       0827  t5state
       0828  ON_1
       0829  ON_2
       082A  TOOHIGHflag
       082B  SHOWflag
       082C  SHOWCOUNT
       082E  NODIGflag
       082F  ZEROflag
       0830  CLINE1flag
       0831  CLINE2flag
       0832  COUNTBUFF
       0833  FIRSTRUN1
       0834  FIRSTRUN2
       0835  __bss_end

Area                               Start  End    Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
               interrupt_vectors   0000   10000 =  65536. bytes (abs,ovr,rom)

Area                               Start  End    Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                     LCD_KEY_BUF   0BB0   0BFD =   3069. bytes (abs,ovr,rom)

       Addr  Global Symbol
      -----  --------------------------------
       0BB0  L$CHARACTER
       0BB1  L$KEY_FLG
       0BB2  L$VREF_BUF
       0BB6  L$VACT_BUF
       0BBA  L$ERR_BUF
       0BBE  L$EFRT_BUF
       0BC2  L$KI_BUF
       0BC7  L$KP_BUF
       0BF9  L$POS_BUF
       0BFB  L$VEL_BUF

Area                               Start  End    Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                          IO_LIB   FB00   FF9B =  65435. bytes (abs,ovr,rom)

       Addr  Global Symbol
      -----  --------------------------------
       FB00  INITLCD
       FB00  _initlcd
       FB78  PUTCHAR
       FB78  _putchar
       FBFE  OUTSTRING
       FC16  OUTCHAR_AT
       FC25  OUTCHAR
       FC37  _clrscreen
       FC37  CLRSCREEN
       FC41  _setaddr
       FC43  SETADDR
       FC4D  _backspc
       FC4D  BACKSPC
       FC61  _cursor
       FC61  CURSOR
       FC6B  _dispoff
       FC6B  DISPOFF
       FCF9  _loadaddr
       FCFF  LOAD_ADDR
       FD3A  LCDTEMPLATE
       FD41  UPDATELCDL1
       FD68  UPDATELCDL2
       FE5C  _initkey
       FE5C  INITKEY
       FE67  KP_ACTIVE
       FE67  _kp_active
       FE6C  _kp_inactive
       FE6C  KP_INACTIVE
       FE71  FLUSH_BFR
       FE77  _getchar
       FE77  GETCHAR
       FE8B  _echo
       FE8B  ECHO
       FE9F  KEYPAD
       FECB  INITSC0
       FEDF  INITSC1
       FEF3  SC0_GETCHAR
       FF01  SC1_GETCHAR
       FF0F  SC0_PUTCHAR
       FF24  SC1_PUTCHAR
       FF39  SC0_PUTDATA
       FF6A  SC1_PUTDATA

Files Linked      [ module(s) ]

Y:\icc\lib\crt12ext.o	[ crt12ext.s ]
Lab3.o	[ Lab3.s ]
<library>	[ ME305libV7.s, setup.c ]

User Global Definitions

init_sp = 0xbb0

Area Definitions

-btext:0xc000.0xffff
-bdata:0x800.0xffff

