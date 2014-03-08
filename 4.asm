		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Press any key to continue ...$'

start:		mov	dx,offset m1
		mov	ah,9
		int	21h

		hlt		; instruction which halts the central processing unit (CPU) until the next external interrupt is fired
;		xor ax,ax ;поскольку у нас куча внешних прерываний, например, таймер, который их кидает кучу раз в секунду, то мы даже не успеваем увидеть приостановку
;		int 16h
		
		ret
		end	_
