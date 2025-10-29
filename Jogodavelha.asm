.MODEL SMALL
.STACK 100h
.DATA
    MSGMENU         DB 0Dh, 0Ah, '--- MENU PRINCIPAL ---', 0Dh, 0Ah
                    DB '1. Jogar: Dois Jogadores', 0Dh, 0Ah
                    DB '2. Jogar: Contra Computador', 0Dh, 0Ah
                    DB '3. Instrucoes', 0Dh, 0Ah
                    DB '4. Sair', 0Dh, 0Ah
                    DB 'Escolha uma opcao: $' ,0Dh, 0Ah

    ; === INSTRUÇÕES DO JOGO ===
    MSG_INSTRUCOES  DB 0Dh, 0Ah, '--- INSTRUCOES ---', 0Dh, 0Ah
                    DB 'Use o teclado numerico (1-9):', 0Dh, 0Ah
                    DB ' 1 | 2 | 3 ', 0Dh, 0Ah
                    DB '-----------', 0Dh, 0Ah
                    DB ' 4 | 5 | 6 ', 0Dh, 0Ah
                    DB '-----------', 0Dh, 0Ah
                    DB ' 7 | 8 | 9 ', 0Dh, 0Ah
                    DB 'Pressione qualquer tecla...', '$'

    ; === PROMPTS JOGADA E INDICAÇÃO DE VEZ ===
    MSG_JOGADA      DB 0Dh, 0Ah, 'Digite a posicao (1-9): $'
    MSG_VEZ_X       DB 0Dh, 0Ah, '>>> Vez do jogador X <<<', 0Dh, 0Ah, '$'
    MSG_VEZ_O       DB 0Dh, 0Ah, '>>> Vez do jogador O <<<', 0Dh, 0Ah, '$'
    MSG_VEZ_CPU     DB 0Dh, 0Ah, '>>> Vez do Computador <<<', 0Dh, 0Ah, '$'

    ; === MENSAGENS DE ERRO E FIM DE JOGO ===
    MSG_INVALIDA    DB 0Dh, 0Ah, 'Jogada invalida! Tente novamente.', 0Dh, 0Ah, '$'
    MSG_OCUPADA     DB 0Dh, 0Ah, 'Posicao ja ocupada!', 0Dh, 0Ah, '$'
    MSG_VITORIA_X   DB 0Dh, 0Ah, 'JOGADOR X VENCEU!', 0Dh, 0Ah, '$'
    MSG_VITORIA_O   DB 0Dh, 0Ah, 'JOGADOR O VENCEU!', 0Dh, 0Ah, '$'
    MSG_EMPATE      DB 0Dh, 0Ah, 'EMPATE!', 0Dh, 0Ah, '$'
    
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
    
    ; Constantes para dimensões
    NUM_COLUNAS EQU 3
    
.CODE
; MAIN - Programa Principal
MAIN PROC
    MOV AX, @DATA   
    MOV DS, AX
    
    ; 1. Mostra a mensagem de boas-vindas
    LEA DX, MSGMENU
    MOV AH, 09h
    INT 21h
    
    ; 2. Mostra o tabuleiro de exemplo (1-9)
    CALL IMPRIMIREXEMPLO
    
    ; 3. Pula uma linha extra
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    ; 4. Lê os 9 valores
    CALL LERMATRIZ    
    
    ; 5. Mostra o título "TABULEIRO:"
    LEA DX, MSG4
    MOV AH, 09h
    INT 21h
    
    ; 6. Imprime o tabuleiro preenchido
    CALL IMPRIMIRMATRIZ
    
    ; 7. Encerra o programa
    MOV AH, 4Ch
    INT 21h       
MAIN ENDP 


LERMATRIZ PROC
;entrada: nenhuma
;saida: matriz 3x3 
;o que faz: lê uma matriz de 3x3 
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA BX, TABULEIRO; BX = endereço base do tabuleiro
    MOV CX, 9; Vamos ler 9 valores (3x3)
    MOV SI, 0; SI = offset/índice (começa em 0)

