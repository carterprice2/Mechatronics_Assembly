;L. Carter Price
;Sarah Visitacion

;Lab 5



;Assembler Equates

Encoder = $0280

PORTJ = $0028
DDRJ =  $0029
PIN5 =	0b00010000

TIOS =  $0080	  ;Timer I/O select register address
TCTL2 = $0089	  ;address timer control register
TFLG1 = $008E	  ;Timer flag register
TCNT =  $0084	  ;timer count register high byte
TCNT2 = $0085	  ;timer count register low byte
TC0 =   $0090	  ;timer channel 0 compare register
TMSK1 = $008C	  ;timer chan 0 interrupt enable bits
Chan0 = $01

DACAMSB = $0301	  ;the bit combo to send into msb of DAC
DACALSB = $0300 


.area bss

t1state:: 	   .blkb 1
t2state::	   .blkb 1
t3state::	   .blkb 1
t4state::	   .blkb 1
RUN::		   .blkb 1
TEMP::		   .blkb 1
CLOSED::	   .blkb 1
COUNT::		   .blkb 1
BUFFER::	   .blkb 4
POINTER::	   .blkb 2
prompt_flag::  .blkb 1
DIGITflag::    .blkb 1
AUTOUPDATE::   .blkb 1
BACKflag::     .blkb 1
ZEROflag::	   .blkb 1
TOOHIGHflag::  .blkb 1
KP::		   .blkb 2
KI::		   .blkb 2
RESULT::	   .blkb 2
FIRSTdig::	   .blkb 1
t1s4state::	   .blkb 1
t1s5state::	   .blkb 1
t1s6state::	   .blkb 1 
bstate::	   .blkb 1
INPUT::		   .blkb 1
key_flag::	   .blkb 1
Eflag::		   .blkb 1
aPRIME::	   .blkb 2
INTERVAL::	   .blkb 2
FRED::	  	   .blkb 2
Vact::		   .blkb 2
Vref::		   .blkb 2
ERR::		   .blkb 2
aKP::		   .blkb 2
aKI::		   .blkb 2
Cflag::		   .blkb 1
Dflag::		   .blkb 1
FIRSTCH::	   .blkb 1
DPTR::		   .blkb 2
VrefPTR::	   .blkb 2
VrefNEG::	   .blkb 1
inVrefNEG::	   .blkb 1
KPPTR::		   .blkb 2
KIPTR::		   .blkb 2
NODIGflag::	   .blkb 1
COUNTBUFF::	   .blkb 1
newHEX::	   .blkb 2
EFRTPTR::	   .blkb 2
UPCOUNT::	   .blkb 1
EFFRT::		   .blkb 2
new::		   .blkb 2
old::	   	   .blkb 2
VactPTR::	   .blkb 2
negEFF::	   .blkb 1
negVact::	   .blkb 1
errPTR::	   .blkb 2
negERR::	   .blkb 1
INT::		   .blkb 2
intVref::	   .blkb 2
a::			   .blkb 2
eKI::		   .blkb 2
eKP::		   .blkb 2
Esum::		   .blkb 2
aSTAR::		   .blkb 2
intVact::	   .blkb 2
ERRact::	   .blkb 2
TEMPadd::	   .blkb 2
toggleCL::	   .blkb 1
NOUPDATE::	   .blkb 1
VactOUT::	   .blkb 2

.area text


_main::	  
		  movb #$00, t1state
	   	  movb #$00, t2state
	   	  movb #$00, t3state
	   	  movb #$00, t4state
		  movb #$FF, UPCOUNT
		  movw #$0000, EFFRT
		  
	  TOP: 
	  	
	  	  jsr TASK_1 		;Mastermind
		  jsr TASK_2		;Keypad	
		  jsr TASK_3 		;Display
		  jsr TASK_4		;Timer Ch0
		  bra TOP

		  
		  ;everything else is in the interrupt service routine
;===========================================================================
;Mastermind

TASK_1:	   ldaa	 t1state
		   beq	 t1state0
		   deca	
		   beq	 t1state1
		   deca	
		   lbeq	 t1state2
		   deca
		   lbeq  t1state3
		   deca 
		   lbeq	 t1state4
		   deca
		   lbeq	 t1state5
		   deca
		   lbeq	 t1state6
		   deca
		   lbeq	 t1state7
		   rts
		   
	t1state0:										;initialization state
				movb #$01, RUN						;run is on			
				movb #$00, CLOSED					;open loop mode	
				movb #$01, t1state
				movb #$00, t1s4state
				movb #$00, COUNT
				rts
				
t1state1:		 	   		  	  	;hub state
				ldab TEMP
				cmpb #$41
				beq  Apress			;toggle run
				cmpb #$42	
				beq  Bpress			;toggle open close
				cmpb #$43
				beq  Cpress			;change Vref
				cmpb #$44
				beq  Dpress			;change kp/stop motor
				cmpb #$45
		   		beq  Epress			;change KI/stop motor	
				cmpb #$46
				beq  Fpress			;toggle auto/manual update
				clr	 TEMP
				clr  key_flag
				rts
				
		Apress: movb #$02, t1state
				bra	 EXIT_t1s1
		Bpress: movb #$03, t1state
				bra	 EXIT_t1s1			
		Cpress: movb #$04, t1state
				movb #$01, INPUT
				movb #$01, Cflag
				movb #$01, FIRSTdig
				movb #$01, FIRSTCH
				movb #$01, NOUPDATE 
				bra	 EXIT_t1s1
		Dpress: movb #$05, t1state
				movb #$02, INPUT
				movb #$00, RUN
				movb #$01, Dflag
				movb #$01, FIRSTdig
				movb #$01, FIRSTCH
				bra	 EXIT_t1s1				
	   	Epress: movb #$06, t1state
				movb #$03, INPUT
				movb #$00, RUN
				movb #$01, Eflag
				movb #$01, FIRSTdig
				movb #$01, FIRSTCH
				bra	 EXIT_t1s1
		Fpress: movb #$07, t1state
				bra  EXIT_t1s1
	 EXIT_t1s1: clr  TEMP
	 			clr  key_flag
	 			rts	
				
