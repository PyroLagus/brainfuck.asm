  DATASIZE equ 30000
  INPUTSIZE equ 10000
  CODESIZE equ 10000
  STACKSIZE equ 10000

segment .data
  ip dd 0                               ; instruction pointer
  dp dw 0                               ; data pointer
  stackp dd 0                           ; stack pointer

segment .bss
  cells resq DATASIZE                   ; data array
  input resb INPUTSIZE                  ; input array
  code resb CODESIZE                    ; code array
  stack resd STACKSIZE                  ; stack array

segment .text
global _start
_start:
init:
  ;read STDIN
  xor rax, rax                          ; rax = 0 (sys_read)
  xor rdi, rdi                          ; rdi = 0 (stdin)
  mov rsi, input                        ; buf address
  mov rdx, INPUTSIZE                    ; buf size
  syscall

  cld
  xor ecx,ecx                           ; instruction pointer = 0
  mov esi, input
  mov edi, code

init_lp:
  lodsb                                 ; al = [esi], esi++
  test al, al                           ; stop reading if null is encountered
  je init_le

  jmp check_symbol

left_bracket:
  mov ebx, [stackp]
  mov [stack+ebx*4], ecx                ; push instruction address into stack
  inc dword [stackp]
  stosb
  add edi, 4                            ; make space for instruction address
  add ecx, 5                            ; move instruction pointer forward, and skip the four bytes for the address
  jmp init_lp

right_bracket:
  dec dword [stackp]
  mov ebx, [stackp]
  mov ebx, [stack+ebx*4]                ; pop from stack into ebx
  stosb
  mov [edi], dword ebx                  ; put address of previous [ after the current ]
  add edi, 4
  mov [code+ebx+1], dword ecx           ; put address of current ] after the previous [
  add ecx, 5                            ; move instruction pointer forward, and skip the four bytes for the address
  jmp init_lp

other_valid:
  stosb
  inc dword ecx
  jmp init_lp
init_le:


main_lp:
  mov ecx, [ip]
  mov al, [code+ecx]

  test al, al
  je exit
  cmp al, 0x3E                          ; >
  je next
  cmp al, 0x3C                          ; <
  je prev
  cmp al, 0x2B                          ; +
  je incr
  cmp al, 0x2D                          ; -
  je decr
  cmp al, 0x2E                          ; .
  je print
  cmp al, 0x2C                          ; ,
  je read
  cmp al, 0x5B                          ; [
  je sloop
  cmp al, 0x5D                          ; ]
  je eloop
instr_done:
  inc dword [ip]
  jmp main_lp


next:
  inc word [dp]
  jmp instr_done
prev:
  dec word [dp]
  jmp instr_done
incr:
  mov ebx, [dp]
  inc qword [cells+ebx*8]
  jmp instr_done
decr:
  mov ebx, [dp]
  dec qword [cells+ebx*8]
  jmp instr_done
print:
  mov rax, 1
  mov rdi, 1
  mov ebx, [dp]
  lea rsi, [cells+ebx*8]
  mov rdx, 1
  syscall
  jmp instr_done
read:
  mov rax, 0
  mov rdi, 0
  mov ebx, [dp]
  lea rsi, [cells+ebx*8]
  mov rdx, 1
  syscall
  jmp instr_done
sloop:
  mov ebx, [dp]
  mov rax, qword [cells+ebx*8]
  test rax, rax
  jne sloop_end
  mov ecx, [ip]
  mov ecx, [code+ecx+1]
  mov [ip], ecx
sloop_end:
  add [ip], dword 5
  jmp main_lp
eloop:
  mov ebx, [dp]
  mov rax, qword [cells+ebx*8]
  test rax, rax
  je eloop_end
  mov ecx, [ip]
  mov ecx, [code+ecx+1]
  mov [ip], ecx
eloop_end:
  add [ip], dword 5
  jmp main_lp

check_symbol:
  cmp al, 0x3E                          ; >
  je other_valid
  cmp al, 0x3C                          ; <
  je other_valid
  cmp al, 0x2B                          ; +
  je other_valid
  cmp al, 0x2D                          ; -
  je other_valid
  cmp al, 0x2E                          ; .
  je other_valid
  cmp al, 0x2C                          ; ,
  je other_valid
  cmp al, 0x5B                          ; [
  je left_bracket
  cmp al, 0x5D                          ; ]
  je right_bracket
  jmp init_lp                           ; invalid, ignore

exit:
  mov rax, 60
  mov rdi, 0
  syscall
