TITLE JOGO DA VELHA
; definicao das macros


FINALIZAR MACRO
    MOV AH, 4Ch
    INT 21h
ENDM

IMPRIMIR MACRO MENSAGEM
    LEA DX, MENSAGEM
    MOV AH, 09h
    INT 21h
ENDM

SALVA_TUDO MACRO
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
ENDM

RECUPERA_TUDO MACRO
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
ENDM

TITLE JOGO DA VELHA
.MODEL SMALL
.STACK 100h
.DATA

    MSG_INSTRUCOES  DB 0Dh, 0Ah, '--- INSTRUCOES ---', 0Dh, 0Ah
                    DB 'Digite LINHA (1-3) e depois COLUNA (1-3):', 0Dh, 0Ah
                    DB 'Exemplo: Linha 1, Coluna 1 = canto superior esquerdo', 0Dh, 0Ah
                    DB 0Dh, 0Ah, '$'

    MSG_MENU        DB 0Dh, 0Ah, '--- MENU PRINCIPAL ---', 0Dh, 0Ah
                    DB '1. Jogar: Dois Jogadores', 0Dh, 0Ah
                    DB '2. Jogar: Contra Computador', 0Dh, 0Ah
                    DB '3. Sair', 0Dh, 0Ah
                    DB 'Escolha uma opcao: $'

    MSG_LINHA       DB 0Dh, 0Ah, 'Digite a LINHA (1-3): $'
    MSG_COLUNA      DB 0Dh, 0Ah, 'Digite a COLUNA (1-3): $'
    MSG_VEZ_X       DB 0Dh, 0Ah, '>>> Vez do jogador X <<<', 0Dh, 0Ah, '$'
    MSG_VEZ_O       DB 0Dh, 0Ah, '>>> Vez do jogador O <<<', 0Dh, 0Ah, '$'
    MSG_VEZ_MAQUINA DB 0Dh, 0Ah, '>>> Vez do Computador <<<', 0Dh, 0Ah, '$'
    MSG_INVALIDA    DB 0Dh, 0Ah, 'Jogada invalida! Tente novamente.', 0Dh, 0Ah, '$'
    MSG_OCUPADA     DB 0Dh, 0Ah, 'Posicao ja ocupada! Tente novamente.', 0Dh, 0Ah, '$'
    MSG_VIT_X       DB 0Dh, 0Ah, 'JOGADOR X VENCEU!', 0Dh, 0Ah, '$'
    MSG_VIT_O       DB 0Dh, 0Ah, 'JOGADOR O VENCEU!', 0Dh, 0Ah, '$'
    MSG_EMPATE      DB 0Dh, 0Ah, 'EMPATE!', 0Dh, 0Ah, '$'
    NOVAMENTE       DB 0Dh,0Ah, 'Deseja jogar novamente ?', 0Dh, 0Ah
                    DB '1. SIM', 0Dh, 0Ah
                    DB '2. NAO$', 0Dh, 0Ah
    MSG_TAB         DB 0Dh, 0Ah, "TABULEIRO:", 0Dh, 0Ah, "$"
    PULA_LINHA      DB 0Dh, 0Ah, "$"
    SEP_COLUNA      DB " | $"
    SEP_LINHA       DB "---+---+---$"
    
    TABULEIRO       DB 3 DUP(3 DUP(?))
    RANDOMIZADOR    DW 3
    NUM_COLUNAS     EQU 3
    STATUS_VITORIA  DB 0

.CODE

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
COMECO:
    ; exibe instrucoes iniciais
    IMPRIMIR MSG_INSTRUCOES
    IMPRIMIR PULA_LINHA
    
MENU:
    ; exibe o menu e le a opcao
    IMPRIMIR MSG_MENU
    
    MOV AH, 01h
    INT 21h
    
    CMP AL, '1'
    JE JOGA_2
    
    CMP AL, '2'
    JE JOGA_MAQUINA
    
    CMP AL, '1'
    JB INVALIDO
    CMP AL, '3'
    JA INVALIDO
    
    JMP SAIR_JOGO
    
INVALIDO:
    IMPRIMIR MSG_INVALIDA
    JMP MENU
    
JOGA_MAQUINA:
    CALL LEITURA_MAQUINA
    JMP PERGUNTA_RESTART
    
JOGA_2:
    CALL LEITURA_2_JOG
    JMP PERGUNTA_RESTART

PERGUNTA_RESTART:
    ; pergunta se quer jogar novamente
    IMPRIMIR NOVAMENTE
    MOV AH, 01h
    INT 21h

    CMP AL, '1'
    JE COMECO
    
    CMP AL, '2'
    JE SAIR_JOGO
    
    ; se nao for 1 nem 2, pula linha e pergunta de novo
    IMPRIMIR PULA_LINHA
    JMP PERGUNTA_RESTART