t1state2:		tst  RUN   		  	;toggle Run
				beq  RUN1
				movb #$00, RUN
				bra  EXIT_t1s2
		 RUN1:  movb #$01, RUN
    EXIT_t1s2:	clr  key_flag
   				movb #$01, t1state
				rts		
				
t1state3:		movb #$01, toggleCL
				movw #$0000, Esum
				tst  CLOSED		  	;toggle closed
				beq  CLOSE
				movb #$00, CLOSED
				bra  EXIT_t1s2
		CLOSE: 	movb #$01, CLOSED
     EXIT_t1s3:	clr  key_flag
   				movb #$01, t1state
				rts			
				
t1state4:   	ldaa    t1s4state
				beq	    t1s4s0	  			;initialize
				deca
				beq	    t1s4s1				;state 4 HUB
				deca
				beq	    t1s4s2				;digit state
				deca
				lbeq    t1s4s3				;backspace	
				deca
				lbeq	t1s4s4				;enter	
				deca
				lbeq	t1s4s5				;make negative	
				rts
				
	 t1s4s0:	movw	#L$VREF_BUF, VrefPTR
	 			ldx		#L$VREF_BUF			;load vref buffer
	 			movb    #'+',0,X
				movb	#' ',1,X
				movb	#' ',2,X
				movb    #' ',3,X
				movb	#$01,t1s4state
				rts
			
	 t1s4s1:	tst     key_flag			;test if a key has been pressed
			  	lbeq    EXIT
			  	ldab 	TEMP 
				CMPB	#$F2				
				lbeq	F2press	
			  	CMPB	#$0A				;compares acc b to ent ascii value
			  	LBEQ	ENTERpress	
			  	CMPB	#$08				;compare acc b to BACKSPACE ascii value
			  	LBEQ	BACKSPACE		
			  	CMPB    #$30				;compares acc b to 30
			  	LBLT	EXIT				;branch to Loop if less than 30
			  	CMPB	#$39				;compares acc b to 39
			  	LBLE	DIGITpress			;branches to digit
				clr		key_flag
				bra 	EXIT
			
	ENTERpress:	movb    #$04, t1s4state
				bra 	EXIT
	BACKSPACE:  movb	#$03, t1s4state
				bra 	EXIT
	DIGITpress: movb	#$02, t1s4state
				bra 	EXIT
	F2press:	movb	#$05, t1s4state					
	    EXIT:	rts		
				
	  t1s4s2:	tst		key_flag
	  			lbeq	EXIT
	  			movb 	#$01, DIGITflag		   	;sets the digit flag 
			 	ldab 	COUNT 					;places current LCD address in accumulator A
			 	cmpb	#$03					;makes sure don't type more than 3 digits
			 	lbeq	MAXdig					;clears dig flag so typing stops
				ldab  	TEMP
				ldx 	VrefPTR					;loads acc X with pointer
			 	stab 	1,X						;Stores contents of acc B into the location of the address found in acc X which is POINTER
				inc   	COUNT
			 	INX
			 	stx   	VrefPTR
			 	clr   	key_flag
				lbra  	END
		MAXdig: movb	#$00, DIGITflag
				clr 	TEMP
				clr 	key_flag
		END:	movb 	#$01, t1s4state
				rts
				
				
				
	  t1s4s3:	    ldaa bstate
					beq  accounting
					deca 
					beq  wait
					rts
					
		accounting: movb #$01, BACKflag		   		;sets the backspace flag
			 		ldab COUNT					    ;makes sure that you can't backspace past 0
			 		cmpb #$00					   
			 		beq  NOBS					    ;moves the pointer to account for backspace
					ldx  VrefPTR					;load POINTER into X
			 		dex										
			 		clr  1,X					 	;clears the value stored at the address in X
			 		dec  COUNT
			 		stx  VrefPTR
					movb #01, bstate
					clr  TEMP
					clr  key_flag
			 		rts
					
		wait:		ldab BACKflag
					cmpb #$03
					beq	 moveon
					rts
					
				moveon: movb #00,BACKflag			;resets backspace
						movb #01, t1s4state
						movb #$00, bstate 
						rts  
	
		NOBS:		movb #$00, BACKflag	  			;resets the backspace if the count is too low
					movb #$01, t1s4state
					clr  key_flag
					rts

		
	t1s4s4:		;ASCII to BCD converter
				
				movw  #L$VREF_BUF, VrefPTR	   ;moves address of buffer to pointer
				movw  #$0000, RESULT		   ;clears result
				ldy	  #$0000	 			   ;clears regis y
				clra 					   
				clrb
				
		LOOP:	
				ldy	  #$000A			   ;loads 10 in register y
				ldd	  RESULT			   ;loads result in acc d
				emul  					   ;multiplies d * y stores low in d high in y
				cpy	  #$0000			   ;compares y to 0
				bne   TOOBIG 			   ;if y is greater than 0 than entry is too large
				std   RESULT			   ;stores acc into result
				ldx	  VrefPTR			   ;loads pointer into x
				ldab  1,X				   ;loads b with contents of address stored in x
				subb  #$30				   ;subtracts 30 from b
				clra
				addd  RESULT	 	   	   ;add acc d and RESULT
				BVS	  TOOBIG			   ;brances to toobig if carry flag set
				std   RESULT			   ;stores acc d in result
				dec	  COUNT				   ;decrement count	
				tst   COUNT				   ;tests count to see if 0
				beq	  DONE
				inx		 				   ;increments x
				stx	  VrefPTR				   ;stores contents of x in pointer
				bra   LOOP
				
