		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Press any key to continue ...$'

start:		mov	dx,offset m1
		mov	ah,9
		int	21h
		
		xor ax,ax ;вызываем 16 прерывание с нулем в ax - это функция чтения с клавиатуры
		int 16h
		
		ret
		end	_
