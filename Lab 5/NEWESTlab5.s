;L. Carter Price
;Sarah Visitacion

;Lab 5



;Assembler Equates

Encoder = $0280

PORTJ = $0028
DDRJ =  $0029
PIN5 =	0b00010000

TIOS = $0080	  ;Timer I/O select register address
TCTL2 = $0089	  ;address timer control register
TFLG1 = $008E	  ;Timer flag register
TCNT = $0084	  ;timer count register high byte
TCNT2 = $0085	  ;timer count register low byte
TC0 = $0090		  ;timer channel 0 compare register
TMSK1 = $008C	  ;timer chan 0 interrupt enable bits
Chan0 = $01

DACAMSB = $0301	  ;the bit combo to send into msb of DAC
DACALSB = $0300 


.area bss

t1state:: 	   .blkb 1
t2state::	   .blkb 1
t3state::	   .blkb 1
t4state::	   .blkb 1

;intertask
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
KP::		   .blkb 1
KI::		   .blkb 1
RESULT::	   .blkb 1
FIRSTdig::	   .blkb 1
;Task 1
t1s4state::	   .blkb 1 
bstate::	   .blkb 1
INPUT::		   .blkb 1
;Task 2
key_flag::	   .blkb 1
;Task 3

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

;use these for the UPDATE line
;L$VACT_BUF	   .blkb 2
;L$VREF_BUF	   .blkb 2
;L$ERR_BUF	   .blkb 2 

.area text


_main::	  
		  movb #$00, t1state
	   	  movb #$00, t2state
	   	  movb #$00, t3state
	   	  movb #$00, t4state
		
		  

	  TOP: 
	  	  jsr TASK_1 		;Mastermind
		  jsr TASK_2		;Keypad	
		  jsr TASK_3 		;Display
		  jsr TASK_4		;Timer Ch0
		  bra TOP

		  
		  ;everything else is in the interrupt service routine
;===========================================================================
;Mastermind

TASK_1:	   ldaa	t1state
		   beq	t1state0
		   deca	
		   beq	t1state1
		   deca	
		   lbeq	t1state2
		   deca
		   lbeq  t1state3
		   deca 
		   lbeq	t1state4
		   deca 
		   lbeq  t1state4
		   deca
		   lbeq	t1state5
		   rts
		   
	t1state0:						;initialization state
				movb #$01, prompt_flag
				movb #$01, RUN
				movb #BUFFER, POINTER
				movb #$01, CLOSED		
				movb #$01, t1state
				
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
				
		Apress: movb #$02, t1state
				bra	 EXIT_t1s1
		Bpress: movb #$03, t1state
				bra	 EXIT_t1s1			
		Cpress: movb #$04, t1state
				movb #$01, INPUT
				movb #$01, Cflag
				movb #$01, FIRSTdig
				bra	 EXIT_t1s1
		Dpress: movb #$04, t1state
				movb  #$02, INPUT
				movb  #$00, RUN
				movb #$01, Dflag
				movb #$01, FIRSTdig
				bra	 EXIT_t1s1				
	   	Epress: movb #$04, t1state
				movb  #$03, INPUT
				movb  #$00, RUN
				movb #$01, Eflag
				movb #$01, FIRSTdig
				bra	 EXIT_t1s1
		Fpress: movb #$05, t1state
				bra  EXIT_t1s1
	 EXIT_t1s1: clr  TEMP
	 			rts	
				
t1state2:		tst  RUN   		  	;toggle Run
				beq  RUN1
				movb #$00, RUN
				bra  EXIT_t1s2
		 RUN1:  movb #$01, RUN
    EXIT_t1s2:	clr key_flag
   				movb #$01, t1state
				rts		
				
t1state3:		tst  CLOSED		  	;toggle closed
				beq  CLOSE
				movb #$00, CLOSED
				bra  EXIT_t1s2
		CLOSE: 	movb #$01, CLOSED
     EXIT_t1s3:	clr key_flag
   				movb #$01, t1state
				rts			
				