TOOBIG:		 		 				   	   ;sets the magnitude too high flag
				movw  #$7FFF, RESULT
				movw  RESULT, Vref
				clr   COUNT
				bra	  FINISH
				
ZERO:			movw  #$0000, RESULT	  	   ;sets the zero flag
				bra   FINISH		
	
		 		
DONE:							   ;finishes the BCD conversion
				movw  RESULT, Vref
				movw  RESULT, intVref
				bra   FINISH
	FINISH:	    movb  #$00, t1s4state
				clr	  NOUPDATE 		   
				clr   key_flag
				movb  #01, t1state
				tst	  inVrefNEG
				bne	  setVrefNEG
		boom:	jsr   LCDTEMPLATE
				rts
	setVrefNEG: movb #$01, VrefNEG
				clr  inVrefNEG
				bra  boom		
						     	
	t1s4s5:		ldx	 #L$VREF_BUF 		;Load the #L$VREF_BUF
				movb #'-',0,X	 		;inputs a - to buffer
				movb #$01, inVrefNEG		;flag to indicate negative Vref value
				movb #$01, t1s4state
				clr	 key_flag
				clr  TEMP
				rts
	
t1state5:   	ldaa    t1s5state
				beq	    t1s5s0	  			;initialize
				deca
				beq	    t1s5s1				;state 4 HUB
				deca
				beq	    t1s5s2				;digit state
				deca
				lbeq    t1s5s3				;backspace	
				deca
				lbeq	t1s5s4				;enter	
				clr 	TEMP
				clr     key_flag	
				rts
				
	 t1s5s0:	movw	#L$KP_BUF, KPPTR
	 			ldx		#L$KP_BUF			;load vref buffer
	 			movb    #' ',0,X
				movb	#' ',1,X
				movb	#' ',2,X
				movb    #' ',3,X
				movb    #' ',4,X
				movb	#$01,t1s5state
				rts
			
	 t1s5s1:	tst     key_flag			;test if a key has been pressed
			  	lbeq    EXIT1
			  	ldab 	TEMP 
			  	CMPB	#$0A				;compares acc b to ent ascii value
			  	LBEQ	ENTERpress1	
			  	CMPB	#$08				;compare acc b to BACKSPACE ascii value
			  	LBEQ	BACKSPACE1		
			  	CMPB    #$30				;compares acc b to 30
			  	LBLT	EXIT1				;branch to Loop if less than 30
			  	CMPB	#$39				;compares acc b to 39
			  	LBLE	DIGITpress1			;branches to digit
				clr		key_flag
				clr 	TEMP
				bra 	EXIT1
			
	ENTERpress1:movb    #$04, t1s5state
				bra 	EXIT1
	BACKSPACE1: movb	#$03, t1s5state
				bra 	EXIT1
	DIGITpress1:movb	#$02, t1s5state
				bra 	EXIT1					
	    EXIT1:	rts		
				
	  t1s5s2:	tst		key_flag
	  			lbeq	EXIT1
	  			movb 	#$01, DIGITflag		   	;sets the digit flag 
			 	ldab 	COUNT 					;places current LCD address in accumulator A
			 	cmpb	#$05					;makes sure don't type more than 3 digits
			 	lbeq	MAXdig1					;clears dig flag so typing stops
				ldab  	TEMP
				ldx 	KPPTR					;loads acc X with pointer
			 	stab 	0,X						;Stores contents of acc B into the location of the address found in acc X which is POINTER
				inc   	COUNT
			 	INX
			 	stx   	KPPTR
			 	clr   	key_flag
				lbra  	END1
	MAXdig1: 	movb	#$00, DIGITflag
				clr 	TEMP
				clr 	key_flag
		END1:	movb 	#$01, t1s5state
				rts
				
				
				
	  t1s5s3:	    ldaa bstate
					beq  accounting1
					deca 
					beq  wait1
					rts
					
		accounting1: movb #$01, BACKflag		   		;sets the backspace flag
			 		ldab COUNT					    ;makes sure that you can't backspace past 0
			 		cmpb #$00					   
			 		beq  NOBS1					    ;moves the pointer to account for backspace
					ldx  KPPTR					;load POINTER into X
			 		dex										
			 		clr  0,X					 	;clears the value stored at the address in X
			 		dec  COUNT
			 		stx  KPPTR
					movb #01, bstate
					clr  TEMP
					clr  key_flag
			 		rts
					
		wait1:		ldab BACKflag
					cmpb #$03
					beq	 moveon1
					rts
					
				moveon1: movb #00,BACKflag			;resets backspace
						movb #01, t1s5state
						movb #$00, bstate 
						rts  
	
		NOBS1:		movb #$00, BACKflag	  			;resets the backspace if the count is too low
					movb #$01, t1s5state
					clr  key_flag
					rts

		
	t1s5s4:		;ASCII to BCD converter
				
				movw  #L$KP_BUF, KPPTR	   ;moves address of buffer to pointer
				movw  #$0000, RESULT		   ;clears result
				ldy	  #$0000	 			   ;clears regis y
				clra 					   
				clrb
				
		LOOP1:	
				ldy	  #$000A			   ;loads 10 in register y
				ldd	  RESULT			   ;loads result in acc d
				emul  					   ;multiplies d * y stores low in d high in y
				cpy	  #$0000			   ;compares y to 0
				bne   TOOBIG1 			   ;if y is greater than 0 than entry is too large
				std   RESULT				   ;stores acc into result
				ldx	  KPPTR				   ;loads pointer into x
				ldab  0,X				   ;loads b with contents of address stored in x
				subb  #$30				   ;subtracts 30 from b
				clra
				addd  RESULT	 	   	   ;add acc d and RESULT
				BVS	  TOOBIG1			   ;brances to toobig if carry flag set
				std   RESULT			   ;stores acc d in result
				dec	  COUNT				   ;decrement count	
				tst   COUNT				   ;tests count to see if 0
				beq	  DONE1
				inx		 				   ;increments x
				stx	  KPPTR				   ;stores contents of x in pointer
				bra   LOOP1
				
