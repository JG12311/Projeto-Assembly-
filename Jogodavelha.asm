TITLE JOGO DA VELHA

; COMO FUNCIONA O JOGO
; O objetivo e alinhar 3 simbolos iguais X ou O em linha coluna ou diagonal
; O jogador escolhe se quer jogar contra outra pessoa ou contra o computador
; Para jogar deve se digitar a LINHA de 1 a 3 e a COLUNA de 1 a 3
; O jogo acaba quando alguem ganha ou quando o tabuleiro enche dando empate
;
; COMO FUNCIONA O CODIGO
; 1 MEMORIA DO TABULEIRO
; O tabuleiro e uma sequencia de 9 bytes na memoria
; Para achar a posicao certa o codigo multiplica a LINHA por 3 e soma a COLUNA
; Usa os registradores BX para linha e SI para coluna
;
; 2 CONTROLE DOS TURNOS
; O registrador DI conta quantas jogadas foram feitas
; O codigo testa se o numero em DI e par ou impar
; Se for impar e a vez do X e se for par e a vez do O
;
; 3 JOGADAS DO COMPUTADOR
; No modo contra a maquina o codigo usa matematica para gerar numeros
; Ele cria coordenadas aleatorias para linha e coluna
; Se a posicao criada ja estiver ocupada ele calcula outra
;
; 4 VERIFICACAO DE VITORIA
; O codigo checa manualmente todas as possibilidades de vitoria
; Ele olha as 3 linhas as 3 colunas e as 2 diagonais uma por uma
; Se encontrar 3 simbolos iguais define quem ganhou
;
; 5 DESENHO NA TELA
; Tudo foi utilizado textos definidos no .data e caracteres ASCII
; O codigo usa interrupcoes do sistema INT 21h para escrever e ler dados


; definicao das macros
FINALIZAR MACRO
    MOV AH, 4Ch     ; funcao do dos para encerrar o programa
    INT 21h
ENDM

IMPRIMIR MACRO MENSAGEM
    LEA DX, MENSAGEM ; carrega o endereco da string
    MOV AH, 09h      ; funcao de impressao
    INT 21h
ENDM

SALVA_TUDO MACRO
    PUSH AX         ; salva contexto dos registradores
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
ENDM

RECUPERA_TUDO MACRO
    POP DI          ; restaura contexto dos registradores
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

    MSG_INSTRUCOES  DB 0Dh, 0Ah, ' INSTRUCOES ', 0Dh, 0Ah
                    DB 'Digite LINHA de 1 a 3 e depois COLUNA de 1 a 3:', 0Dh, 0Ah
                    DB 'Exemplo: Linha 1 e Coluna 1 igual canto superior esquerdo', 0Dh, 0Ah
                    DB 0Dh, 0Ah, '$'

    MSG_MENU        DB 0Dh, 0Ah, ' MENU PRINCIPAL ', 0Dh, 0Ah
                    DB '1. Jogar: Dois Jogadores', 0Dh, 0Ah
                    DB '2. Jogar: Contra Computador', 0Dh, 0Ah
                    DB '3. Sair', 0Dh, 0Ah
                    DB 'Escolha uma opcao: $'

    MSG_LINHA       DB 0Dh, 0Ah, 'Digite a LINHA 1 a 3: $'
    MSG_COLUNA      DB 0Dh, 0Ah, 'Digite a COLUNA 1 a 3: $'
    MSG_VEZ_X       DB 0Dh, 0Ah, '>>> Vez do jogador X <<<', 0Dh, 0Ah, '$'
    MSG_VEZ_O       DB 0Dh, 0Ah, '>>> Vez do jogador O <<<', 0Dh, 0Ah, '$'
    MSG_VEZ_MAQUINA DB 0Dh, 0Ah, '>>> Vez do Computador <<<', 0Dh, 0Ah, '$'
    MSG_INVALIDA    DB 0Dh, 0Ah, 'Jogada invalida Tente novamente.', 0Dh, 0Ah, '$'
    MSG_OCUPADA     DB 0Dh, 0Ah, 'Posicao ja ocupada Tente novamente.', 0Dh, 0Ah, '$'
    MSG_VIT_X       DB 0Dh, 0Ah, 'JOGADOR X VENCEU', 0Dh, 0Ah, '$'
    MSG_VIT_O       DB 0Dh, 0Ah, 'JOGADOR O VENCEU', 0Dh, 0Ah, '$'
    MSG_EMPATE      DB 0Dh, 0Ah, 'EMPATE', 0Dh, 0Ah, '$'
    NOVAMENTE       DB 0Dh,0Ah, 'Deseja jogar novamente ?', 0Dh, 0Ah
                    DB '1. SIM', 0Dh, 0Ah
                    DB '2. NAO', 0Dh, 0Ah
                    DB 'Escolha uma opcao: $'
    MSG_TAB         DB 0Dh, 0Ah, "TABULEIRO:", 0Dh, 0Ah, "$"
    PULA_LINHA      DB 0Dh, 0Ah, "$"
    SEP_COLUNA      DB " | $"
    SEP_LINHA       DB "---+---+---$"
    
    TABULEIRO       DB 3 DUP(3 DUP(?))
    RANDOMIZADOR    DW 3
    NUM_COLUNAS     EQU 3
    STATUS_VITORIA  DB 0

