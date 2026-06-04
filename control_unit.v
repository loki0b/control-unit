module control_unit (
    input wire                  clk,
    input wire                  rst,
    input wire                 send,
    input wire [17:0]   instruction,

    output reg                clear,
    //output reg            display,
    output reg          write_enable
    //output                    lcd,
);
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

    reg [2:0] state = OFF;
    
    // Combinational
    always @(*) begin
        write_enable = 0;
        clear = 0;

        case (state)
            OFF: begin
                write_enable = 0;
            end
            
            INIT: begin
                clear = 1;
            end

            IDLE: begin
                clear = 0;
            end

            FETCH: begin
                ;
            end

            DECODE: begin
                ;
            end

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
                
                state <= DECODE;
            end

            DECODE: begin
                
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