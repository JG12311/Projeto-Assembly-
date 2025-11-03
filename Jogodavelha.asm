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

    ;Matriz exemplo
    matriz_exemplo db '1','2','3'
                   db '4','5','6'
                   db '7','8','9'
    
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
    
    ;Lê um caracter e coloca em al
    MOV AH,01H
    INT 21h

     ;6. Imprime o tabuleiro preenchido
    CALL IMPRIMIRMATRIZ

    ;compara AL com esses valores pra saber pra onde ir no programa
    CMP AL,'1'
    JE JOGA_2
    ;CMP AL,2
    ;JE JOGA_MAQUINA
    JMP FIM

   
JOGA_MAQUINA:
    ;CALL LEITURA_MAQUINA
    

JOGA_2:
    CALL LEITURA2JOG

FIM:

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

    MOV CX,9; vezes totais so como teste jão

    XOR BX,BX;zera ax

TURNOS:
    INC BX  
    TEST BX, 1      ; Testa o último bit de AX
    JZ PAR       ; PULA SE FOR ZERO (se ZF=1). Ou seja, se for PAR.

    IMPAR:
    LEA DX,MSGVEZ_X
    MOV AH,09 
    INT 21h;PRINTA MSGVEZ_X
    JMP FIM_TESTE

    
    PAR:
    LEA DX,MSGVEZ_O
    MOV AH,09 
    INT 21h;PRINTA MSGVEZ_O

    FIM_TESTE:
    CALL POSICAO;chama o procedimento posicao

    loop TURNOS

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
    INT 21h;printa MSG_JOGADA

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

    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
POSICAO ENDP 

IMPRIMIRMATRIZ PROC  
;entrada: matriz definid em data
;saida: impressão da matriz 3x3
;o que faz: imprime uma matriz 3x3

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    ; Imprime nova linha
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h

    ; Mostra o título "TABULEIRO:"
    LEA DX, MSG4
    MOV AH, 09h
    INT 21h

    XOR BX,BX;Indice de linha

    XOR CX,CX
    MOV CH,3; contador de COLUNAS
PRINT_COLUNA:
   ;Imprime ' '
    MOV DL,' '
    MOV AH,02h
    INT 21H

    ; Imprime nova linha
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h

    MOV CL, 3; CX = contador de LINHAS (3 linhas)
    XOR SI,SI; SI = offset/índice (começa em 0)
PRINT_LINHA:
    ; === Imprime a linha no formato: [char] | [char] | [char] ===
    
    ; Primeiro caractere da linha
    MOV DL, matriz_exemplo [BX][SI]     ; Lê usando [BX][SI]
    MOV AH, 02h
    INT 21h        
    
    ; Separador " | "
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    ;+1 em si 
    INC SI

    ;se diferente de 0 jumpa
    DEC CL
    JNZ PRINT_LINHA


    ; Imprime nova linha
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    ; Imprime a linha divisória "---+---+---"
    LEA DX, SEPARADOR_LIN
    MOV AH, 09h
    INT 21h

    ;pula pra proxima linha 
    ADD BX,3


    ;se ch diferente de 0 jumpa pra print_coluna
    DEC CH
    JNZ PRINT_COLUNA
    
FIM_PRINT_LOOP:
       
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIRMATRIZ ENDP


END MAIN