TITLE JOGO DA VELHA
; Definição da Macro
FINALIZAR MACRO
    MOV AH, 4Ch
    INT 21h
ENDM
TITLE JOGO DA VELHA
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
    NOVAMENTE       DB 0Dh,0Ah, 'Deseja jogar novamente ?', 0Dh, 0Ah
                    DB '1. SIM', 0Dh, 0Ah
                    DB '2. NAO$', 0Dh, 0Ah
    MSG4            DB 0Dh, 0Ah, "TABULEIRO:", 0Dh, 0Ah, "$"
    NOVA_LINHA      DB 0Dh, 0Ah, "$"
    SEPARADOR_COL   DB " | $"
    SEPARADOR_LIN   DB "---+---+---$"
    
    TABULEIRO       DB 3 DUP(3 DUP(?))

    RANDOMIZADOR    DW 3
    
    NUM_COLUNAS     EQU 3
    
    WIN_FLAG        DB 0

.CODE

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX;inicia as variaveis em data
    
COMECO:
    LEA DX, MSG_INSTRUCOES
    MOV AH, 09h
    INT 21h; printa as instruções do jogo
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h; printa uma nova linha
    
MENU:
    LEA DX, MSGMENU
    MOV AH, 09h
    INT 21h; printa o menu principal
    
    MOV AH, 01H
    INT 21h; pede e lê o input do jogador para iniciar o jogo ou sair dele
    
    CMP AL, '1'
    JE JOGA_2; se for 1, vai para o modo 2 jogadores
    
    CMP AL, '2'
    JE JOGA_MAQUINA; se for 2, vai para o modo contra o computador
    
    CMP AL, '1'
    JB INVALIDO; se for menor que 1, entrada inválida

    CMP AL, '3'
    JA INVALIDO; se for maior que 3, entrada inválida
    
    JMP FIM; opção 3: sair do jogo
    
INVALIDO:
    MOV AH, 09H
    LEA DX, INVALIDA
    INT 21H; printa mensagem de entrada inválida
    JMP MENU; volta para o menu
    
JOGA_MAQUINA:
    CALL LEITURA_MAQUINA; chama a função para jogar contra a máquina

    LEA DX, NOVAMENTE
    MOV AH, 09h
    INT 21h; printa o menu principal

    MOV AH, 01H
    INT 21h; pede e lê o input do jogador para iniciar o jogo ou sair dele

    CMP AL,'1'
    JE COMECO;se o jogador quiser continuar retorna pro começo

    CMP AL,'2'
    JE FIM;se não sai do programa

    JMP COMECO; volta para o começo
    
JOGA_2:
    CALL LEITURA2JOG; chama a função para jogar com 2 jogadores

    LEA DX, NOVAMENTE
    MOV AH, 09h
    INT 21h; printa o menu principal

    MOV AH, 01H
    INT 21h; pede e lê o input do jogador para iniciar o jogo ou sair dele

    CMP AL,'1'
    JE COMECO;se o jogador quiser continuar retorna pro começo

    CMP AL,'2'
    JE FIM;se não sai do programa

    JMP COMECO; volta para o começo

FIM:
    FINALIZAR ; <--- USO DA MACRO AQUI
    
MAIN ENDP

LEITURA2JOG PROC
;entrada: Matriz tabuleiro definida em data
;saida: Matriz preenchida com as jogadas
;o que faz: lê as jogadas entre 2 jogadores e insere-as no tabuleiro
    PUSH DI
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva os resgistradores 
    
    ; Inicializa o tabuleiro com espaços
    MOV CX, 3; contador de linhas
    XOR BX, BX; zera o índice de linha
INIT_LINHA:
    PUSH CX; salva o contador de linhas
    MOV CX, 3; contador de colunas
    XOR SI, SI; zera o índice de coluna
INIT_COLUNA:
    MOV TABULEIRO[BX][SI], ' '; preenche a posição com espaço
    INC SI; avança para a próxima coluna
    LOOP INIT_COLUNA; repete para todas as colunas
    
    ADD BX, 3; avança para a próxima linha
    POP CX; recupera o contador de linhas
    LOOP INIT_LINHA; repete para todas as linhas
    
    CALL IMPRIMIRTABULEIRO; printa o tabuleiro vazio
    
    MOV CX, 9; contador de turnos (máximo 9 jogadas)
    XOR DI, DI; zera o contador de jogadas
    
