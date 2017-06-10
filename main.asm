INCLUDE Irvine32.inc
.data
key_msg byte "Enter Your Key : ",0                                       ;message to print
op_msg byte "Enter The Type Of Operation(E/D) : ",0                      ;message to print
file_msg byte "Do You want to read the message from a file ? (Y/N) : ",0 ;message to print 
path_file byte "Enter the Path of the file : ",0                         ;message to print
msg byte "Enter Your Message : ",0                                       ;message to print
error_read_file byte "Cannot open file",0                                ;message to print
error_loading_file byte  "Error reading file. " ,0                       ;message to print
error_buffer_size byte "Error: Buffer too small for the file",0          ;message to print 
saved_file_dec byte "Your Message has been decrypted successfully and saved at this path : ",0   ;message to print
saved_file_enc byte "Your Message has been encrypted successfully and saved at this path : ",0   ;message t0 print
message_enc byte "Your Encrypted Message is : ",0                           ;message to print
message_dec byte "Your Decrypted Message is : ",0                           ;message to print
errorsiz byte "Size of message Is Not Valid !!!!",0                                                  ;message tp print

arr byte 25 DUP(0)                                                       ;holds the encryption matrix 
indx byte 26 DUP(0)                                                      ;holds in index for every char in the matrix
taken byte 26 DUP(0)                                                     ;mark the taken char to fill matrix
encrypted_msg byte 2001 dup(0)                                           ;to store the final encrypted message
temp byte 2001 dup(0)                                                    ;temp value to edit the decrypted message from Q's
decrypted_msg byte 2001 dup(0)                                           ;holds the final decrypted message
input_msg byte 1001 DUP(0)                                               ;holds the entered message
input_msg_fin byte 1001 DUP(0)                                           ;holds the entered message after remove spaces and convert it to capital
key_val byte 1001 DUP(0)                                                 ;holds the key message
filename BYTE 80 DUP(0)                                                  ;holds the name ( path ) for the input file
outfilename BYTE 80 DUP(0)                                               ;holds the name ( path ) for the output file

pre byte 0                                                               ;tmp value holds the previous char to check the repetition.
sz dword ?                                                               ;size for the entered message
sz1 dword ?                                                              ;size for the key message
row1 byte 0                                                              ;temp value to save the row for some char
row2 byte 0                                                              ;temp value to save the row for some char
indx1 byte 0                                                             ;temp value save the index for char in the array  
indx2 byte 0                                                             ;temp value save the index for char in the array 
col1 byte 0                                                              ;temp value to save the coloumn for some char 
col2 byte 0                                                              ;temp value to save the coloumn for some char 
size_of_final_enc dword 0                                                ;holds the size for the final encrypted message
count2 byte 0                                                            ;holds the size for the decrypted message
path_size byte 0                                                         ;holds the size of the input file path
isfile byte 0                                                            ;flag to check if the user select reading from file or not
fileHandle HANDLE ?                                                      ;handle on the file.
opr byte ?
.code
main PROC

call hello_page

exit
main ENDP
;------------------------------------------------------------------
; Procedure to Read the file and store it in input_msg
;------------------------------------------------------------------
ReadFil PROC
	mov edx,offset path_file
	call writestring
	                                      
	mov edx,OFFSET filename                    ; Let user input a filename.
	mov ecx,SIZEOF filename
	call ReadString
    mov path_size,al
		                                           ; Open the file for input.
	mov edx,OFFSET filename
	call OpenInputFile
	mov fileHandle,eax
		                                       
	cmp eax,INVALID_HANDLE_VALUE                 ; error opening file?
	jne file_ok                                  ; no: skip
	mov edx,offset error_read_file
	call writestring
	call crlf
	exit                                          ; and quit
	file_ok:
                                                  ; Read the file into a buffer.
	mov edx,OFFSET input_msg
	mov ecx,1001
	call ReadFromFile
	jnc check_buffer_size                                ; error reading?
	mov edx,offset error_loading_file                    ; yes: show error message
	call writestring
	call crlf
	call WriteWindowsMsg
	jmp close_file
	check_buffer_size:
	cmp eax,100001                                    ; buffer large enough?
	jb buf_size_ok ; yes
	mov edx,offset error_buffer_size
	call writestring
	call crlf
	jmp quit                                         ; and quit
	buf_size_ok:
	mov input_msg[eax],0                            ; insert null terminator
	mov sz,eax                                     

	close_file:
	mov eax,fileHandle
	call CloseFile
	quit:
