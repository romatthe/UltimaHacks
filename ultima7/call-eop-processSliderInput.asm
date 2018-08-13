%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		call eop to handle key actions and right-click-to-close in sliders
		
	; don't enable keyMouse mode, which would block the Left and Right keys
	off_doSlider_switchToKeyMouseMode       EQU 0x1C31
	off_doSlider_switchToKeyMouseMode_end   EQU 0x1C38
	startBlockAt 340, off_doSlider_switchToKeyMouseMode
		jmp calcJump(off_doSlider_switchToKeyMouseMode_end)
	endBlockWithFillAt nop, off_doSlider_switchToKeyMouseMode_end
	
	; process input with new proc in the absence of a MB1 click
	off_doSlider_determineHowToProcessInput EQU 0x1C44
	off_doSlider_processMb1Input            EQU 0x1C61
	off_doSlider_afterProcessInput          EQU 0x1C71
	startBlockAt 340, off_doSlider_determineHowToProcessInput
		%assign var_mouseState -0x12
		%assign var_slider -0x9A
		
		notMb1Click:
		lea ax, [bp+var_mouseState]
		push ax
		lea ax, [bp+var_slider]
		push ax
		callEopFromOverlay 2, processSliderInput
		pop cx
		pop cx
		
		jmp calcJump(off_doSlider_afterProcessInput)
	endBlockAt off_doSlider_afterProcessInput
endPatch
