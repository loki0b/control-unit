`include "def.vh"

module control_unit (
    input wire                  clk,
    input wire                  rst,
    input wire                 send,
    input wire [17:0]    switch_bus,

    // Control outputs
    output reg                clear,
    output reg         write_enable,
    output reg          read_enable,

    // Outputs
    output reg [2:0]         opcode,
    output reg [3:0]            dst,
    output reg [3:0]           src0, 
    output reg [3:0]           src1, 
    output reg [15:0]           imm
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
        READ        = 3'b101,
        EXECUTE     = 3'b110,
        STORE       = 3'b111;

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
    
    // Combinational
    always @(*) begin
        write_enable = 0;
        read_enable  = 0;
        clear        = 0;

        case (state)
            OFF: begin
                write_enable = 0;
                read_enable  = 0;
            end
            
            INIT: begin
                write_enable = 1;
                clear        = 1;
            end

            IDLE: begin
                write_enable = 0;
                read_enable  = 0;
                clear        = 0;
            end

            FETCH: begin
                ;
            end

            DECODE: begin
                ;
            end

            READ: begin
                read_enable = 1;
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
        if (rst) begin
            if (state == OFF) state <= INIT;
            else state <= OFF;
        end

        else begin
            case (state)
                OFF: begin
                   ;
                end
                
                INIT: begin
                    instruction <= 0;
                    opcode      <= 0;
                    dst         <= 0;
                    src0        <= 0;
                    src1        <= 0;
                    imm         <= 0;  
                    state       <= IDLE;
                end

                IDLE: begin
                    if (send) state <= FETCH;
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

                    else if (instruction[`OUT_OPCODE] == CLEAR ||
                            instruction[`OUT_OPCODE] == DISPLAY)
                    begin
                        opcode <= instruction[`OUT_OPCODE];
                        src0   <= instruction[`OUT_SRC0];
                    end

                    state <= READ;
                end

                READ: begin
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
    end
endmodule