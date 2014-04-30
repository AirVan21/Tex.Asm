		; Обязательно смотрим сюда: http://wiki.osdev.org/PCI		
		model	tiny
		.code
		.386
		org	100h
_:		jmp	start

ln		db	13,10,'$' 	;новая строка

space		db	' ', '$'	;пробел
path		db	'C:\PCI\PCI',0	;путь к нашему корневому каталогу
nextdir1	db	'    ', 0	;тут будет записано название каталога, соответствующего vendor ID
nextdir2	db	' ', 0		;тут будут записываться названия каталогов, соответствующих цифрам в product ID
filename	db	'a.txt', 0	;название файлов для открытия 
text		db      '                                                                                            ', '$' ;здесь будет записано название продукта

start:		
		mov	dx,0CF8h	;запонимаем адрес confid_address регистра
		mov	ecx,80000000h	;это в двоичной системе даст нам нулевую шину, нулевое устройство, нулевую функцию. (смотрим по ссылке в начале на структуру config_address)
_c:		
		mov	eax, ecx	;адрес устройства запоминаем в eax
		add	eax, 0Ch	;добавляем в адрес устройства к битам, отвечающим за регистр, 0Ch. Теперь мы сможем получить строчку в которой есть поле header type, а в его первом бите увидеть мультифункциональное ли устройство (читаем ссылку в начале)
		out	dx, eax		;отправляем в config_address регистр адрес нужного устройства. Доступ получим к регистру 0Ch 
		add	dx, 4		;переходим к config_data регистру - CFC (CF8+4=CFC)
		in	eax, dx		;читаем из него содержимое регистра 0Ch
		sub	dx, 4		;возвращаемся с config_address регистру
		
		xor	ebp, ebp	;ebp будет счетчиком функций, то есть если он дойдет до 8, то мы все остановим.
		shr	eax, 23		;делаем так, чтобы 23 бит был последним (он отвечает за определение мультифукциональное ли устройство)
		and	ax, 0001h	;теперь в ax будет только 23 бит.
		je	non_mult	;если устройство не мультифункционально, то мы прыгнем к коду non_mult

cycle:					;дальше код для мультифункциональных устройств
		mov	eax, ecx	;в eax будет адрес устройства с битами отвечающими за регистр равными 0
		shl	ebp, 8		;хотим перейти к следующей функции. Биты отвечающиие за номер функции - 10-8
		add	eax, ebp	;переходим к следующей функции
		shr	ebp, 8		;возвращаем исходное состояние ebp
		out	dx, eax		;просим доступ к конкретному устройству
		add	dx, 4		;переходим к config_data регистру
		in	eax, dx		;получаем product ID, device ID
		sub	dx, 4		;возвращаемся к config_address регистру
		call	print_info	;печатаем все что нужно
		inc	bp		;увеличиваем bp (то есть перейдем к следующей фукции)
		cmp	bp, 8		
		jl	cycle		;если увеличенное bp<8, то повторяем все действо
		jmp	_after_non_mult	;если все функции были перечислены, то уходим к коду _after_non_mult

non_mult:				;дальше код для однофункциональных устройств
		mov	eax, ecx	;в eax будет адрес устройства с битами отвечающими за регистр равными 0
		shl	ebp, 8		;хотим перейти к следующей функции. Биты отвечающиие за номер функции - 10-8
		add	eax, ebp	;переходим к следующей функции
		shr	ebp, 8		;возвращаем исходное состояние ebp
		out	dx, eax		;просим доступ к конкретному устройству
		add	dx,4		;переходим к config_data регистру
		in	eax,dx		;получаем product ID, device ID
		sub	dx,4		;возвращаемся к config_address регистру
		call	print_info	;печатаем все что нужно
		cmp	ax, -1		;если устройства нет (то есть из CFC вернулась -1) 
		jne	_after_non_mult	;то уходим к коду _after_non_mult
		inc	bp		;увеличиваем bp
		cmp	bp, 8		
		jl	non_mult	;если увеличенное bp<8, то повторяем все действо
		