TOOBIG1:		 		 				   	   ;sets the magnitude too high flag
				movw  #$7FFF, RESULT
				movw  RESULT, KP
				clr   COUNT
				ldx		#L$KP_BUF			;load vref buffer
	 			movb    #'3',0,X
				movb	#'2',1,X
				movb	#'7',2,X
				movb    #'6',3,X
				movb    #'7',4,X
				bra	  FINISH1
				
ZERO1:			movw  #$0000, RESULT	  	   ;sets the zero flag
				bra   FINISH1		
	
		 		
DONE1:								   ;finishes the BCD conversion
				ldd   #$7FFF			   ;loads 0 into acc d
				subd   RESULT			   ;compares d to result
				bmi   TOOBIG1				   ;if result is 0 branch to Zero
				movw  RESULT, KP
				bra   FINISH1
	FINISH1:	movb  #$00, t1s5state 		   
				clr   key_flag
				movb  #01, t1state
				jsr   LCDTEMPLATE
				rts
				
t1state6:   	ldaa    t1s6state
				beq	    t1s6s0	  			;initialize
				deca
				beq	    t1s6s1				;state 4 HUB
				deca
				beq	    t1s6s2				;digit state
				deca
				lbeq    t1s6s3				;backspace	
				deca
				lbeq	t1s6s4				;enter	
				clr 	TEMP
				clr     key_flag	
				rts
				
	 t1s6s0:	movw	#L$KI_BUF, KIPTR
	 			ldx		#L$KI_BUF			;load vref buffer
	 			movb    #' ',0,X
				movb	#' ',1,X
				movb	#' ',2,X
				movb    #' ',3,X
				movb    #' ',4,X
				movb	#$01,t1s6state
				rts
			
	 t1s6s1:	tst     key_flag			;test if a key has been pressed
			  	lbeq    EXIT2
			  	ldab 	TEMP 
			  	CMPB	#$0A				;compares acc b to ent ascii value
			  	LBEQ	ENTERpress2	
			  	CMPB	#$08				;compare acc b to BACKSPACE ascii value
			  	LBEQ	BACKSPACE2		
			  	CMPB    #$30				;compares acc b to 30
			  	LBLT	EXIT2				;branch to Loop if less than 30
			  	CMPB	#$39				;compares acc b to 39
			  	LBLE	DIGITpress2			;branches to digit
				clr 	key_flag
				clr		TEMP
				bra 	EXIT2
			
	ENTERpress2:movb    #$04, t1s6state
				bra 	EXIT2
	BACKSPACE2: movb	#$03, t1s6state
				bra 	EXIT2
	DIGITpress2:movb	#$02, t1s6state
				bra 	EXIT2					
	    EXIT2:	rts		
				
	  t1s6s2:	tst		key_flag
	  			lbeq	EXIT2
	  			movb 	#$01, DIGITflag		   	;sets the digit flag 
			 	ldab 	COUNT 					;places current LCD address in accumulator A
			 	cmpb	#$05					;makes sure don't type more than 3 digits
			 	lbeq	MAXdig2					;clears dig flag so typing stops
				ldab  	TEMP
				ldx 	KIPTR					;loads acc X with pointer
			 	stab 	0,X						;Stores contents of acc B into the location of the address found in acc X which is POINTER
				inc   	COUNT
			 	INX
			 	stx   	KIPTR
			 	clr   	key_flag
				lbra  	END2
	MAXdig2: 	movb	#$00, DIGITflag
				clr 	TEMP
				clr 	key_flag
		END2:	movb 	#$01, t1s6state
				rts
				
				
				
	  t1s6s3:	    ldaa bstate
					beq  accounting2
					deca 
					beq  wait2
					rts
					
		accounting2: movb #$01, BACKflag		   		;sets the backspace flag
			 		ldab COUNT					    ;makes sure that you can't backspace past 0
			 		cmpb #$00					   
			 		beq  NOBS2					    ;moves the pointer to account for backspace
					ldx  KIPTR					;load POINTER into X
			 		dex										
			 		clr  0,X					 	;clears the value stored at the address in X
			 		dec  COUNT
			 		stx  KIPTR
					movb #01, bstate
					clr  TEMP
					clr  key_flag
			 		rts
					
		wait2:		ldab BACKflag
					cmpb #$03
					beq	 moveon2
					rts
					
				moveon2: movb #00,BACKflag			;resets backspace
						movb #01, t1s6state
						movb #$00, bstate 
						rts  
	
		NOBS2:		movb #$00, BACKflag	  			;resets the backspace if the count is too low
					movb #$01, t1s6state
					clr  key_flag
					rts

		
	t1s6s4:		;ASCII to BCD converter
				
				movw  #L$KI_BUF, KIPTR	   ;moves address of buffer to pointer
				movw  #$0000, RESULT		   ;clears result
				ldy	  #$0000	 			   ;clears regis y
				clra 					   
				clrb
				
		LOOP2:	
				ldy	  #$000A			   ;loads 10 in register y
				ldd	  RESULT			   ;loads result in acc d
				emul  					   ;multiplies d * y stores low in d high in y
				cpy	  #$0000			   ;compares y to 0
				bne   TOOBIG2 			   ;if y is greater than 0 than entry is too large
				std   RESULT				   ;stores acc into result
				ldx	  KIPTR				   ;loads pointer into x
				ldab  0,X				   ;loads b with contents of address stored in x
				subb  #$30				   ;subtracts 30 from b
				clra
				addd  RESULT	 	   	   ;add acc d and RESULT
				BVS	  TOOBIG2			   ;brances to toobig if carry flag set
				std   RESULT			   ;stores acc d in result
				dec	  COUNT				   ;decrement count	
				tst   COUNT				   ;tests count to see if 0
				beq	  DONE2
				inx		 				   ;increments x
				stx	  KIPTR				   ;stores contents of x in pointer
				bra   LOOP2
				