RET
ReadFil ENDP
;---------------------------------------------------
; Procedure to Write the Encrypted message into the file
;---------------------------------------------------
ewritefil PROC

call editpath                         ;Edit the File Path

mov eax,size_of_final_enc
push eax
mov edx,offset filename
call createoutputfile
mov filehandle ,eax
pop ecx
mov edx,offset encrypted_msg
call writetofile
mov eax,filehandle
call closefile
mov edx,offset saved_file_enc
call writestring
call crlf
mov edx,offset filename
call writestring 
call crlf
RET
ewritefil ENDP
;----------------------------------------------------
;Procedure to Rename the input file 
;----------------------------------------------------
editpath PROC
movzx esi,path_size
sub esi,4

cmp opr,'D'
je els
mov filename[esi],'-'
inc esi
mov filename[esi],'e'
inc esi
mov filename[esi],'n'
inc esi
mov filename[esi],'c'
inc esi
mov filename[esi],'r'
inc esi
mov filename[esi],'y'
inc esi
mov filename[esi],'p'
inc esi
mov filename[esi],'t'
inc esi
mov filename[esi],'e'
inc esi
mov filename[esi],'d'
inc esi

mov filename[esi],'.'
inc esi
mov filename[esi],'t'
inc esi
mov filename[esi],'x'
inc esi
mov filename[esi],'t'
inc esi
RET
els:
mov filename[esi],'-'
inc esi
mov filename[esi],'d'
inc esi
mov filename[esi],'e'
inc esi
mov filename[esi],'c'
inc esi
mov filename[esi],'r'
inc esi
mov filename[esi],'y'
inc esi
mov filename[esi],'p'
inc esi
mov filename[esi],'t'
inc esi
mov filename[esi],'e'
inc esi
mov filename[esi],'d'
inc esi

mov filename[esi],'.'
inc esi
mov filename[esi],'t'
inc esi
mov filename[esi],'x'
inc esi
mov filename[esi],'t'
inc esi
RET
editpath ENDP
;---------------------------------------------------
;Procedure to write the decrypted message into the file
;-----------------------------------------------------
dwritefil PROC

call editpath ; edit the input path and make it output

mov eax,size_of_final_enc
push eax
mov edx,offset filename
call createoutputfile
mov filehandle ,eax
pop ecx
mov edx,offset decrypted_msg
call writetofile
mov eax,filehandle
call closefile

mov edx,offset saved_file_dec
call writestring                            ; print the output path
call crlf
mov edx,offset filename
call writestring 
call crlf
RET
dwritefil ENDP
;---------------------------------------------------
;The main Page that appears when open the program
;---------------------------------------------------
Hello_page PROC

mov edx,offset op_msg
call writestring      ; print which operation that user want

mov ecx,2
call readstring      ;read the user choice

cmp byte ptr[edx],68
je En
mov opr,'E'
call encryption 
jmp sk
En:
mov opr,'D'
call decryption
sk:
RET
Hello_page ENDP
;---------------------------------------------------
; Procedure to Encrypt the input message 
;---------------------------------------------------
encryption PROC

mov edx,offset file_msg
call writestring         ;print if the user want to read from file or not

mov ecx,2
call readstring          ;read the user choice

cmp byte ptr[edx],89
jne els
mov isfile,1
call readfil
jmp iff
els:
mov edx,offset msg 
call writestring           ;Enter the message to encrypt.

mov edx,offset input_msg     ;offset for message to encrypt.
mov ecx,1000               ;mov max size to ecx
call readstring
mov sz,eax                 ;mov the size for messageto encrypt.

iff:
mov edx,offset key_msg     ;enter the key message.
call writestring

mov edx,offset key_val    ;offset for the key msg.
mov ecx,1000              ;max size
call readstring
mov sz1,eax               ;mov the size of the key.

call fill_matrix

call msg_filter


