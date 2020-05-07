;Sarah Visitacion
;L. Carter Price
;Lab 4 Function Generator 

;Assembler Equates

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
DACALSB = $0300   ;the bit combo to send into lsb of DAC


.area bss

t1state::		  .blkb 1 			;state variable for mastermind
t2state::		  .blkb 1			;state variable for Keypad
t3state::		  .blkb 1			;state variable for Display
t4state::		  .blkb 1			;state variable for Timer channel 0
t5state::		  .blkb 1			;state variable for Function Generator
TEMP::			  .blkb 1			;stores the key entered
key_flag::		  .blkb 1			;indicates if a key is entered and in use
BACKflag::	      .blkb 1			;backspace flag  NOT USED YET
ENTERflag::		  .blkb 1			;if enter is pressed						 
DPTR:: 			  .blkb 2			;address of next character to be read and displayed
FIRSTCH::  		  .blkb 1         	;first character flag 	 
prompt_flag::	  .blkb 1			;flag to set initial prompt screen 
BUFFER::		  .blkb 6			;stores the entered digit
POINTER::		  .blkb 2 			;points to address of the next digit in buffer
COUNT::			  .blkb 1			;number of digits enterd  	   		 		  		 *
wave::			  .blkb 1			;which wave 
DIGITflag::		  .blkb 1			;flag to display digit
sawprompt_flag::  .blkb 1			;flag to display the saw wave prompt
bstate::		  .blkb 1			;the variable to track the movement through backspace
TOOHIGHflag::	  .blkb 1			;flag to display too high error
ZEROflag::		  .blkb 1			;flag for zero error
NODIGflag::		  .blkb 1			;no digits entered flag
RESULT::		  .blkb 1			;stores the result of BCD to binary conversion			
sineprompt_flag:: .blkb 1			;flag to dispaly sine 
squareprompt_flag::.blkb 1			;flag to display square
FIRSTdig::		  .blkb 1			;indicates first digit is being printed
NINT::			  .blkb 1			;number of interrupts per BTI
WAVEPTR::		  .blkb 2			;add. of 1st line of data table
CSEG::			  .blkb 1			;# of segments remaining for selected wave
LSEG::			  .blkb 1			;# of BTIs remaining in this segment
SEGINC::		  .blkb 2			;16-bit segment increment 
CINT::			  .blkb 1			;# of interrupts remaining in this BTI
VALUE::			  .blkb 2			;16-bit DAC input value
SEGPTR::		  .blkb 2			;points to the current segment
NEWBTI::		  .blkb 1			;new basic time interval
RUN::			  .blkb 1			;flag to run fuction generator
INTERVAL:: 		  .blkb 2			;the timer interrupt interval		
NINTOK::		  .blkb 1			;flag to let know that the NINT is valid			
TINC::			  .blkb 2			;temporary var for increment calculation

.area text

_main::	  	  movb #$00, t1state	;sets all initial states
			  movb #$00, t2state
			  movb #$00, t3state
			  movb #$00, t4state
			  movb #$00, t5state
			  movb #$00, wave
			  movb #$00, bstate
			  movb #$01, FIRSTCH
TOP:  
			 
			  jsr TASK_1			;mastermind
			  jsr TASK_2			;Keypad Driver
			  jsr TASK_3			;Display Driver
			  jsr TASK_4			;TIMER_C0
			  jsr TASK_5			;Function GEnerator
			  bra TOP
			  
			   
;============================================================================

;MASTERMIND	   check all the variables 																 

TASK_1:	   	ldaa    t1state
			beq	 	INITscreen 				;initialization state													 	
			deca
			beq 	Hubstate	 			;go to Hub state t1state = 1
			deca
			beq		Digitstate				;if t1state=2 
			deca
			lbeq	backstate				;t1state = 3
			deca
			lbeq	enterstate 				;t1state = 4
			rts
			 
INITscreen:   movb  #$01, prompt_flag		;sets the prompt flag
			  movb  #$01, FIRSTCH
			  movb  #$01, t1state
			  movw  #BUFFER, POINTER
			  rts