TOOBIG2:		 		 				   	   ;sets the magnitude too high flag
				movw  #$7FFF, RESULT
				movw  RESULT, KI
				clr   COUNT
				ldx		#L$KI_BUF			;load vref buffer
	 			movb    #'3',0,X
				movb	#'2',1,X
				movb	#'7',2,X
				movb    #'6',3,X
				movb    #'7',4,X
				bra	  FINISH2
				
ZERO2:			movw  #$0000, RESULT	  	   ;sets the zero flag
				bra   FINISH2		
	
		 		
DONE2:								   ;finishes the BCD conversion
				ldd   #$7FFF			   ;loads 0 into acc d
				subd  RESULT			   ;compares d to result
				bmi   TOOBIG2				   ;if result is 0 branch to Zero
				movw  RESULT, KI
				bra   FINISH2
	FINISH2:	movb  #$00, t1s6state 		   
				clr   key_flag
				movb  #01, t1state
				jsr   LCDTEMPLATE
				rts
					
				
t1state7:		tst  AUTOUPDATE		;toggle AUTOUPDATE		   	 	   					
				lbeq  UPDATE1
				movb #$00, AUTOUPDATE
				lbra EXIT_t1s7
		UPDATE1: movb #$01, AUTOUPDATE
				bra EXIT_t1s7
	 EXIT_t1s7:	clr key_flag
   				movb #$01, t1state
				rts
						     	   				     
;===============================================================================
	;keypad driver

TASK_2:		  ldaa t2state
			  beq  initKEY
			  deca 
			  beq  t2state1
			  deca
			  beq  t2state2
			  rts
			  
			  	  		  				;t2state0
	initKEY:  jsr  KP_ACTIVE			;initializes the keypad
			  jsr  INITKEY
			  jsr  FLUSH_BFR
			  movb #$01,t2state			;t2state to 1
			  rts
			  
	t2state1: 
			  tst	L$KEY_FLG			;test key available flag t2state1
			  bne	SKIP					
			  jsr	GETCHAR				;gets the character entered, stores in b 
			  stab 	TEMP				;stores the contents of b in temp
			  movb  #$01, key_flag
	   		  movb  #02, t2state
			  rts
			  
	t2state2: tst key_flag	   	 		;when key_flag clears can accept next key
			  bne SKIP
			  movb #$01, t2state
			
	SKIP:	  rts		   				;returns to subroutine
	
;==========================================================================	 
;Display

TASK_3: 	ldaa t3state
			beq	 initDIS
			deca 
			lbeq t3state1			    ;display hub																																				
			deca
			lbeq t3state2 				;Change Vref
			deca
			lbeq t3state3				;Change Kp
			deca
			lbeq t3state4 				;Change Ki
			deca 
			lbeq t3state5				;digit state
			deca
			lbeq t3state6				;back space state
			deca
			lbeq t3state7				;closed displayed
			rts
			
initDIS:	jsr   INITLCD	 				;intializes the display
			jsr   CLRSCREEN				;t3state0	
			ldx		#L$KI_BUF			;load vref buffer
	 		movb    #'0',0,X
			movb	#'0',1,X
			movb	#'0',2,X
			movb    #'0',3,X
			movb    #'0',4,X
			ldx		#L$KP_BUF			;load vref buffer
	 		movb    #'0',0,X
			movb	#'0',1,X
			movb	#'0',2,X
			movb    #'0',3,X
			movb    #'0',4,X
			ldx		#L$VREF_BUF			;load vref buffer
	 		movb    #'0',0,X
			movb	#'0',1,X
			movb	#'0',2,X
			movb    #'0',3,X
			ldx		#L$VACT_BUF			;load vref buffer
	 		movb    #'0',0,X
			movb	#'0',1,X
			movb	#'0',2,X
			movb    #'0',3,X
			ldx		#L$ERR_BUF			;load vref buffer
	 		movb    #'0',0,X
			movb	#'0',1,X
			movb	#'0',2,X
			movb    #'0',3,X
			ldx		#L$EFRT_BUF			;load vref buffer
	 		movb    #'0',0,X
			movb	#'0',1,X
			movb	#'0',2,X
			movb    #'0',3,X
			jsr   LCDTEMPLATE
			movb #$01, t3state			;sets to state 1																									
			rts
			
t3state1:
			tst Cflag
			bne Cstate
			tst Dflag
			bne Dstate
			tst Eflag
			bne Estate
			tst	DIGITflag
			bne	Digit
			tst	BACKflag
			bne BackS
			tst	toggleCL
			bne ClosST
			rts
	Cstate:	movb #$02, t3state
			rts 
	Dstate: movb #$03, t3state
			rts	
    Estate: movb #$04, t3state
			rts
	Digit:  movb #$05, t3state
			rts
	BackS:  movb #$06, t3state
			rts
	ClosST: movb #$07, t3state
			rts		