TURNOS:
    INC DI; incrementa o contador de jogadas
    TEST DI, 1; testa se o número é ímpar ou par
    JZ PAR; se for par (bit 0 = 0), vai para PAR
    
IMPAR:
    LEA DX, MSGVEZ_X
    MOV AH, 09
    INT 21h; printa mensagem da vez do jogador X
    JMP FIM_TESTE
    
PAR:
    LEA DX, MSGVEZ_O
    MOV AH, 09
    INT 21h; printa mensagem da vez do jogador O
    
FIM_TESTE:
    CALL POSICAO; lê a posição da jogada
    CALL IMPRIMIRTABULEIRO; printa o tabuleiro atualizado
    
    CMP DI, 4
    JLE continua_jogo; se houver menos de 5 jogadas, não verifica vitória ainda
    
    CALL VITORIA; verifica se alguém ganhou
    CMP WIN_FLAG, 0
    JE continua_jogo; se ninguém ganhou, continua o jogo
    JMP FIM_JOGO; se alguém ganhou, termina o jogo
    
continua_jogo:
    JMP final_loop
    
final_loop:
    LOOP TURNOS; repete para o próximo turno
    
    CMP WIN_FLAG, 0
    JNE FIM_JOGO; se alguém ganhou, termina o jogo
    MOV AH, 09h
    LEA DX, MSG_EMPATE
    INT 21h; se acabaram as jogadas sem vencedor, printa empate

FIM_JOGO:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    POP DI; recupera os registradores 
    RET; retorna da função
LEITURA2JOG ENDP

POSICAO PROC
;entrada: input do jogador lido em LEITURA2JOG
;saida: matriz TABULEIRO preenchido com o input do jogador 
;o que faz: preenche o tabuleiro com as jogadas de X e O
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva os resgistradores 
    
INICIO_PREENCHER:
    ; Lê LINHA
    LEA DX, MSG_LINHA
    MOV AH, 09
    INT 21h; printa mensagem para digitar a linha
    
    MOV AH, 01H
    INT 21H; lê o caractere da linha
    
    ; Valida linha (1-3)
    CMP AL, '1'
    JB ENTRADA_INVALIDA; se for menor que 1, entrada inválida
    CMP AL, '3'
    JA ENTRADA_INVALIDA; se for maior que 3, entrada inválida
    
    SUB AL, '1'; converte de '1'-'3' para 0-2
    MOV BL, 3
    MUL BL; AX = linha * 3 (calcula o offset da linha)
    MOV BX, AX; BX = índice da linha na matriz
    
    ; Lê COLUNA
    LEA DX, MSG_COLUNA
    MOV AH, 09
    INT 21h; printa mensagem para digitar a coluna
    
    MOV AH, 01H
    INT 21H; lê o caractere da coluna
    
    ; Valida coluna (1-3)
    CMP AL, '1'
    JB ENTRADA_INVALIDA; se for menor que 1, entrada inválida
    CMP AL, '3'
    JA ENTRADA_INVALIDA; se for maior que 3, entrada inválida
    
    SUB AL, '1'; converte de '1'-'3' para 0-2
    XOR AH, AH
    MOV SI, AX; SI = índice da coluna

VERIFICA_OCUPACAO:
    ; Verifica se posição está ocupada
    CMP TABULEIRO[BX][SI], ' '
    JNE OCUPADA; se não estiver vazia, posição ocupada
    
    ; Verifica vez do jogador
    TEST DI, 1
    JZ MARCA_O
    
MARCA_X:
    MOV TABULEIRO[BX][SI], 'X'; jogador 1 marca X
    JMP FIM_PREENCHER
    
MARCA_O:
    MOV TABULEIRO[BX][SI], 'O'; jogador 2 marca O
    JMP FIM_PREENCHER

ENTRADA_INVALIDA:
    LEA DX, MSG_INVALIDA
    MOV AH, 09h
    INT 21h; printa mensagem de entrada inválida
    JMP INICIO_PREENCHER; pede novamente a entrada
    
OCUPADA:
    LEA DX, MSG_OCUPADA
    MOV AH, 09h
    INT 21h; printa mensagem de posição ocupada
    JMP INICIO_PREENCHER; pede novamente a entrada

FIM_PREENCHER:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX; recupera os registradores 
    RET; retorna da função
POSICAO ENDP

