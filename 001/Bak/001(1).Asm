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
    mov edx,eax     ;eax保存着KERNEL32基址 ,xp  win7 64位通杀
    mov eax,(IMAGE_DOS_HEADER ptr [edx]).e_lfanew   ;得到IMAGE_NT_HEADERS地址
    mov eax,(IMAGE_NT_HEADERS ptr [edx + eax]).OptionalHeader.DataDirectory.VirtualAddress  ;得到导出表RVA
    add eax,edx                 ;导出表在内存的实际地址
    assume eax:ptr IMAGE_EXPORT_DIRECTORY
    mov esi,[eax].AddressOfNames
    add esi,edx
    push 00007373h  ;在堆栈中构造GetProcAddress
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
        mov ecx,0fh ;GetProcAddress的长度，包括0
        repz cmpsb
        .break .if ZERO? ;找到跳出循环
        pop ecx
        pop esi
        add esi,4
        inc ecx
    .until ecx >= [eax].NumberOfNames
    pop ecx
    mov esi,[eax].AddressOfNameOrdinals
    add esi,edx
    movzx ecx,word ptr [esi + ecx*2] ;取出序数
    mov esi,[eax].AddressOfFunctions
    assume eax:nothing
    add esi,edx
    mov esi,[esi + ecx*4]
    add esi,edx ;得到GetProcAddress地址
    mov  edi,edx
        push 00000000
    push 41797261h ;在栈中构造LoadLibraryA
    push 7262694Ch
    push 64616F4Ch
    push esp
    push edx
    call esi ;调用GetProcAddress获取LoadLibraryc地址
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