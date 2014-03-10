		model	tiny
		.386
		.code
		org	100h
_:		jmp	start
m1		db	13,10,'$'
f1: 
    push bp ;save everything!
    push cx
	push ax
	push dx	 
    
    mov bp,sp ;NEVER touch sp! Use bp instead of sp.
    add bp, 8h
    mov cx, [bp] ;now ip in cx.
    sub bp, 8h
    
    push ds	
    push cs ;correct current ds
    pop ds
	
	call	print_ip ;this will print cx <=> ip
	push dx
	mov	dx,offset m1 ;print "\n"
		mov	ah,9         
		int	21h
    pop dx
    
    pop ds ;restore everything
    pop dx
    pop ax
    pop cx
    pop bp
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
		mov	ax,2501h ;обрабатываем 1 прерывание, то есть трассировку
		int	21h

		mov	dx,(offset start-offset _+100h+15)/16 ;говорим размер резидентной части программы в параграфах (читаем лекцию 3)
		mov	ax,3100h ;оставляем резидента
		int	21h
		end	_
