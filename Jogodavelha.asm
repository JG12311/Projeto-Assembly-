.MODEL SMALL
.STACK 100h
.DATA

     MSG_INSTRUCOES  DB 0Dh, 0Ah, '--- INSTRUCOES ---', 0Dh, 0Ah
                    DB 'Use o teclado numerico (1-9) para escolhar sua posicao:', 0Dh, 0Ah
                    DB ' 1 | 2 | 3 ', 0Dh, 0Ah
                    DB '-----------', 0Dh, 0Ah
                    DB ' 4 | 5 | 6 ', 0Dh, 0Ah
                    DB '-----------', 0Dh, 0Ah
                    DB ' 7 | 8 | 9 $', 0Dh, 0Ah

    MSGMENU         DB 0Dh, 0Ah, '--- MENU PRINCIPAL ---', 0Dh, 0Ah
                    DB '1. Jogar: Dois Jogadores', 0Dh, 0Ah
                    DB '2. Jogar: Contra Computador', 0Dh, 0Ah
                    DB '3. Sair', 0Dh, 0Ah
                    DB 'Escolha uma opcao: $' ,0Dh, 0Ah

    ; === PROMPTS JOGADA E INDICAÇÃO DE VEZ ===
    MSG_JOGADA      DB 0Dh, 0Ah, 'Digite a posicao (1-9): $'
    MSGVEZ_X       DB 0Dh, 0Ah, '>>> Vez do jogador X <<<', 0Dh, 0Ah, '$'
    MSGVEZ_O       DB 0Dh, 0Ah, '>>> Vez do jogador O <<<', 0Dh, 0Ah, '$'
    MSGVEZ_CPU     DB 0Dh, 0Ah, '>>> Vez do Computador <<<', 0Dh, 0Ah, '$'

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
    
    ; Tabuleiro do Jogo (vazio)
    TABULEIRO DB 3 DUP(3 DUP(?)) 
    
    ; Constantes para dimensões
    NUM_COLUNAS EQU 3
    
.CODE
; MAIN - Programa Principal
MAIN PROC
    MOV AX, @DATA   
    MOV DS, AX
    
    LEA DX, MSG_INSTRUCOES
    MOV AH, 09h
    INT 21h; printa msg_instrucoes
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h; printa nova_linha
    LEA DX, MSGMENU
    MOV AH, 09h
    INT 21h; printa msgmenu

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


LEITURA2JOG PROC
;entrada: nenhuma
;saida: matriz 3x3 
;o que faz: lê uma matriz de 3x3 
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV AX, 1     
    TEST AX, 1      ; Testa o último bit de AX
    JZ PAR       ; PULA SE FOR ZERO (se ZF=1). Ou seja, se for PAR.
    IMPAR:
    LEA DX,MSGVEZ_X
    MOV AH,09 
    INT 21h
    JMP FIM_TESTE

    PAR:
    LEA DX,MSGVEZ_O
    MOV AH,09 
    INT 21h

    FIM_TESTE:
    ; ... continua o programa ...



    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
LEITURA2JOG ENDP

POSICAO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA DX,MSG_JOGADA
    MOV AH,09
    INT 21;printa MSG_JOGADA

    MOV AH,01H
    INT 21H;Lê o caracter e coloca em al
    CMP AL,'1'
    JE OCUPADA
    CMP AL,'2'
    JE OCUPADA
    CMP AL,'3'
    JE OCUPADA
    CMP AL,'4'
    JE OCUPADA
    CMP AL,'5'
    JE OCUPADA
    CMP AL,'6'
    JE OCUPADA
    CMP AL,'7'
    JE OCUPADA
    CMP AL,'8'
    JE OCUPADA
    CMP AL,'9'
    JE OCUPADA

    OCUPADA:
    LEA DX,MSG_OCUPADA
    MOV AH,09
    INT 21

    MOV AH
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
POSICAO ENDP 

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


END MAIN