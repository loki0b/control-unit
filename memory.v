module memory (
    input  wire                clk,
    input  wire                rst,
    input  wire                 we,
    input  wire [3:0]   write_addr,
    input  wire [15:0]  write_data,
    input  wire [3:0]   read_addr0,
    input  wire [3:0]   read_addr1,
    
    output wire [15:0]  read_data0,
    output wire [15:0]  read_data1
);
    localparam NUM_REG  = 16;
    localparam REG_SIZE = 16;

    reg [REG_SIZE-1:0] ram [0:NUM_REG-1];
    integer i;

    // Sync write
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < NUM_REG; i++) begin
                ram[i] <= 16'h0000;
            end
        end else if (we) begin
            ram[write_addr] <= write_data;
        end
    end

    // Assync read
    assign read_data0 = ram[read_addr0];
    assign read_data1 = ram[read_addr1];
endmodule
