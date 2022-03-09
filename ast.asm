%include "io.mac"

section .data
    delim db " ", 0
    mystring db "-1234567 ", 0

section .bss
    root resd 1
    sign resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern malloc
extern printf
extern free
extern strlen

global create_tree
global iocla_atoi

iocla_atoi: 
    ; TODO
    push    ebp
    mov     ebp, esp

    push esi
    mov dword[sign], 1
    mov esi , [ebp + 8]

    push ebx
    push ecx
    push edx
    
    xor eax, eax
    xor ebx, ebx
    mov ecx , 10
    
	loopity:
    mov bl , [esi]

    cmp bl , 32		; end of number/string check
    jle return
    cmp bl, 45		; negative number check
    je negativity
    
    mul ecx			; eax = eax * 10
    sub ebx , 48	; switching from ascii to digit
    add eax, ebx	; adding digit to number

    inc esi
   	jmp loopity

	negativity:
	mov dword[sign], -1
	inc esi
	jmp loopity

	return:
   	mov ecx, [sign]
    imul ecx
    	
    pop edx
    pop ecx
    pop ebx
    pop esi

    leave
    ret

create_tree:
	push    ebp
    mov     ebp, esp

    push ebx
    push ecx
    push edx

    push edi
    
    mov esi, [ebp + 8] ;; getting the adress of current element

    xor eax, eax

    find_token_len:
    cmp byte[esi + eax], 32
    jle end_find_tklen
    inc eax
    jmp find_token_len


    end_find_tklen:
    cmp eax, 0
    je get_out

    inc eax			; allocating an extra byte for '\0'
    push eax
    call malloc
    pop ecx
    dec ecx		

    cmp ecx, 1		; if length > 1, surely number
    jg number

    xor edx, edx
    mov dl, [esi]	; moving number/operator to edx
    cmp edx, 48 	; determining if number or operator
    jge number
    cmp edx, 42		; one last insurances that it is an operator
    jge operator

    operator: 
    mov byte[eax], dl
    mov byte[eax+1], 0
    add esi, 2

    mov edi, eax
    push 12
    call malloc
    add esp, 4
    
    mov [eax], edi
    mov edx, eax 	; preserving current node adress

    push edx
    push esi
    call create_tree			;send_noodes
    add esp, 4
    pop edx
    
    mov [edx + 4], eax	; left = send_noodes(string)

    push edx	
    push esi
    call create_tree			;send_noodes
    add esp, 4
    pop edx

    mov [edx + 8], eax	; right = send_noodes(string)
    mov eax, edx

    jmp get_out

    number:
    mov edi, eax	; moving to edi for movsb function
    cld
    rep movsb		; copying ecx bytes from esi to edi

    mov edi, eax 	; pointing to first element instead of last
    
    push 12
    call malloc
    add esp, 4

    mov dword[eax + 4], 0	; left = null
    mov dword[eax + 8], 0
    mov [eax], edi	; data = extracted string
    inc esi
    
    get_out:
    pop edi
    pop edx
    pop ecx
    pop edx

    leave
    ret