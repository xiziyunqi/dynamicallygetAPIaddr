.386
.model flat,stdcall
option casemap:none
include windows.inc
.code
start proc
 
            
        assume fs:nothing
        xor   ecx,ecx
    mov eax,fs:[30h]
    mov eax,[eax + 0ch]
    mov esi,[eax + 1ch]
next_module:
        mov   eax,[esi+08h]
        mov   edi,[esi+20h]
        mov   esi,[esi]
        cmp  [edi+12*2],cx
        jnz  next_module
;****************************************************************************************       
    mov edx,eax     ;eax������KERNEL32��ַ ,xp  win7 64λͨɱ
    mov eax,(IMAGE_DOS_HEADER ptr [edx]).e_lfanew   ;�õ�IMAGE_NT_HEADERS��ַ
    mov eax,(IMAGE_NT_HEADERS ptr [edx + eax]).OptionalHeader.DataDirectory.VirtualAddress  ;�õ�������RVA
    add eax,edx                 ;���������ڴ��ʵ�ʵ�ַ
    assume eax:ptr IMAGE_EXPORT_DIRECTORY
    mov esi,[eax].AddressOfNames
    add esi,edx
    push 00007373h  ;�ڶ�ջ�й���GetProcAddress
    push 65726464h
    push 41636F72h
    push 50746547h
    push esp
    xor ecx,ecx
    .repeat
        mov edi,[esi]
        add edi,edx
        push esi
        mov esi,[esp + 4]
        push ecx
        mov ecx,0fh ;GetProcAddress�ĳ��ȣ�����0
        repz cmpsb
        .break .if ZERO? ;�ҵ�����ѭ��
        pop ecx
        pop esi
        add esi,4
        inc ecx
    .until ecx >= [eax].NumberOfNames
    pop ecx
    mov esi,[eax].AddressOfNameOrdinals
    add esi,edx
    movzx ecx,word ptr [esi + ecx*2] ;ȡ������
    mov esi,[eax].AddressOfFunctions
    assume eax:nothing
    add esi,edx
    mov esi,[esi + ecx*4]
    add esi,edx ;�õ�GetProcAddress��ַ
    mov  edi,edx
        push 00000000
    push 41797261h ;��ջ�й���LoadLibraryA
    push 7262694Ch
    push 64616F4Ch
    push esp
    push edx
    call esi ;����GetProcAddress��ȡLoadLibraryc��ַ
    ;mov edx,ebx
        call _user32
        db 'user32',0
_user32:
        pop ebx
        push ebx
        call eax
    ;    mov edi,eax
        call _msg
       db 'MessageBoxA',0
  _msg:
        pop  ebx
        push ebx
        push eax
        call esi
        call _hello
        db 'hello',0
_hello:
        pop ebx
        push 0
        push 0
        push ebx
        push 0
        call eax
        call _exit
 
       db 'ExitProcess',0
_exit:        
       pop ebx
       push ebx
       push edi
       call esi
       push 0
       call eax
 
       
start endp
end start