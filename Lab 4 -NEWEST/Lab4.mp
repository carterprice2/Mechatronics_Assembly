Project:      Lab4
Build Number: 0
Date:         Mon Nov 16 10:47:16 2015
Compiler:     ICC12
Version:      7.09.00


Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            text   C000   0779 =   1913. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       C000  __start
       C053  _exit
       C055  _main
       C774  __HC12Setup
       C779  __text_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             bss   0800   0034 =     52. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       0800  __bss_start
       0800  t1state
       0801  t2state
       0802  t3state
       0803  t4state
       0804  t5state
       0805  TEMP
       0806  key_flag
       0807  BACKflag
       0808  ENTERflag
       0809  DPTR
       080B  FIRSTCH
       080C  prompt_flag
       080D  BUFFER
       0813  POINTER
       0815  COUNT
       0816  wave
       0817  DIGITflag
       0818  sawprompt_flag
       0819  bstate
       081A  TOOHIGHflag
       081B  ZEROflag
       081C  NODIGflag
       081D  RESULT
       081E  sineprompt_flag
       081F  squareprompt_flag
       0820  FIRSTdig
       0821  NINT
       0822  WAVEPTR
       0824  CSEG
       0825  LSEG
       0826  SEGINC
       0828  CINT
       0829  VALUE
       082B  SEGPTR
       082D  NEWBTI
       082E  RUN
       082F  INTERVAL
       0831  NINTOK
       0832  TINC
       0834  __bss_end

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
       FB00  _initlcd
       FB00  INITLCD
       FB78  _putchar
       FB78  PUTCHAR
       FBFE  OUTSTRING
       FC16  OUTCHAR_AT
       FC25  OUTCHAR
       FC37  _clrscreen
       FC37  CLRSCREEN
       FC41  _setaddr
       FC43  SETADDR
       FC4D  BACKSPC
       FC4D  _backspc
       FC61  CURSOR
       FC61  _cursor
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
Lab4.o	[ Lab4.s ]
<library>	[ ME305libV7.s, setup.c ]

User Global Definitions

init_sp = 0xbb0

Area Definitions

-btext:0xc000.0xffff
-bdata:0x800.0xffff

