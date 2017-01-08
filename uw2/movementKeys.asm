%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

[bits 16]

; TODO: read movement keys from a configuration file

; original movement scancodes:
;MovementScancode_FLY_DOWN               EQU 0x10 ; q
;MovementScancode_RUN_FORWARD            EQU 0x11 ; w
;MovementScancode_FLY_UP                 EQU 0x12 ; e
;MovementScancode_TURN_LEFT              EQU 0x1E ; a
;MovementScancode_WALK_FORWARD           EQU 0x1F ; s
;MovementScancode_TURN_RIGHT             EQU 0x20 ; d
;MovementScancode_SLIDE_LEFT             EQU 0x2C ; z
;MovementScancode_BACKWARDS              EQU 0x2D ; x
;MovementScancode_SLIDE_RIGHT            EQU 0x2E ; c

; These values are, more or less, Set 2 Translated key scancodes.
MovementScancode_FLY_DOWN               EQU 0x1D ; LCtrl
MovementScancode_RUN_FORWARD            EQU 0x11 ; w
MovementScancode_FLY_UP                 EQU 0x2A ; LShift
MovementScancode_TURN_LEFT              EQU 0x69 ; Left
MovementScancode_WALK_FORWARD           EQU 0x2D ; x
MovementScancode_TURN_RIGHT             EQU 0x6A ; Right
MovementScancode_SLIDE_LEFT             EQU 0x1E ; a
MovementScancode_BACKWARDS              EQU 0x1F ; s
MovementScancode_SLIDE_RIGHT            EQU 0x20 ; d

MovementType_NORMAL                     EQU 0x01
MovementType_BACKWARDS                  EQU 0x08
MovementType_SLIDE_LEFT                 EQU 0x09
MovementType_SLIDE_RIGHT                EQU 0x0A
MovementType_FLY_UP                     EQU 0x0C
MovementType_FLY_DOWN                   EQU 0x0D

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		customize movement keys
		
	off_movementScancodesArray EQU \
		off_dseg_segmentZero + dseg_movementScancodesArray
	startBlockAt off_movementScancodesArray
		db MovementScancode_FLY_DOWN
		db MovementScancode_RUN_FORWARD
		db MovementScancode_FLY_UP
		db MovementScancode_TURN_LEFT
		db MovementScancode_WALK_FORWARD
		db MovementScancode_TURN_RIGHT
		db MovementScancode_SLIDE_LEFT
		db MovementScancode_BACKWARDS
		db MovementScancode_SLIDE_RIGHT
	endBlockAt off_movementScancodesArray + 9
	
	startBlockAt 0x329E2
		; original would skip applying movement keys if any of Shift, Capslock,
		; Alt, or Ctrl were held.
		
		; instead, skip movement keys only if Ctrl and Alt are held together.
		; this prevents unwanted movement while Ctrl and Alt are held to select
		; spell runes, but otherwise allows modifier keys to be used as movement
		; keys.
		
		les bx, [dseg_shiftStates_ps]
		
		cmp byte [es:bx+ShiftStates_alt], 0
		jz ctrlAltNotHeld
		
		cmp byte [es:bx+ShiftStates_ctrl], 0
		jz ctrlAltNotHeld
		
		; Ctrl and Alt are both held; jump to end of proc
			jmp calcJump(0x32B2D)
			
		; spare bytes
			times 51 nop
			
		ctrlAltNotHeld:
	endBlockAt 0x32A2A
	
	startBlockAt 0x32A4A
		; ax == one of the 9 elements of movementScancodesArray
		
		mov bl, 0
		
		cmp ax, MovementScancode_RUN_FORWARD
		jnz notRunForward
		mov word [dseg_forwardThrottle], 112
		mov bl, MovementType_NORMAL
		jmp haveMovementType
		notRunForward:
		
		cmp ax, MovementScancode_WALK_FORWARD
		jnz notWalkForward
		mov word [dseg_forwardThrottle], 50
		mov bl, MovementType_NORMAL
		jmp haveMovementType
		notWalkForward:
		
		cmp ax, MovementScancode_TURN_LEFT
		jnz notTurnLeft
		mov word [dseg_rotationThrottle], -90
		mov bl, MovementType_NORMAL
		jmp haveMovementType
		notTurnLeft:
		
		cmp ax, MovementScancode_TURN_RIGHT
		jnz notTurnRight
		mov word [dseg_rotationThrottle], 90
		mov bl, MovementType_NORMAL
		jmp haveMovementType
		notTurnRight:
		
		cmp ax, MovementScancode_SLIDE_LEFT
		jnz notSlideLeft
		mov bl, MovementType_SLIDE_LEFT
		jmp haveMovementType
		notSlideLeft:
		
		cmp ax, MovementScancode_SLIDE_RIGHT
		jnz notSlideRight
		mov bl, MovementType_SLIDE_RIGHT
		jmp haveMovementType
		notSlideRight:
		
		cmp ax, MovementScancode_BACKWARDS
		jnz notBackwards
		xor ax, ax
		mov word [dseg_forwardThrottle], ax
		mov word [dseg_rotationThrottle], ax
		mov bl, MovementType_BACKWARDS
		jmp haveMovementType
		notBackwards:
		
		; can fly?
			test byte [dseg_avatarMovementFlags], 0x14
			jz notFly
			
		cmp ax, MovementScancode_FLY_DOWN
		jnz notFlyDown
		mov bl, MovementType_FLY_DOWN
		jmp haveMovementType
		notFlyDown:
		
		cmp ax, MovementScancode_FLY_UP
		jnz notFly
		mov bl, MovementType_FLY_UP
		jmp haveMovementType
		notFly:
		
		; none of the above
			jmp doneWithMovementKey
			
		haveMovementType:
			mov byte [dseg_movementType], bl
			
		doneWithMovementKey:
		; continue loop to check next movement key
			jmp calcJump(0x32B24)
			
		; spare bytes
			times 82 nop
			
	endBlockAt 0x32B24
endPatch