LEITURA_MAQUINA PROC
;entrada: Matriz tabuleiro definida em data
;saida: Matriz preenchida com as jogadas (humano vs CPU)
;o que faz: lê as jogadas entre jogador e computador e insere-as no tabuleiro
    PUSH DI
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva os resgistradores 
    
    ; Inicializa o tabuleiro com espaços
    MOV CX, 3; contador de linhas
    XOR BX, BX; zera o índice de linha
INIT_LINHA_MAQUINA:
    PUSH CX; salva o contador de linhas
    MOV CX, 3; contador de colunas
    XOR SI, SI; zera o índice de coluna
INIT_COLUNA_MAQUINA:
    MOV TABULEIRO[BX][SI], ' '; preenche a posição com espaço
    INC SI; avança para a próxima coluna
    LOOP INIT_COLUNA_MAQUINA; repete para todas as colunas
    
    ADD BX, 3; avança para a próxima linha
    POP CX; recupera o contador de linhas
    LOOP INIT_LINHA_MAQUINA; repete para todas as linhas
    
    CALL IMPRIMIRTABULEIRO; printa o tabuleiro vazio
    
    MOV CX, 9; contador de turnos (máximo 9 jogadas)
    XOR DI, DI; zera o contador de jogadas
    
TURNOS_MAQUINA:
    INC DI; incrementa o contador de jogadas
    TEST DI, 1; testa se o número é ímpar ou par
    JZ VEZ_O_MAQUINA; se for par (bit 0 = 0), vai para VEZ_O_MAQUINA
    
VEZ_X_MAQUINA:
    LEA DX, MSGVEZ_X
    MOV AH, 09
    INT 21h; printa mensagem da vez do jogador X (humano)
    JMP CONTINUA_TURNO_MAQUINA
    
VEZ_O_MAQUINA:
    LEA DX, MSGVEZ_CPU
    MOV AH, 09
    INT 21h; printa mensagem da vez do Computador
    
CONTINUA_TURNO_MAQUINA:
    CALL POSICAO_PC; lê a posição da jogada (humano ou CPU)
    CALL IMPRIMIRTABULEIRO; printa o tabuleiro atualizado
    
    CMP DI, 4
    JLE NAO_VERIFICA_VITORIA_MAQUINA; se houver menos de 5 jogadas, não verifica vitória ainda
    
    CALL VITORIA; verifica se alguém ganhou
    CMP WIN_FLAG, 0
    JE NAO_VERIFICA_VITORIA_MAQUINA; se ninguém ganhou, continua o jogo
    JMP TERMINA_JOGO_MAQUINA; se alguém ganhou, termina o jogo
    
NAO_VERIFICA_VITORIA_MAQUINA:
    LOOP TURNOS_MAQUINA; repete para o próximo turno
    
    CMP WIN_FLAG, 0
    JNE TERMINA_JOGO_MAQUINA; se alguém ganhou, termina o jogo
    MOV AH, 09h
    LEA DX, MSG_EMPATE
    INT 21h; se acabaram as jogadas sem vencedor, printa empate

TERMINA_JOGO_MAQUINA:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    POP DI; recupera os registradores 
    RET; retorna da função
LEITURA_MAQUINA ENDP

POSICAO_PC PROC
;entrada: input do jogador humano ou geração aleatória da CPU
;saida: matriz TABULEIRO preenchido com X (humano) ou O (CPU)
;o que faz: preenche o tabuleiro com jogadas do humano ou posições geradas pela CPU
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva os resgistradores 
    
    TEST DI,1
    JZ JOGADA_CPU; se for par, vai para jogada do CPU
    
JOGADA_HUMANO:
    ; Lê LINHA
    LEA DX, MSG_LINHA
    MOV AH, 09
    INT 21h; printa mensagem para digitar a linha
    
    MOV AH, 01H
    INT 21H; lê o caractere da linha
    
    ; Valida linha (1-3)
    CMP AL, '1'
    JB INVALIDA_HUMANO; se for menor que 1, entrada inválida
    CMP AL, '3'
    JA INVALIDA_HUMANO; se for maior que 3, entrada inválida
    
    SUB AL, '1'; converte de '1'-'3' para 0-2
    MOV BL, 3
    MUL BL; AX = linha * 3 (calcula o offset da linha)
    MOV BX, AX; BX = índice da linha na matriz

    ; Lê COLUNA
    LEA DX, MSG_COLUNA
    MOV AH, 09
    INT 21h; printa mensagem para digitar a coluna
    
    MOV AH, 01H
    INT 21H; lê o caractere da coluna
    
    ; Valida coluna (1-3)
    CMP AL, '1'
    JB INVALIDA_HUMANO; se for menor que 1, entrada inválida
    CMP AL, '3'
    JA INVALIDA_HUMANO; se for maior que 3, entrada inválida
    
    SUB AL, '1'; converte de '1'-'3' para 0-2
    XOR AH, AH
    MOV SI, AX; SI = índice da coluna
    JMP VERIFICA_OCUPACAO_PC

