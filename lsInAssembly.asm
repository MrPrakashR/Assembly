bits 64
default rel

section .data
	prompt db "Enter the directory path: ",0
	error_msg db "Error Opening directory",10,0
	fmt_entry db "File: %-30s, Size: %ld bytes, Modified: %02d-%02d-%02d %2d-%2d",10,0
	dot db ".", 0
	dotdot db "..",0
	path_seperator db "/",0

section .bss

	path	resb 256
	dir 	resb 1
	file_stat resb 144
	timeinfo resb 1
	path_buffer resb 512

section .text
	global main
	extern printf, fgets, opendir, closedir, stdin, readdir
	extern strcmp, lstat, strcat, memset, strcpy, localtime
	extern exit

main:

	push rbp
	mov rbp,rsp
	sub rsp,48

	mov rdi,prompt
	call printf

	mov rdi,path
	mov rsi,256
	mov rdx,[stdin]
	call fgets

	mov rdi,path
	mov rcx,255
	mov al,10
	repne scasb
	mov byte [rdi-1],0

	mov rdi,[dir]
	call opendir 
	test rax,rax
	jz error_open
	mov [dir],rax

read_loop:

	mov rdi,[dir]
	call readdir
	test rax,rax
	jz close_dir
	mov r12,rax

	lea rdi,[r12+19]
	mov rsi,dot
	call strcmp
	test eax,eax
	jz read_loop

	lea rdi,[r12+19]
	mov rsi,dotdot
	call strcmp
	test eax,eax
	jz read_loop

	mov rdi,path_buffer
	mov rsi,512
	xor edx,edx
	call memset

	mov rdi,path_buffer
	mov rsi,path
	call strcpy

	mov rdi,path_buffer
	mov rsi,path_seperator
	call strcat

	mov rdi,path_buffer
	lea rsi,[r12+19]
	call strcat

	mov rdi,path_buffer
	mov rsi,file_stat
	call lstat
	test eax,eax
	jnz read_loop
	
	lea rdi,[file_stat+72]
	call timeinfo
	test rax,rax
	jz read_loop
	mov [timeinfo],rax

	mov rdi,fmt_entry
	lea rsi,[r12+19]
	mov rdx, [file_stat+48]

	mov r10,[timeinfo]

	movzx rcx, word [r10+20]
	add rcx,1900

	movzx r8, byte [r10+16]
	add r8,1

	movzx r9,byte [r10+12]

	sub rsp,32

	movzx rax, byte [r10+8]
	mov [rsp],rax

	movzx rax, byte [r10+4]
	mov [rsp+8],rax

	movzx rax, byte [r10]
	mov [rsp+16],rax

	xor rax,rax
	mov [rsp+24],rax

	xor rax,rax
	call printf

	add rsp,32

	jmp read_loop

close_dir:
	mov rdi,[dir]
	call closedir
	xor eax,eax
	jmp exit_program

error_open:
	mov rdi,error_msg
	call printf
	mov eax,1

exit_program:
	mov rsp,rbp
	pop rbp
	mov rdi,rax
	call exit