Hubstate:	  	
			  tst   key_flag				;test if a key has been pressed
			  lbeq   EXIT
			  ldab 	TEMP 			
			  CMPB	#$0A					;compares acc b to ent ascii value
			  LBEQ	ENTERpress	
			  CMPB	#$08					;compare acc b to BACKSPACE ascii value
			  LBEQ	BACKSPACE		
			  CMPB  #$30					;compares acc b to 30
			  LBLT	ERROR					;branch to Loop if less than 30
			  CMPB	#$39					;compares acc b to 39
			  LBLE	DIGITpress				;branches to digit
			 
			  rts		    	   
				
			  
			  
	DIGITpress:	  movb#02, t1state			  ;set to digitstate
				  rts		
				  
	BACKSPACE:	  movb#$03, t1state			  ;set to backstate  
				  rts	
				  
	ENTERpress:	  movb #$04, t1state		  ;set to enter state
				  rts
			   
Digitstate:	  
			   	  tst  wave	 				  ;test for wave
			  	  bne  DIGIT				  
			  	  ldaa TEMP
			  	  suba #$30	   				  ;subtract 30 from the digit entered
			  	  beq  ERROR   				  ;branch to Error	  
			  	  deca 
			  	  beq  Sawtooth		
			  	  deca
			  	  beq  Sine
			  	  deca
			  	  beq  Square
			  	  rts
			 
					  
					  
		ERROR:  	  lbra clear
					  
		
		Sawtooth:	  movb #01,  wave		  		;sets wave to sawtooth
					  movb #$01, sawprompt_flag
					  movb #$01, FIRSTdig
					  clr  RUN
					  movw #SAWTOOTH, WAVEPTR
					  lbra  clear
					  
					  
		Sine:		  movb #02,  wave		   		;sets wave to sine
					  movb #$01, sineprompt_flag
					  movb #$01, FIRSTdig
					  clr  RUN
					  movw #SINE, WAVEPTR
					  lbra clear
					  
					  
		Square:		  movb #03,  wave		 		;sets wave to Square
					  movb #$01, squareprompt_flag
					  movb #$01, FIRSTdig
					  clr  RUN
					  movw #SQUARE, WAVEPTR
					  lbra clear
					  
		DIGIT:		  
					  movb  #$01, DIGITflag		  	;sets the digit flag 
			 		  ldab 	COUNT 				    ;places current LCD address in accumulator A
			 		  cmpb	#$03				    ;makes sure don't type more than 3 digits
			 		  lbeq	MAXdig				    ;clears dig flag so typing stops
					  ldab  TEMP
					  ldx 	POINTER					;loads acc X with pointer
			 		  stab 	0,X						;Stores contents of acc B into the location of the address found in acc X which is POINTER
			 		  inc   COUNT
			 		  INX
			 		  stx   POINTER
			 		  clr 	key_flag
					  lbra 	End
			 
			 
	backstate:		ldaa bstate
					beq  accounting
					deca 
					beq  wait
					rts
					
		accounting: movb #$01, BACKflag		   		;sets the backspace flag
			 		ldab COUNT					    ;makes sure that you can't backspace past 0
			 		cmpb #$00					   
			 		beq  NOBS					    ;moves the pointer to account for backspace
					ldx  POINTER					;load POINTER into X
			 		dex										
			 		clr  0,X					 	;clears the value stored at the address in X
			 		dec  COUNT
			 		stx  POINTER
					movb #01, bstate
					clr  TEMP
					clr  key_flag
			 		rts
					
		wait:		ldab BACKflag
					cmpb #$03
					beq	 moveon
					rts
					
				moveon: movb #00,BACKflag			;resets backspace
						movb #01, t1state
						movb #$00, bstate 
						rts  
	
		NOBS:		movb #$00, BACKflag	  			;resets the backspace if the count is too low
					movb #$01, t1state
					clr  key_flag
					rts
					
enterstate: 		
				movw  #BUFFER, POINTER	   			;moves address of buffer to pointer
				clr   RESULT		   				;clears result
				tst   COUNT
				beq	  NODIG
				clra 					   
				clrb
				bgnd
					
		LOOP1:	
				clra
				clrb
				ldaa #$0A			   	   ;loads 10 in register a
				ldab RESULT			       ;loads result in acc d
				mul  					   ;multiplies a * b stores low in b high in y
				cmpa #$00				   ;
				bne	 TOOBIG				   ;brances to toobig if carry flag set
		OK:		stab RESULT			   	   ;stores acc into result
				ldx	 POINTER			   ;loads pointer into x
				ldab 0,X				   ;loads b with contents of address stored in x
				subb #$30				   ;subtracts 30 from b
				addb RESULT	 	   	  	   ;add acc b and RESULT
				
				stab RESULT				   ;stores acc d in result
				dec	 COUNT				   ;decrement count
					
				tst COUNT				   ;tests count to see if 0
				beq	DONE1
				
				inx		 				   ;increments x
				stx	POINTER				   ;stores contents of x in pointer
				bra LOOP1
				