.CODE

;entrada nenhuma inicio do programa
;saida interacao com usuario
;o que faz gerencia o menu e escolhe o modo de jogo
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
COMECO:
    ; exibe as instrucoes iniciais na tela
    IMPRIMIR MSG_INSTRUCOES
    IMPRIMIR PULA_LINHA
    
MENU:
    ; desenha o menu e captura a escolha
    IMPRIMIR MSG_MENU
    
    MOV AH, 01h
    INT 21h
    
    ; verifica qual opcao foi escolhida
    CMP AL, '1'
    JE JOGA_2       ; modo pvp
    
    CMP AL, '2'
    JE JOGA_MAQUINA ; modo contra cpu
    
    ; validacao da entrada para nao aceitar caracteres estranhos
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
    JMP PERGUNTA_RESTART ; ao fim do jogo pergunta se quer jogar de novo
    
JOGA_2:
    CALL LEITURA_2_JOG
    JMP PERGUNTA_RESTART

PERGUNTA_RESTART:
    ; menu de reinicio do jogo
    IMPRIMIR NOVAMENTE
    MOV AH, 01h
    INT 21h

    CMP AL, '1'
    JE COMECO
    
    CMP AL, '2'
    JE SAIR_JOGO
    
    IMPRIMIR PULA_LINHA
    JMP PERGUNTA_RESTART

SAIR_JOGO:
    FINALIZAR
    
MAIN ENDP

;entrada: Matriz tabuleiro definida em data
;saida: Matriz preenchida com as jogadas
;o que faz: lê as jogadas entre 2 jogadores e insere-as no tabuleiro
LEITURA_2_JOG PROC
    SALVA_TUDO
    
    ; loops aninhados para limpar o tabuleiro na memoria
    MOV CX, 3
    XOR BX, BX
INIC_LINHA:
    PUSH CX         ; salva contador da linha
    MOV CX, 3
    XOR SI, SI
INIC_COLUNA:
    MOV TABULEIRO[BX][SI], ' ' ; preenche com espaco vazio
    INC SI
    LOOP INIC_COLUNA
    
    ADD BX, 3       ; avanca para a proxima linha da matriz
    POP CX          ; recupera contador
    LOOP INIC_LINHA
    
    CALL IMPRIMIR_TAB
    
    ; inicia o loop principal de 9 jogadas
    MOV CX, 9
    XOR DI, DI      ; di sera o contador de turnos
    
CICLO_JOGO:
    INC DI
    TEST DI, 1      ; verifica se o turno e par ou impar
    JZ VEZ_JOGADOR_O
    
VEZ_JOGADOR_X:
    IMPRIMIR MSG_VEZ_X
    JMP LER_JOGADA
    
VEZ_JOGADOR_O:
    IMPRIMIR MSG_VEZ_O
    
LER_JOGADA:
    ; executa a jogada e redesenha a tela
    CALL POSICAO
    CALL IMPRIMIR_TAB
    
    ; checa vitoria somente apos 4 jogadas minimas
    CMP DI, 4
    JLE PROXIMO_TURNO
    
    CALL VITORIA
    CMP STATUS_VITORIA, 0 ; se status mudou alguem ganhou
    JNE FIM_DO_JOGO
    
PROXIMO_TURNO:
    LOOP CICLO_JOGO
    
    ; se saiu do loop sem vitoria e empate
    IMPRIMIR MSG_EMPATE