JOGADA_CPU:
    ;gera linha
    MOV AX,RANDOMIZADOR;coloca o valor do RANDOMIZADOR em Ax
    MOV DX,25173
    MUL DX

    ADD AX,13849
    MOV RANDOMIZADOR,AX;coloca no randomizador para que garanta que um novo numero seja gerado

    XOR DX, DX
    MOV BX, 3
    DIV BX;divide 3 garantindo que esteja entre 0-2
                    
    MOV AL, DL;resto em dl            
    MOV BL, 3
    MUL BL; multiplica por 3 para obter a linha

    MOV BX, AX;coloca em BX o numero


    ;gera coluna
    MOV AX,RANDOMIZADOR
    MOV DX,8121
    MUL DX
    ADD AX,28411
    MOV RANDOMIZADOR,AX;coloca no randomizador para que garanta a geração de um novo número

    XOR DX,DX
    MOV CX,3
    DIV CX;garante que o numero esta entre 0-2

    MOV SI,DX;coloca o numero no indice da coluna

VERIFICA_OCUPACAO_PC:
    ; Verifica se posição está ocupada
    CMP TABULEIRO[BX][SI], ' '
    JNE POSICAO_OCUPADA_PC; se não estiver vazia, posição ocupada
    
    ; Verifica vez do jogador
    TEST DI, 1
    JZ MARCA_O_PC; se for par, CPU marca O
    
MARCA_X_PC:
    MOV TABULEIRO[BX][SI], 'X'; jogador humano marca X
    JMP TERMINA_JOGADA_PC
    
MARCA_O_PC:
    MOV TABULEIRO[BX][SI], 'O'; CPU marca O
    JMP TERMINA_JOGADA_PC
    
INVALIDA_HUMANO:
    LEA DX, MSG_INVALIDA
    MOV AH, 09h
    INT 21h; printa mensagem de entrada inválida
    JMP JOGADA_HUMANO; pede novamente a entrada
    
POSICAO_OCUPADA_PC:
    TEST DI, 1
    JZ JOGADA_CPU; se for CPU, tenta nova posição automaticamente
    LEA DX, MSG_OCUPADA
    MOV AH, 09h
    INT 21h; printa mensagem de posição ocupada para humano
    JMP JOGADA_HUMANO; pede novamente a entrada

TERMINA_JOGADA_PC:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX; recupera os registradores 
    RET; retorna da função
POSICAO_PC ENDP



VITORIA PROC
;entrada: Matriz tabuleiro com as posições jogadas preenchidas pelo procedimento anterior
;saida: winflag, o qual diz se alguem ganhou nessa rodada ou não
;o que faz: printa o quem ganhou essa rodada e retorna pro main 
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva os resgistradores 
    
    XOR BX, BX; zera o índice de linha
    MOV CH, 3; contador de linhas a verificar
    
checa_linha_x:
    MOV WIN_FLAG, 0; reseta o contador de vitória
    XOR SI, SI; zera o índice de coluna
    MOV CL, 3; contador de colunas a verificar
conta_x_linha:
    CMP TABULEIRO[BX][SI], 'X'
    JNE prox_linha_x; se não for X, vai para a próxima linha
    INC WIN_FLAG; incrementa o contador de X consecutivos
    INC SI; avança para a próxima coluna
    DEC CL; decrementa o contador de colunas
    JNZ conta_x_linha; repete para todas as colunas
    CMP WIN_FLAG, 3
    JNE skip_vx_1; se não tiver 3 X, não é vitória
    JMP VICTORY_X; se tiver 3 X, jogador X venceu
skip_vx_1:
prox_linha_x:
    ADD BX, 3; avança para a próxima linha
    DEC CH; decrementa o contador de linhas
    JNZ checa_linha_x; repete para todas as linhas
    
    XOR BX, BX; zera o índice de linha
    MOV CH, 3; contador de linhas a verificar
checa_linha_o:
    MOV WIN_FLAG, 0; reseta o contador de vitória
    XOR SI, SI; zera o índice de coluna
    MOV CL, 3; contador de colunas a verificar
