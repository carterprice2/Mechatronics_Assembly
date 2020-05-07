
;Hello world on LCD display

_main::

	   		 jsr	 INITLCD		;initialize LCD
	   		 jsr	 CURSOR			;show cursor

	   		 ldaa #$00			;load accumulator with LCD address
	   		 ldx	 #MESSAGE		;load message in register x
	   		 jsr OUTSTRING
			 
CARTER:		 bra CARTER

 

MESSAGE: 	 .ascii	  'hello world'		   ;message to be displayed
			 .byte	  $00

			 
.area interrupt_vectors (abs)
	  .org		$FFFE			 			   ;at reset vector location,
	  .word		__start						   ;load starting address	