t1state4:   	ldaa   t1s4state
				beq	   t1s4s0	  			;state 4 HUB
				deca
				beq	   t1s4s1				;digit state
				deca
				beq	   t1s4s2				;backspace
				deca
				lbeq   t1s4s3				;enter			
				rts
			
	 t1s4s0:	tst     key_flag			;test if a key has been pressed
			  	lbeq    EXIT
			  	ldab 	TEMP 			
			  	CMPB	#$0A				;compares acc b to ent ascii value
			  	LBEQ	ENTERpress	
			  	CMPB	#$08				;compare acc b to BACKSPACE ascii value
			  	LBEQ	BACKSPACE		
			  	CMPB    #$30				;compares acc b to 30
			  	LBLT	EXIT				;branch to Loop if less than 30
			  	CMPB	#$39				;compares acc b to 39
			  	LBLE	DIGITpress			;branches to digit
				bra 	EXIT
			
	ENTERpress:	movb    #$03, t1s4state
				bra 	EXIT
	BACKSPACE:  movb	#$02, t1s4state
				bra 	EXIT
	DIGITpress: movb	#$01, t1s4state					
		EXIT:	clr 	key_flag
				rts		
				
	  t1s4s1:	movb 	#$01, DIGITflag		   	;sets the digit flag 
			 	ldab 	COUNT 					;places current LCD address in accumulator A
			 	cmpb	#$05					;makes sure don't type more than 3 digits
			 	lbeq	MAXdig					;clears dig flag so typing stops
				ldab  	TEMP
				ldx 	POINTER					;loads acc X with pointer
			 	stab 	0,X						;Stores contents of acc B into the location of the address found in acc X which is POINTER
			 	inc   	COUNT
			 	INX
			 	stx   	POINTER
			 	clr   	key_flag
				lbra  	EXIT
		MAXdig: movb	#$00, DIGITflag
				movb 	#$00, t1s4state
				lbra 	EXIT
				
	  t1s4s2:	ldaa bstate	  		   			;backspace
				beq  accounting
				deca 
				beq  wait
				rts
					
		accounting: movb #$01, BACKflag		   	;sets the backspace flag
			 		ldab COUNT					;makes sure that you can't backspace past 0
			 		cmpb #$00					   
			 		beq  NOBS
					ldx POINTER					;load POINTER into X
			 		dex										
			 		clr 0,X						;clears the value stored at the address in X
			 		dec COUNT
			 		stx POINTER
					movb #01, bstate
					clr TEMP
					clr key_flag
			 		rts
					
		wait:		ldab BACKflag
					cmpb #$03
					beq	 moveon
					rts
					
				moveon: movb #00,BACKflag
						movb #00,  t1s4state
						movb #$00, bstate 
						rts  
	
		NOBS:		movb #$00, BACKflag
					movb #$00, t1s4state
					clr key_flag
					rts

		
	t1s4s3:									;the enter state for Vref
		 		;ASCII to BCD converter
				
				movw  #BUFFER, POINTER	   ;moves address of buffer to pointer
				movw #$00, RESULT		   ;clears result
				clra 					   
				clrb
			
		LOOP1:	
				ldaa  #$0A			   ;loads 10 in register y
				ldab  RESULT		   ;loads result in acc d
				mul  				   ;multiplies d * y stores low in d high in y
				stab  RESULT		   ;stores acc into result
				ldx	 POINTER		   ;loads pointer into x
				ldab 0,X			   ;loads b with contents of address stored in x
				subb #$30			   ;subtracts 30 from b
				addb RESULT	 	   	   ;add acc b and RESULT
				BCS	 TOOBIG			   ;brances to toobig if carry flag set
				std  RESULT			   ;stores acc d in result
				dec	 COUNT			   ;decrement count
					
				tst COUNT			   		;tests count to see if 0
				beq	DONE1
				
				inx		 				   ;increments x
				stx	POINTER				   ;stores contents of x in pointer
				bra LOOP1
				
TOOBIG:		 	;BGND	 				   ;sets the magnitude too high flag
				movb #$01, TOOHIGHflag
				rts
				
