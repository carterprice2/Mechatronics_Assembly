;Assembler equates

PORTS        = $00D6              ; output port for LEDs
DDRS         = $00D7
LED_MSK_1    = 0b00000011         ; LED_1 output pins
R_LED_1      = 0b00000001         ; red LED_1 output pin
G_LED_1      = 0b00000010		  ; green LED_1 output pin
LED_MSK_2	 = 0b00001100        
R_LED_2		 = 0b00000100
G_LED_2		 = 0b00001000

; RAM area
.area bss
TICKS_1::    .blkb 2              ; use this space to explain each of your variables
COUNT_1::    .blkb 2
DONE_1::     .blkb 1
TICKS_2::    .blkb 2
COUNT_2::    .blkb 2
DONE_2::     .blkb 1
t1state::    .blkb 1
t2state::    .blkb 1
t3state::    .blkb 1
t4state::    .blkb 1
t5state::    .blkb 1

;code area
.area text
;
;==============================================================================
;
;   main program

_main::

        clr    t1state            ; initialize all tasks to state0
        clr    t2state
        clr    t3state

;  Normally no code other than that to clear the state variables and call the tasks
;  repeatedly should be in your main program.  However, this week we will make an 
;  exception.  The following code will allow the user to set TICKS_1 and TICKS_2 in
;  the debugger.

        movw   #200, TICKS_1      ; set default for TICKS_1
        movw   #500, TICKS_2      ; set default for TICKS_2
        bgnd                      ; stop in DEBUGGER to allow user to alter TICKS

TOP:    ;bgnd
		jsr    TASK_1
		;bgnd
        jsr    TASK_2
		;bgnd
        jsr    TASK_3
		;bgnd
		jsr	   TASK_4
		jsr	   TASK_5
        bra    TOP

; end main
 
;=============================================================================
;
;    Subroutine TASK_1            ; pattern_1

TASK_1: ldaa   t1state            ; get current t1state and branch accordingly
        beq    t1state0
        deca
        beq    t1state1
        deca
        beq    t1state2
        deca
        beq    t1state3
        deca
        beq    t1state4
        deca
        beq    t1state5
        deca
        beq    t1state6
        rts                       ; undefined state - do nothing but return

t1state0:                         ; init TASK_1
        bclr   PORTS, LED_MSK_1   ; ensure that LEDs are off when initialized
        bset   DDRS, LED_MSK_1    ; set LED_MSK_1 pins as PORTS outputs
        movb   #$01, t1state      ; set next state
        rts

t1state1:                         ; G, not R
        bset   PORTS, G_LED_1     ; set state1 pattern on LEDs
        tst    DONE_1             ; check TASK_1 done flag
        beq    exit_t1s1          ; if not done, return
        movb   #$02, t1state      ; if done, set next state
exit_t1s1:
        rts
t1state2:                         ; not G, not R
        bclr   PORTS, G_LED_1     ; set state2 pattern on LEDs
        tst    DONE_1             ; check TASK_1 done flag
        beq    exit_t1s2          ; if not done, return
        movb   #$03, t1state      ; if done, set next state
exit_t1s2:
        rts
t1state3:                         ; not G, R
        bset   PORTS, R_LED_1     ; set state3 pattern on LEDs
        tst    DONE_1             ; check TASK_1 done flag
		;bgnd
        beq    exit_t1s3          ; if not done, return
        movb   #$04, t1state      ; if done, set next state
exit_t1s3:
        rts
t1state4:                         ; not G, not R
        bclr   PORTS, LED_MSK_1   ; set state4 pattern on LEDs
        tst    DONE_1             ; check TASK_1 done flag
        beq    exit_t1s4          ; if not done, return
        movb   #$05, t1state      ; if done, set next state
exit_t1s4:
	     rts
t1state5:                         ; G, R
        bset   PORTS, LED_MSK_1   ; set state5 pattern on LEDs
        tst    DONE_1             ; check TASK_1 done flag
		;bgnd
        beq    exit_t1s5          ; if not done, return
        movb   #$06, t1state      ; if done, set next state
exit_t1s5:
        rts

t1state6:                         ; not G, not R
        bclr   PORTS, LED_MSK_1   ; set state6 pattern on LEDs
        tst    DONE_1             ; check TASK_1 done flag
        beq    exit_t1s6          ; if not done, return
        movb   #$01, t1state      ; if done, set next state
exit_t1s6:
        rts

; end TASK_1
;
;=============================================================================
;
;    Subroutine TASK_2            ; count down LED_1 pair

TASK_2: ldaa   t2state            ; get current t2state and branch accordingly
        beq    t2state0
        deca
        beq    t2state1
		deca
		beq	   t2state2
        rts                       ; undefined state - do nothing but return

t2state0:                         ; initialization for TASK_2
        clr    DONE_1
        movb   #$01, t2state      ; set next state

t2state1:                         ; (re)initialize COUNT_1
        movw   TICKS_1, COUNT_1
        ldx    COUNT_1
        dex                       ; decrement COUNT_1
        stx    COUNT_1            ; store decremented COUNT_1
        clr    DONE_1
        movb   #$02, t2state      ; set next state
        ;rts

