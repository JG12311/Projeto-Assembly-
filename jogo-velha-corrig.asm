.MODEL SMALL
.STACK 100h
.DATA

    MSG_INSTRUCOES  DB 0Dh, 0Ah, '--- INSTRUCOES ---', 0Dh, 0Ah
                   DB 'Digite LINHA (1-3) e depois COLUNA (1-3):', 0Dh, 0Ah
                   DB 'Exemplo: Linha 1, Coluna 1 = canto superior esquerdo', 0Dh, 0Ah
                   DB 0Dh, 0Ah, '$'

    MSGMENU         DB 0Dh, 0Ah, '--- MENU PRINCIPAL ---', 0Dh, 0Ah
                   DB '1. Jogar: Dois Jogadores', 0Dh, 0Ah
                   DB '2. Jogar: Contra Computador', 0Dh, 0Ah
                   DB '3. Sair', 0Dh, 0Ah
                   DB 'Escolha uma opcao: $'

    MSG_LINHA       DB 0Dh, 0Ah, 'Digite a LINHA (1-3): $'
    MSG_COLUNA      DB 0Dh, 0Ah, 'Digite a COLUNA (1-3): $'
    MSGVEZ_X        DB 0Dh, 0Ah, '>>> Vez do jogador X <<<', 0Dh, 0Ah, '$'
    MSGVEZ_O        DB 0Dh, 0Ah, '>>> Vez do jogador O <<<', 0Dh, 0Ah, '$'
    MSGVEZ_CPU      DB 0Dh, 0Ah, '>>> Vez do Computador <<<', 0Dh, 0Ah, '$'
    INVALIDA        DB 0Dh, 0Ah, 'Numero invalido. Tente novamente!', 0Dh, 0Ah, '$'
    MSG_INVALIDA    DB 0Dh, 0Ah, 'Jogada invalida! Tente novamente.', 0Dh, 0Ah, '$'
    MSG_OCUPADA     DB 0Dh, 0Ah, 'Posicao ja ocupada! Tente novamente.', 0Dh, 0Ah, '$'
    MSG_VITORIA_X   DB 0Dh, 0Ah, 'JOGADOR X VENCEU!', 0Dh, 0Ah, '$'
    MSG_VITORIA_O   DB 0Dh, 0Ah, 'JOGADOR O VENCEU!', 0Dh, 0Ah, '$'
    MSG_EMPATE      DB 0Dh, 0Ah, 'EMPATE!', 0Dh, 0Ah, '$'
    
    MSG4            DB 0Dh, 0Ah, "TABULEIRO:", 0Dh, 0Ah, "$"
    NOVA_LINHA      DB 0Dh, 0Ah, "$"
    SEPARADOR_COL   DB " | $"
    SEPARADOR_LIN   DB "---+---+---$"
    
    TABULEIRO       DB 3 DUP(3 DUP(?))
    
    NUM_COLUNAS     EQU 3
    
    WIN_FLAG        DB 0

.CODE

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
COMECO:
    LEA DX, MSG_INSTRUCOES
    MOV AH, 09h
    INT 21h
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
MENU:
    LEA DX, MSGMENU
    MOV AH, 09h
    INT 21h
    
    MOV AH, 01H
    INT 21h
    
    CMP AL, '1'
    JE JOGA_2
    
    CMP AL, '2'
    JE JOGA_MAQUINA
    
    CMP AL, '1'
    JB INVALIDO
    
    CMP AL, '3'
    JA INVALIDO
    
    JMP FIM
    
INVALIDO:
    MOV AH, 09H
    LEA DX, INVALIDA
    INT 21H
    JMP MENU
    
JOGA_MAQUINA:
    JMP COMECO
    
JOGA_2:
    CALL LEITURA2JOG
    JMP COMECO

FIM:
    MOV AH, 4Ch
    INT 21h
    
MAIN ENDP

LEITURA2JOG PROC
    PUSH DI
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    ; Inicializa o tabuleiro com espaços
    MOV CX, 3
    XOR BX, BX
INIT_LINHA:
    PUSH CX
    MOV CX, 3
    XOR SI, SI
INIT_COLUNA:
    MOV TABULEIRO[BX][SI], ' '
    INC SI
    LOOP INIT_COLUNA
    
    ADD BX, 3
    POP CX
    LOOP INIT_LINHA
    
    CALL IMPRIMIRTABULEIRO
    
    MOV CX, 9
    XOR DI, DI
    