conta_o_linha:
    CMP TABULEIRO[BX][SI], 'O'
    JNE prox_linha_o; se não for O, vai para a próxima linha
    INC WIN_FLAG; incrementa o contador de O consecutivos
    INC SI; avança para a próxima coluna
    DEC CL; decrementa o contador de colunas
    JNZ conta_o_linha; repete para todas as colunas
    CMP WIN_FLAG, 3
    JNE skip_vo_1; se não tiver 3 O, não é vitória
    JMP VICTORY_O; se tiver 3 O, jogador O venceu
skip_vo_1:
prox_linha_o:
    ADD BX, 3; avança para a próxima linha
    DEC CH; decrementa o contador de linhas
    JNZ checa_linha_o; repete para todas as linhas
    
    XOR SI, SI; zera o índice de coluna
    MOV CH, 3; contador de colunas a verificar
checa_coluna_x:
    MOV WIN_FLAG, 0; reseta o contador de vitória
    XOR BX, BX; zera o índice de linha
    MOV CL, 3; contador de linhas a verificar
conta_x_coluna:
    CMP TABULEIRO[BX][SI], 'X'
    JNE prox_coluna_x; se não for X, vai para a próxima coluna
    INC WIN_FLAG; incrementa o contador de X consecutivos
    ADD BX, 3; avança para a próxima linha
    DEC CL; decrementa o contador de linhas
    JNZ conta_x_coluna; repete para todas as linhas
    CMP WIN_FLAG, 3
    JNE skip_vx_2; se não tiver 3 X, não é vitória
    JMP VICTORY_X; se tiver 3 X, jogador X venceu
skip_vx_2:
prox_coluna_x:
    INC SI; avança para a próxima coluna
    DEC CH; decrementa o contador de colunas
    JNZ checa_coluna_x; repete para todas as colunas
    
    XOR SI, SI; zera o índice de coluna
    MOV CH, 3; contador de colunas a verificar
checa_coluna_o:
    MOV WIN_FLAG, 0; reseta o contador de vitória
    XOR BX, BX; zera o índice de linha
    MOV CL, 3; contador de linhas a verificar
conta_o_coluna:
    CMP TABULEIRO[BX][SI], 'O'
    JNE prox_coluna_o; se não for O, vai para a próxima coluna
    INC WIN_FLAG; incrementa o contador de O consecutivos
    ADD BX, 3; avança para a próxima linha
    DEC CL; decrementa o contador de linhas
    JNZ conta_o_coluna; repete para todas as linhas
    CMP WIN_FLAG, 3
    JNE skip_vo_2; se não tiver 3 O, não é vitória
    JMP VICTORY_O; se tiver 3 O, jogador O venceu
skip_vo_2:
prox_coluna_o:
    INC SI; avança para a próxima coluna
    DEC CH; decrementa o contador de colunas
    JNZ checa_coluna_o; repete para todas as colunas
    
    MOV WIN_FLAG, 0; reseta o contador de vitória
    XOR BX, BX; zera o índice de linha
    XOR SI, SI; zera o índice de coluna
    MOV CX, 3; contador de elementos na diagonal
checa_diag1_x:
    CMP TABULEIRO[BX][SI], 'X'
    JNE checa_diag1_o; se não for X, checa para O
    INC WIN_FLAG; incrementa o contador de X consecutivos
    ADD BX, 3; avança para a próxima linha
    INC SI; avança para a próxima coluna (diagonal principal)
    DEC CX; decrementa o contador
    JNZ checa_diag1_x; repete para todos os elementos da diagonal
    CMP WIN_FLAG, 3
    JNE skip_vx_3; se não tiver 3 X, não é vitória
    JMP VICTORY_X; se tiver 3 X, jogador X venceu
skip_vx_3:
    
checa_diag1_o:
    MOV WIN_FLAG, 0; reseta o contador de vitória
    XOR BX, BX; zera o índice de linha
    XOR SI, SI; zera o índice de coluna
    MOV CX, 3; contador de elementos na diagonal
conta_o_diag1:
    CMP TABULEIRO[BX][SI], 'O'
    JNE checa_diag2_x; se não for O, checa diagonal secundária para X
    INC WIN_FLAG; incrementa o contador de O consecutivos
    ADD BX, 3; avança para a próxima linha
    INC SI; avança para a próxima coluna (diagonal principal)
    DEC CX; decrementa o contador
    JNZ conta_o_diag1; repete para todos os elementos da diagonal
    CMP WIN_FLAG, 3
    JNE skip_vo_3; se não tiver 3 O, não é vitória
    JMP VICTORY_O; se tiver 3 O, jogador O venceu
