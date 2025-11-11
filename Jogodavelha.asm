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

    ;  PROMPTS JOGADA E INDICAÇÃO DE VEZ 
    MSG_JOGADA      DB 0Dh, 0Ah, 'Digite a posicao (1-9): $'
    MSGVEZ_X       DB 0Dh, 0Ah, '>>> Vez do jogador X <<<', 0Dh, 0Ah, '$'
    MSGVEZ_O       DB 0Dh, 0Ah, '>>> Vez do jogador O <<<', 0Dh, 0Ah, '$'
    MSGVEZ_CPU     DB 0Dh, 0Ah, '>>> Vez do Computador <<<', 0Dh, 0Ah, '$'
    INVALIDA        DB 0Dh, 0Ah, 'Numero invalido. Tente novamente!', 0Dh, 0Ah, '$'

    ;  MENSAGENS DE ERRO E FIM DE JOGO 
    MSG_INVALIDA    DB 0Dh, 0Ah, 'Jogada invalida! Tente novamente.', 0Dh, 0Ah, '$'
    MSG_OCUPADA     DB 0Dh, 0Ah, 'Posicao ja ocupada! Tente novamente.', 0Dh, 0Ah, '$'
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

    ;Matriz exemplo com os números em ASCII
    MATRIZ         DB '1','2','3'  ; Primeira linha
                   DB '4','5','6'  ; Segunda linha
                   DB '7','8','9'  ; Terceira linha
                
    ;Flag de vitória
    WIN_FLAG DB 0
    
.CODE
; MAIN - Programa Principal
MAIN PROC
    MOV AX, @DATA   
    MOV DS, AX
    
    COMECO:
    LEA DX, MSG_INSTRUCOES
    MOV AH, 09h
    INT 21h; printa msg_instrucoes
    LEA DX, NOVA_LINHA
    MOV AH, 09h
    INT 21h; printa nova_linha
    
    
    MENU:
    LEA DX, MSGMENU
    MOV AH, 09h
    INT 21h; printa msgmenu 
    
    ;Lê um caracter e coloca em al
    MOV AH,01H
    INT 21h


    ;compara AL com esses valores pra saber pra onde ir no programa
    CMP AL,'1'
    JE JOGA_2
    ;CMP AL,2
    ;JE JOGA_MAQUINA

    CMP AL,'1'
    JB INVALIDO

    CMP AL,'3'
    JA INVALIDO;se for maior do que 3 e menor do que vai jumpar pro invalido

    JMP FIM
    INVALIDO:
    MOV AH,09H
    LEA DX,INVALIDA
    INT 21H;printa a mensagem de invalido

    JMP MENU;jumpa pro menu
    
   CALL IMPRIMIRMATRIZ
JOGA_MAQUINA:
    ;CALL LEITURA_MAQUINA
    JMP COMECO
JOGA_2:
    CALL LEITURA2JOG
    JMP COMECO



FIM:

    ; 7. Encerra o programa
    MOV AH, 4Ch
    INT 21h     
    
MAIN ENDP 


LEITURA2JOG PROC
;entrada: nenhuma
;saida: matriz 3x3 
;o que faz: lê uma matriz de 3x3 
    PUSH DI
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva o valor dos registradores na pilha

    ; Inicializa o tabuleiro com espaços
    MOV CX,3            ; Contador de linhas
    XOR BX,BX           ; Zera índice da linha
INIT_LINHA:
    PUSH CX             ; Salva contador de linhas
    MOV CX,3           ; Contador de colunas
    XOR SI,SI          ; Zera índice da coluna
INIT_COLUNA:
    MOV TABULEIRO[BX][SI],' '
    INC SI
    LOOP INIT_COLUNA   ; Decrementa CX e continua se não for zero
    
    ADD BX,3           ; Próxima linha
    POP CX             ; Recupera contador de linhas
    LOOP INIT_LINHA    ; Decrementa CX e continua se não for zero

    ; Imprime tabuleiro inicial
    CALL IMPRIMIRTABULEIRO

    MOV CX,9    ; Total de jogadas possíveis
    XOR DI,DI   ; Contador de turnos começando com 0

TURNOS:
    INC DI  
    TEST DI,1       ; Testa o último bit de DI
    JZ PAR         ; Se for par, vez do O

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
    CALL POSICAO
    CALL IMPRIMIRTABULEIRO    ; Mostra tabuleiro após cada jogada
    
    ; Verifica vitória a partir da 5ª jogada
    CMP DI,4                  ; DI começa do 0, então 4 é a 5ª jogada
    JLE continua_jogo        ; Se menor que 5 jogadas, continua
    
    CALL VITORIA
    CMP WIN_FLAG,0
    JE continua_jogo         ; Se ninguém ganhou, continua
    JMP FIM_JOGO            ; Se alguém ganhou, termina
    
continua_jogo:
    JMP final_loop
    
