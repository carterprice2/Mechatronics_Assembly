; Assembler equates
PORTT      = $00AE                 ; input port for DELAY_CNT
DDRT       = $00AF
PORTJ      = $0028                 ; output port for LEDs
DDRJ       = $0029
LED_MSK    = 0b01100000            ; LED output pins
R_LED      = 0b00100000            ; red LED output pin
G_LED      = 0b01000000            ; green LED output pin


; RAM area
.area bss
DELAY_CNT::    .blkb 1

; code area
.area text
;
;===============================================================
;
;    main
_main::

        jsr    SETUP               ; jump to SETUP subroutine

; YOUR CODE GOES HERE

Top:
  	   bset PORTJ, G_LED 		   ; Green ON and red OFF
	   ;bclr PORTJ, 
	   jsr DELAY
	   
	   bclr PORTJ, LED_MSK		   ; Green OFF and red OFF 
	   ;bset PORTJ, 
	   jsr DELAY
	   
	   ;bclr PORTJ, 
	   bset PORTJ, R_LED		   ; Green OFF and red ON 
	   jsr DELAY
	   
	   bclr PORTJ, R_LED		   ; Green OFF and red OFF 
	   ;bclr PORTJ, 
	   jsr DELAY
	   
	   bset PORTJ, LED_MSK		   ; Green ON and red ON 
	   ;bset PORTJ, 
	   jsr DELAY
	   
	   bclr PORTJ, LED_MSK 		   ; Green OFF and red OFF
	   ;bclr PORTJ, 
	   jsr DELAY
	
	   bra Top
		
;    end main

;===============================================================
;
;    Subroutine Delay Delay[s] = ~100ms per DELAY_CNT
;
DELAY:
        ldaa   PORTT               ; (3) load 8-bit DELAY_CNT
        staa   DELAY_CNT           ; (3)
OUTER:                             ; outer loop

        ldaa   DELAY_CNT           ; (3)
        cmpa   #0                  ; (1)
        beq    EXIT                ; (1)
        dec    DELAY_CNT           ; (4)
        ldy    #$FFFC              ; (2)
INNER:                             ; inside loop
        cpy    #0                  ; (2)
        beq    OUTER               ; (1)
        dey                        ; (1)
        bra    INNER               ; (3)
EXIT:
        rts                        ; (5) exit DELAY

;    end subroutine DELAY
;===============================================================
;
;    Subroutine SETUP
;
SETUP:

; setup IO ports

        clr    DDRT                ; set PORTT to input
        bclr   PORTJ, LED_MSK      ; initialize LEDs to off
        bset   DDRJ,LED_MSK        ; set LED pins to output
        rts                        ; exit SETUP

;;;; end subroutine SETUP
;===============================================================


.area interrupt_vectors (abs)
        .org   $FFFE               ; at reset vector location, 
        .word  __start             ; load starting address