LOOP_LEITURA:
    ; Mostra a MSG3, para pedir a entrada
    MOV AH, 09h
    LEA DX, MSG_JOGADA
    INT 21h

    ; Lê o caractere (X ou O)
    MOV AH, 01h
    INT 21h
    
    ; Guarda o caractere na matriz usando [BX][SI]
    ; [BX][SI] = [BX+SI] = endereço_base + offset
    MOV [BX][SI], AL; Armazena na posição atual
    INC SI; Incrementa o offset/índice
    
    ; Pula a linha
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h

    LOOP LOOP_LEITURA; Repete 9 vezes

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
LERMATRIZ ENDP

IMPRIMIRMATRIZ PROC  
;entrada: matriz 3x3 lida em LERMATRIZ
;saida: impressão da matriz 3x3
;o que faz: imprime uma matriz 3x3

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA BX, TABULEIRO    ; BX = endereço base do tabuleiro
    MOV CX, 3            ; CX = contador de LINHAS (3 linhas)
    MOV SI, 0            ; SI = offset/índice (começa em 0)
    
PRINT_LINHA:
    ; === Imprime a linha no formato: [char] | [char] | [char] ===
    
    ; Primeiro caractere da linha
    MOV DL, [BX][SI]     ; Lê usando [BX][SI]
    MOV AH, 02h
    INT 21h
    INC SI               ; Próxima coluna
    
    ; Separador " | "
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    ; Segundo caractere da linha
    MOV DL, [BX][SI]     ; Lê usando [BX][SI]
    MOV AH, 02h
    INT 21h
    INC SI               ; Próxima coluna
    
    ; Separador " | "
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    ; Terceiro caractere da linha
    MOV DL, [BX][SI]     ; Lê usando [BX][SI]
    MOV AH, 02h
    INT 21h
    INC SI               ; Próxima linha (SI agora aponta para início da próxima linha)
    
    ; Pula para a próxima linha (CR/LF)
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    ; Verifica se é a última linha
    CMP CX, 1
    JE FIM_PRINT_LOOP
    
    ; Imprime a linha divisória "---+---+---"
    LEA DX, SEPARADOR_LIN
    MOV AH, 09h
    INT 21h
    
    ; Pula para a próxima linha (CR/LF)
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
FIM_PRINT_LOOP:
    LOOP PRINT_LINHA     ; Decrementa CX e repete
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIRMATRIZ ENDP

IMPRIMIREXEMPLO PROC
;entrada: matriz definida em data 
;saida: matriz de exemplo pra ser utilizada no programa
;o que faz: printa um tabuleiro de exemplo para orientar os jogadores

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA BX, EXEMPLO_TAB  ; BX = endereço base do exemplo
    MOV CX, 3            ; CX = contador de LINHAS (3 linhas)
    MOV SI, 0            ; SI = offset/índice (começa em 0)
    
PRINT_EX_LINHA:
   
    
    ; Primeiro caractere
    MOV DL, [BX][SI]     ; Lê usando [BX][SI]
    MOV AH, 02h
    INT 21h
    INC SI
    
    
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    ; Segundo caractere
    MOV DL, [BX][SI]     ; Lê usando [BX][SI]
    MOV AH, 02h
    INT 21h
    INC SI
    
    ; Separador " | "
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    ; Terceiro caractere
    MOV DL, [BX][SI]     ; Lê usando [BX][SI]
    MOV AH, 02h
    INT 21h
    INC SI
    
    ; Pula para a próxima linha
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    ; Verifica se é a última linha
    CMP CX, 1
    JE FIM_EX_LOOP
    
    ; Imprime a linha divisória
    LEA DX, SEPARADOR_LIN
    MOV AH, 09h
    INT 21h
    
    ; Pula para a próxima linha
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
FIM_EX_LOOP:
    LOOP PRINT_EX_LINHA
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIREXEMPLO ENDP
END MAIN