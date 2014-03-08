		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, INT!',13,10,'$'
f0		db	'(func 0)',13,10,'$'
f1		db	'(func 1)',13,10,'$'
fer		db	'(error)',13,10,'$'
v_f1		dd	0 ; dd = define double word

i_f1:		or 	ah,ah ;проверка на ноль, если ah ноль, то в флаге нуля будет ноль.
		jnz	f1_1 ;если во флаге нуля не ноль, то прыгаем в f1_1
		mov	dx,offset m1 ;это выполняется только если ah было нулем
		mov	ah,9
		int	21h
		mov	dx,offset f0 ; В итоге, если ah 0, то выведется Hello, INT! (func 0)
		mov	ah,9
		int	21h
		iret ; специальная команда для возврата из прерывания
f1_1:		test	ah,0FEh ; test делает тоже самое, что и and, но результат никуда не записывается, только меняются флаги. По факту делаем and с 11111110, то есть если у нас в ah 00000001 или 00000000, то в флаге нуля будет 1, иначе в флаге нуля будет 0
		jnz	f1_err ;если во флаге нуля 1, то у нас ah было не 00000001 или 00000000, значит error
		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset f1
		mov	ah,9
		int	21h ; В итоге, если ah 1, то выведется Hello, INT! (func 1)
		iret
f1_err:		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset fer
		mov	ah,9
		int	21h ; В итоге, если ah не 0 и 1, то выведется Hello, INT! (error)
		iret

start:		mov	ax,35F1h ;ah = 35h - функция, возвращающая адрес обрабочика прерывания. Какого именно прерывания? Того, номер которого в al - 0F1h
		int	21h
		mov	word ptr v_f1,bx ; 35 функция вернет адрес в ES:BX
		mov	word ptr v_f1+2,es ; ну и из ES:BX мы это запишем по адресу v_f1

		mov	dx,offset i_f1
		mov	ax,25F1h ; ah = 25 - функция задает адрес обработчика прерывания, номер которого в al = F1, в DS:DX должен содержаться адрес искомого обработчика (для этого и нужна 43 строка, DS из-за model tiny по умолчанию указывает на сегмент в котором мы сидим)
		int	21h

		xor	ah,ah
		int	0F1h

		mov	ah,1
		int	0F1h

		mov	ah,2
		int	0F1h

		lds	dx,v_f1 ;после того как мы наигрались с нашим обработчиком прерываний вернем F1 прерыванию старый обработчик.
		mov	ax,25F1h
		int	21h
		ret
		end	_