final_loop:
    LOOP TURNOS

    ; Verifica empate apenas se chegou ao fim sem vencedor
    CMP WIN_FLAG,0
    JNE FIM_JOGO
    MOV AH,09h
    LEA DX,MSG_EMPATE
    INT 21h

    ; Se chegou aqui e WIN_FLAG = 0, é empate (todas jogadas feitas sem vencedor)
    CMP WIN_FLAG,0
    JNE FIM_JOGO
    MOV AH,09h
    LEA DX,MSG_EMPATE
    INT 21h

FIM_JOGO:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    POP DI;retorna o valor dos registradores salvos na pilha
    RET
LEITURA2JOG ENDP

POSICAO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva o valor dos registradores na pilha

INICIO_PREENCHER: 
    LEA DX,MSG_JOGADA
    MOV AH,09
    INT 21h         ; printa MSG_JOGADA

    MOV AH,01H
    INT 21H         ; Lê o caracter e coloca em al
   
    
    XOR BX,BX       ; Zera BX (índice da linha)
    XOR SI,SI       ; Zera SI (índice da coluna)
    
    ; Encontra a posição correta na matriz
PROCURA_POSICAO:
    CMP AL,MATRIZ[BX][SI]  ; Compara com o número na matriz (já em ASCII)
    JE POSICAO_ENCONTRADA  ; Se encontrou, processa a posição
    
    INC SI                 ; Próxima coluna
    CMP SI,3              ; Chegou ao fim da linha?
    JNE PROCURA_POSICAO
    
    XOR SI,SI             ; Volta para primeira coluna
    ADD BX,3              ; Próxima linha
    CMP BX,9              ; Chegou ao fim da matriz?
    JNE PROCURA_POSICAO
    LEA DX,MSG_INVALIDA   ; Se não encontrou, posição inválida
    MOV AH,09h
    INT 21h
    JMP INICIO_PREENCHER

POSICAO_ENCONTRADA:
    ; Verifica se posição está ocupada
    CMP TABULEIRO[BX][SI],' '  ; Verifica se está vazio
    JNE OCUPADA               ; Se não estiver vazio, está ocupada
    
    ; Verifica vez do jogador
    TEST DI,1             ; Testa se é vez do X ou O
    JZ PAR_PREENCHER
    
    ; Vez do X
    MOV TABULEIRO[BX][SI],'X'
    JMP ATUALIZA_TELA
    
PAR_PREENCHER:
    ; Vez do O
    MOV TABULEIRO[BX][SI],'O'
    
ATUALIZA_TELA:
    JMP FIM_PREENCHER

OCUPADA:
    LEA DX,MSG_OCUPADA
    MOV AH,09h
    INT 21h 
    JMP INICIO_PREENCHER


FIM_PREENCHER:
    CALL IMPRIMIRTABULEIRO
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX;retorna o valor dos registradores salvos na pilha
    
    RET
POSICAO ENDP 

VITORIA PROC
    PUSH AX
    PUSH BX
    PUSH CX 
    PUSH DX 
    PUSH SI;salva o valor dos registradores na pilha 

    XOR BX,BX       ;ZERA BX para começar da primeira linha
    MOV CH,3        ;contador de linhas

;checa se X ganhou nas linhas
checa_linha_x:
    MOV WIN_FLAG,0
    XOR SI,SI       ;zera SI para começar da primeira coluna
    MOV CL,3        ;contador de colunas
conta_x_linha:
    CMP TABULEIRO[BX][SI],'X'
    JNE prox_linha_x
    INC WIN_FLAG
    INC SI          ;próxima coluna
    DEC CL
    JNZ conta_x_linha
    CMP WIN_FLAG,3
    JNE prox_linha_x    ; Inverte a lógica do salto
    JMP VICTORY_X       ; Usa JMP para salto longo
prox_linha_x:
    ADD BX,3        ;pula pra próxima linha
    DEC CH
    JNZ checa_linha_x

;checa se O ganhou nas linhas
    XOR BX,BX       ;volta para primeira linha
    MOV CH,3        ;reseta contador de linhas
checa_linha_o:
    MOV WIN_FLAG,0
    XOR SI,SI
    MOV CL,3        ;contador de colunas
conta_o_linha:
    CMP TABULEIRO[BX][SI],'O'
    JNE prox_linha_o
    INC WIN_FLAG
    INC SI
    DEC CL
    JNZ conta_o_linha
    CMP WIN_FLAG,3
    JNE prox_linha_o    ; Inverte a lógica do salto
    JMP VICTORY_O       ; Usa JMP para salto longo
prox_linha_o:
    ADD BX,3        ;próxima linha
    DEC CH
    JNZ checa_linha_o

;checa se X ganhou nas colunas
    XOR SI,SI       ;começa da primeira coluna
    MOV CH,3        ;3 colunas para verificar
checa_coluna_x:
    MOV WIN_FLAG,0
    XOR BX,BX       ;começa da primeira linha
    MOV CL,3        ;3 posições em cada coluna
conta_x_coluna:
    CMP TABULEIRO[BX][SI],'X'
    JNE prox_coluna_x
    INC WIN_FLAG
    ADD BX,3        ;próxima linha
    DEC CL
    JNZ conta_x_coluna
    CMP WIN_FLAG,3
    JNE prox_coluna_x   ; Inverte a lógica do salto
    JMP VICTORY_X       ; Usa JMP para salto longo
