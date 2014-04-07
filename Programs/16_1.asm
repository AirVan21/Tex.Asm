		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, KBD!',13,10,'$'

i16:
		db	0EAh ;far jump
v16		dd	0 ;здесь будет лежать адрес куда мы прыгнем

start:		mov	ax,3516h ;узнаем адрес вектора 16 прерывания (он вернется в ES:BX)
		int	21h
		mov	word ptr v16,bx
		mov	word ptr v16+2,es ;запоминаем адрес оригинального вектора в v16
		mov	ax,2516h ;ставим вместо оригинального обработчика 16 прерывания наш (то бишь адрес i16)
		mov	dx,offset i16
		int	21h

		mov	dx,offset m1
		mov	ah,9
		int	21h ;распечатаем то, что в m1

		mov	ax,3100h ;оставляем резидентной частью все до старта
		mov	dx,(start-_+100h+15)/16
		int	21h
		end	_