TOOBIG:		 			 				   ;sets the magnitude too high flag
				movb #$01, TOOHIGHflag
				movb #$01, t1state
				clr  TEMP
				clr  COUNT
				movw #BUFFER, POINTER 	   ;resets POINTER
				rts
				
ZERO:			movb #$01, ZEROflag	  	   ;sets the zero flag
				movb #$01, t1state		   ;returns to hub stae
				clr  TEMP
				clr  COUNT
				movw #BUFFER, POINTER	   ;resets the POINTER
				rts
				
NODIG:			movb #$01, NODIGflag 	   ;sets the no digits entered flag
				movb #$01, t1state
				clr  TEMP
				clr  COUNT
				movw #BUFFER, POINTER	   ;resets the POINTER
				rts		
	
DONE1:								       ;finishes the BCD conversion
				ldab #$00				   ;loads 0 into acc d
				cmpb RESULT				   ;compares d to result
				beq  ZERO				   ;if result is 0 branch to Zero
				movb RESULT, NINT
				movb #$01, NINTOK		   ;sets NINTOK
				movb #$01, RUN	   		   ;sets RUN
				clr  key_flag
				movb #01, t1state		   ;return to hub
				clr  wave  				   ;clears variables used
				clr  TEMP
				clr  RESULT
				clr  COUNT
				movw #BUFFER, POINTER
				rts				   

		MAXdig:		 clr  DIGITflag		   ;clears the digit flag, so no typing
					 bra  clear
			 		 
			
		clear:		 clr  key_flag
					 clr  TEMP
					 movb #$01, t1state
					 rts		  
		End:		  
		
					 movb #$01, t1state    ;return to hubstate
					 rts
					  
		
EXIT:			rts	
;=============================================================================

;keypad driver

TASK_2:		  ldaa 	t2state
			  beq  	initKEY
			  deca 
			  beq  	t2state1
			  deca
			  beq  	t2state2
			  rts
			  
			  	  		  				;t2state0
	initKEY:  jsr   KP_ACTIVE			;initializes the keypad 
			  jsr   INITKEY
			  jsr 	FLUSH_BFR
			  movb 	#$01,t2state		;t2state to 1
			  rts
			  
	t2state1: tst	L$KEY_FLG			;test key available flag t2state1
			  bne	SKIP					
			  jsr	GETCHAR				;gets the character entered, stores in b 
			  stab 	TEMP				;stores the contents of b in temp
			  movb  #$01, key_flag
	   		  movb  #02, t2state
			  rts
			  
	t2state2: tst   key_flag	   	 	;when key_flag clears can accept next key
			  bne   SKIP
			  movb  #$01, t2state
			
	SKIP:	  rts		   				;returns to subroutine
	
;===============================================================================	   	   																	 

;Display

TASK_3:																														
			ldaa t3state
			beq	 initDIS
			deca 
			beq	 t3state1			    ;display hub	t3state = 1																																				
			deca
			lbeq t3state2				;initial prompt
			deca
			lbeq t3state3				;sawtooth prompt
			deca
			lbeq t3state4				;sine prompt
			deca
			lbeq t3state5				;square prompt
			deca 
			lbeq t3state6				;echo
			deca
			lbeq  t3state7				;backspace
			deca
			lbeq  t3state8				;too high
			deca  
			lbeq  t3state9				;zero magnitude
			deca
			lbeq  t3state10				;no digits entered  
			rts
			
initDIS:	jsr INITLCD	 				;intializes the display
			jsr CLRSCREEN				;t3state0		
			movb #$01, t3state			;sets to state 1																									
			rts

