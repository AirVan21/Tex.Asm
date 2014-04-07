        ;Дабы все понять, обязательно читаем http://courses.engr.illinois.edu/ece390/books/labmanual/io-devices.html
		model	tiny
		.code
		.386
		org	100h
_:		jmp	start

m0		db	'  '
m1		db	'KBD bye!',13,10,'$'

i9:		push ax              ; Save registers
        push ds              ;
        sti
        mov ax, cs           ; Make sure DS = CS
        mov ds, ax           ;
        in al, 60h           ; Get scan code
		cmp al,1             ;
		jne	_1               ; Process event
		mov	cs:f9,al         ;
_1:		call prn
        in al, 61h           ; Send acknowledgment without
        or al, 10000000b     ;   modifying the other bits.
        out 61h, al          ;
        and al, 01111111b    ;
        out 61h, al          ;
        mov al, 20h          ; Send End-of-Interrupt signal
        out 20h, al          ;
        pop ds               ; Restore registers
        pop ax               ;
        iret                 ; End of handler
        
v9		dd	0
f9		db	0

prn:	pusha
		push ds
		push es
		push cs
		pop	ds
		push cs
		pop	es
		mov	di,offset m0
		cld
		call h2 ;convert to ascii code
		mov	al,m0
		mov	ah,9    ; 9 функция 10 прерывания - печать символа на месте курсора с атрибутами
		mov	bx, 0Fh ; записанными в bx 
		mov	cx,1    ; сколько раз напечатать символ
		int	10h     
		xor	bh,bh
		mov	ah,3    ; 3 функция 10 прерыванияполучить нынешнее положение курсора
		int	10h
		inc	dl      ;в dl номер столбца. Соответственно увеличиваем его
		mov	ah,2    ;2 функция 10 прерывания - переместить курсор
		int	10h
		mov	al,m0+1 ;печатаем второй символ
		mov	ah,9
		mov	bx, 0Fh
		mov	cx,1
		int	10h
		xor	bh,bh   ;сдвигаем курсор в начало строки
		mov	ah,3
		int	10h
		xor	dl, dl
		mov	ah,2
		int	10h
		
		mov ah, 06h ;6 функция 10 прерывание - window scroll up
		mov al, 1
		mov bh, 0Fh
		xor ch, ch
		xor cl, cl
		mov dh, 25
		mov dl, 85
		int 10h 
		
		pop	es
		pop	ds
		popa
		ret

start:  push bx                            ;запоминаем адрес старого обработчика 9 прерывания. Оно находится по адресу 0000:0024h
        push es	
        xor bx, bx
		mov es, bx
		mov bx, [es:24h] 
		mov	word ptr v9,bx
		xor bx, bx
		mov es, bx
		mov bx, [es:26h]
		mov	word ptr v9+2,bx
		pop es
		pop bx
        
        push ax
        push es
        xor ax, ax
        mov es, ax
        cli                               ; Disable interrupts, might not be needed if seting up a software-only interrupt
        mov word ptr es:[24h], offset i9  ; setups offset of handler 9h
        mov word ptr es:[26h], cs         ; Here I'm assuming segment of handler is current CS
        sti                               ; Reenable interrupts
        pop es
        pop ax                            ; End of setup
        
_c:		cmp	f9,1
		jne	_c

		push ds
		push ax
        push es
        lds	dx,v9
        xor ax, ax
        mov es, ax
        cli                               ; Disable interrupts, might not be needed if seting up a software-only interrupt
        mov word ptr es:[24h], dx         ; setups offset of handler 9h
        mov word ptr es:[26h], ds         ; Here I'm assuming segment of handler is current CS
        sti                               ; Reenable interrupts
        pop es
        pop ax                            ; End of setup
		pop	ds

		ret

h2:		push	ax
		shr	al,4
		call	h1
		pop	ax
h1:		push	ax
		and	al,0Fh
		cmp	al,10
		sbb	al,69h
		das
		stosb
		pop	ax
		ret

		end	_
