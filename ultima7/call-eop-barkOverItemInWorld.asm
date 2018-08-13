%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		call eop to print bark text when not in dialog mode
		
	off_usecodeCallSite     EQU 0x005A
	off_usecodeCallSite_end EQU 0x0087
	startBlockAt 330, off_usecodeCallSite
		; di == ibo
		
		; get bark-text string pointer from Usecode list
		push 1
		lea ax, [si-8]
		push ax
		callFromOverlay unicode_getListNode
		pop cx
		pop cx
		
		mov bx, ax
		
		push word [bx+5]
		push di
		callEopFromOverlay 2, barkOverItemInWorld
		pop cx
		pop cx
		
		jmp calcJump(off_usecodeCallSite_end)
	endBlockAt off_usecodeCallSite_end
endPatch