mov esi,0     ;loop counter
l6:          ;loop to split the message into pairs.
call split
add esi,2
cmp esi,ecx
jb l6
cmp isfile,1
jne done
call ewritefil
jmp ok
done:
mov edx,offset message_enc
call writestring
mov edx,offset encrypted_msg
call writestring
call crlf
ok:
RET
encryption ENDP
;---------------------------------------------------
; Procedure to decrypt the input message 
;---------------------------------------------------
decryption PROC

mov edx,offset file_msg
call writestring

mov ecx,2
call readstring

cmp byte ptr[edx],89
jne els
call readfil
mov isfile,1
jmp iff
els:
mov edx,offset msg 
call writestring           ;Enter the message to decrypt.

mov edx,offset input_msg     ;offset for message to decrypt.
mov ecx,1000               ;mov max size to ecx
call readstring
mov sz,eax                 ;mov the size for message to decrypt.
iff:


mov edx,offset key_msg     ;enter the key message.
call writestring

mov edx,offset key_val    ;offset for the key msg.
mov ecx,1000              ;max size
call readstring
mov sz1,eax               ;mov the size of the key.

call fill_matrix          ;fill the encryption matrix

call msg_filter       ;remove spaces and make all letters to capital

mov ecx,ebx
mov esi,0
l7:
call split            ;split the message into pairs
add esi,2
cmp esi,ecx
jb l7
mov esi,0
mov edi,0

l1:                        ;this loop removes the added Qs
cmp temp[esi],81
jne skip
cmp esi,0
je ifbody
movzx edx,count2
dec edx
cmp esi,edx
je skip2
mov edx,esi
dec edx
mov al,temp[edx]
add edx,2
mov bl,temp[edx]
cmp al,bl
je skip2
ifbody:
mov decrypted_msg[edi],81
inc edi
jmp skip2
skip:
mov al,temp[esi]
mov decrypted_msg[edi],al
inc edi
skip2:
inc esi
loop l1


mov size_of_final_enc ,edi

cmp isfile,1
jne done
call dwritefil
jmp ok
done:
mov edx,offset message_dec
call writestring
mov edx,offset decrypted_msg
call writestring
call crlf
ok:
RET
decryption ENDP
;---------------------------------------------------
; Procedure to fill the matrix
;---------------------------------------------------
fill_matrix PROC
mov ebx,0                 ; counter for the distinict chars
mov esi,0                 ; loop counter

loop1:
cmp esi,sz1
je break
movzx eax,key_val[esi] ; take the current char

cmp al,32
je skip

cmp al,90
jle skop
sub al,32
mov key_val[esi],al
skop:

sub al,65            ;convert the char to index from range ( 0-25 ). 
cmp al,8             ; if the char is I
jne sk

mov ecx,9            ; mark J as taken
mov taken[ecx],1

sk:
cmp al,9             ;if the char is J
jne skip2

mov taken[eax],1    ; mark J as taken
SUB al,1            ; convert J to I
skip2:
cmp taken[eax],0   ; if not taken take and mark it then give it index
jne skip
mov taken[eax],1   ; mark taken
mov indx[eax],bl   ; give index to this char

mov al,key_val[esi] 
mov arr[ebx],al    ; put this char in the matrix

inc ebx

skip:
inc esi
jmp loop1
break:

mov esi,65         ; start from A to Z and fill the remaining chars into the matrix.
l3:
mov ecx,esi         
sub ecx,65         ; convert to index
cmp ecx,9          ; if the char is J
jne skk            
mov edi,8          ; Give the J char the same address as I.
mov al,indx[edi]
mov indx[ecx],al
mov taken[ecx],1
skk:
mov al,taken[ecx]  
cmp al,1           ; if not taken then take and give it index.
je skip3
mov eax,esi
mov arr[ebx],al
sub eax,65
mov indx[eax],bl
inc ebx
skip3:
add esi,1
cmp esi,90
jbe l3
RET
fill_matrix ENDP
;---------------------------------------------------------------------------
;Procedure to filter the Message
;---------------------------------------------------------------------------
msg_filter PROC