FIM_DO_JOGO:
    RECUPERA_TUDO
    RET
LEITURA_2_JOG ENDP


;entrada: input do jogador lido em LEITURA2JOG
;saida: matriz TABULEIRO preenchido com o input do jogador 
;o que faz: preenche o tabuleiro com as jogadas de X e O
POSICAO PROC
    SALVA_TUDO
    
INICIO_POSICAO:
    ; solicita e valida a linha
    IMPRIMIR MSG_LINHA
    MOV AH, 01h
    INT 21h
    
    CMP AL, '1'
    JB ERRO_ENTRADA
    CMP AL, '3'
    JA ERRO_ENTRADA
    
    ; converte caractere ascii para indice de linha
    SUB AL, '1'
    MOV BL, 3
    MUL BL
    MOV BX, AX
    
    ; solicita e valida a coluna
    IMPRIMIR MSG_COLUNA
    MOV AH, 01h
    INT 21h
    
    CMP AL, '1'
    JB ERRO_ENTRADA
    CMP AL, '3'
    JA ERRO_ENTRADA
    
    ; converte caractere ascii para indice de coluna
    SUB AL, '1'
    XOR AH, AH
    MOV SI, AX

    ; verifica colisao na matriz
    CMP TABULEIRO[BX][SI], ' '
    JNE ERRO_OCUPADA
    
    ; define o simbolo com base no turno atual
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

;entrada variaveis globais
;saida controle do jogo contra cpu
;o que faz alterna entre jogador e computador
LEITURA_MAQUINA PROC
    SALVA_TUDO
    
    ; rotina de limpeza do tabuleiro
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
    
    ; loop principal do modo vs cpu
    MOV CX, 9
    XOR DI, DI
    
CICLO_MAQUINA:
    INC DI
    TEST DI, 1
    JZ VEZ_MAQUINA ; turnos pares sao da cpu
    
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
    
    CALL VITORIA
    CMP STATUS_VITORIA, 0
    JNE FIM_JOGO_MAQUINA
    
PROXIMO_TURNO_M:
    LOOP CICLO_MAQUINA
    IMPRIMIR MSG_EMPATE

FIM_JOGO_MAQUINA:
    RECUPERA_TUDO
    RET
LEITURA_MAQUINA ENDP


;entrada: input do jogador humano ou geração aleatória da CPU
;saida: matriz TABULEIRO preenchido com X usuario ou O CPU
;o que faz: preenche o tabuleiro com jogadas do usuario ou posições geradas pela CPU
POSICAO_MAQUINA PROC
    SALVA_TUDO
    
    ; decide se a jogada e manual ou automatica
    TEST DI, 1
    JZ GERA_JOGADA_MAQUINA
    
ENTRADA_JOGADOR:
    ; bloco de leitura manual igual ao jogo pvp
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
    ; gera linha usando algoritmo linear congruente
    MOV AX, RANDOMIZADOR
    MOV DX, 25173
    MUL DX
    ADD AX, 13849
    MOV RANDOMIZADOR, AX

    XOR DX, DX
    MOV BX, 3
    DIV BX          ; resto da divisao em dx define a linha
                    
    MOV AL, DL
    MOV BL, 3
    MUL BL
    MOV BX, AX      ; linha calculada

    ; gera coluna usando constantes diferentes
    MOV AX, RANDOMIZADOR
    MOV DX, 8121
    MUL DX
    ADD AX, 28411
    MOV RANDOMIZADOR, AX

    XOR DX, DX
    MOV CX, 3
    DIV CX
    MOV SI, DX      ; coluna calculada

VERIFICA_POSICAO:
    ; verifica se esta vazio
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
    ; colisao da cpu gera nova tentativa silenciosa
    TEST DI, 1
    JZ GERA_JOGADA_MAQUINA
    IMPRIMIR MSG_OCUPADA
    JMP ENTRADA_JOGADOR

SAI_POSICAO_PC:
    RECUPERA_TUDO
    RET
POSICAO_MAQUINA ENDP


;entrada: Matriz tabuleiro com as posições jogadas preenchidas pelo procedimento anterior
;saida: winflag, o qual diz se alguem ganhou nessa rodada ou não
;o que faz: printa o quem ganhou essa rodada e retorna pro main 
VITORIA PROC
    SALVA_TUDO
    
    ; verifica as 3 linhas para o jogador X
    XOR BX, BX
    MOV CH, 3