ZERO:			movb #$01, ZEROflag	  	   ;sets the zero flag
				rts			
	
DONE1:			BGND					   ;finishes the BCD conversion
				ldd  #$0000				   ;loads 0 into acc d
				cpd  RESULT				   ;compares d to result
				beq  ZERO				   ;if result is 0 branch to Zero
				ldaa INPUT
				deca
				beq   C
				deca
				beq   D
				deca
				beq	E
				bra  FINISH

		C:		movb RESULT, Vref
				bra FINISH
		D:		movb RESULT, KP
				bra FINISH
		E:		movb RESULT, KI
	FINISH:		movb  #$00, t1s4state 		   
				clr  key_flag
				movb #01, t1state
				rts
						     	


t1state5:		tst  AUTOUPDATE		;toggle AUTOUPDATE		   	 	   					
				beq  UPDATE
				movb #$00, AUTOUPDATE
				lbra EXIT_t1s5
		UPDATE: movb #$01, AUTOUPDATE
				bra EXIT_t1s5
	 EXIT_t1s5:	clr key_flag
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
	initKEY:  jsr  KP_ACTIVE			
	
	;initializes the keypad 
			  jsr  INITKEY
			  jsr  FLUSH_BFR
			  movb #$01,t2state			;t2state to 1
			  rts
			  
	t2state1: tst	L$KEY_FLG			;test key available flag t2state1
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
			beq	 t3state1			    ;display hub																																				
			deca
			lbeq t3state2				;initial prompt
			deca
			lbeq Cstate 				;Change Vref
			deca
			lbeq Dstate 				;Change Kp
			deca
			lbeq Estate 				;Change Ki
			deca 

initDIS:	jsr INITLCD	 				;intializes the display
			jsr CLRSCREEN				;t3state0		
			movb #$01, t3state			;sets to state 1																									
			rts
			
t3state1:	tst prompt_flag
			bne prompt
			tst Cflag
			bne Cstate1
			tst Dflag
			bne Dstate
			tst Eflag
			bne Estate
			
			
	prompt:		movb #$02, t3state
				rts
	Cstate1:		movb #$03, t3state
				rts 
				
t3state2:	 jsr	 LCDTEMPLATE
			 ldx	 #L$VREF_BUF	;load index register X with buffer address
			 movb	 #'-', 0, X		;load first byte with ASCII character representing '-'
			 movb	 #'1', 1, X		;load next byte with ASCII character repinn' '1'
			 movb	 #'2', 2, X		;load next byte with ASCII character repinn' '2' 
		 	 movb	 #'5', 3, X		;load next byte with ASCII character repinn' '5'

Cstate:		 tst	FIRSTdig	 	   ;Change Vref
			 bne	Vref_1st
			 bra	Ddigit			  	 	   

	Vref_1st:	ldaa #$05 			   ;sets the address to display the first digit
		   	 	jsr SETADDR
			 	jsr CURSOR
			 	clr FIRSTdig
			
		Ddigit:	ldab TEMP			   ;displays a digit at a time
			 	jsr  OUTCHAR
			 	clr  TEMP
				clr  key_flag	
				clr  DIGITflag
				movb #01, t3state	   ;return to hub ALWAYS		  	 	   
			 	rts
				
Dstate:		 tst	FIRSTdig	 	   ;Change Kp
			 bne	Kp_1st
			 bra	Ddigit			  	 	   

	Kp_1st:	ldaa #$59 			   ;sets the address to display the first digit
		   	jsr SETADDR
			jsr CURSOR
			clr FIRSTdig
			
Estate:		 tst	FIRSTdig	 	   ;Change Ki
			 bne	Kp_1st
			 bra	Ddigit			  	 	   

	Ki_1st:	ldaa #$48 			   ;sets the address to display the first digit
		   	jsr SETADDR
			jsr CURSOR
			clr FIRSTdig
			
				



;============================================================================= 
;Timer channel 0 initialization 

;timer channel 0