t3state2:		   	 	   		   ;initial display
			 tst 	FIRSTCH 	   ;test if the first character is true
	  		 lbeq	DCHAR
	  		 ldaa	#$40		   ;loads the LCD address 
			 
	  		 ldx	#VrefPrompt	   ;starting address of string to be displayed
	  		 jsr 	DCHAR_1st
	  		 lbra 	BOTTOM
			 rts
			 
t3state3:	 
			  
			 tst 	FIRSTCH 	   ;test if the first character is true
	  		 lbeq	DCHAR
	  		 ldaa	#$40		   ;loads the LCD address 
	  		 ldx	#KPprompt	   ;starting address of string to be displayed
	  		 jsr 	DCHAR_1st
	  		 lbra 	BOTTOM
			 rts

t3state4:	 			  	 	   
			 tst 	FIRSTCH 	   ;test if the first character is true
	  		 lbeq	DCHAR
	  		 ldaa	#$40		   ;loads the LCD address 
	  		 ldx	#KIprompt	   ;starting address of string to be displayed
	  		 jsr 	DCHAR_1st
	  		 lbra 	BOTTOM
			 rts

t3state5:	 			  	 	   
			 tst	FIRSTdig	 	   ;ECHO state
			 bne	Ddigit_1st
			 bra	Ddigit			  	 	   

	Ddigit_1st:	ldaa #$47 
		   	 	jsr SETADDR
			 	jsr CURSOR
			 	clr FIRSTdig
			
	Ddigit:		 ldab TEMP
			 	 jsr OUTCHAR
			 	 clr TEMP
				 clr key_flag	
				 clr DIGITflag
				 movb #01, t3state		   ;return to hub ALWAYS		  	 	   
			 	 rts
				
				
t3state6:	 	ldaa  BACKflag
				deca  
				beq   b1
				deca
				beq	  b2
				rts
				
			b1: jsr  LOAD_ADDR		   ;load current address in acc A
			 	SUBA #$01			   ;subtract 1 from address
			 	jsr  SETADDR
			 	jsr  CURSOR
				movb #$02, BACKflag
				rts
				
			b2: ldab #$20	 		   ;load space into B
			 	jsr  OUTCHAR		   ;prints character in B
			 	jsr  LOAD_ADDR		   ;load current address in acc A
			 	SUBA #$01	
			 	jsr  SETADDR
			 	jsr  CURSOR	
				movb #$03, BACKflag
				movb #$01, t3state 	   ;return to hubstate
				rts

t3state7:    tst 	FIRSTCH 	   ;test if the first character is true
	  		 lbeq	DCHAR
	  		 ldaa	#$65		   ;loads the LCD address 
			 tst	CLOSED
			 beq	OPN
	  		 ldx	#CLOSEDprompt  ;starting address of string to be displayed
			 bra	NEXT
		OPN: ldx	#OPENprompt	 
	  	NEXT:jsr 	DCHAR_1st
	  		 lbra 	BOTTOM
			 rts
			 
  	  DCHAR_1st: 	
	  			STX DPTR   		   	   ;store contents of X in DPTR
			 	jsr SETADDR		   	   ;set the address of of cursor to current location
			 	clr FIRSTCH		   	   ;clear variable FIRSTCH
	  
  	  DCHAR:
	  			ldx DPTR		   	   ;load x with DPTR
				ldab 0,x		   	   ;load acc b with contents of the address located in X
				beq DONEdis		   
				jsr OUTCHAR
				inx
				stx DPTR
			
  	  BOTTOM:		
	   			tst FIRSTCH		   	   ;test if firstchar entered for another string
				bne RTNHUB	   	   	   ;branch to done 
				rts
			
      DONEdis:		
		  		movb #$01, FIRSTCH
				bra BOTTOM
			
      RTNHUB:	
				movb #$01, t3state	   ;sets back to hub state
				clr Cflag
				clr Dflag
				clr Eflag
				clr toggleCL
				rts 

;============================================================================= 
;Timer channel 0 initialization 

;timer channel 0

TASK_4:		   ldaa	t4state
			   beq  Setup
			   deca
			   beq  Donothing
	Setup:
		  	   			 ;set-up code

			movw #$3E80, INTERVAL	 ;sets interval to 16000

			bset PORTJ, PIN5			;closed latch
			bset DDRJ,  PIN5			; sets PORTJ to output from PIN5 
			 
			bset TIOS, Chan0  		 ;sets timer ch0 for output compare
			bset TCTL2, Chan0		 ;sets to toggle
			bset TFLG1, Chan0		 ;clears the output compare flag
			CLI	 					 ;clears th interrupt mask
			bset TMSK1, Chan0		 ;enables output compare interrupts
			
				 		;step 3 generates the first interrupt 

	   		bset $0086, $A0			 ;enables timer and sets to stop in background mode
			ldd  TCNT				 ;reads timer channel- load acc d
			ADDD INTERVAL			 ;adds interval to timer
			STD	 TC0
			movb #$01, t4state
			rts

 	Donothing: rts
		  
;=======================================================================

TCH0_ISR:
		 jsr	  VrefCalc
		 jsr	  READENCODER
		 tst   	  RUN 		  	 	;test RUN
		 beq	  STOPMOTOR			;branch to stopmotor
		 dec	  UPCOUNT			;decrement UPCOUNT
		 beq	  UPDATE		 
BACK:	 
		 tst	  CLOSED			;test closed or open loop
		 bne	  closed_loop		;branch to closed loop
		 lbra	  open_loop			;branch always to open loop
		 
UPDATE:	
		 tst	  NOUPDATE
		 bne	  SKIP1
		 jsr	  BCDtoASCIIerr
		 jsr	  BCDtoASCIIeff
		 jsr	  BCDtoASCIIVact
	     jsr 	  UPDATELCDL1
 SKIP1:	 movb	  #$FF, UPCOUNT
		 bra	  BACK
		 
