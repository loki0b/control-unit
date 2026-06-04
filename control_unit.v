`include "def.vh"

module control_unit (
    input wire                  clk,
    input wire                  rst,
    input wire                 send,
    input wire [17:0]    switch_bus,

    output reg                clear,
    //output reg            display,
    output reg          write_enable
    //output                    lcd,
);

    function [15:0] signal_extension;
        input signal;
        input [5:0] imm;
        begin
            if (signal) // Negative number
                signal_extension = {10'b1111111111, imm};
            else // Positive number
                signal_extension = {10'b0000000000, imm};
        end
    endfunction

    localparam [2:0]
        OFF         = 3'b000,
        INIT        = 3'b001,
        IDLE        = 3'b010,
        FETCH       = 3'b011,
        DECODE      = 3'b100,
        EXECUTE     = 3'b101,
        STORE       = 3'b110;

    // opcodes
    localparam [2:0]
        LOAD    = 3'b000,
        ADD     = 3'b001,
        ADDI    = 3'b010,
        SUB     = 3'b011,
        SUBI    = 3'b100,
        MUL     = 3'b101,
        CLEAR   = 3'b110,
        DISPLAY = 3'b111;

    reg [2:0]  state        = OFF;
    reg [17:0] instruction  = 18'd0;
    reg [2:0]  opcode       = 3'd0;
    reg [3:0]  dst          = 4'd0;
    reg [3:0]  src0         = 4'd0;
    reg [3:0]  src1         = 4'd0;
    reg [15:0] imm          = 16'd0;
    
    // Combinational
    always @(*) begin
        write_enable = 0;
        clear = 0;

        case (state)
            OFF: begin
                write_enable = 0;
            end
            
            INIT: begin
                write_enable = 1;
                clear = 1;
            end

            IDLE: begin
                write_enable = 0;
                clear = 0;
            end

            FETCH: begin
                ;
            end

            DECODE: begin
                ;
            end

            // Execution depends on the instruction
            EXECUTE: begin
                ;
            end

            STORE: begin
                ;
            end
        endcase
    end
    

    // Sequential
    always @(posedge clk) begin
        case (state)
            OFF: begin
                if (rst) state <= INIT;
            end
            
            INIT: begin
                state <= IDLE;
            end

            IDLE: begin
                if (rst) state <= OFF;
                else if (send) state <= FETCH;
            end

            FETCH: begin
                instruction[17:0] <= switch_bus[17:0];
                state <= DECODE;
            end

            DECODE: begin
                if (instruction[`IMM_OPCODE] == ADDI ||
                    instruction[`IMM_OPCODE] == SUBI ||
                    instruction[`IMM_OPCODE] == MUL)
                begin                    
                    opcode <= instruction[`IMM_OPCODE];
                    dst    <= instruction[`IMM_DST];
                    src0   <= instruction[`IMM_SRC0];
                    imm    <= signal_extension(instruction[`SIG], instruction[`IMM]);
                end 

                else if (instruction[`REG_OPCODE] == ADD ||
                         instruction[`REG_OPCODE] == SUB)
                begin
                    opcode <= instruction[`REG_OPCODE];
                    dst    <= instruction[`REG_DST];
                    src0   <= instruction[`REG_SRC0];
                    src1   <= instruction[`REG_SRC1];
                end

                else if (instruction[`LOAD_OPCODE] == LOAD)
                begin
                    opcode <= instruction[`LOAD_OPCODE];
                    dst    <= instruction[`LOAD_DST];
                    imm    <= signal_extension(instruction[`SIG], instruction[`IMM]);
                end

                else if (instruction[`OUT_OPCODE])
                begin
                    opcode <= instruction[`OUT_OPCODE];
                    src0   <= instruction[`OUT_SRC0];
                end


                state <= EXECUTE;
            end

            EXECUTE: begin
                
                state <= STORE;
            end

            STORE: begin
                
                state <= IDLE;
            end
        endcase
    end
endmodule