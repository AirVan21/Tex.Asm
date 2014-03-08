		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, INT!',13,10,'$'
f0		db	'(func 0)',13,10,'$'
f1		db	'(func 1)',13,10,'$'
fer		db	'(error)',13,10,'$'
v_f1		dd	0 ; dd = define double word

i_f1:		or 	ah,ah ;�������� �� ����, ���� ah ����, �� � ����� ���� ����� ����.
		jnz	f1_1 ;���� �� ����� ���� �� ����, �� ������� � f1_1
		mov	dx,offset m1 ;��� ����������� ������ ���� ah ���� �����
		mov	ah,9
		int	21h
		mov	dx,offset f0 ; � �����, ���� ah 0, �� ��������� Hello, INT! (func 0)
		mov	ah,9
		int	21h
		iret ; ����������� ������� ��� �������� �� ����������
f1_1:		test	ah,0FEh ; test ������ ���� �����, ��� � and, �� ��������� ������ �� ������������, ������ �������� �����. �� ����� ������ and � 11111110, �� ���� ���� � ��� � ah 00000001 ��� 00000000, �� � ����� ���� ����� 1, ����� � ����� ���� ����� 0
		jnz	f1_err ;���� �� ����� ���� 1, �� � ��� ah ���� �� 00000001 ��� 00000000, ������ error
		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset f1
		mov	ah,9
		int	21h ; � �����, ���� ah 1, �� ��������� Hello, INT! (func 1)
		iret
f1_err:		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset fer
		mov	ah,9
		int	21h ; � �����, ���� ah �� 0 � 1, �� ��������� Hello, INT! (error)
		iret

start:		mov	ax,35F1h ;ah = 35h - �������, ������������ ����� ���������� ����������. ������ ������ ����������? ����, ����� �������� � al - 0F1h
		int	21h
		mov	word ptr v_f1,bx ; 35 ������� ������ ����� � ES:BX
		mov	word ptr v_f1+2,es ; �� � �� ES:BX �� ��� ������� �� ������ v_f1

		mov	dx,offset i_f1
		mov	ax,25F1h ; ah = 25 - ������� ������ ����� ����������� ����������, ����� �������� � al = F1, � DS:DX ������ ����������� ����� �������� ����������� (��� ����� � ����� 43 ������, DS ��-�� model tiny �� ��������� ��������� �� ������� � ������� �� �����)
		int	21h

		xor	ah,ah
		int	0F1h

		mov	ah,1
		int	0F1h

		mov	ah,2
		int	0F1h

		lds	dx,v_f1 ;����� ���� ��� �� ���������� � ����� ������������ ���������� ������ F1 ���������� ������ ����������.
		mov	ax,25F1h
		int	21h
		ret
		end	_