skip_vo_3:
    
checa_diag2_x:
    MOV WIN_FLAG, 0; reseta o contador de vitória
    XOR BX, BX; zera o índice de linha
    MOV SI, 2; começa na última coluna
    MOV CX, 3; contador de elementos na diagonal
conta_x_diag2:
    CMP TABULEIRO[BX][SI], 'X'
    JNE checa_diag2_o; se não for X, checa para O
    INC WIN_FLAG; incrementa o contador de X consecutivos
    ADD BX, 3; avança para a próxima linha
    DEC SI; retrocede para a coluna anterior (diagonal secundária)
    DEC CX; decrementa o contador
    JNZ conta_x_diag2; repete para todos os elementos da diagonal
    CMP WIN_FLAG, 3
    JNE skip_vx_4; se não tiver 3 X, não é vitória
    JMP VICTORY_X; se tiver 3 X, jogador X venceu
skip_vx_4:
    
checa_diag2_o:
    MOV WIN_FLAG, 0; reseta o contador de vitória
    XOR BX, BX; zera o índice de linha
    MOV SI, 2; começa na última coluna
    MOV CX, 3; contador de elementos na diagonal
conta_o_diag2:
    CMP TABULEIRO[BX][SI], 'O'
    JNE FIM_VERIFICACAO; se não for O, ninguém ganhou
    INC WIN_FLAG; incrementa o contador de O consecutivos
    ADD BX, 3; avança para a próxima linha
    DEC SI; retrocede para a coluna anterior (diagonal secundária)
    DEC CX; decrementa o contador
    JNZ conta_o_diag2; repete para todos os elementos da diagonal
    CMP WIN_FLAG, 3
    JNE skip_vo_4; se não tiver 3 O, não é vitória
    JMP VICTORY_O; se tiver 3 O, jogador O venceu
skip_vo_4:
    
FIM_VERIFICACAO:
    JMP FIMVIC; nenhuma vitória foi encontrada
    
VICTORY_X:
    MOV WIN_FLAG, 1; define flag de vitória para jogador X
    MOV AH, 09H
    LEA DX, MSG_VITORIA_X
    INT 21h; printa mensagem de vitória do jogador X
    JMP FIMVIC
    
VICTORY_O:
    MOV WIN_FLAG, 2; define flag de vitória para jogador O
    MOV AH, 09H
    LEA DX, MSG_VITORIA_O
    INT 21h; printa mensagem de vitória do jogador O
    JMP FIMVIC

FIMVIC:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX; recupera os registradores 
    RET; retorna da função
VITORIA ENDP

IMPRIMIRTABULEIRO PROC
;entrada: matriz tabuleiro lida e preenchida anteriormente
;saida: tabuleiro printado
;o que faz: printa o tabuleiro da jogada atual na tela do jogador
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva os resgistradores 
    
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h; printa uma nova linha
    
    LEA DX, MSG4
    MOV AH, 09h
    INT 21h; printa o título "TABULEIRO:"
    
    XOR BX, BX; zera o índice de linha
    XOR CX, CX; zera o contador
    MOV CH, 3; contador de linhas
    
PRINTT_COLUNA:
    MOV DL, ' '
    MOV AH, 02h
    INT 21H; printa um espaço para formatação
    
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h; printa uma nova linha
    
    MOV CL, 3; contador de colunas
    XOR SI, SI; zera o índice de coluna
    
PRINTT_LINHA:
    MOV DL, TABULEIRO[BX][SI]
    MOV AH, 02h
    INT 21h; printa o caractere da posição (X, O ou espaço)
    
    LEA DX, SEPARADOR_COL
    MOV AH, 09h
    INT 21h; printa o separador de coluna " | "
    
    INC SI; avança para a próxima coluna
    DEC CL; decrementa o contador de colunas
    JNZ PRINTT_LINHA; repete para todas as colunas
    
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h; printa uma nova linha
    
    LEA DX, SEPARADOR_LIN
    MOV AH, 09h
    INT 21h; printa o separador de linha "---+---+---"
    
    ADD BX, 3; avança para a próxima linha
    DEC CH; decrementa o contador de linhas
    JNZ PRINTT_COLUNA; repete para todas as linhas
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX; recupera os registradores 
    RET; retorna da função
IMPRIMIRTABULEIRO ENDP

END MAIN