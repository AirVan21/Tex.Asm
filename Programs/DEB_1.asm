	.model tiny
	.386
	.code
	org	100h
psp = ((buf-_+100h) + 15)/16*16
prog	= psp+100h
_:
;	mov	cx,0BEEFh
;	call	print_word
	mov	ah,03Dh ;3D - open a file
	xor	al,al ; open mode in al, 0 - read-only access
	lea	dx,fname ; DS:DX - pointer to filename
	int	21h

	jc	err_ ;jump if carry flag == 1, if CF is set => 3D returned error code(if everything ok then 3D returns file handle in ax)

	mov	bx,ax ; in bx should be file file handle to read file
	mov	ah,03Fh ;read bytes from file into the buffer
	mov	cx,0FFFFh ;number of bytes to read
	mov	dx,prog ; adress of buffer
	int 21h

	jc	err_ ; again if it was an error, then carry flag = 1
	
	mov	ah,09h
	lea	dx,msg ;the same as mov ds, offset msg
	int	21h	

	mov	ah,03Eh ; close a file handle
	int	21h

	jc	err_ ;is smth happened, then CF = 1

		
	mov	ax,psp/16 ;adress of loaded program segment in paragraphs
	push	cs ;memorize current segment
	pop	bx ;now its in bx
	add	ax,bx ;all in all we somehow counted cs:ip of loaded program

	mov	bx, psp
	mov	byte ptr [bx], 0CBh ;code of retf in the begining of psp of loaded program (default: cd20), so when loaded program terminates it does retf, not ret

	mov	ds, ax
	
	push	cs
	push	offset eod_handler ;end of debug ;retf of loaded program will use these.
	push	0
	push	ax
	push	100h
	retf ;RETF executes a far return: after popping IP/EIP, it then pops CS, and then increments the stack pointer by the optional argument if present.
	
	ret
eod_handler: ;code for actions after termination of loaded program
	
	ret
err_:
	mov	ah,09h
	lea	dx,err_msg
	int	21h

	ret

fname	db	"hw1.com",0
err_msg	db	"Error!$"
msg	db	"File load successfully!$"

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

buf:
end	_