TURNOS:
    INC DI
    TEST DI, 1
    JZ PAR
    
IMPAR:
    LEA DX, MSGVEZ_X
    MOV AH, 09
    INT 21h
    JMP FIM_TESTE
    
PAR:
    LEA DX, MSGVEZ_O
    MOV AH, 09
    INT 21h
    
FIM_TESTE:
    CALL POSICAO
    CALL IMPRIMIRTABULEIRO
    
    CMP DI, 4
    JLE continua_jogo
    
    CALL VITORIA
    CMP WIN_FLAG, 0
    JE continua_jogo
    JMP FIM_JOGO
    
continua_jogo:
    JMP final_loop
    
final_loop:
    LOOP TURNOS
    
    CMP WIN_FLAG, 0
    JNE FIM_JOGO
    MOV AH, 09h
    LEA DX, MSG_EMPATE
    INT 21h

FIM_JOGO:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    POP DI
    RET
LEITURA2JOG ENDP

POSICAO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
INICIO_PREENCHER:
    ; Lê LINHA
    LEA DX, MSG_LINHA
    MOV AH, 09
    INT 21h
    
    MOV AH, 01H
    INT 21H
    
    ; Valida linha (1-3)
    CMP AL, '1'
    JB ENTRADA_INVALIDA
    CMP AL, '3'
    JA ENTRADA_INVALIDA
    
    SUB AL, '1'     ; Converte para 0-2
    MOV BL, 3
    MUL BL          ; AX = linha * 3
    MOV BX, AX      ; BX = índice da linha na matriz
    
    ; Lê COLUNA
    LEA DX, MSG_COLUNA
    MOV AH, 09
    INT 21h
    
    MOV AH, 01H
    INT 21H
    
    ; Valida coluna (1-3)
    CMP AL, '1'
    JB ENTRADA_INVALIDA
    CMP AL, '3'
    JA ENTRADA_INVALIDA
    
    SUB AL, '1'     ; Converte para 0-2
    XOR AH, AH
    MOV SI, AX      ; SI = índice da coluna
    
    ; Verifica se posição está ocupada
    CMP TABULEIRO[BX][SI], ' '
    JNE OCUPADA
    
    ; Verifica vez do jogador
    TEST DI, 1
    JZ PAR_PREENCHER
    
    MOV TABULEIRO[BX][SI], 'X'
    JMP ATUALIZA_TELA
    
PAR_PREENCHER:
    MOV TABULEIRO[BX][SI], 'O'
    
ATUALIZA_TELA:
    JMP FIM_PREENCHER
    
ENTRADA_INVALIDA:
    LEA DX, MSG_INVALIDA
    MOV AH, 09h
    INT 21h
    JMP INICIO_PREENCHER
    
OCUPADA:
    LEA DX, MSG_OCUPADA
    MOV AH, 09h
    INT 21h
    JMP INICIO_PREENCHER

FIM_PREENCHER:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
POSICAO ENDP

VITORIA PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    XOR BX, BX
    MOV CH, 3
    
checa_linha_x:
    MOV WIN_FLAG, 0
    XOR SI, SI
    MOV CL, 3
conta_x_linha:
    CMP TABULEIRO[BX][SI], 'X'
    JNE prox_linha_x
    INC WIN_FLAG
    INC SI
    DEC CL
    JNZ conta_x_linha
    CMP WIN_FLAG, 3
    JNE skip_vx_1
    JMP VICTORY_X
skip_vx_1:
prox_linha_x:
    ADD BX, 3
    DEC CH
    JNZ checa_linha_x
    
    XOR BX, BX
    MOV CH, 3
checa_linha_o:
    MOV WIN_FLAG, 0
    XOR SI, SI
    MOV CL, 3
conta_o_linha:
    CMP TABULEIRO[BX][SI], 'O'
    JNE prox_linha_o
    INC WIN_FLAG
    INC SI
    DEC CL
    JNZ conta_o_linha
    CMP WIN_FLAG, 3
    JNE skip_vo_1
    JMP VICTORY_O
skip_vo_1:
prox_linha_o:
    ADD BX, 3
    DEC CH
    JNZ checa_linha_o
    
    XOR SI, SI
    MOV CH, 3
checa_coluna_x:
    MOV WIN_FLAG, 0
    XOR BX, BX
    MOV CL, 3