TASK_4:		   ldaa	t4state
			   beq  Setup
			   deca
			   beq  Donothing
	Setup:
		  	   			 ;set-up code
			
			movw #$0320, INTERVAL	 ;sets interval to 800

			bset TIOS, Chan0  		 ;sets timer ch0 for output compare
			bset TCTL2, Chan0		 ;sets to toggle
			bset TFLG1, Chan0		 ;clears the output compare flag
			CLI	 					 ;clears th interrupt mask
			bset TMSK1, Chan0		 ;enables output compare interrupts
			
				 		;step 3 generates the first interrupt 

	   		bset $0086, $A0			 ;enables timer and sets to stop in background mode
			ldd TCNT				 ;reads timer channel- load acc d
			ADDD INTERVAL			 ;adds interval to timer
			STD	 TC0
			movb #$01, t4state
			rts

 	Donothing: rts
		  
;=======================================================================
TCH0_ISR::

tst   RUN 		  	 	;test RUN
beq	  STOPMOTOR			;branch to stopmotor
tst	  CLOSED			;test closed or open loop
bne	  closed_loop		;branch to closed loop
bra	  open_loop			;branch always to open loop

STOPMOTOR:

	ldd		  #$099A		;load acc d with 2458 = 6v (no motor turn)
	std		  aPRIME		;store in aprime
	bra 	  OUTDAC		;branch to outdac

	;Read the encoder and get Vactual (ONLY FOR CLOSED LOOP)

closed_loop:

	ldd 	Encoder			;loads the value of the encoder
	std		FRED			;stores encoder value in FRED
	movw	FRED, Vact		;loads fred into the actual velocity
	ldd		Vref  			;loads vref into d
	subd	FRED	  		;subtraction
	std		ERR     		;store difference in fred and ref in error
	bra		CONTROLLER		;branch to controller

open_loop:
	ldd	    Vref			;load Vref to d
	std		ERR				;move Vref to error
	
CONTROLLER:

	ldd		ERR	 			;loads err in d
	ldy		KP				;loads KP in y
	emul					;multiply y*d
	std	    aKP				;stores the result in (should only be 12 bit max)
	ldy		aKP				;load y with aKP
	ldx 	#$0400			;load x with 1024
	ediv					;divide by 1024 stores in y
	sty		aKP				;stores y into aKP
	;Check for saturation, overflow
	cmpd	#$0000		   	;compare d to 0;checks for remainder in d 
	bne		SAT				;branch to error if y not 0
	bra		add_offset		;branch to add offset
	
SAT: ;this needs to check the saturation based on if positive or negative
		
add_offset:

	ldd	  	aKP	 		   	;loads akp into d
	addd	#$099A		   	;adds offset(2458) to the aKP
	std		aPRIME			;stores the result in aprime

	;Bound the input to the SA60-check sat/overflow
								
	ldd    aPRIME	 		;load d with aprime
	cmpd   #$0D99			;compare to 8.5 = 3481
	bgt	   a8.5				;branch to high sat
	cmpd   #$0599			;compare to 3.5 = 1433
	ble	   a3.5				;branch low sat
	bra	   OUTDAC

a8.5:

	ldd	   #$0D99			;load acc d with 3481
	std	   aPRIME			;store in aprime
	bra	   OUTDAC			;branches to send to motor

a3.5:

	ldd	   #$0599			;load acc d with 1433
	std	   aPRIME			;store in aprime
	bra    OUTDAC			;branches to send to motor

OUTDAC:

	ldd	 	aPRIME			;loads D with input value
	staa  	$0301			;stores the msb of A
	stab    $0300			;stores ot lsb of A
	bclr	PORTJ, PIN5		;Opens latch to DAC
	bset	PORTJ, PIN5		;closes latch to DAC	
	
ERROR:	rti



;============================================================================

.area interrupt_vectors (abs)
	  .org	    $FFEE			 	;set location for interrupt service routine
	  .word	 	TCH0_ISR			;load address 
	  .org		$FFFE  				;at reset vector location
	  .word		__start				;load starting address
	  
;========================================================================




	  
	  
