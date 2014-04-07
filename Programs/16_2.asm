		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, KBD!',13,10,'$'

i16:
;		filter before

;       Дабы осознать смысл 11-25 строк, надо прочесть "Разговор о 16_2.txt"
		pushf ;запоминаем флаги до вызова call
		db	9Ah ; far call
v16		dd	0 ; здесь будет лежать адрес вызова

		push	ax
		push	bp
		pushf
		pop	ax
		mov	bp,sp
		mov	[bp+8],ax ;в стеке сейчас именно в таком порядке лежат: pushf, push CS, push IP, push ax, push bp, то бишь мы здесь заменим флаги на новые. (СS+IP+ax+bp = 8)
		pop	bp
		pop	ax

;		filter after
		iret

start:		mov	ax,3516h
		int	21h
		mov	word ptr v16,bx
		mov	word ptr v16+2,es
		mov	ax,2516h
		mov	dx,offset i16
		int	21h

		mov	dx,offset m1
		mov	ah,9
		int	21h

		mov	ax,3100h
		mov	dx,(start-_+100h+15)/16
		int	21h
		end	_