SAIR_JOGO:
    FINALIZAR
    
MAIN ENDP

LEITURA_2_JOG PROC
    SALVA_TUDO
    
    ; limpa o tabuleiro preenchendo com espacos
    MOV CX, 3
    XOR BX, BX
INIC_LINHA:
    PUSH CX
    MOV CX, 3
    XOR SI, SI
INIC_COLUNA:
    MOV TABULEIRO[BX][SI], ' '
    INC SI
    LOOP INIC_COLUNA
    
    ADD BX, 3
    POP CX
    LOOP INIC_LINHA
    
    CALL IMPRIMIR_TAB
    
    ; inicia ciclo de 9 jogadas
    MOV CX, 9
    XOR DI, DI
    
CICLO_JOGO:
    INC DI
    TEST DI, 1
    JZ VEZ_JOGADOR_O
    
VEZ_JOGADOR_X:
    IMPRIMIR MSG_VEZ_X
    JMP LER_JOGADA
    
VEZ_JOGADOR_O:
    IMPRIMIR MSG_VEZ_O
    
LER_JOGADA:
    ; recebe a jogada e atualiza tela
    CALL POSICAO
    CALL IMPRIMIR_TAB
    
    ; verifica vitoria a partir da 5a rodada
    CMP DI, 4
    JLE PROXIMO_TURNO
    
    CALL VERIFICA_VITORIA
    CMP STATUS_VITORIA, 0
    JNE FIM_DO_JOGO
    
PROXIMO_TURNO:
    LOOP CICLO_JOGO
    
    ; se terminou sem vitoria eh empate
    IMPRIMIR MSG_EMPATE

FIM_DO_JOGO:
    RECUPERA_TUDO
    RET
LEITURA_2_JOG ENDP

POSICAO PROC
    SALVA_TUDO
    
INICIO_POSICAO:
    ; pede e valida a linha
    IMPRIMIR MSG_LINHA
    MOV AH, 01h
    INT 21h
    
    CMP AL, '1'
    JB ERRO_ENTRADA
    CMP AL, '3'
    JA ERRO_ENTRADA
    
    ; calcula indice da linha
    SUB AL, '1'
    MOV BL, 3
    MUL BL
    MOV BX, AX
    
    ; pede e valida a coluna
    IMPRIMIR MSG_COLUNA
    MOV AH, 01h
    INT 21h
    
    CMP AL, '1'
    JB ERRO_ENTRADA
    CMP AL, '3'
    JA ERRO_ENTRADA
    
    ; calcula indice da coluna
    SUB AL, '1'
    XOR AH, AH
    MOV SI, AX

    ; verifica se posicao esta livre
    CMP TABULEIRO[BX][SI], ' '
    JNE ERRO_OCUPADA
    
    ; marca x ou o dependendo do turno
    TEST DI, 1
    JZ MARCA_O
    
MARCA_X:
    MOV TABULEIRO[BX][SI], 'X'
    JMP FIM_POSICAO
    
MARCA_O:
    MOV TABULEIRO[BX][SI], 'O'
    JMP FIM_POSICAO

ERRO_ENTRADA:
    IMPRIMIR MSG_INVALIDA
    JMP INICIO_POSICAO
    
ERRO_OCUPADA:
    IMPRIMIR MSG_OCUPADA
    JMP INICIO_POSICAO

FIM_POSICAO:
    RECUPERA_TUDO
    RET
POSICAO ENDP

LEITURA_MAQUINA PROC
    SALVA_TUDO
    
    ; limpa o tabuleiro
    MOV CX, 3
    XOR BX, BX
INIC_LINHA_M:
    PUSH CX
    MOV CX, 3
    XOR SI, SI
INIC_COLUNA_M:
    MOV TABULEIRO[BX][SI], ' '
    INC SI
    LOOP INIC_COLUNA_M
    
    ADD BX, 3
    POP CX
    LOOP INIC_LINHA_M
    
    CALL IMPRIMIR_TAB
    
    MOV CX, 9
    XOR DI, DI
    
CICLO_MAQUINA:
    INC DI
    TEST DI, 1
    JZ VEZ_MAQUINA
    
VEZ_HUMANO_X:
    IMPRIMIR MSG_VEZ_X
    JMP ACAO_JOGO
    
VEZ_MAQUINA:
    IMPRIMIR MSG_VEZ_MAQUINA
    
ACAO_JOGO:
    CALL POSICAO_MAQUINA
    CALL IMPRIMIR_TAB
    
    CMP DI, 4
    JLE PROXIMO_TURNO_M
    
    CALL VERIFICA_VITORIA
    CMP STATUS_VITORIA, 0
    JNE FIM_JOGO_MAQUINA
    
PROXIMO_TURNO_M:
    LOOP CICLO_MAQUINA
    IMPRIMIR MSG_EMPATE

