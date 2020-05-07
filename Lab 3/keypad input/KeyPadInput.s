
; Read number from keypad and display different messages based on number

; RAM area
.area bss

NUM::	blkb 1


;=================================================================================
.area text

_main::		  

		    jsr INITKEY						;initialize keypad
			jsr	KP_ACTIVE					;turn on keypad
			
			jsr CLRSCREEN					;clears LCD screen
			jsr	 INITLCD					;initialize LCD
	   		jsr	 CURSOR						;show cursor

	;SKIP:	tst	   L$KEY_FLG				;test key available flag, loops until keypad entr
		;	bne	   SKIP
			
			bgnd   	   						;takes values 1-3
			jsr	   GETCHAR					;the resulting ASCII character is placed in accumulator B 
			stab   NUM						;stores ASCII Character in NUM
			bgnd
			
			ldaa   NUM						;load acc a with NUM
			ldab   #$30						;load acc with hex30 
			sba	   							;stubtracts b from a, stores in a
			
			deca							;subtract 1 from acc a
			beq	  DISPLAY1					;if acc a is 0 then jsr Display 1
			deca  
			beq	  DISPLAY2
			deca
			beq	  DISPLAY3
			
			
	SARA:   bra SARA

;=================================================================================
; Subroutine display1

  DISPLAY1:
			 ldaa #$00			;load accumulator with LCD address
			 ldx  #MESSAGE1		;load register x with Message 1
	   		 jsr OUTSTRING
			 bra SARA
			 
;================================================================================			 
;Subroutine 

DISPLAY2:
			 ldaa #$00			;load accumulator with LCD address
			 ldx  #MESSAGE2		;load register x with Message 1
	   		 jsr OUTSTRING
			 bra SARA
;================================================================================
; subroutine display3
			 
DISPLAY3:
			 ldaa #$00			;load accumulator with LCD address
			 ldx  #MESSAGE3		;load register x with Message 1
	   		 jsr OUTSTRING
			 bra SARA
			 
;================================================================================
			 
MESSAGE1: 	 .ascii	  'hello world'		   ;message to be displayed
			 .byte	  $00		
			 
MESSAGE2: 	 .ascii	  'what up'		   	   ;message to be displayed
			 .byte	  $00		
			 
MESSAGE3: 	 .ascii	  'hey sara'		   ;message to be displayed
			 .byte	  $00			 
			 
.area interrupt_vectors (abs)
	  .org		$FFFE			 			   ;at reset vector location,
	  .word		__start						   ;load starting address	