		model	tiny
		.code
		.386
		org	100h
_:		jmp	start

m0		db	'  '
m1		db	'KBD bye!',13,10,'$'

i9:		push	ax
		in	al,60h
		cmp	al,1
		jne	_1
		mov	cs:f9,al
_1:		call	prn
		mov	al,20h ;здесь особенность в том, что мы не передаем управление дальше, а просто делаем iret. Проблема в том, что мы должны послать End-of-Interrupt signal (если мы передаем управление дальше, то за нас это кто-то сделает), иначе все будут думать, что все еще обрабатываем наше прерывание и будут ждать.
		out	20h,al ;этот End-of-Interrupt signal посылется как 20h в 20h порт.
		pop	ax
		iret
v9		dd	0
f9		db	0

prn:		pusha
		push	ds
		push	es
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	di,offset m0
		cld
		call	h2
		mov	al,m0
		mov	ah,9
		mov	bx,4Fh
		mov	cx,1
		int	10h
		xor	bh,bh
		mov	ah,3
		int	10h
		inc	dl
		mov	ah,2
		int	10h
		mov	al,m0+1
		mov	ah,9
		mov	bx,4Fh
		mov	cx,1
		int	10h
		xor	bh,bh
		mov	ah,3
		int	10h
		inc	dl
		mov	ah,2
		int	10h
		mov	al,'-'
		mov	ah,9
		mov	bx,4Fh
		mov	cx,1
		int	10h
		xor	bh,bh
		mov	ah,3
		int	10h
		inc	dl
		mov	ah,2
		int	10h
		pop	es
		pop	ds
		popa
		ret

start:		mov	ax,3509h
		int	21h
		mov	word ptr v9,bx
		mov	word ptr v9+2,es

		mov	dx,offset i9
		mov	ax,2509h
		int	21h

_c:		cmp	f9,1
		jne	_c

		push	ds
		lds	dx,v9
		mov	ax,2509h
		int	21h
		pop	ds

		mov	dx,offset m1
		mov	ah,9
		int	21h
		ret

h2:		push	ax
		shr	al,4
		call	h1
		pop	ax
h1:		push	ax
		and	al,0Fh
		cmp	al,10
		sbb	al,69h
		das
		stosb
		pop	ax
		ret

		end	_
