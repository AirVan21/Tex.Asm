		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, KBD!',13,10,'$'

i16:		iret ; Просто возвращаем управление

start:		mov	ax,2516h
		mov	dx,offset i16
		int	21h

		mov	dx,offset m1
		mov	ah,9
		int	21h

		mov	ax,3100h
		mov	dx,(start-_+100h+15)/16
		int	21h
		end	_
