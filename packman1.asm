DOSSEG
    .MODEL SMALL
    .STACK 200h
   
   
    .data
    lives dw ?, '$'
    score db ?,'$'
    input_message db  'Lives left $'
    score_msg db  'Your Score $', '$'
    new_game db 'Press N$'
    new_game_ db 'for new game$'
    
    end_game db 'Press E$'
    end_game_ db 'to exit game$'

    .CODE
    ;Ideal

;===- Data -===

BufferSeg   dw  0

ErrMsgOpen  db  "Error opening `"
FileName1    db  "1.TXT",0,8,"'$"
FileName2    db  "2.TXT",0,8,"'$" 
FileName3    db  "3.TXT",0,8,"'$" 
FileName4    db  "4.TXT",0,8,"'$" 
FileName5    db  "5.TXT",0,8,"'$" 
FileName6    db  "10.TXT",0,8,"'$" 


temp dw ?
cou dw 0h
row dw ?
col dw ?
color dw ?
counter2 dw ?
counter dw ?
                                        ;0 is required for filename 
                                        ;(displays a space)
FileLength dw 0

;===- Macro -=========

SETCURSOR MACRO row,col 

    PushAll
    mov dh, row ; row number
    mov dl, col ; column numnber
    mov bh, 0 ; page number
    mov ah, 2
    int 10h
    PopAll
    
endm

COLORPIXEL MACRO Row, Col, Color
	
	PushAll
		mov ax, Color
		mov cx, Col
		mov dx, Row
		mov ah, 0ch
		int 10h 
	PopAll
	
	endm
	
prompt macro message
    push ax
    mov ah , 09h
    lea dx , message ; get effective adress of a variable
    int 21h
    
    pop ax ; remember to pop with every push
    
    endm
    
PushAll macro 
	push ax
	push bx
	push cx
	push dx
	endm

PopAll macro
	pop dx
	pop cx
	pop bx
	pop ax
	endm 

;===- Subroutines -===


;===- Main Program -===

START:
;insert video mode here
    
    mov ax, @data
		mov ds, ax
		
		call SETVIDEOMODE
        call DRAWSCOREBOARD
        
    comment @
    loopinf:
    
    mov cou,1h
    asec:
    
    cmp cou,5h
    je desc
    call DELAY
    call DisplayFile
    
    inc cou
    
    jmp asec
    
    desc:
    cmp cou,0h
    je gen_case
    call DisplayFile
    call DELAY
    dec cou
    
    jmp desc

gen_case:
        
    jmp loopinf
    @

    mov     ax,4c00h
    int     21h

DisplayFile PROC 

    PushAll
    
    mov     ax,cs
    mov     ds,ax
    mov     bx,ss
    add     bx,200h/10h     ;get past the end of the file
    mov     [BufferSeg],bx  ;store the buffer segment
    
    
    push    ds

    mov     ax,cs
    mov     ds,ax
    mov     ax,3d00h    ;open file (ah=3dh)
    
    ;make a large test case!!
    
    cmp cou,1h
    jne case1
    mov     dx,offset FileName1
    jmp def_case
case1:
    cmp cou,2h
    jne case2
    mov     dx,offset FileName2
    jmp def_case
case2:
    cmp cou,3h
    jne case3
    mov     dx,offset FileName3
    jmp def_case
case3:
    cmp cou,4h
    jne case4
    mov     dx,offset FileName4
    jmp def_case
case4:
    cmp cou,05h
    jne case5
    mov     dx,offset FileName5
    jmp def_case

case5:
    cmp cou, 10
    jne default_case_exit
    mov     dx,offset FileName6
    jmp def_case
    
default_case_exit:
ret

def_case:    
    ;end the large loop!
    
    int     21h
    
NoError:    
    ;;something diff
    mov     bx,ax       ;move the file handle into bx

    mov     ds,[BufferSeg]
    mov     dx,0            ;load to [BufferSeg]:0000
    mov     ah,3fh
    mov     cx,0FFFFh       ;try to read an entire segments worth
    int     21h
    
    mov bx,cs
    add bx,FileLength
    mov     [bx],ax

    mov     ah,3eh
    int     21h             ;close the file

    cld
    mov     si,0
    
    ;error!
    mov bx,cs
    add bx,FileLength
    mov cx,[bx]
    
PrintLoop :

       mov ah, 02h
       lodsb
       mov dl, al
       cmp dl, 0ah
       je no_draw
       cmp dl, 21h
       jb default
       sub dl, '0'
       mov dh, 00h
       COLORPIXEL row, col, dx
       inc col
       dec cx
       jnz PrintLoop

       no_draw :

       PushAll
       mov cx, temp
       mov col, cx
       PopAll
       inc row

        default:
           inc col
           dec cx
           jnz PrintLoop

       end_draw:
       pop ds
           
       PopAll
       ret

DisplayFile ENDP

;video mode set up

SETVIDEOMODE proc near
   
   		push ax
   		mov ah, 00h
		mov al, 13h
		int 10h
		pop ax
		
		ret
		
	SETVIDEOMODE endp
	
; proc to cause delay

DELAY proc near
	
		mov counter, 1000h
		
		loopempty1 :
			
			mov counter2, 1000h
			loopempty2 :
				dec counter2
				jnz loopempty2
		    dec counter
		    jnz loopempty1
			   
		ret
	DELAY endp	

 DRAWSCOREBOARD proc near
 
 SETCURSOR 2,29
 prompt input_message
 
 SETCURSOR 4,33
 mov lives[0], 3
 
 SETCURSOR 6, 29
 prompt score_msg
 
 SETCURSOR 8, 33
 mov score[0], 3
 add score[0], 48
 prompt score
 
 SETCURSOR 14, 30
 prompt new_game
 SETCURSOR 16, 28
 prompt new_game_ 
 
 SETCURSOR 19, 30
 prompt end_game
 SETCURSOR 21, 28
 prompt end_game_ 

 push ax
 mov ax, lives[0]
 mov counter, ax
 pop ax
 
 mov cou, 5
 mov row, 26
 mov col, 236
 
 push ax
 mov ax, col
 mov temp, ax
 pop ax

 draw_images:
    mov row, 26
    add temp, 15
    call DisplayFile
    dec counter
    jnz draw_images
    
 mov row, 85
 mov col, 260
 push ax
 mov ax, col
 mov temp, ax
 pop ax
 mov cou, 10
 
 call DisplayFile

 mov row, 0
 mov col, 220
 call DRAWLINE_VER
 mov row, 0
 mov col, 221
 call DRAWLINE_VER
 mov row, 0
 mov col, 220
 call DRAWLINE_HOR
 mov row, 1
 mov col, 220
 call DRAWLINE_HOR
 mov row, 0
 mov col, 318
 call DRAWLINE_VER
 mov row, 0
 mov col, 319
 call DRAWLINE_VER
 mov row, 198
 mov col, 220
 call DRAWLINE_HOR
 mov row, 199
 mov col, 220
 call DRAWLINE_HOR
 
    ret
 DRAWSCOREBOARD endp
 
 DRAWLINE_HOR proc near
 
    mov counter, 100
    horizontal:
        COLORPIXEL row, col, 1
        inc col
        dec counter
        jnz horizontal
        
    ret 
 DRAWLINE_HOR endp
 
 DRAWLINE_VER proc near
 
    mov counter, 200
    vertical:
        COLORPIXEL row, col, 1
        inc row
        dec counter
        jnz vertical
        
    ret 
 DRAWLINE_VER endp
    
END START