cmp opr,'D'
je decr
mov esi,0                  ; loop counter
mov ebx,0                  ; counter for the final message
l5:
mov al,input_msg[esi]
cmp al,32                  ; if this char is space then skip
je skkk
cmp al,90                  
jbe skk1
sub al,32                  ; check if this char is small convert it to capital.
skk1:
cmp al,'J'
jne isnotj
mov al,'I'
isnotj:
cmp pre,al                 ; check if two consecutive chars are equal.
jne skop
mov input_msg_fin[ebx],81   ; if equal add Q between them
inc ebx
skop:
mov input_msg_fin[ebx],al    
inc ebx
mov pre,al
skkk:
inc esi
cmp esi,sz
jb l5
mov ecx,ebx
mov eax,ebx
mov ebx,2
mov edx,0
div ebx
cmp edx,0
je skop1
mov input_msg_fin[ecx],81
inc ecx
jmp skop1
decr:

mov esi,0                  ; loop counter
mov ebx,0                  ; counter for the final message
l51:
mov al,input_msg[esi]
cmp al,32                  ; if this char is space then skip
je skkk2

cmp al,90                  
jbe skk12
sub al,32                  ; check if this char is small convert it to capital.
skk12:
mov input_msg_fin[ebx],al    
inc ebx
skkk2:
inc esi
cmp esi,sz
jb l51
push ebx
mov eax,ebx
mov ebx,2
mov edx,0
div ebx
pop ebx
cmp edx,0
je skop1
mov edx,offset errorsiz
call writestring
call crlf
exit
skop1:

RET
msg_filter ENDP
;---------------------------------------------------------------------------------------------
;takes every two chars that is in esi and esi+1 and encrypt them
;---------------------------------------------------------------------------------------------
split PROC uses esi ecx
movzx eax,input_msg_fin[esi]
inc esi
movzx ebx,input_msg_fin[esi]

sub al,65
sub bl,65

cmp opr,'D'
je decr

mov al,indx[eax] ; index for the first char
mov indx1,al
mov al,indx[ebx] ; index for the second char
mov indx2,al

movzx eax,indx1
mov ebx,5
mov edx,0
div ebx
mov row1,al
mov col1,dl

movzx eax,indx2
mov edx,0
div ebx
mov row2,al
mov col2,dl

mov al,row1
cmp al,row2
jne skip
call same_row
jmp skip2
skip:

mov al,col1
cmp al,col2
jne skip1
call same_col
jmp skip2
skip1:
call else_body
jmp skip2
decr:
mov al,indx[eax]               ; index for the first char
mov indx1,al
mov al,indx[ebx] ; index for the second char
mov indx2,al

movzx eax,indx1
mov ebx,5
mov edx,0
div ebx
mov row1,al
mov col1,dl

movzx eax,indx2
mov edx,0
div ebx
mov row2,al
mov col2,dl

mov al,row1
cmp al,row2
jne skip11
call same_row_dec
jmp skip2
skip11:

mov al,col1
cmp al,col2
jne skip12
call same_col_dec
jmp skip2
skip12:
call else_body_dec
skip2:
RET
split ENDP
;-----------------------------------------------------
; encrypt Two chars those in the same coloumn
;-----------------------------------------------------
same_col PROC uses esi
mov al,row1
mov bl,row2
inc al
cmp al,5
jne skip
mov al,0
skip:

inc bl
cmp bl,5
jne skip2
mov bl,0
skip2:

movzx ecx,al
movzx esi,bl

mov eax,ecx
mov ebx,5
mov edx,0
mul ebx
add al,col1
mov al,arr[eax]
mov edi,size_of_final_enc
mov encrypted_msg[edi],al
inc size_of_final_enc

mov eax,esi
mov edx,0
mul ebx
add al,col2
mov al,arr[eax]
mov edi,size_of_final_enc
mov encrypted_msg[edi],al
inc size_of_final_enc

RET
same_col ENDP
;----------------------------------------
; encrypt Two chars those in the same Row
;-----------------------------------------------------
same_row PROC uses esi

mov al,col1
mov bl,col2

inc al
cmp al,5
jne skip
mov al,0
skip:

inc bl
cmp bl,5
jne skip2
mov bl,0
skip2:

movzx ecx,al
movzx esi,bl

