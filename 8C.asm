		model	tiny
		.code
		org	100h
_:		xor	ah,ah
		int	0F1h

		mov	ah,1
		int	0F1h

		mov	ah,2
		int	0F1h
		ret
		end	_