_after_non_mult:
		add	ecx, 0800h	;переходим не к следующей функции, а сразу к следующему устройству.
		;То есть процесс будет такой: Если устройство есть и оно мультифункционально, то пройдет перебор всех его функций и потом только переход к следующему устройству.
		;Если же устройство есть и оно однофункциональное (то есть первый раз когда мы его обнаружили и увидели, что оно однофункциональное), то мы печатаем его и после сразу переходим к следующему устройству, то есть мы пропустим весь мусор 
		;(хотя никто не сказал, что та функция, которую мы печатали не мусор. Вообще непонятно как определить какая из функций в наборе мусора будет настоящей).
		;В общем мы печатаем просто однофункциональное устройство просто в первый раз, когда его увидели и идем к следующему устройству.
		test	ecx, 01000000h	;если мы еще не все устройства прошли
		jz	_c		;то повторяем все для следующего устройства
		ret			;иначе возвращаемся. Фокус в том, что 1000000h в двоичной системе имеет единицу только в 24 бите. Когда у нас исчерпаются все устройства, то этот бит станет единицей и мы по нему можем сказать, что пора заканчивать работу.

; input: eax, ecx, ebp
print_info:				;код для печати всего, что нужно
		cmp	ax, -1		;если устройства нет, то уходим
		je	_ecycle
		push	edi
		push	ds
		pop	es
		call	print_bus_number	; from ecx ;печатаем номер шины
		call	print_device_number	; from ecx ;печатаем номер устройства
		mov	edi, ecx		; edi for swap	;
		mov	ecx, ebp		; ebp has function number
		call	print_word		; печатаем номер функции
		mov	ecx, edi
		call	print_dword		; from eax ;печатаем product id, vendor id
		call	print_string		; from eax ;печатаем название устройства. Это только для талантов.
		call	print_new_line		; переход на слледующую строку
		pop	edi
_ecycle:
		ret

;prints from ecx register
print_bus_number: ;код для печати номера шины
		push	ecx
		shr	ecx, 10h	;сдвигаем на 16, чтобы получить номер шины
		and	cx, 00FFh	;обнуляем все, кроме номера шины
		call	print_word	;печатаем номер шины
		pop	ecx		
		ret
; prints from ecx register
print_device_number: ;код для печати номера устройства
		push	ecx
		shr	ecx, 11		;сдвигаем, чтобы в конце получить номер устройства
		and	cl, 00011111b	;обнуляем все, кроме номера устройства
		call	print_word	;печатаем номер устройства
		pop	ecx
		ret

print_new_line:	;перевод на новую строчку
		push	dx
		push	ax
		mov	dx, offset ln
		mov	ah, 09h
		int	21h
		pop	ax
		pop	dx
		ret
; prints eax register
print_string:		;эта функция только для талантов
		push ecx
		push eax
		push dx
		push eax ;потом четыре раза pop сделаем
		push eax
		push eax
		push eax
		
		push ax	;печатаем пробел
		mov dx, offset space
		mov ah, 09h
		int 21h
		pop ax
			
		mov dx, offset nextdir1	;хотим записать в nextdir1 - vendor id - название каталога, куда перейти
		mov bx, dx
		mov cx, ax
		call convert_word	;конвертирует данные из сx в ascii код, соответствующий этим данным, и записывает этот код в [bx]. В данном случае в nextdir1
		mov ah, 3Bh		;переходим в каталог nextdir1
		int 21h

		pop eax			;восстановили все значения
		mov dx, offset nextdir2	;теперь хотим записать первую цифру product id в nextdir2
		shr eax, 28		;первая цифра product id теперь будет последней в регистре 
		and ax, 0Fh		;обнуляем всё кроме этой цифры
		mov cx, ax		
		mov bx, dx	
		call convert_symbol	;конвертирует один символ из cx в его ascii код и записывает этот [bx]. В данном случае в nextdir2
		mov ah, 3Bh		;переходим в каталог nextdir2
		int 21h

		pop eax			;аналогично предыдущему, но теперь для второй цифры product id
		mov dx, offset nextdir2		
		shr eax, 24
		and ax, 0Fh
		mov cx, ax
		mov bx, dx
		call convert_symbol
		mov ah, 3Bh
		int 21h

		pop eax			;аналогично предыдущему, но теперь для третьей цифры product id
		mov dx, offset nextdir2		
		shr eax, 20
		and ax, 0Fh
		mov cx, ax
		mov bx, dx
		call convert_symbol
		mov ah, 3Bh
		int 21h

		pop eax			;аналогично предыдущему, но теперь для четвертой цифры product id
		mov dx, offset nextdir2		
		shr eax, 16
		and ax, 0Fh
		mov cx, ax
		mov bx, dx
		call convert_symbol
		mov ah, 3Bh
		int 21h

		mov ah, 3Dh		;теперь мы в каталоге с файлом a.txt, в котором название нашего устройства
		xor al, al
		mov dx, offset filename	;открываем файл a.txt
		int 21h
		push ax			;это нужно, чтобы потом закрыть файл. Нам надо будет, чтобы file handle в bx лежал. Мы этот file handle вернем потом из стека

		mov bx, ax		;считываем 90 символов из нашего файла. (Почему 90? Нууу... потому что!)
		mov ah, 3Fh
		mov cx, 90
		mov dx, offset text
		int 21h

		mov ah, 09h		;печатаем название название устройства
		mov dx, offset text
		int 21h
		
		mov cx, 90		;поскольку мы все время записываем имена устройств в одно и то же место, то если у предыдущего устройства название было длинее нынешнего, то мы выведем на печать название нашего устройства и незатертую часть старого названия.
