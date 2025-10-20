Title Jogo da Velha
.MODEL SMALL
.STACK 100h
.DATA
    MSG3 DB "DIGITE X OU O: $"
    
   
    MSG4 DB 0Dh, 0Ah, "TABULEIRO:", 0Dh, 0Ah, "$"  
    NOVA_LINHA DB 0Dh, 0Ah, "$"
    SEPARADOR_COL DB " | $"
    SEPARADOR_LIN DB "---+---+---$"
    EXEMPLO_TAB DB '1','2','3'
                DB '4','5','6'
    		    DB '7','8','9'
    
    TABULEIRO DB 3 DUP(3 DUP(' ')) 
    
.CODE

; Lê 9 caracteres, um para cada posição do tabuleiro 3x3
LERMATRIZ PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, OFFSET tabuleiro ; Aponta SI para o início do tabuleiro
    MOV CX, 9                ; Vamos ler 9 números (3x3)

LOOP_LEITURA:
    ; Mostra a MSG3, para pedir o numero
    MOV AH, 09h
    LEA DX, MSG3
    INT 21h

    ; Le o numero (caractere)
    MOV AH, 01h
    INT 21h
    
    
    
    ; 1. JOGA O CARACTERE NA MATRIZ (PRIMEIRO)
    MOV [SI], AL 
    INC SI           ; Anda uma casinha pra frente na matriz

    ; 2. PULA A LINHA (DEPOIS)
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    ; --- FIM DA CORRECAO ---

    LOOP LOOP_LEITURA ; Repete 9 vezes

    POP SI
    POP DX
    POP CX
    POP AX
    RET
LERMATRIZ ENDP

; --- PROCEDURE IMPRIMIRMATRIZ (Corrigida e Formatada) ---
IMPRIMIRMATRIZ PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, TABULEIRO  ; Aponta SI para o início do tabuleiro
    MOV CX, 3          ; CX será nosso contador de LINHAS (3 linhas)
    
PRINT_LINHA:
    ; --- Imprime a linha no formato: [char] | [char] | [char] ---
    
    ; Imprime o primeiro caractere da linha
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI ; Avança para a próxima posição (coluna 2)
    
    ; Imprime o separador " | "
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    ; Imprime o segundo caractere
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI ; Avança para a próxima posição (coluna 3)
    
    ; Imprime o separador " | "
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    ; Imprime o terceiro caractere
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI ; Avança para o início da próxima linha
    
    ; Pula para a próxima linha (CR/LF)
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    ; --- Fim da impressão da linha ---
    
    ; Verifica se é a última linha. Se for, não imprime "---+---"
    CMP CX, 1
    JE FIM_PRINT_LOOP ; Se CX=1, era a última linha, então pule
    
    ; Imprime a linha divisória "---+---+---"
    LEA DX, SEPARADOR_LIN
    MOV AH, 09h
    INT 21h
    
    ; Pula para a próxima linha (CR/LF)
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
FIM_PRINT_LOOP:
    LOOP PRINT_LINHA ; Decrementa CX e volta para PRINT_LINHA se CX != 0
    
    POP SI
    POP DX
    POP CX
    POP AX
    RET
IMPRIMIRMATRIZ ENDP

IMPRIMIREXEMPLO PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, EXEMPLO_TAB  ; Aponta SI para o início do tabuleiro
    MOV CX, 3          ; CX será nosso contador de LINHAS (3 linhas)
    
PRINT_LINHA:
    ; --- Imprime a linha no formato: [char] | [char] | [char] ---
    
    ; Imprime o primeiro caractere da linha
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI ; Avança para a próxima posição (coluna 2)
    
    ; Imprime o separador " | "
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    ; Imprime o segundo caractere
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI ; Avança para a próxima posição (coluna 3)
    
    ; Imprime o separador " | "
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    ; Imprime o terceiro caractere
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI ; Avança para o início da próxima linha
    
    ; Pula para a próxima linha (CR/LF)
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    ; --- Fim da impressão da linha ---
    
    ; Verifica se é a última linha. Se for, não imprime "---+---"
    CMP CX, 1
    JE FIM_PRINT_LOOP ; Se CX=1, era a última linha, então pule
    
    ; Imprime a linha divisória "---+---+---"
    LEA DX, SEPARADOR_LIN
    MOV AH, 09h
    INT 21h
    
    ; Pula para a próxima linha (CR/LF)
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
FIM_PRINT_LOOP:
    LOOP PRINT_LINHA ; Decrementa CX e volta para PRINT_LINHA se CX != 0
    
    POP SI
    POP DX
    POP CX
    POP AX
    RET
IMPRIMIREXEMPLO ENDP


MAIN PROC
    MOV AX, @DATA   
    MOV DS, AX
    
    ; 1. Chama a rotina para ler os 9 valores
    CALL LERMATRIZ    
    
    ; 2. Mostra o título "TABULEIRO:"
    LEA DX, MSG4
    MOV AH, 09h
    INT 21h
    
    ; 3. Chama a rotina para imprimir o tabuleiro formatado
    CALL IMPRIMIRMATRIZ
    
    ; 4. Encerra o programa
    MOV AH, 4Ch
    INT 21h       
MAIN ENDP 

END MAIN