;read a sequence of digits and store into the buffer

; RAM area
.area bss

BUFFER::	 .blkb 6
COUNT::   	 .blkb 1
POINTER::	 .blkb 2


.area text
;============================================================================

_main::

	  	jsr INITKEY					;initialize keypad
		jsr FLUSH_BFR				;flushes the character input buffer
		clr COUNT					
		movw  #BUFFER,POINTER		;moves the contents of BUFFER into POINTER
		
		
LOOP:	
		bgnd
		jsr 	GETCHAR					;the resulting ASCII char is put in accumulator B
		
										;code to make sure it is a digit
		CMPB	#$0A					;compares acc b to ent ascii value
		BEQ		DONE					;exits the loop
		CMPB 	#$30					;compares acc b to 30
		BLT		LOOP					;branch to Loop if less than 30
		CMPB	#$39					;compares acc b to 39
		BLE		DIGIT					;branches to digit
		BRA 	LOOP				;branch always to not digit
		
		
DIGIT:	
		;stab 	BUFFER					;loads the contents of acc B into Buffer
		ldx POINTER						;loads acc X with pointer
		stab 0,X						;Stores contents of acc B into the location of the address found in acc X which is POINTER
		inc COUNT
		INX
		stx POINTER
		bra LOOP
		
DONE:

	 	bra DONE
		
		
		
.area interrupt_vectors (abs)
	  .org		$FFFE			 			   ;at reset vector location,
	  .word		__start						   ;load starting address	