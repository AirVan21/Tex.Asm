		model	tiny
		.code
		org	100h
_:		jmp	start

m2		db	'Hello, I',27h,'m TSR!',13,10,'$'

start:		mov	dx,offset m2
		mov	ah,9
		int	21h

		mov	dx,12h   ;dx должен содержать длину резидентной части программы в параграфах
		mov	ax,3100h ;в ah 31 - оставить резидента, в al 00 - код возврата
		int	21h
		end	_
