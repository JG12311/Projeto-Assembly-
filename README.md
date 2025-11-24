# ⭕ Jogo da Velha (Tic-Tac-Toe) em Assembly 8086 ❌

Projeto desenvolvido para a disciplina de **Sistemas de Computação** no curso de **Engenharia de Computação (PUC-Campinas)**.

O objetivo deste projeto é demonstrar domínio sobre a arquitetura 8086, manipulação direta de memória, lógica booleana, uso de pilhas, macros e interrupções do DOS.

## 🚀 Funcionalidades Implementadas

Diferente de versões básicas que apenas imprimem caracteres, este projeto é um jogo funcional completo:

* **Menu Interativo:** Seleção de modos de jogo e opção de saída.
* **Dois Modos de Jogo:**
    1.  **PvP:** Jogador contra Jogador (local).
    2.  **PvE:** Jogador contra Computador (CPU).
* **Inteligência Artificial (CPU):**
    * Utiliza um algoritmo **Linear Congruential Generator (LCG)** para gerar jogadas pseudo-aleatórias.
    * A CPU valida automaticamente se a posição gerada está livre antes de jogar.
* **Sistema de Coordenadas:** Entrada de dados intuitiva solicitando Linha (1-3) e Coluna (1-3).
* **Validações Robustas:**
    * Impede jogadas em posições já ocupadas.
    * Impede entrada de caracteres inválidos (fora do intervalo 1-3).
* **Verificação de Vitória:** Algoritmo de força bruta que checa as 8 possibilidades de vitória (3 linhas, 3 colunas, 2 diagonais) a cada turno.
* **Loop de Jogo:** Permite reiniciar a partida sem fechar o programa.

## 🛠️ Tecnologias e Conceitos

* **Linguagem:** Assembly 8086 (Intel 16-bit).
* **Montador:** Compatível com TASM (Turbo Assembler) e MASM.
* **Conceitos de Baixo Nível:**
    * **Macros:** Para padronização de I/O (`IMPRIMIR`) e preservação de contexto (`SALVA_TUDO`, `RECUPERA_TUDO`).
    * **Aritmética de Ponteiros:** Mapeamento de uma matriz lógica 3x3 em um vetor linear de 9 bytes (`Endereço = Linha*3 + Coluna`).
    * **Manipulação de Bits:** Uso de instruções `TEST` e `XOR` para alternância eficiente de turnos.
    * **Interrupções:** Uso intensivo da `INT 21h` para controle de console.

## 📋 Como Compilar e Executar

Você precisará de um emulador DOS (como **DOSBox**) e do **TASM**.

1.  **Monte o ambiente:**
    Certifique-se de que o arquivo `.ASM` e o executável do TASM/TLINK estejam acessíveis no DOSBox.

2.  **Compilação (Montagem):**
    Gera o arquivo objeto (`.OBJ`).
    ```dos
    tasm jogo.asm
    ```

3.  **Linkedição:**
    Gera o executável (`.EXE`).
    ```dos
    tlink jogo.obj
    ```

4.  **Execução:**
    ```dos
    jogo.exe
    ```

## 🎮 Como Jogar

1.  No menu inicial, digite `1` para jogar contra um amigo ou `2` para desafiar a CPU.
2.  O tabuleiro é organizado em linhas e colunas numeradas de 1 a 3.
3.  Quando for sua vez, o jogo pedirá:
    * **LINHA:** Digite `1` (topo), `2` (meio) ou `3` (baixo).
    * **COLUNA:** Digite `1` (esquerda), `2` (centro) ou `3` (direita).
4.  O jogo avisará se você tentar jogar em um lugar ocupado.
5.  Vence quem alinhar 3 símbolos iguais. Se o tabuleiro encher, dá **EMPATE**.

## 📂 Estrutura do Código

* **Macros:** Definições reutilizáveis para `IMPRIMIR`, `FINALIZAR` e manipulação de pilha (`PUSH/POP`).
* **MAIN:** Gerencia o menu principal e o loop de reinício.
* **LEITURA_2_JOG / LEITURA_MAQUINA:** Controladores principais de fluxo para cada modo de jogo.
* **POSICAO / POSICAO_MAQUINA:** Responsáveis pela lógica de entrada, validação de coordenadas e geração de números aleatórios (na CPU).
* **VITORIA:** Varredura da matriz para detectar o fim do jogo.
* **IMPRIMIR_TAB:** Renderização gráfica do tabuleiro usando caracteres ASCII.

---
Desenvolvido por **João Gabriel Breganon Ferreira e Gabriel Frias**.

* [ ] Implementar a lógica de turnos (Jogador 'X' e Jogador 'O').
* [ ] Adicionar verificação para impedir que uma posição já ocupada seja sobrescrita.
* [ ] Criar uma rotina para verificar as 8 condições de vitória (3 linhas, 3 colunas, 2 diagonais).
* [ ] Implementar a verificação de "Empate" (quando o tabuleiro está cheio e não há vencedor).
