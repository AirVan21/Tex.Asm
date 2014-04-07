		model	tiny
		.386
		.code
		org	100h
_:		jmp	start

m1		db	' ','$'         ;сюда запишется символ
m2      db  ' ','$'         ;тут пробел
m3      db  13,10,'$'       ;тут возврат каретки и перевод строки

start:		xor	ah,ah       ;обнуляем ah
		int	16h             ;смотрим ввели ли что-либо (это что-то вернется в ax)
		
		push ax
		push ax
        push ax
        
        pop cx
		call    print_word  ;печатаем все что нам вернулось от int 16 (печатаем значение cx)
		
	    mov	dx,offset m2    ;печатаем пробел
		mov	ah,9
		int	21h
		
		pop ax              ;Наша задача напечатать символ, даже если по идее это код возврата каретки или переноса строки (то есть возврата каретки произойти не должно, а должна напечататься нота). 0Ah функция 10h прерывания нам в этом сможет помочь
		mov	ah,0Ah          ;На 13 код символа функция 09h 21 прерывания сделает возврат каретки, а не печать нотки
		mov bh,0            ;в bh должен храниться номер страницы на который делается вывод
		mov cx,1            ;в cx должно быть записано сколько раз вывести символ
		int	10h
		
		mov	dx,offset m3    ;перенос строки
		mov	ah,9
		int	21h
		
		pop	ax		
		cmp	al,1Bh          ; смотрим, а не Esc ли мы нажали (1Bh - код Esc)
		jne	start           ; если ввели Esc, то ZF==0 и мы уходим, иначе прогоняем еще раз цикл  _c
		ret

print_word: ;printig from register... (we did the same in 6.asm)
	pusha ;This instruction pushes the eight general-purpose registers
	lea	bx,sym_tab
	mov	ax,cx
	shr	ax,12
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	mov	ax,cx
	shr	ax,8
	and	al,0Fh
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	
	mov	dx,offset m2 ;печатаем пробел
	mov	ah,9
	int	21h
	
	mov	ax,cx
	shr	ax,4
	and	al,0Fh
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	mov	ax,cx
	and	ax,0Fh
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	popa ;Use POPA to pop all the registers again
	ret

    sym_tab	db	"0123456789ABCDEF"
    end	_