_loop:	        mov dx, offset text	;поэтому после каждого вывода надо чистить text
		add dx, cx
		mov bx, dx
		mov byte ptr [bx], ' '
		loop _loop 					
		
		mov dx, offset path	;возвращаемся в исходный каталог
		mov ah, 3Bh
		int 21h
		
		pop bx		;вспоминаем file handle в bx
		mov	ah,03Eh ;закрываем файл
		int	21h

		pop dx
		pop eax
		pop ecx
		ret 

convert_symbol: ; in al ;Только для талантов. Конвертируем один символ в его код ascii и записываем его в [bx] 
		pusha
		push ax
		
		push bx
		lea	bx, sym_tab
		mov	ax, cx
		xlat
		pop bx
		mov [bx], al
		
		pop ax
		popa
		ret		

convert_word: ; in ax ;Только для талантов. Конвертируем 16 бит регистра cx в их код ascii и записываем его в [bx]		
		pusha
		push ax
		
		push bx
		lea	bx, sym_tab
		mov	ax, cx
		shr	ax, 12
		xlat
		pop bx
		mov [bx], al
		push bx
		lea	bx, sym_tab
		mov	ax, cx
		shr	ax, 8
		and	al, 0Fh
		xlat
		pop bx
		mov [bx]+1, al
		push bx
		lea	bx, sym_tab
		mov	ax, cx
		shr	ax, 4
		and	al, 0Fh
		xlat
		pop bx
		mov [bx]+2, al
		push bx
		lea	bx, sym_tab
		mov	ax, cx
		and	ax, 0Fh
		xlat
		pop bx
		mov [bx]+3, al
		
		pop ax
		popa
		ret
		
print_dword:	;код для печати ecx
		push	ecx
		push	eax
		shr	eax, 10h
		mov	cx, ax
		call	print_word ;конвертирует 16 бит из cx и печатает их
		pop	eax
		mov	cx, ax
		call	print_word
		pop	ecx
		ret

; prints cx register
print_word:	;конвертирует 16 бит регистра cx в их ascii код и печатает. (отличается от convert word только тем, что здесь печатаем, а там записываем в [bx])
		pusha
		lea	bx, sym_tab
		mov	ax, cx
		shr	ax, 12
		xlat
		mov	dl, al
		mov	ah, 02
		int	21h
		mov	ax, cx
		shr	ax, 8
		and	al, 0Fh
		xlat
		mov	dl, al
		mov	ah, 02
		int	21h
		mov	ax, cx
		shr	ax, 4
		and	al, 0Fh
		xlat
		mov	dl, al
		mov	ah, 02
		int	21h
		mov	ax, cx
		and	ax, 0Fh
		xlat
		mov	dl, al
		mov	ah, 02
		int	21h
		
		mov	ah, 02h
		mov	dl, 20h
		int	21h
		popa
		ret
sym_tab		db	"0123456789ABCDEF"

		end	_