t2state2:                         ; count down COUNT_1
        ldx    COUNT_1
        beq    setdone_1          ; test to see if COUNT_1 is already zero
        dex                       ; decrement COUNT_1
        stx    COUNT_1            ; store decremented COUNT_1
        bne    exit_t2s2          ; if not done, return
setdone_1:
        movb   #$01, DONE_1       ; if done, set DONE_1 flag
        movb   #$01, t2state      ; set next state
exit_t2s2:
        rts

; end TASK_2
; 
;=============================================================================
;    Subroutine TASK_4            ; pattern_2

TASK_4: ldaa   t4state            ; get current t4state and branch accordingly
        beq    t4state0
        deca
        beq    t4state1
        deca
        beq    t4state2
        deca
        beq    t4state3
        deca
        beq    t4state4
        deca
        beq    t4state5
        deca
        beq    t4state6
        rts                       ; undefined state - do nothing but return

t4state0:                         ; init TASK_1
        bclr   PORTS, LED_MSK_2   ; ensure that LEDs are off when initialized
        bset   DDRS, LED_MSK_2    ; set LED_MSK_1 pins as PORTS outputs
        movb   #$01, t4state      ; set next state
        rts

t4state1:                         ; G, not R
        bset   PORTS, G_LED_2     ; set state1 pattern on LEDs
        tst    DONE_2             ; check TASK_1 done flag
        beq    exit_t4s1          ; if not done, return
        movb   #$02, t4state      ; if done, set next state
exit_t4s1:
        rts
t4state2:                         ; not G, not R
        bclr   PORTS, G_LED_2     ; set state2 pattern on LEDs
        tst    DONE_2             ; check TASK_1 done flag
        beq    exit_t4s2          ; if not done, return
        movb   #$03, t4state      ; if done, set next state
exit_t4s2:
        rts
t4state3:                         ; not G, R
        bset   PORTS, R_LED_2     ; set state3 pattern on LEDs
        tst    DONE_2             ; check TASK_1 done flag
		;bgnd
        beq    exit_t4s3          ; if not done, return
        movb   #$04, t4state      ; if done, set next state
exit_t4s3:
        rts
t4state4:                         ; not G, not R
        bclr   PORTS, LED_MSK_2   ; set state4 pattern on LEDs
        tst    DONE_2             ; check TASK_1 done flag
        beq    exit_t4s4          ; if not done, return
        movb   #$05, t4state      ; if done, set next state
exit_t4s4:
	     rts
t4state5:                         ; G, R
        bset   PORTS, LED_MSK_2   ; set state5 pattern on LEDs
        tst    DONE_2             ; check TASK_1 done flag
		;bgnd
        beq    exit_t4s5          ; if not done, return
        movb   #$06, t4state      ; if done, set next state
exit_t4s5:
        rts

t4state6:                         ; not G, not R
        bclr   PORTS, LED_MSK_2   ; set state6 pattern on LEDs
        tst    DONE_2             ; check TASK_1 done flag
        beq    exit_t4s6          ; if not done, return
        movb   #$01, t4state      ; if done, set next state
exit_t4s6:
        rts

; end TASK_4
;
;=============================================================================
;
;    Subroutine TASK_5            ; count down LED_2 pair

TASK_5: ldaa   t5state            ; get current t5state and branch accordingly
        beq    t5state0
        deca
        beq    t5state1
		deca
		beq	   t5state2
        rts                       ; undefined state - do nothing but return

t5state0:                         ; initialization for TASK_2
        clr    DONE_2
        movb   #$01, t5state      ; set next state

t5state1:                         ; (re)initialize COUNT_2
        movw   TICKS_2, COUNT_2
        ldx    COUNT_2
        dex                       ; decrement COUNT_2
        stx    COUNT_2            ; store decremented COUNT_2
        clr    DONE_2
        movb   #$02, t5state      ; set next state
        ;rts

t5state2:                         ; count down COUNT_2
        ldx    COUNT_2
        beq    setdone_2          ; test to see if COUNT_2 is already zero
        dex                       ; decrement COUNT_2
        stx    COUNT_2            ; store decremented COUNT_2
        bne    exit_t5s2          ; if not done, return
setdone_2:
        movb   #$01, DONE_2       ; if done, set DONE_2 flag
        movb   #$01, t5state      ; set next state
exit_t5s2:
        rts

; end TASK_2
; 


;=============================================================================
;
;    Subroutine TASK_3            ; delay 1.00ms

TASK_3: ldaa   t3state            ; get current t3state and branch accordingly
        beq    t3state0
        deca
        beq    t3state1
        rts                       ; undefined state - do nothing but return

t3state0:                         ; initialization for TASK_3
                                  ; no initialization required
        movb   #$01, t3state      ; set next state
        rts

t3state1:
        jsr    DELAY_1ms
        rts

; end TASK_3
;
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


.area interrupt_vectors (abs)
        .org    $FFFE             ; at reset vector location
        .word   __start           ; load starting address

