.area bss

FIRST::	 	.blkb 01				; reserved space for addend
SECOND:: 	.blkb 01				; reserved space for augend
RESULT::	.blkb 01				; reserved space for result

.area text


_main::	  BGND
		  movb	  #$07, FIRST
		  movb	  #$06, SECOND
		  ldaa	  FIRST
		  ldab 	  SECOND
		  aba
		  staa	  RESULT
		  
spin:: bra		  spin

.area interrupt_vectors(abs) 
	  .org					 $FFFE
	  .word					 __start 