# Jogo da Velha em Assembly 8086

Este é um projeto acadêmico simples, escrito em Assembly 8086, para a disciplina de Sistemas de Computação. O objetivo é demonstrar a manipulação de matrizes, entrada e saída de dados (I/O) no console usando interrupções do DOS.

## 👾 Funcionalidades Atuais

No estado atual, o programa não implementa a lógica completa do jogo (como verificação de vencedor ou alternância de jogadores). Ele foca nas seguintes rotinas:

1.  **Leitura de Entradas:** Solicita ao usuário que digite 9 caracteres, um para cada posição do tabuleiro.
2.  **Armazenamento em Matriz:** Guarda os 9 caracteres em uma matriz 3x3 na memória.
3.  **Exibição Formatada:** Imprime o tabuleiro no console com divisórias (`|`) e (`---`), simulando a grade de um Jogo da Velha.

## 🛠️ Como Compilar e Executar

Para rodar este projeto, você precisará de um ambiente que possa executar programas DOS de 16 bits.

### Pré-requisitos

* **Emulador DOS:** [**DOSBox**](https://www.dosbox.com/) é a opção mais comum.
* **Montador/Linkador:** **TASM** (Turbo Assembler) ou **MASM** (Microsoft Macro Assembler). Os comandos abaixo assumem que você está usando o TASM.

### Passos para Execução

1.  **Inicie o DOSBox** e monte o diretório onde estão seus arquivos `.asm` e o TASM. (Ex: `mount c C:\TASM`)
2.  Navegue até o diretório do seu projeto.
3.  **Monte o programa** (Compile) para criar o arquivo objeto (`.obj`):
    ```dos
    tasm jogo.asm
    ```
    *(Substitua `jogo.asm` pelo nome do seu arquivo)*

4.  **Linke o programa** para criar o arquivo executável (`.exe`):
    ```dos
    tlink jogo.obj
    ```

5.  **Execute o programa:**
    ```dos
    jogo.exe
    ```

## 📂 Estrutura do Código

O código é dividido em três partes principais:

* `.DATA`: Define todas as variáveis, mensagens (prompts) e as strings de formatação do tabuleiro.
* `LERMATRIZ PROC`: Rotina responsável por pedir os 9 caracteres ao usuário e armazená-los sequencialmente na matriz `tabuleiro`.
* `IMPRIMIRMATRIZ PROC`: Rotina que percorre a matriz `tabuleiro` e a imprime no console com a formatação de Jogo da Velha.
* `MAIN PROC`: Ponto de entrada principal. Ele inicializa o segmento de dados (`DS`), chama `LERMATRIZ` e depois `IMPRIMIRMATRIZ` antes de encerrar o programa.

## 🚀 Próximos Passos (Possíveis Melhorias)

* [ ] Implementar a lógica de turnos (Jogador 'X' e Jogador 'O').
* [ ] Adicionar verificação para impedir que uma posição já ocupada seja sobrescrita.
* [ ] Criar uma rotina para verificar as 8 condições de vitória (3 linhas, 3 colunas, 2 diagonais).
* [ ] Implementar a verificação de "Empate" (quando o tabuleiro está cheio e não há vencedor).