FIM_JOGO_MAQUINA:
    RECUPERA_TUDO
    RET
LEITURA_MAQUINA ENDP

POSICAO_MAQUINA PROC
    SALVA_TUDO
    
    ; verifica se e vez da maquina ou humano
    TEST DI, 1
    JZ GERA_JOGADA_MAQUINA
    
ENTRADA_JOGADOR:
    ; leitura linha usuario
    IMPRIMIR MSG_LINHA
    MOV AH, 01h
    INT 21h
    
    CMP AL, '1'
    JB ERRO_JOGADOR
    CMP AL, '3'
    JA ERRO_JOGADOR
    
    SUB AL, '1'
    MOV BL, 3
    MUL BL
    MOV BX, AX

    ; leitura coluna usuario
    IMPRIMIR MSG_COLUNA
    MOV AH, 01h
    INT 21h
    
    CMP AL, '1'
    JB ERRO_JOGADOR
    CMP AL, '3'
    JA ERRO_JOGADOR
    
    SUB AL, '1'
    XOR AH, AH
    MOV SI, AX
    JMP VERIFICA_POSICAO

GERA_JOGADA_MAQUINA:
    ; gera linha aleatoria
    MOV AX, RANDOMIZADOR
    MOV DX, 25173
    MUL DX
    ADD AX, 13849
    MOV RANDOMIZADOR, AX

    XOR DX, DX
    MOV BX, 3
    DIV BX
                    
    MOV AL, DL
    MOV BL, 3
    MUL BL
    MOV BX, AX

    ; gera coluna aleatoria
    MOV AX, RANDOMIZADOR
    MOV DX, 8121
    MUL DX
    ADD AX, 28411
    MOV RANDOMIZADOR, AX

    XOR DX, DX
    MOV CX, 3
    DIV CX
    MOV SI, DX

VERIFICA_POSICAO:
    ; verifica disponibilidade
    CMP TABULEIRO[BX][SI], ' '
    JNE POSICAO_OCUPADA
    
    TEST DI, 1
    JZ MARCA_MAQUINA_O
    
MARCA_JOGADOR_X:
    MOV TABULEIRO[BX][SI], 'X'
    JMP SAI_POSICAO_PC
    
MARCA_MAQUINA_O:
    MOV TABULEIRO[BX][SI], 'O'
    JMP SAI_POSICAO_PC
    
ERRO_JOGADOR:
    IMPRIMIR MSG_INVALIDA
    JMP ENTRADA_JOGADOR
    
POSICAO_OCUPADA:
    ; se ocupado maquina tenta de novo
    TEST DI, 1
    JZ GERA_JOGADA_MAQUINA
    IMPRIMIR MSG_OCUPADA
    JMP ENTRADA_JOGADOR

SAI_POSICAO_PC:
    RECUPERA_TUDO
    RET
POSICAO_MAQUINA ENDP

VERIFICA_VITORIA PROC
    SALVA_TUDO
    
    ; verifica linhas para jogador x
    XOR BX, BX
    MOV CH, 3
LINHA_X:
    MOV STATUS_VITORIA, 0
    XOR SI, SI
    MOV CL, 3
CONTA_X:
    CMP TABULEIRO[BX][SI], 'X'
    JNE PROXIMA_LINHA_X
    INC STATUS_VITORIA
    INC SI
    DEC CL
    JNZ CONTA_X
    CMP STATUS_VITORIA, 3
    JNE PROXIMA_LINHA_X
    JMP VITORIA_X
PROXIMA_LINHA_X:
    ADD BX, 3
    DEC CH
    JNZ LINHA_X
    
    ; verifica linhas para jogador o
    XOR BX, BX
    MOV CH, 3
LINHA_O:
    MOV STATUS_VITORIA, 0
    XOR SI, SI
    MOV CL, 3
CONTA_O:
    CMP TABULEIRO[BX][SI], 'O'
    JNE PROXIMA_LINHA_O
    INC STATUS_VITORIA
    INC SI
    DEC CL
    JNZ CONTA_O
    CMP STATUS_VITORIA, 3
    JNE PROXIMA_LINHA_O
    JMP VITORIA_O
PROXIMA_LINHA_O:
    ADD BX, 3
    DEC CH
    JNZ LINHA_O
    
    ; verifica colunas para jogador x
    XOR SI, SI
    MOV CH, 3
COLUNA_X:
    MOV STATUS_VITORIA, 0
    XOR BX, BX
    MOV CL, 3
CONTA_COLUNA_X:
    CMP TABULEIRO[BX][SI], 'X'
    JNE PROXIMA_COLUNA_X
    INC STATUS_VITORIA
    ADD BX, 3
    DEC CL
    JNZ CONTA_COLUNA_X
    CMP STATUS_VITORIA, 3
    JNE PROXIMA_COLUNA_X
    JMP VITORIA_X
