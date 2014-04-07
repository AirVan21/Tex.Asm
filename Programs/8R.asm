		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, INT!',13,10,'$'
f0		db	'(func 0)',13,10,'$'
f1		db	'(func 1)',13,10,'$'
fer		db	'(error)',13,10,'$'
f_f1		dw	f1_0
		dw	f1_1
		dw	f1_err

i_f1:		push	cs
		pop	ds
		xor	bx,bx
		mov	bl,ah
		and	bl,1
		test	ah,0FEh
		jz	_0
		mov	bl,2
_0:		shl	bx,1
		jmp	f_f1[bx]

f1_0:		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset f0
		mov	ah,9
		int	21h
		iret
f1_1:		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset f1
		mov	ah,9
		int	21h
		iret
f1_err:		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset fer
		mov	ah,9
		int	21h
		iret

start:		mov	dx,offset i_f1
		mov	ax,25F1h
		int	21h

		mov	dx,(offset start-offset _+100h+15)/16 ;говорим размер резидентной части программы в параграфах (читаем лекцию 3)
		mov	ax,3100h ;оставляем резидента
		int	21h
		end	_
