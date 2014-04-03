	.model tiny
	.code
	org 100h
_:
	mov ah, 9
	lea dx, msg
	jmp nxt
msg	db "Hello, world !$"
nxt:
	int 21h
	ret
end _