;initial Display prompt

;RAM
.area bss

TICKS::	 .blkb 2

;===============================================================================


.area text


;intial display upon start up "hub state"

_main::
	  jsr 		INITLCD		 	   ;initalize the LCD	
TOP:  jsr 		CLRSCREEN		   ;clears the screen
	  
	  ldaa		#$00		   ;loads the LCD address 
	  ldx		#LINE1	   	   ;starting address of string to be displayed
	  jsr 		OUTSTRING
	 
	  ldaa		#$40
	  ldx		#LINE2	   	   ;starting address of string to be displayed
	  jsr 		OUTSTRING
	  
READDIS:
	  
	  jsr 		INITKEY	 	   ;initialize keypad
	  jsr 		GETCHAR		   ;get character
	  CMPB		#$F1
	  BEQ		F1RES	   ;branch to F1RESPONSE 
	  CMPB		#$F2
	  BEQ		F2RES	   ;branch to F2RESPONSE
	  jsr		CLRSCREEN
	  ldaa		#$00
	  ldx		#ERROR
	  jsr 		OUTSTRING
	  bgnd
	  jsr 		DELAY
	  jsr 		OUTSTRING
	  bra		TOP
	  
	  
	  
F1RES:
		   		jsr		 	CLRSCREEN
	  			ldaa		#$00
	  			ldx			#F1RESPONSE
	  			jsr 		OUTSTRING
				bgnd
	  			jsr			DELAY
				bra			TOP
				

F2RES:
		   		jsr		 	CLRSCREEN
	  			ldaa		#$00
	  			ldx			#F2RESPONSE
	  			jsr 		OUTSTRING
				jsr			DELAY
				bgnd
	 			bra			TOP
				
;===========================================================================
	  

	  
;============================================================================	 
	 
LINE1:			.ascii	 'LED pair 1:     <Press F1>'
				.byte	 $00 
				
LINE2:			.ascii	 'LED pair 2:     <Press F2>'
				.byte	 $00 

ERROR:			.ascii	 'Please enter a valid response'
				.byte	 $00			
				
F1RESPONSE:		.ascii	 'Enter ms delay for LED 1'
				.byte	 $00	
							
F2RESPONSE:		.ascii	 'Enter ms delay for LED 2'
				.byte	 $00							
;=============================================================================
;
;    Subroutine Delay_1ms delays for ~1.00ms
;
DELAY_1ms:
        ldy    #$0262
INNER:                            ; inside loop
        cpy    #0
        beq    EXIT
        dey
        bra    INNER
EXIT:
        rts                       ; exit DELAY_1ms

; end subroutine DELAY_1ms
;
;==============================================================================

;============================================================================
	
.area interrupt_vectors (abs)
	  .org				$FFFE
	  .word				__start
			