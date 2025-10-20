Title Jogo da Velha
.MODEL SMALL
.STACK 100h
.DATA
    MSG3 DB "DIGITE X OU O: $"
    
    ; Mensagem para o tabuleiro de exemplo
    MSG_EXEMPLO DB "Bem-vindo! Use as posicoes:", 0Dh, 0Ah, "$" 
    
    MSG4 DB 0Dh, 0Ah, "TABULEIRO:", 0Dh, 0Ah, "$" 
    NOVA_LINHA DB 0Dh, 0Ah, "$"
    SEPARADOR_COL DB " | $"
    SEPARADOR_LIN DB "---+---+---$"
    
    ; Tabuleiro de Exemplo (1-9)
    EXEMPLO_TAB DB '1','2','3'
                DB '4','5','6'
                DB '7','8','9'
    
    ; Tabuleiro do Jogo (vazio)
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

    LOOP LOOP_LEITURA ; Repete 9 vezes

    POP SI
    POP DX
    POP CX
    POP AX
    RET
LERMATRIZ ENDP

; --- PROCEDURE IMPRIMIRMATRIZ (Tabuleiro do Jogo) ---
IMPRIMIRMATRIZ PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, TABULEIRO  ; Aponta SI para o início do tabuleiro
    MOV CX, 3          ; CX será nosso contador de LINHAS (3 linhas)
    
PRINT_LINHA: ; <-- Etiqueta original
    ; --- Imprime a linha no formato: [char] | [char] | [char] ---
    
    MOV DL, [SI] ; Imprime o primeiro caractere
    MOV AH, 02h
    INT 21h
    INC SI
    
    LEA DX, SEPARADOR_COL ; Imprime o separador " | "
    MOV AH, 09h
    INT 21h
    
    MOV DL, [SI] ; Imprime o segundo caractere
    MOV AH, 02h
    INT 21h
    INC SI
    
    LEA DX, SEPARADOR_COL ; Imprime o separador " | "
    MOV AH, 09h
    INT 21h
    
    MOV DL, [SI] ; Imprime o terceiro caractere
    MOV AH, 02h
    INT 21h
    INC SI 
    
    LEA DX, NOVA_LINHA ; Pula para a próxima linha (CR/LF)
    MOV AH, 09h
    INT 21h
    
    ; --- Fim da impressão da linha ---
    
    CMP CX, 1 ; Verifica se é a última linha.
    JE FIM_PRINT_LOOP ; Se for, não imprime "---+---"
    
    LEA DX, SEPARADOR_LIN ; Imprime a linha divisória
    MOV AH, 09h
    INT 21h
    
    LEA DX, NOVA_LINHA ; Pula para a próxima linha (CR/LF)
    MOV AH, 09h
    INT 21h
    
FIM_PRINT_LOOP: ; <-- Etiqueta original
    LOOP PRINT_LINHA ; Decrementa CX e volta para PRINT_LINHA
    
    POP SI
    POP DX
    POP CX
    POP AX
    RET
IMPRIMIRMATRIZ ENDP

; --- PROCEDURE IMPRIMIREXEMPLO (Tabuleiro 1-9) ---
; (CORRIGIDA COM NOVAS ETIQUETAS)
IMPRIMIREXEMPLO PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, EXEMPLO_TAB  ; Aponta SI para o início do tabuleiro EXEMPLO
    MOV CX, 3            ; CX será nosso contador de LINHAS (3 linhas)
    
PRINT_EX_LINHA: ; <-- ETIQUETA RENOMEADA
    ; --- Imprime a linha no formato: [char] | [char] | [char] ---
    
    MOV DL, [SI] ; Imprime o primeiro caractere
    MOV AH, 02h
    INT 21h
    INC SI
    
    LEA DX, SEPARADOR_COL ; Imprime o separador " | "
    MOV AH, 09h
    INT 21h
    
    MOV DL, [SI] ; Imprime o segundo caractere
    MOV AH, 02h
    INT 21h
    INC SI
    
    LEA DX, SEPARADOR_COL ; Imprime o separador " | "
    MOV AH, 09h
    INT 21h
    
    MOV DL, [SI] ; Imprime o terceiro caractere
    MOV AH, 02h
    INT 21h
    INC SI 
    
    LEA DX, NOVA_LINHA ; Pula para a próxima linha (CR/LF)
    MOV AH, 09h
    INT 21h
    
    ; --- Fim da impressão da linha ---
    
    CMP CX, 1 ; Verifica se é a última linha.
    JE FIM_EX_LOOP ; <-- ETIQUETA RENOMEADA
    
    LEA DX, SEPARADOR_LIN ; Imprime a linha divisória
    MOV AH, 09h
    INT 21h
    
    LEA DX, NOVA_LINHA ; Pula para a próxima linha (CR/LF)
    MOV AH, 09h
    INT 21h
    
FIM_EX_LOOP: ; <-- ETIQUETA RENOMEADA
    LOOP PRINT_EX_LINHA ; Decrementa CX e volta para PRINT_EX_LINHA
    
    POP SI
    POP DX
    POP CX
    POP AX
    RET
IMPRIMIREXEMPLO ENDP


MAIN PROC
    MOV AX, @DATA   
    MOV DS, AX
    
    ; 1. Mostra a mensagem de boas-vindas
    LEA DX, MSG_EXEMPLO
    MOV AH, 09h
    INT 21h
    
    ; 2. Mostra o tabuleiro de exemplo (1-9)
    CALL IMPRIMIREXEMPLO
    
    ; 3. Pula uma linha extra antes de começar
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    ; 4. Chama a rotina para ler os 9 valores
    CALL LERMATRIZ    
    
    ; 5. Mostra o título "TABULEIRO:"
    LEA DX, MSG4
    MOV AH, 09h
    INT 21h
    
    ; 6. Chama a rotina para imprimir o tabuleiro preenchido
    CALL IMPRIMIRMATRIZ
    
    ; 7. Encerra o programa
    MOV AH, 4Ch
    INT 21h       
MAIN ENDP 

END MAIN