PROXIMA_COLUNA_X:
    INC SI
    DEC CH
    JNZ COLUNA_X
    
    ; verifica colunas para jogador o
    XOR SI, SI
    MOV CH, 3
COLUNA_O:
    MOV STATUS_VITORIA, 0
    XOR BX, BX
    MOV CL, 3
CONTA_COLUNA_O:
    CMP TABULEIRO[BX][SI], 'O'
    JNE PROXIMA_COLUNA_O
    INC STATUS_VITORIA
    ADD BX, 3
    DEC CL
    JNZ CONTA_COLUNA_O
    CMP STATUS_VITORIA, 3
    JNE PROXIMA_COLUNA_O
    JMP VITORIA_O
PROXIMA_COLUNA_O:
    INC SI
    DEC CH
    JNZ COLUNA_O
    
    ; verifica diagonal principal x
    MOV STATUS_VITORIA, 0
    XOR BX, BX
    XOR SI, SI
    MOV CX, 3
DIAGONAL1_X:
    CMP TABULEIRO[BX][SI], 'X'
    JNE TENTA_DIAGONAL1_O
    INC STATUS_VITORIA
    ADD BX, 3
    INC SI
    DEC CX
    JNZ DIAGONAL1_X
    CMP STATUS_VITORIA, 3
    JNE TENTA_DIAGONAL1_O
    JMP VITORIA_X
    
TENTA_DIAGONAL1_O:
    ; verifica diagonal principal o
    MOV STATUS_VITORIA, 0
    XOR BX, BX
    XOR SI, SI
    MOV CX, 3
DIAGONAL1_O:
    CMP TABULEIRO[BX][SI], 'O'
    JNE TENTA_DIAGONAL2_X
    INC STATUS_VITORIA
    ADD BX, 3
    INC SI
    DEC CX
    JNZ DIAGONAL1_O
    CMP STATUS_VITORIA, 3
    JNE TENTA_DIAGONAL2_X
    JMP VITORIA_O
    
TENTA_DIAGONAL2_X:
    ; verifica diagonal secundaria x
    MOV STATUS_VITORIA, 0
    XOR BX, BX
    MOV SI, 2
    MOV CX, 3
DIAGONAL2_X:
    CMP TABULEIRO[BX][SI], 'X'
    JNE TENTA_DIAGONAL2_O
    INC STATUS_VITORIA
    ADD BX, 3
    DEC SI
    DEC CX
    JNZ DIAGONAL2_X
    CMP STATUS_VITORIA, 3
    JNE TENTA_DIAGONAL2_O
    JMP VITORIA_X
    
TENTA_DIAGONAL2_O:
    ; verifica diagonal secundaria o
    MOV STATUS_VITORIA, 0
    XOR BX, BX
    MOV SI, 2
    MOV CX, 3
DIAGONAL2_O:
    CMP TABULEIRO[BX][SI], 'O'
    JNE SEM_VITORIA
    INC STATUS_VITORIA
    ADD BX, 3
    DEC SI
    DEC CX
    JNZ DIAGONAL2_O
    CMP STATUS_VITORIA, 3
    JNE SEM_VITORIA
    JMP VITORIA_O
    
SEM_VITORIA:
    JMP SAI_VERIFICA
    
VITORIA_X:
    MOV STATUS_VITORIA, 1
    IMPRIMIR MSG_VIT_X
    JMP SAI_VERIFICA
    
VITORIA_O:
    MOV STATUS_VITORIA, 2
    IMPRIMIR MSG_VIT_O
    JMP SAI_VERIFICA

SAI_VERIFICA:
    RECUPERA_TUDO
    RET
VERIFICA_VITORIA ENDP

IMPRIMIR_TAB PROC
    SALVA_TUDO
    
    IMPRIMIR PULA_LINHA
    IMPRIMIR MSG_TAB
    
    XOR BX, BX
    XOR CX, CX
    MOV CH, 3
    
IMPRIME_GERAL:
    ; imprime espaco lateral
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    
    IMPRIMIR PULA_LINHA
    
    MOV CL, 3
    XOR SI, SI
    
IMPRIME_LINHA:
    ; imprime o x ou o ou espaco
    MOV DL, TABULEIRO[BX][SI]
    MOV AH, 02h
    INT 21h
    
    IMPRIMIR SEP_COLUNA
    
    INC SI
    DEC CL
    JNZ IMPRIME_LINHA
    
    IMPRIMIR PULA_LINHA
    IMPRIMIR SEP_LINHA
    
    ADD BX, 3
    DEC CH
    JNZ IMPRIME_GERAL
    
    RECUPERA_TUDO
    RET
IMPRIMIR_TAB ENDP

END MAIN