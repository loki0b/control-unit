# Projeto Mini CPU - FPGA DE2-115

## Descrição
Este projeto implementa uma Mini CPU de 16 bits em Verilog, projetada para ser sintetizada na placa FPGA Altera/Terasic DE2-115. O sistema processa instruções inseridas manualmente via switches da placa, executa operações aritméticas, manipula uma memória de dados interna e exibe o estado e os resultados das operações no display LCD 16x2 nativo da placa.

## Arquitetura do Sistema
O projeto adota uma arquitetura modularizada, separando o caminho de dados, a unidade de controle e as interfaces de hardware periférico.

* **mini_cpu_fpga:** Módulo principal que encapsula o processador e os periféricos. Mapeia os sinais físicos da placa (botões, chaves e pinos do LCD) para os módulos internos.
* **cpu:** Agrupa os componentes centrais do processador (Unidade de Controle, ULA e Memória) e gerencia o barramento de dados interno.
* **control_unit:** Máquina de Estados Finitos responsável por orquestrar o ciclo de instrução. Gera todos os sinais de controle (enable de escrita/leitura, seletores de multiplexadores).
* **arithmetic_logic_unit :** Circuito combinacional puro responsável pelas operações matemáticas (Soma, Subtração, Multiplicação).
* **memory:** Memória SRAM sincrona de dados com 16 endereços (registradores) de 16 bits cada.
* **button_handler:** Circuito debouncer que filtra os ruídos mecânicos dos botões físicos da placa, garantindo que cada pulso seja interpretado como um único ciclo útil.
* **Controlador de LCD:**
    * **lcd_controller:** Wrapper que une a lógica de dados à lógica física.
    * **lcd_formatter:** Converte dados binários para BCD (Binary-Coded Decimal) e mapeia os resultados e opcodes para os caracteres ASCII correspondentes.
    * **lcd_driver:** Controlador físico responsável pela inicialização do controlador HD44780 e pelo respeito às restrições de temporização elétrica do display.

## Fluxo de Execução
A Unidade de Controle opera baseada em uma FSM com os seguintes estados sequenciais:

1.  **OFF:** Estado inativo aguardando o primeiro acionamento de reset.
2.  **INIT:** Zera todos os endereços de memória, limpa os barramentos de dados e inicia a rotina do LCD.
3.  **IDLE:** Estado de repouso. Aguarda o sinal do botão "send".
4.  **FETCH:** Lê a instrução de 18 bits diretamente do barramento de chaves.
5.  **DECODE:** Extrai o opcode, o registrador de destino, os registradores fontes e estende o sinal de valores imediatos.
6.  **READ:** Ativa os sinais de leitura da memória e carrega os dados dos registradores fonte.
7.  **EXECUTE:** Roteia os dados para a ULA e aciona lógicas internas de controle.
8.  **STORE:** Grava o resultado da ULA ou o valor imediato no registrador de destino na memória e sinaliza o LCD para formatação e exibição. Retorna ao estado IDLE.

## Conjunto de Instruções
As instruções são formadas por 18 bits inseridos nas chaves físicas. Os Opcodes principais de 3 bits são:
* **000 (LOAD):** Carrega um valor imediato em um registrador.
* **001 (ADD):** Soma dois registradores.
* **010 (ADDI):** Soma um registrador a um valor imediato.
* **011 (SUB):** Subtrai dois registradores.
* **100 (SUBI):** Subtrai um imediato de um registrador.
* **101 (MUL):** Multiplica dois registradores.
* **110 (CLEAR):** Zera toda a memória (instrução sem parâmetros matemáticos).
* **111 (DISPLAY):** Exibe o valor de um registrador específico no LCD.