;DISPLAY HUB
t3state1:	   							;Display hub test for variales

			tst prompt_flag   			
			bne	prompt
			tst sawprompt_flag
			bne Sawprompt
			tst sineprompt_flag
			bne Sineprompt
			tst	squareprompt_flag
			bne Squareprompt
			tst DIGITflag
			bne ECHO
			tst BACKflag
			bne back
			tst TOOHIGHflag
			bne toohigh
			tst	ZEROflag
			bne zero
			tst NODIGflag
			bne nodig
			rts


	prompt:			movb #$02, t3state
					rts 
	Sawprompt:  	movb #$03, t3state
					rts
	Sineprompt:		movb #$04, t3state
					rts
	Squareprompt:	movb #$05, t3state
					rts
	ECHO:		 	movb #$06, t3state
					rts
	back:			movb #$07, t3state
					rts
	toohigh:		movb #$08, t3state
					rts
	zero:			movb #$09, t3state
					rts
	nodig:			movb #$0A, t3state
					rts
			
t3state2:		   	 	   		   ;initial display
			 tst 	FIRSTCH 	   ;test if the first character is true
	  		 lbeq	DCHAR
	  		 ldaa	#$00		   ;loads the LCD address 
			 
	  		 ldx	#PROMPT	   	   ;starting address of string to be displayed
	  		 jsr 	DCHAR_1st
	  		 lbra 	BOTTOM
			 rts
			 
t3state3:	 			  	 	   ;Sawtooth prompt 
			 tst 	FIRSTCH 	   ;test if the first character is true
	  		 lbeq	DCHAR
	  		 ldaa	#$40		   ;loads the LCD address 
	  		 ldx	#SAWPROMPT	   ;starting address of string to be displayed
	  		 jsr 	DCHAR_1st
	  		 lbra 	BOTTOM
			 rts

t3state4:	 			  	 	   ;Sawtooth prompt 
			 tst 	FIRSTCH 	   ;test if the first character is true
	  		 lbeq	DCHAR
	  		 ldaa	#$40		   ;loads the LCD address 
	  		 ldx	#SINEPROMPT	   ;starting address of string to be displayed
	  		 jsr 	DCHAR_1st
	  		 lbra 	BOTTOM
			 rts

t3state5:	 			  	 	   ;Sawtooth prompt 
			 tst 	FIRSTCH 	   ;test if the first character is true
	  		 lbeq	DCHAR
	  		 ldaa	#$40		   ;loads the LCD address 
	  		 ldx	#SQUAREPROMPT  ;starting address of string to be displayed
	  		 jsr 	DCHAR_1st
	  		 lbra 	BOTTOM
			 rts
			 
t3state6:	 tst	FIRSTdig	 	   ;ECHO state
			 bne	Ddigit_1st
			 bra	Ddigit			  	 	   

	Ddigit_1st:	ldaa #$52 			   ;sets the address to display the first digit
		   	 	jsr SETADDR
			 	jsr CURSOR
			 	clr FIRSTdig
			
	Ddigit:		 ldab TEMP			   ;displays a digit at a time
			 	 jsr  OUTCHAR
			 	 clr  TEMP
				 clr  key_flag	
				 clr  DIGITflag
				 movb #01, t3state	   ;return to hub ALWAYS		  	 	   
			 	 rts
				
				
t3state7:	 	ldaa  BACKflag
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

  	  DCHAR_1st: 	
	  			STX DPTR   		   	   ;store contents of X in DPTR
			 	jsr SETADDR		   	   ;set the address of of cursor to current location
			 	clr FIRSTCH		   	   ;clear variable FIRSTCH
	  
  	  DCHAR:
	  			ldx  DPTR		   	   ;load x with DPTR
				ldab 0,x		   	   ;load acc b with contents of the address located in X
				beq  DONE		   
				jsr  OUTCHAR
				inx
				stx  DPTR
			
  	  BOTTOM:		
	   			tst  FIRSTCH		   ;test if firstchar entered for another string
				bne  RTNHUB	   	   	   ;branch to done 
				rts
			
      DONE:		
		  		movb #$01, FIRSTCH
				bra  BOTTOM
			
      RTNHUB:	clr  prompt_flag
				movb #$01, t3state	   ;sets back to hub state
				tst  TOOHIGHflag
				bne  t3s8b
				tst  ZEROflag
				bne  t3s9b
				tst  NODIGflag
				bne  t3s10b
				clr  sawprompt_flag
				clr  sineprompt_flag
				clr  squareprompt_flag
				rts
