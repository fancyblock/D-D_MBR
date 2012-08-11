org 7c00h

jmp short boot_start
nop

db 'HJB_SYS1'
dw 512
db 1
dw 1
db 2
dw 224
dw 2880
db 0xf0
dw 9
dw 18
dw 2
dd 0
dd 0
db 0
db 0
db 29h
dd 0
db 'D&D_SYS0.01'
db 'FAT12';软盘引导扇区的BPB

boot_start:
mov ax,cs
mov es,ax
mov ds,ax
mov ah,00h
mov dl,0
int 13h
jc boot_start;软盘复位失败重来

read_start:
mov bx,0x7e00
mov ah,2
mov ch,0
mov dh,0
mov al,32
mov cl,2
mov dl,0
int 13h
jc read_start;软盘FAT和根目录区读取失败重来

mov bx,0xa200;寻找引导文件BOOT.HJB
mov cx,224
search_bootfile:
mov si,boot_file
mov di,bx
xor al,al
sub_loop:
mov ah,byte[si]
cmp ah,byte[di]
jnz tear_search
inc al
cmp al,11
jz go_on
inc si
inc di
jmp sub_loop
tear_search:
add bx,32
loop search_bootfile

mov ax,no_sys;没有找到引导程序的话的处理方式
mov bp,ax
mov cx,9
mov ax,01301h
mov bx,000ch
mov dl,0
int 10h
jmp $;显示一行提示

go_on:
;开始加载引导程序
mov ax,0x9000
mov es,ax
add bx,26
mov ax,word[bx]
mov word[cu],ax
xor bx,bx
mov word[tar],bx

readto_mem:
mov ax,word[cu]
add ax,31;根目录区该条目的文件的开始簇
mov bh,18
div bh
mov ch,al
shr ch,1
mov dh,al
and dh,1
mov cl,ah
inc cl
mov al,1
xor dl,dl
mov ah,2
mov bx,word[tar]
int 13h

mov bx,word[tar]
add bx,512
mov word[tar],bx

mov ax,word[cu];算出下一簇的簇号
mov bh,2
div bh
mov ch,ah
inc bh
mul bh
add ax,0x7e00
mov bx,ax
cmp ch,1
jz other
mov al,byte[ds:bx]
inc bx
mov ah,byte[ds:bx]
and ah,0x0f
jmp jud_fina
other:
inc bx
mov al,byte[ds:bx]
inc bx
mov ah,byte[ds:bx]
mov cl,4
shr ax,cl
jud_fina:
cmp ax,0xfff
jz complete
mov word[cu],ax
jmp readto_mem

complete:
jmp dword 0x9000:0;跳到引导程序处执行

boot_file db 'BOOT    HJB'
no_sys db 'No D&D OS'
cu dw 0
tar dw 0

times 510-($-$$) db 0
dw 0xaa55
