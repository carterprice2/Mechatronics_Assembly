;L. Carter Price
;Sarah Visitacion

;Lab 5

;DOES THIS CHANGE

;Assembler Equates

Encoder = $0280
PORTJ   = $0028

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
Vref::		   .blkb 1
VrefBUFF::	   .blkb 3
VrefPTR::	   .blkb 2
;Task 1
t1s4state::	   .blkb 1 
bstate::	   .blkb 1
;Task 2
key_flag::	   .blkb 1

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
		  jsr Task_4		;Timer Ch0
		  bra TOP

		  
		  ;everything else is in the interrupt service routine
;===========================================================================
;Mastermind

TASK_1:	   ldaa	t1state
		   beq	t1state0
		   suba	
		   beq	t1state1
		   suba	
		   beq	t1state2
		   suba
		   beq  t1state3
		   suba 
		   beq	t1state4
		   suba 
		   beq  t1state4
		   suba
		   beq	t1state5
		   suba
		   beq  t1state6
		   suba 
		   beq	t1state7
		   suba 
		   beq  t1state8
		   
	t1state0:						;initialization state
				movb #$01, RUN
				movb #VrefBUFF, VrefPTR
				movb #$01, CLOSED		
				movb #$01, t1state
				
t1state1:		 	   		  	  	;hub state
				ldab TEMP
				cmpb #$41
				beq  Apress			;toggle run
				cmpb #$42	
				beq	 Bpress			;toggle open close
				cmpb #$43
				beq  Cpress			;change Vref
				cmpb #$44
				beq	 Dpress			;change kp/stop motor
				cmpb #$45
		   		beq  Epress			;change KI/stop motor	
				cmpb #$46
				beq	 Fpress			;toggle auto/manual update
				
		Apress: movb #$02, t1state
				bra	 EXIT_t1s1
		Bpress: movb #$03, t1state
				bra	 EXIT_t1s1			
		Cpress: movb #$04, t1state
				bra	 EXIT_t1s1
		Dpress: movb #$05, t1state
				bra	 EXIT_t1s1				
	   	Epress: movb #$06, t1state
				bra	 EXIT_t1s1
		Fpress: movb #$07, t1state
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
		 CLOSE: movb #$01, CLOSED
     EXIT_t1s3:	clr key_flag
   				movb #$01, t1state
				rts			
				
t1state4:   	ldaa   t1s4state
				beq	   t1s4s0	  			;state 4 hub
				suba
				beq	   t1s4s1				;digit state
				suba
				beq	   t1s4s2				;backspace
				suba
				beq	   t1s4s3				;enter
				suba
				beq	   t1s4s4				;error
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
				
	  t1s4s1:	movb 	#$01, DIGITflag		   ;sets the digit flag 
			 	ldab 	COUNT 				   ;places current LCD address in accumulator A
			 	cmpb	#$03				   ;makes sure don't type more than 3 digits
			 	lbeq	MAXdig				   ;clears dig flag so typing stops
				ldab  	TEMP
				ldx 	VrefPTR					;loads acc X with pointer
			 	stab 	0,X						;Stores contents of acc B into the location of the address found in acc X which is POINTER
			 	inc   	COUNT
			 	INX
			 	stx   	VrefPTR
			 	clr   	key_flag
				lbra  	EXIT
		MAXdig: movb	#$00, DIGITflag
				lbra 	EXIT
				
	  t1s4s1:	ldaa bstate	  		   			;backspace
				beq  accounting
				deca 
				beq  wait
				rts
					
		accounting: movb #$01, BACKflag		   		;sets the backspace flag
			 		ldab COUNT					    ;makes sure that you can't backspace past 0
			 		cmpb #$00					   
			 		beq  NOBS
					ldx VrefPTR					;load POINTER into X
			 		dex										
			 		clr 0,X						;clears the value stored at the address in X
			 		dec COUNT
			 		stx VrefPTR
					movb #01, bstate
					clr TEMP
					clr key_flag
			 		rts
					
		wait:		ldab BACKflag
					cmpb #$03
					beq	 moveon
					rts
					
				moveon: movb #00,BACKflag
						movb #01, t1state
						movb #$00, bstate 
						rts  
	
		NOBS:		movb #$00, BACKflag
					movb #$01, t1state
					clr key_flag
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
	initKEY:  jsr  KP_ACTIVE			+
	
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
;Read the Encoder

	;NOT REALLY PART OF THIS STATE
				 jsr	 INITLCD
				 jsr	 LCDTEMPLATE
				 ldx	 #L$VREF_BUF	;load index register X with buffer address
				 movb	 #'-', 0, X		;load first byte with ASCII character representing '-'
				 movb	 #'1', 1, X		;load next byte with ASCII character repinn' '2'
				 movb	 #'2', 2, X		;load next byte with ASCII character repinn' '2' 
		 		 movb	 #'5', 3, X		;load next byte with ASCII character repinn' '2'
		 		 jsr 	 UPDATELCDL1
				 movb 	 #$01, t3state
				 rts

		 
		  ldd 	 	Encoder				;loads the value of the encoder
		  std		FRED
		  movw		FRED, L$VACT_BUF	;loads fred into the actual velocity
		  ldd		L$VREF_BUF
		  subd		FRED	  			;subtraction
		  std		L$ERR_BUF			;store difference in fred and ref in error
		  jsr		UPDATELCDL1
		  jsr 		UPDATELCDL2
		  rts
		  
		  
;========================================================================



.area interrup_vectors (abs)
	  .org		$FFFE  				;at reset vector location
	  .word		__start				;load starting address