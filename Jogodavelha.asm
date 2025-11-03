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
    PUSH DI
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

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

    LOOP TURNOS

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
CALL VITORIA

FIM_PREENCHER:
    CALL IMPRIMIRTABULEIRO
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

PUSH
VITORIA ENDP 

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
    POP AX
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
    POP AX
    RET
IMPRIMIRTABULEIRO ENDP
END MAIN