t3state8:		   	 			   	   ;too high display
		 tst	FIRSTCH
		 lbeq	DCHAR
		 ldaa	#$40
		 ldx	#HIGH
		 jsr 	DCHAR_1st
		 bra	BOTTOM
			 		 
	t3s8b:	 clr TOOHIGHflag
			 jsr ClearError
			 rts	 

t3state9:			   				   ;zero magnitude display
		 tst 	FIRSTCH
		 lbeq	DCHAR
		 ldaa	#$40
		 ldx	#ZEROMAG
		 jsr 	DCHAR_1st
		 bra	BOTTOM
			 
	t3s9b:
			 clr ZEROflag
			 jsr ClearError
			 rts	
		 
t3state10:			   				   ;no digits entered display
		 tst 	FIRSTCH
		 lbeq	DCHAR
		 ldaa	#$40
		 ldx	#NODIGIT
		 jsr 	DCHAR_1st
		 bra	BOTTOM
			 
	t3s10b:	 clr NODIGflag
			 jsr ClearError
			 rts
				
ClearError:		 		   			   ;resets variables and flags after error is displayed
		   	 clr  TEMP		   	   	   ;error message clears when a new wave is selected
			 clr  sawprompt_flag
			 clr  sineprompt_flag
			 clr  squareprompt_flag
			 clr  wave
			 clr  key_flag
			 movb #01, t3state
			 rts

;==============================================================================
;timer channel 0

TASK_4:		   ldaa	t4state
			   beq  Setup
			   deca
			   beq  Donothing
	Setup:
		  	   			 ;set-up code
			
			movw #$0320, INTERVAL	 ;sets interval to 800

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
	
	
	TC0_ISR:   	  	   		  	;interrupt service routine
		
		tst RUN
		beq NOT_YET
		dec CINT   				;decrements CINT each time through
		beq RESET
		ldd VALUE				
		jsr OUTDAC				;outputs value to the dac
		
	NOT_YET:	  			  	;reset timer
		
		ldd  TC0				;read TC0
		ADDD INTERVAL   		;adds interval to TC0
		std	 TC0			  	;stores new value in TC0
		bset TFLG1, Chan0 		;clears the interrupt flag
		rti
	
	RESET: 	 					;resets the nint
		movb NINT, CINT
		movb #$01, NEWBTI		;sets new bti flag
		rti
		
;==============================================================================

;Function Generator     NEEDS WORK

TASK_5:	  ldaa t5state
		  beq  t5state0
		  deca 
		  beq  t5state1
		  deca
		  beq  t5state2
		  deca
		  beq  t5state3
		  deca 
		  beq  t5state4
		  rts
		 
t5state0: movb #$01, NEWBTI   	 ;sets new BTI
		  movb #$01, t5state  	 ;initialize
		  rts 
t5state1:
	   	  tst  wave
		  beq  t5s1a
		  movb #$02, t5state
t5s1a:	  rts


t5state2:                       ; NEW WAVE
        ldx    WAVEPTR          ; point to start of data for wave
        movb   0,X, CSEG        ; get number of wave segments
        movw   1,X, VALUE       ; get initial value for DAC
        movb   3,X, LSEG        ; load segment length
        movw   4,X, SEGINC      ; load segment increment
        inx                     ; inc SEGPTR to next segment
        inx
        inx
        inx
        inx
        inx
        stx    SEGPTR           ; store incremented SEGPTR for next segment
        movb   #$03, t5state    ; set next state
t5s2a:  rts


t5state3: 
		 tst   RUN	 			;tests to see if run is true
		 bne   move				
		 rts
		 
move: 	 tst   NINTOK			;test if the NINT is OK
		 beq   leave
		 movb  #04, t5state		;moves to next state and sets the NINT in CINT
		 movb  NINT, CINT
		 rts
leave:	 rts
			 

