		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, ASM!',13,10,'$'
l_m1		=	$-m1

start:		mov	ax,0B800h
		mov	es,ax
		xor	di,di
		mov	si,offset m1
		cld
		mov	cx,l_m1
		mov	al,1Fh ;добавляем атрибут символа (белый текст на синем выделении)
_c:		movsb
		stosb ;(ES:DI) <- Al, if DF==0: DI++; else DI-- 
		;Так как все атрибуты мы сами добавили, то теперь все нормально выведется
		loop	_c

		xor	ah,ah
		int	16h
		ret
		end	_
