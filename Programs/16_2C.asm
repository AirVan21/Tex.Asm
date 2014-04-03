		model	tiny
		.386
		.code
		org	100h
_:		jmp	start

m1		db	' ','$'

start:		call	geti
		mov	m1,al
		call	prni
_c:		xor	ah,ah
		int	16h
		push	ax		; ->
		call	geti
		cmp	al,m1
		mov	m1,al
		je	_0
		call	prni
_0:		pop	ax		; <-
		cmp	al,1Bh
		jne	_c
		ret

geti:		pushf
		pop	ax
		shr	ax,9
		and	al,1
		add	al,'0'
		ret

prni:		mov	dx,offset m1
		mov	ah,9
		int	21h
		ret
		end	_