STOPMOTOR:

		  ldd	  #$099A			;load acc d with 2458 = 6v (no motor turn)
		  std	  aSTAR				;store in aSTAR
		  lbra 	  OUTDAC			;branch to outdac

closed_loop:
		  
		  jsr	  ERRORact			;calculates error
		  ldd	  Esum				
		  movw	  ERRact, TEMPadd
		  jsr	  SatDA1   		 	;do a saturated doublebyte add
		  std	  Esum
		  ldd	  Esum
		  ldy	  KI
		  emuls	  	  				;multiply KI and esum
		  ldx  	  #$0400
		  edivs	  					;divide anser by 1024
		  bvs	  satEsum 			;branch if saturated		
		  sty	  eKI
		  
	MID:  ldd	  ERRact			;loads error
		  ldy	  KP				;loads KP
		  emuls	  					;multiplies the error and KP
		  ldx	  #$0400			;loads 1024
		  edivs	  					;divide by 1024
		  bvs	  sateKP			;branch if saturated
		  sty  	  eKP				;stores result
		  
		  
	ADD:  jsr	  SatDA				;adds eKP and eKI
		  bra	  add_offset		;branch to offset addition 
		  
	satEsum:
		  ldd	  Esum				;load e sum
		  bmi	  mEsum				;branch if negative
		  movw	  #$7FFF, eKI		;move highest positive number to esum		  
		  bra	  MID	  			;branch to mid
	mEsum:movw	  #$8000, eKI		;move highest negative nubmer to esum
		  bra	  MID
		  
	sateKP:
		  ldd	  ERRact	  		;load error
		  bmi	  mERR				;branch if negative
		  movw	  #$7FFF, eKP 		;saturate eKP to highest postive value
		  bra	  ADD	 			;branch to add
	mERR: movw	  #$8000, eKP		;satuate to most negaive value
		  bra	  ADD	  			;branch to add
		  	  
open_loop:
		  ldd 	  Vref	 			;loads err in d
		  ldy	  KP				;loads KP in y
		  emuls						;multiply y*d
		  ldx 	  #$0400			;load x with 1024
		  edivs						;divide by 1024 stores in y
		  
		  bvs	  OPsat
	nice: sty	  aPRIME			;stores y into aKP
OPend:
		  bra	  add_offset		;branch to add offset
	
	OPsat:
		  tst	  Vref
		  bmi	  nVref
		  movw	  #$7FFF,aPRIME
		  bra	  OPend
	nVref:cpd	  #$FFFF
		  beq	  nice
		  movw	  #$8000,aPRIME
		  bra	  OPend
		  
add_offset:

	movw    aPRIME, TEMPadd	;loads akp into d
	ldd		#$099A		   	;adds offset(2458) to the aKP
	jsr		SatDA1		
	std		aSTAR			;stores the result in aSTAR					
	ldd    	aSTAR	 		;load d with aSTAR
	cpd   	#$0D99			;compare to 8.5 = 3481
	bgt	   	a8.5			;branch to high sat
	cpd   	#$0599			;compare to 3.5 = 1433
	ble	   	a3.5			;branch low sat
	bra	   	OUTDAC

a8.5: 
	movw 	#$0D99,aSTAR		;move 3481 store in aSTAR
	movw   	#$0064,EFFRT		;make the effort 100
	bra	    OUTDAC			;branches to send to motor

a3.5:
	movw   #$0064,EFFRT		;make the effort 100
	movw   #$0599,aSTAR		;load acc d with 1433   			
	bra    OUTDAC			;branches to send to motor

OUTDAC: 
	jsr 	EFFORT	
	jsr	    ERROR	   
	ldd	 	aSTAR			;loads D with input value
	staa  	$0301			;stores the msb of A
	stab    $0300			;stores ot lsb of A
	bclr	PORTJ, PIN5		;Opens latch to DAC
	bset	PORTJ, PIN5		;closes latch to DAC	
	
	
OUTDACVact:  

	ldd 	Vact	 		;loads err in d
	ldy	    #0013			;multiply by 13
	emuls					;multiply y*d
	std		VactOUT			;stores y into aKP

	ldd	    VactOUT
	addd	#$099A
	staa  	$0303			;stores the msb of B
	stab    $0302			;stores ot lsb of B
	bclr	PORTJ, PIN5		;Opens latch to DAC
	bset	PORTJ, PIN5		;closes latch to DAC	
	
	ldd  	TC0				;read TC0
	ADDD 	INTERVAL   		;adds interval to TC0
	std	 	TC0			  	;stores new value in TC0
	bset 	TFLG1, Chan0 	;clears the interrupt flag
	rti
	
;=============================================================================
;Subroutines

BCDtoASCIIeff:

			  
		   ;value comes in in accumulator d
		    ldx		#L$EFRT_BUF			;load vref buffer
	 		movb    #'+',0,X
			movb	#' ',1,X
			movb	#' ',2,X
			movb    #' ',3,X
		   
		   movw	#L$EFRT_BUF, EFRTPTR
		   movb	#$03, COUNTBUFF
	
	   
		   
	OHYEAH:ldd	EFFRT
	YEAH:  ldx	#$000A		;load accumulator A with 10
		   idivs
		   stx	newHEX		;sores result in x
		   addb	#$30		;adds 30 to remainder
		   pshb			    ;pushes value on the stack
		   ldd	newHEX
		   dec	COUNTBUFF
		   beq	PULL
		   bra	YEAH
		   bgnd
		   
   PULL:   movb #$03, COUNTBUFF
		   
		ya: ldx	EFRTPTR
		   pulb
		   stab 1,X
		   inx
		   stx  EFRTPTR
		   dec 	COUNTBUFF
		   beq 	out
		   bra  ya
		   
	out:   tst	negEFF
		   beq	outtie
		   ldx	#L$EFRT_BUF
		   movb #'-',0,X	   
	outtie: rts	  
		   