conta_x_coluna:
    CMP TABULEIRO[BX][SI], 'X'
    JNE prox_coluna_x
    INC WIN_FLAG
    ADD BX, 3
    DEC CL
    JNZ conta_x_coluna
    CMP WIN_FLAG, 3
    JNE skip_vx_2
    JMP VICTORY_X
skip_vx_2:
prox_coluna_x:
    INC SI
    DEC CH
    JNZ checa_coluna_x
    
    XOR SI, SI
    MOV CH, 3
checa_coluna_o:
    MOV WIN_FLAG, 0
    XOR BX, BX
    MOV CL, 3
conta_o_coluna:
    CMP TABULEIRO[BX][SI], 'O'
    JNE prox_coluna_o
    INC WIN_FLAG
    ADD BX, 3
    DEC CL
    JNZ conta_o_coluna
    CMP WIN_FLAG, 3
    JNE skip_vo_2
    JMP VICTORY_O
skip_vo_2:
prox_coluna_o:
    INC SI
    DEC CH
    JNZ checa_coluna_o
    
    MOV WIN_FLAG, 0
    XOR BX, BX
    XOR SI, SI
    MOV CX, 3
checa_diag1_x:
    CMP TABULEIRO[BX][SI], 'X'
    JNE checa_diag1_o
    INC WIN_FLAG
    ADD BX, 3
    INC SI
    DEC CX
    JNZ checa_diag1_x
    CMP WIN_FLAG, 3
    JNE skip_vx_3
    JMP VICTORY_X
skip_vx_3:
    
checa_diag1_o:
    MOV WIN_FLAG, 0
    XOR BX, BX
    XOR SI, SI
    MOV CX, 3
conta_o_diag1:
    CMP TABULEIRO[BX][SI], 'O'
    JNE checa_diag2_x
    INC WIN_FLAG
    ADD BX, 3
    INC SI
    DEC CX
    JNZ conta_o_diag1
    CMP WIN_FLAG, 3
    JNE skip_vo_3
    JMP VICTORY_O
skip_vo_3:
    
checa_diag2_x:
    MOV WIN_FLAG, 0
    XOR BX, BX
    MOV SI, 2
    MOV CX, 3
conta_x_diag2:
    CMP TABULEIRO[BX][SI], 'X'
    JNE checa_diag2_o
    INC WIN_FLAG
    ADD BX, 3
    DEC SI
    DEC CX
    JNZ conta_x_diag2
    CMP WIN_FLAG, 3
    JNE skip_vx_4
    JMP VICTORY_X
skip_vx_4:
    
checa_diag2_o:
    MOV WIN_FLAG, 0
    XOR BX, BX
    MOV SI, 2
    MOV CX, 3
conta_o_diag2:
    CMP TABULEIRO[BX][SI], 'O'
    JNE FIM_VERIFICACAO
    INC WIN_FLAG
    ADD BX, 3
    DEC SI
    DEC CX
    JNZ conta_o_diag2
    CMP WIN_FLAG, 3
    JNE skip_vo_4
    JMP VICTORY_O
skip_vo_4:
    
FIM_VERIFICACAO:
    JMP FIMVIC
    
VICTORY_X:
    MOV WIN_FLAG, 1
    MOV AH, 09H
    LEA DX, MSG_VITORIA_X
    INT 21h
    JMP FIMVIC
    
VICTORY_O:
    MOV WIN_FLAG, 2
    MOV AH, 09H
    LEA DX, MSG_VITORIA_O
    INT 21h
    JMP FIMVIC

FIMVIC:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
VITORIA ENDP

IMPRIMIRTABULEIRO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    LEA DX, MSG4
    MOV AH, 09h
    INT 21h
    
    XOR BX, BX
    XOR CX, CX
    MOV CH, 3
    
PRINTT_COLUNA:
    MOV DL, ' '
    MOV AH, 02h
    INT 21H
    
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    MOV CL, 3
    XOR SI, SI
    
PRINTT_LINHA:
    MOV DL, TABULEIRO[BX][SI]
    MOV AH, 02h
    INT 21h
    
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h
    
    INC SI
    DEC CL
    JNZ PRINTT_LINHA
    
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h
    
    LEA DX, SEPARADOR_LIN
    MOV AH, 09h
    INT 21h
    
    ADD BX, 3
    DEC CH
    JNZ PRINTT_COLUNA
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIRTABULEIRO ENDP

END MAIN