t5state4:                       ; DISPLAY WAVE
        tst    RUN
        beq    t5s4c            ; do not update function generator if RUN=0
        tst    NEWBTI
        beq    t5s4e            ; do not update function generator if NEWBTI=0
        dec    LSEG             ; decrement segment length counter
        bne    t5s4b            ; if not at end, simply update DAC output
        dec    CSEG             ; if at end, decrement segment counter
        bne    t5s4a            ; if not last segment, skip reinit of wave
		ldx    WAVEPTR          ; point to start of data for wave
        movb   0,X, CSEG        ; get number of wave segments
        movw   1,X, VALUE       ; get initial value for DAC
        movb   3,X, LSEG        ; load segment length
        movw   4,X, SEGINC      ; load segment increment
        inx                     ; inc SEGPTR to next segment
        inx
        inx
        inx
        inx
        inx
        stx    SEGPTR           ; store incremented SEGPTR for next segment
		bra    t5s4d
t5s4a:  ldx    SEGPTR           ; point to start of new segment
        movb   0,X, LSEG        ; initialize segment length counter
        movw   1,X, SEGINC      ; load segment increment
        inx                     ; inc SEGPTR to next segment
        inx
        inx
        stx    SEGPTR           ; store incremented SEGPTR
t5s4b:             
		jsr    TESTSEGINC
        bra    t5s4d
t5s4c:  movb   #$01, t5state    ; set next state
		clr    NINTOK
t5s4d:  clr    NEWBTI
t5s4e:  rts


	   				
				
;==============================================================================
PROMPT:			.ascii	 '1-SAWTOOTH  2-SINE  3-SQUARE'
				.byte	 $00 

SAWPROMPT:		.ascii	 'SAWTOOTH  NINT=                [1 -255]'
				.byte	 $00

SINEPROMPT:		.ascii	 'SINE  NINT=                    [1 -255]'
				.byte	 $00

SQUAREPROMPT:	.ascii	 'SQUARE  NINT=                  [1 -255]'
				.byte	 $00
								
HIGH:			.ascii	 '     MAGNITUDE TOO LARGE               '
				.byte	 $00
				
ZEROMAG:		.ascii	 '   ZERO MAGNITUDE INAPPROPRIATE        '
				.byte	 $00	

NODIGIT:		.ascii	 '   NO DIGITS                           '
				.byte	 $00 				
;=============================================================================
SAWTOOTH:

		 .byte 2					;number of segments
		 .word 1024					;initial DAC input value 5 volts
		 .byte 20					;length for segment 1
		 .word 112					;increment for segment 1
		 .byte 1					;length for segment 2
		 .word -2240				;increment for segment 2
		 
SINE:
	 	 .byte 7					;number of segments
		 .word 2048					;intial DAC value
		 .byte 25					;length
		 .word 33					;increment
		 .byte 50
		 .word 8
		 .byte 50
		 .word -8
		 .byte 50
		 .word -33
		 .byte 50
		 .word -8
		 .byte 50
		 .word 8
		 .byte 25
		 .word 33
		 
SQUARE:
	   	 .byte 4
		 .word 1024
		 .byte 1
		 .word 2240
		 .byte 10
		 .word 0
		 .byte 1
		 .word -2240
		 .byte 10
		 .word 0
		 

;====================================================================

SETUP:

	  	bset PORTJ, PIN5			;closed latch
		bset DDRJ,  PIN5			; sets PORTJ to output from PIN5    
	    rts

;===============================================================================		
		
OUTDAC:
	    staa  	$0301				;stores the msb of A
	    stab    $0300				;stores ot lsb of A
	    bclr	PORTJ, PIN5			;Opens latch to DAC
	    bset	PORTJ, PIN5			;closes latch to DAC
		rts	
		
TESTSEGINC:

		ldd		SEGINC 				;load d with seg inc
		cmpd	#$0000				;compare to 0
		BMI 	comp				;branch if negative
		ldd		SEGINC				;load increment to d
		addd    VALUE				;add value and d, result in d
		std 	VALUE				;store d in value
		rts
		
   comp:
		 movw SEGINC, TINC
   		 ldd  TINC					;take 2scompliment of seginc
		 NEGB
		 coma 						;takes the 1s compliment of a
		 std  TINC
		 ldd  VALUE					;load value into d
		 SUBD TINC				    ;subtract inc from value, result in d
		 STD  VALUE 				;store d in value
		 rts
		 
;======================================================================

.area interrupt_vectors (abs)
	  .org		$FFEE
	  .word 	TC0_ISR
	  .org		$FFFE  				;at reset vector location
	  .word		__start				;load starting address
	  
	  
;===============================================================================
