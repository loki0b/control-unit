module arithmetic_logic_unit (
    input wire        [2:0]  opcode,
    input wire signed [15:0]      a,
    input wire signed [15:0]      b,

    output reg signed [15:0]    out
);

    localparam ADD = 3'b000;
    localparam SUB = 3'b001;
    localparam MUL = 3'b010;

    always @(*) begin
        case (opcode)
            ADD:    out = a + b;
            SUB:    out = a - b;
            MUL:    out = a * b;

            default: out = 16'h0000;
        endcase
    end
endmodule