BCDtoASCIIVact:
		   ;value comes in in accumulator d
		    ldx		#L$VACT_BUF			;load vref buffer
	 		movb    #'+',0,X
			movb	#' ',1,X
			movb	#' ',2,X
			movb    #' ',3,X
		   
		   movw	#L$VACT_BUF, VactPTR
		   movb	#$03, COUNTBUFF
		   
		   ldd	intVact
	YEAH1: ldx	#$000A		;load accumulator A with 10
		   idivs
		   stx	newHEX		;sores result in x
		   addb	#$30		;adds 30 to remainder
		   pshb			    ;pushes value on the stack
		   ldd	newHEX
		   dec	COUNTBUFF
		   beq	PULL1
		   bra	YEAH1
		   bgnd
		   
   PULL1:   movb #$03, COUNTBUFF
		   
	ya1:   ldx	VactPTR
		   pulb
		   stab 1,X
		   inx
		   stx  VactPTR
		   dec 	COUNTBUFF
		   beq 	out1
		   bra  ya1
		   bgnd
		   
	out1:  tst	negVact
		   beq	outtie1
		   ldx	#L$VACT_BUF
		   movb #'-',0,X	   
outtie1:   rts	  	  
	
BCDtoASCIIerr:
	  	  
		   ;value comes in in accumulator d
		    ldx		#L$ERR_BUF			;load vref buffer
	 		movb    #'+',0,X
			movb	#' ',1,X
			movb	#' ',2,X
			movb    #' ',3,X
		   
		   movw	#L$ERR_BUF, errPTR
		   movb	#$03, COUNTBUFF
		   
		   ldd	ERR
	YEAH2: ldx	#$000A		;load accumulator A with 10
		   idivs
		   stx	newHEX		;sores result in x
		   addb	#$30		;adds 30 to remainder
		   pshb			    ;pushes value on the stack
		   ldd	newHEX
		   dec	COUNTBUFF
		   beq	PULL2
		   bra	YEAH2
		   bgnd
		   
   PULL2:   movb #$03, COUNTBUFF
		   
	ya2:   ldx	errPTR
		   pulb
		   stab 1,X
		   inx
		   stx  errPTR
		   dec 	COUNTBUFF
		   beq 	out2
		   bra  ya2
		   bgnd
		   
	out2:  tst	negERR
		   beq	outtie2
		   ldx	#L$ERR_BUF
		   movb #'-',0,X	   
outtie2:   rts	  	  	
	
	
	
EFFORT: 
	   	 ldd    aSTAR
		 subd	#$099A 		 	   
		 ldy   	#$0064
		 emuls
		 ldx   	#$03FF
		 edivs
		 sty   	EFFRT
		 bmi   	comp
		 clr	negEFF
		 rts  
		 
	comp:
		 movb  #$01, negEFF
		 ldd   EFFRT
		 coma
	     negb
	     std  EFFRT
		 rts
		 
ERROR:
	  	 ldd  intVref
		 subd intVact
		 std  ERR
		 bmi  negerror
		 clr  negERR
		 rts
		
negerror:movb  #$01, negERR
		 ldd   ERR
		 coma
	     negb
	     std  ERR
		 rts
	
ERRORact: 
		 ldd  Vref
		 subd Vact
		 std  ERRact
		 rts
		  	
READENCODER:
		 ldd   	  Encoder			;read the encoder
		 std   	  new				;store value in d
		 subd  	  old				;subtract previous value
		 std   	  Vact				;store result in Vactual
		 bmi	  comVact
		 movw  	  new, old			;move value to preval
		 movw	  Vact, intVact		;move positvie value
		 clr	  negVact 
		 rts
		
	comVact:
		movb  #$01, negVact
		ldd	  Vact
		coma
		negb
		std	  intVact
		movw  new, old			;move value to preval
		rts			
		
SatDA:
	  	ldd	 eKP				;load d with eKP
		addd eKI				;load d with eKI
		bvc	 AHH2				;branch if no overflow
		tst	 eKP				;test eKI
		bmi	 NEGGY				;branch if minus
		movw #$7FFF, aPRIME		;max pos
		bra  AHH
NEGGY:  movw #$8000, aPRIME		;max neg
		bra	 AHH
	AHH2:std aPRIME
	AHH: rts

SatDA1:
		addd TEMPadd			;load d with eKI
		bvc	 AHH1				;branch if no overflow
		tst	 TEMPadd			;test eKI
		bmi	 NEGGY1				;branch if minus
		ldd  #$7FFF				;max pos
		bra  AHH
NEGGY1: ldd  #$8000 			;max neg
AHH1:	rts
		 
VrefCalc:
		tst		  VrefNEG
		bne		  negate
		rts
		
	negate:
		ldd		Vref
		coma
		negb
		std		Vref
		clr		VrefNEG
		rts
;============================================================================
VrefPrompt:		.ascii	 'Vref=                      '
				.byte	 $00
KPprompt:		.ascii	 'KP =                       '
				.byte	 $00
KIprompt:		.ascii	 'KI =                       '
				.byte	 $00
CLOSEDprompt:	.ascii	 'CL'
				.byte	 $00
OPENprompt:	    .ascii	 'OL'
				.byte	 $00				
;============================================================================

.area interrupt_vectors (abs)
	  .org	    $FFEE			 	;set location for interrupt service routine
	  .word	 	TCH0_ISR			;load address 
	  .org		$FFFE  				;at reset vector location
	  .word		__start				;load starting address
	  
;========================================================================




	  
	  