movzx eax,row1
mov ebx,5
mov edx,0
mul ebx
add eax,ecx
mov al,arr[eax]
mov edi,size_of_final_enc
mov encrypted_msg[edi],al
inc size_of_final_enc

movzx eax,row2
mov edx,0
mul ebx
add eax,esi
mov al,arr[eax]
mov edi,size_of_final_enc
mov encrypted_msg[edi],al
inc size_of_final_enc

RET
same_row ENDP
;-------------------------------------------
; encrypt Two chars those are forms a rectangle
;-----------------------------------------------------
else_body PROC uses eax ebx ecx esi

;Calculate the index for the first char
movzx eax,row1 
mov ebx,5
mul ebx
movzx ebx,col1
add eax,ebx

mov ecx,eax

;Calculate the index for the first char
movzx eax,row2
mov ebx,5
mul ebx
movzx ebx,col2
add eax,ebx

mov edx,eax

mov al,col1

cmp al,col2      ; check if the first char is in the next coloumn or before the next char
jb sk
movzx ebx,col1
sub bl,col2
sub ecx,ebx
add edx,ebx
jmp done
sk:
movzx ebx,col2
sub bl,col1
add ecx,ebx
sub edx,ebx
done:

mov al,arr[ecx]           
mov esi,size_of_final_enc
mov encrypted_msg[esi],al
inc size_of_final_enc

mov al,arr[edx]
mov esi,size_of_final_enc
mov encrypted_msg[esi],al
inc size_of_final_enc
RET
else_body ENDP
;------------------------------------------------------
; decrypt Two chars those are forms a rectangle
;-----------------------------------------------------
else_body_dec PROC uses eax ebx ecx esi

;Calculate the index for the first char

movzx eax,row1
mov ebx,5
mul ebx
movzx ebx,col1
add eax,ebx

mov ecx,eax

movzx eax,row2
mov ebx,5
mul ebx
movzx ebx,col2
add eax,ebx

mov edx,eax

mov al,col1        ; check if the first char is in the next coloumn or before the next char
cmp al,col2
jb sk
movzx ebx,col1
sub bl,col2
sub ecx,ebx
add edx,ebx
jmp done
sk:
movzx ebx,col2
sub bl,col1
add ecx,ebx
sub edx,ebx
done:

mov al,arr[ecx]
movzx esi,count2
mov temp[esi],al
inc count2

mov al,arr[edx]
movzx esi,count2
mov temp[esi],al
inc count2
RET
else_body_dec ENDP
;-------------------------------------------------------
; decrypt Two chars those are in the same row
;-----------------------------------------------------
same_row_dec PROC

mov al,col1
mov bl,col2

cmp al,0
jne skip
mov al,4
jmp elseskip
skip:
dec al
elseskip:

cmp bl,0
jne skip1
mov bl,4
jmp elseskip1
skip1:
dec bl
elseskip1:
movzx ecx,al
movzx esi,bl

movzx eax,row1
mov ebx,5
mov edx,0
mul ebx
add eax,ecx
mov al,arr[eax]
movzx edi,count2
mov temp[edi],al
inc count2

movzx eax,row2
mov edx,0
mul ebx
add eax,esi
mov al,arr[eax]
movzx edi,count2
mov temp[edi],al
inc count2
RET
same_row_dec ENDP
;-------------------------------------------
; decrypt Two chars those are in the same coloumn
;--------------------------------------------
same_col_dec PROC
mov al,row1
mov bl,row2

cmp al,0
jne skip
mov al,4
jmp elseskip
skip:
dec al
elseskip:

cmp bl,0
jne skip1
mov bl,4
jmp elseskip1
skip1:
dec bl
elseskip1:
movzx ecx,al
movzx esi,bl

mov eax,ecx
mov ebx,5
mov edx,0
mul ebx
add al,col1
mov al,arr[eax]
movzx edi,count2
mov temp[edi],al
inc count2

mov eax,esi
mov edx,0
mul ebx
add al,col2
mov al,arr[eax]
movzx edi,count2
mov temp[edi],al
inc count2

RET
same_col_dec ENDP
;----------------------------------------------
; it's Done ............... 
; End Of Project :D
;-----------------------------------------------
END main