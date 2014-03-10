		model	tiny
		.386
		.code
		org	100h
_:		jmp	start

f1: push bp ;save everything
    push cx
	push ax
	push dx	 
	
	mov bp,sp ;memorize cs, ip
	add bp, 8h
    mov cx, [bp]
    add bp, 2h
    mov bx, [bp]    
    sub bp, 2h
    sub bp, 8h
    
    push ds
	
    push cs
    pop ds
	
	call	print_ip
	
	push es ;надо использовать es, чтобы обращаться к конкретному месту в памяти через регистр
	mov es, bx
	mov cl, [es:10h] ;в прямую запишем jump в исходное место. (Все циферки проверяются в файле HW1.lst или turbo debugger'ом)
	mov [es:105h], cl
	pop es
	
	pop ds ;восстанавливаем все
    pop dx
    pop ax
    pop cx
    pop bp
	
	pop cx ;ip то указывает на то место, что идет после брейкпоинта, а не на него самого (поэтому печатается 106, а не 105)
	sub cx, 1h ;поэтому вручную вернем ip на ту команду, что мы зачистили CC'шкой
	push cx
	iret
print_ip: ;printig from register... (we did the same in 6.asm)
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

start:		mov	dx,offset f1
		mov	ax,2503h ;обрабатываем третье прерывание (cc - breakpoint)
		int	21h

		mov	dx,(offset start-offset _+100h+15)/16 ;говорим размер резидентной части программы в параграфах (читаем лекцию 3)
		mov	ax,3100h ;оставляем резидента
		int	21h
		end	_