LINHA_X:
    MOV STATUS_VITORIA, 0
    XOR SI, SI
    MOV CL, 3
CONTA_X:
    CMP TABULEIRO[BX][SI], 'X'
    JNE PROXIMA_LINHA_X
    INC STATUS_VITORIA ; conta acerto
    INC SI
    DEC CL
    JNZ CONTA_X
    CMP STATUS_VITORIA, 3 ; se 3 acertos venceu
    JNE PROXIMA_LINHA_X
    JMP VITORIA_X
PROXIMA_LINHA_X:
    ADD BX, 3       ; vai para proxima linha
    DEC CH
    JNZ LINHA_X
    
    ; verifica as 3 linhas para o jogador O
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
    
    ; verifica as 3 colunas para o jogador X
    XOR SI, SI      ; comeca na coluna 0
    MOV CH, 3
COLUNA_X:
    MOV STATUS_VITORIA, 0
    XOR BX, BX      ; comeca na linha 0
    MOV CL, 3
CONTA_COLUNA_X:
    CMP TABULEIRO[BX][SI], 'X'
    JNE PROXIMA_COLUNA_X
    INC STATUS_VITORIA
    ADD BX, 3       ; desce na matriz
    DEC CL
    JNZ CONTA_COLUNA_X
    CMP STATUS_VITORIA, 3
    JNE PROXIMA_COLUNA_X
    JMP VITORIA_X
PROXIMA_COLUNA_X:
    INC SI          ; avanca coluna
    DEC CH
    JNZ COLUNA_X
    
    ; verifica as 3 colunas para o jogador O
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
    
    ; verifica diagonal principal X
    MOV STATUS_VITORIA, 0
    XOR BX, BX
    XOR SI, SI
    MOV CX, 3
DIAGONAL1_X:
    CMP TABULEIRO[BX][SI], 'X'
    JNE TENTA_DIAGONAL1_O
    INC STATUS_VITORIA
    ADD BX, 3       ; desce e avanca
    INC SI
    DEC CX
    JNZ DIAGONAL1_X
    CMP STATUS_VITORIA, 3
    JNE TENTA_DIAGONAL1_O
    JMP VITORIA_X
    
TENTA_DIAGONAL1_O:
    ; verifica diagonal principal O
    MOV STATUS_VITORIA, 0
    XOR BX, BX
    XOR SI, SI ;zera si e bx
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
    ; verifica diagonal secundaria X
    MOV STATUS_VITORIA, 0
    XOR BX, BX
    MOV SI, 2       ; comeca na direita
    MOV CX, 3
DIAGONAL2_X:
    CMP TABULEIRO[BX][SI], 'X'
    JNE TENTA_DIAGONAL2_O
    INC STATUS_VITORIA
    ADD BX, 3
    DEC SI          ; desce e recua
    DEC CX
    JNZ DIAGONAL2_X
    CMP STATUS_VITORIA, 3
    JNE TENTA_DIAGONAL2_O
    JMP VITORIA_X
    
TENTA_DIAGONAL2_O:
    ; verifica diagonal secundaria O
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
VITORIA ENDP

;entrada matriz tabuleiro
;saida desenho do tabuleiro na tela
;o que faz imprime a grade do jogo
IMPRIMIR_TAB PROC
    SALVA_TUDO
    
    IMPRIMIR PULA_LINHA
    IMPRIMIR MSG_TAB
    
    XOR BX, BX      ; zera base da linha
    XOR CX, CX
    MOV CH, 3       ; loop das linhas
    
IMPRIME_GERAL:
    ; desenha espaco lateral
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    
    IMPRIMIR PULA_LINHA
    
    MOV CL, 3       ; loop das colunas
    XOR SI, SI
    
IMPRIME_LINHA:
    ; imprime conteudo da celula
    MOV DL, TABULEIRO[BX][SI]
    MOV AH, 02h
    INT 21h
    
    IMPRIMIR SEP_COLUNA
    
    INC SI          ; avanca indice coluna
    DEC CL
    JNZ IMPRIME_LINHA
    
    IMPRIMIR PULA_LINHA
    IMPRIMIR SEP_LINHA
    
    ADD BX, 3       ; avanca base da matriz
    DEC CH
    JNZ IMPRIME_GERAL
    
    RECUPERA_TUDO
    RET
IMPRIMIR_TAB ENDP

END MAIN