prox_coluna_x:
    INC SI          ;próxima coluna
    DEC CH
    JNZ checa_coluna_x

;checa se O ganhou nas colunas
    XOR SI,SI       ;volta para primeira coluna
    MOV CH,3        ;reseta contador de colunas
checa_coluna_o:
    MOV WIN_FLAG,0
    XOR BX,BX       ;começa da primeira linha
    MOV CL,3        ;3 posições em cada coluna
conta_o_coluna:
    CMP TABULEIRO[BX][SI],'O'
    JNE prox_coluna_o
    INC WIN_FLAG
    ADD BX,3        ;próxima linha
    DEC CL
    JNZ conta_o_coluna
    CMP WIN_FLAG,3
    JNE prox_coluna_o   ; Inverte a lógica do salto
    JMP VICTORY_O       ; Usa JMP para salto longo
prox_coluna_o:
    INC SI          ;próxima coluna
    DEC CH
    JNZ checa_coluna_o

;checa diagonal principal X (0,0)(1,1)(2,2)
    MOV WIN_FLAG,0
    XOR BX,BX       ;começa do topo
    XOR SI,SI
    MOV CX,3        ;3 posições para checar
checa_diag1_x:
    CMP TABULEIRO[BX][SI],'X'
    JNE checa_diag1_o
    INC WIN_FLAG
    ADD BX,3        ;próxima linha
    INC SI          ;próxima coluna
    DEC CX
    JNZ checa_diag1_x
    CMP WIN_FLAG,3
    JE VICTORY_X

;checa diagonal principal O
checa_diag1_o:
    MOV WIN_FLAG,0
    XOR BX,BX
    XOR SI,SI
    MOV CX,3
conta_o_diag1:
    CMP TABULEIRO[BX][SI],'O'
    JNE checa_diag2_x
    INC WIN_FLAG
    ADD BX,3
    INC SI
    DEC CX
    JNZ conta_o_diag1
    CMP WIN_FLAG,3
    JE VICTORY_O

;checa diagonal secundária X (0,2)(1,1)(2,0)
checa_diag2_x:
    MOV WIN_FLAG,0
    XOR BX,BX       ;começa do topo
    MOV SI,2        ;começa da última coluna
    MOV CX,3
conta_x_diag2:
    CMP TABULEIRO[BX][SI],'X'
    JNE checa_diag2_o
    INC WIN_FLAG
    ADD BX,3        ;próxima linha
    DEC SI          ;coluna anterior
    DEC CX
    JNZ conta_x_diag2
    CMP WIN_FLAG,3
    JE VICTORY_X

;checa diagonal secundária O
checa_diag2_o:
    MOV WIN_FLAG,0
    XOR BX,BX
    MOV SI,2
    MOV CX,3
conta_o_diag2:
    CMP TABULEIRO[BX][SI],'O'
    JNE FIM_VERIFICACAO
    INC WIN_FLAG
    ADD BX,3
    DEC SI
    DEC CX
    JNZ conta_o_diag2
    CMP WIN_FLAG,3
    JNE FIM_VERIFICACAO  ; Inverte a lógica do salto
    JMP VICTORY_O       ; Usa JMP para salto longo

FIM_VERIFICACAO:
    JMP FIMVIC

VICTORY_X:
    MOV WIN_FLAG,1      ;sinaliza vitória do X primeiro
    MOV AH,09H
    LEA DX,MSG_VITORIA_X
    INT 21h
    JMP FIMVIC

VICTORY_O:
    MOV WIN_FLAG,2      ;sinaliza vitória do O primeiro
    MOV AH,09H
    LEA DX,MSG_VITORIA_O
    INT 21h
    JMP FIMVIC

FIMVIC:
    POP SI
    POP DX 
    POP CX
    POP BX 
    POP AX;retorna o valor dos registradores salvos na pilha
    RET
VITORIA ENDP 

IMPRIMIRMATRIZ PROC  
;entrada: matriz definida em data
;saida: impressão da matriz 3x3
;o que faz: imprime uma matriz 3x3

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva o valor dos registradores na pilha

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
    ;  Imprime a linha no formato: [char] | [char] | [char] 
    
    ; Primeiro caractere da linha
    MOV DL, matriz [BX][SI]     ; Lê usando [BX][SI]
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
    POP AX;retorna o valor dos registradores salvos na pilha
    RET
IMPRIMIRMATRIZ ENDP

IMPRIMIRTABULEIRO PROC  
;entrada: matriz definid em data
;saida: impressão da matriz 3x3
;o que faz: imprime uma matriz 3x3

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI;salva o valor dos registradores na pilha 

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
PRINTT_COLUNA:
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
PRINTT_LINHA:
    ; === Imprime a linha no formato: [char] | [char] | [char] ===
    
    ; Primeiro caractere da linha
    MOV DL, TABULEIRO[BX][SI]     ; Lê usando [BX][SI]
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
    JNZ PRINTT_LINHA


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
    JNZ PRINTT_COLUNA
    
       
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX;retorna o valor dos registradores salvos na pilha
    RET
IMPRIMIRTABULEIRO ENDP
END MAIN