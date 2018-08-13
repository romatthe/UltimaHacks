%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		eop-barkOverItemInWorld
		
	startBlockAt seg_eop, off_eop_barkOverItemInWorld
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_string              0x06
		%assign arg_ibo                 0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_ibo                -0x02
		add sp, var_ibo
		
		push si
		push di
		
		mov ax, [bp+arg_ibo]
		mov [bp+var_ibo], ax
		
		; find the outermost containing item
		lea ax, [bp+var_ibo]
		push ax
		push ax
		push ax
		callFromOverlay getOuterContainer
		add sp, 6
		
		push 0  ; skip unconscious?
		push 15 ; duration
		push 0  ; ?flag
		push word [bp+arg_string]
		push word [bp+var_ibo]
		push dseg_graphicsThing
		callFromOverlay barkOnItemInWorld
		add sp, 12
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_barkOverItemInWorld_end
endPatch
