.MODEL SMALL
.STACK 100H
.DATA
PROMPT_MSG DB 'Choose conversion:', 0DH, 0AH, '1. EGP -> USD', 0DH, 0AH, '2. USD -> EGP', 0DH, 0AH, '3. EGP -> EUR', 0DH, 0AH, '4. EUR -> EGP', 0DH, 0AH, '$'
INPUT_MSG DB 0DH, 0AH, 'Enter value to convert: $'   
RESULT_MSG DB 0DH, 0AH, 'Result: $'
ERROR_MSG DB 0DH, 0AH, 'Invalid input! Exiting...', 0DH, 0AH, '$'    
INPUT_BUFFER DB 6, 0, 5 DUP(0)
USD_TO_EGP DW 50
     
EUR_TO_EGP DW 53
VALUE DW ?          
CHOICE DB ?             
TEMP_RESULT DW ?     
.CODE
MAIN PROC    
    MOV AX, @DATA    
    MOV DS, AX
       LEA DX, PROMPT_MSG    
    MOV AH, 09H
        INT 21H
    
    MOV AH, 01H
        INT 21H    
    MOV CHOICE, AL
        CMP CHOICE, '1'
    JE CHOICE_VALID
        CMP CHOICE, '2'
    JE CHOICE_VALID
        CMP CHOICE, '3'
    JE CHOICE_VALID
        CMP CHOICE, '4'
    JE CHOICE_VALID
        LEA DX, ERROR_MSG
    MOV AH, 09H
            INT 21H
    JMP EXIT
CHOICE_VALID:    
    LEA DX, INPUT_MSG
    MOV AH, 09H    
    INT 21H    
    CALL READ_NUMBER
    
    CMP CHOICE, '1'
            JE CONVERT_EGP_TO_USD
    CMP CHOICE, '2'    
    JE CONVERT_USD_TO_EGP
        CMP CHOICE, '3'    
    JE CONVERT_EGP_TO_EUR
        CMP CHOICE, '4'    
    JE CONVERT_EUR_TO_EGP
CONVERT_EGP_TO_USD:
    MOV AX, VALUE
    MOV BX, USD_TO_EGP
        DIV BX
    MOV TEMP_RESULT, AX
    JMP DISPLAY_RESULT
CONVERT_USD_TO_EGP:
    MOV AX, VALUE
    MOV BX, USD_TO_EGP    
    MUL BX
    MOV TEMP_RESULT, AX    
    JMP DISPLAY_RESULT
CONVERT_EGP_TO_EUR:
    MOV AX, VALUE    
    MOV BX, EUR_TO_EGP
    DIV BX    
    MOV TEMP_RESULT, AX
    JMP DISPLAY_RESULT
CONVERT_EUR_TO_EGP:    
    MOV AX, VALUE
    MOV BX, EUR_TO_EGP    
    MUL BX
    MOV TEMP_RESULT, AX    
    JMP DISPLAY_RESULT
DISPLAY_RESULT:
    LEA DX, RESULT_MSG    
    MOV AH, 09H
    INT 21H
    MOV AX, TEMP_RESULT    
    CALL PRINT_NUMBER
    JMP EXIT
EXIT:    
    MOV AH, 4CH    
    INT 21H
READ_NUMBER PROC
    LEA DX, INPUT_BUFFER     
    MOV AH, 0AH
    INT 21H
    XOR SI, SI               ; Clear SI
    MOV SI, OFFSET INPUT_BUFFER+2    ; Point SI to the input buffer after skipping the first two bytes
    XOR AX, AX               ; Clear AX
    MOV VALUE, AX              ; Initialize num (16-bit) to 0
    
ConvertToInt:

    CMP BYTE PTR [SI], 0Dh   ; Check if the current character is a carriage return (Enter key)
    JE complet               ; If yes, exit the loop
    
    MOV AX, VALUE              ; Load the current value of num into AX
    MOV BX, 10               ; Prepare multiplier 10 in BX
    MUL BX                   ; Multiply AX by 10 (result stored in DX:AX, but DX will be 0 since AX is small)
    MOV VALUE, AX              ; Store the result back into num
    
    MOV AL, [SI]             ; Load the current character from the buffer into AL
    SUB AL, 30h              ; Convert ASCII to numeric (subtract ASCII '0')
    XOR AH,AH
    ADD VALUE, AX              ; Store the updated value back into num
    
    INC SI                   ; Move to the next character in the buffer
    JMP ConvertToInt         ; Repeat the loop

complet:

    RET
READ_NUMBER ENDP
PRINT_NUMBER PROC    
    MOV BX, 10
    XOR CX, CX
    REPEAT_DIV:
    XOR DX, DX    
    DIV BX
    PUSH DX    
    INC CX
    CMP AX, 0    
    JNE REPEAT_DIV
PRINT_LOOP:    
    POP DX
    ADD DL, '0'    
    MOV AH, 02H
    INT 21H   
    LOOP PRINT_LOOP
    RET
    PRINT_NUMBER ENDP
END MAIN