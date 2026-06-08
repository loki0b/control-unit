module mini_cpu_fpga (
    input wire                clk,
    input wire            btn_rst,
    input wire           btn_send,
    input wire [17:0]  switch_bus,

    output wire [7:0]    lcd_data,
    output wire            lcd_rs,
    output wire            lcd_rw,
    output wire            lcd_en
);

    wire [2:0]  opcode;
    wire [3:0]  dst;
    wire [15:0] out;
    wire        lcd_enable;
    wire        rst;
    wire        send;

    button_handler btn0 (
        .clk(clk),
        .btn_in(btn_rst),
        .pulse_out(rst)
    );

    button_handler btn1 (
        .clk(clk),
        .btn_in(btn_send),
        .pulse_out(send)
    );

    cpu cpu0(
        .clk(clk),
        .rst(rst),
        .send(send),
        .switch_bus(switch_bus),

        .lcd_enable(lcd_enable),
        .opcode(opcode),
        .dst(dst),
        .out(out)
    );

    lcd_controller lcd_ctl0(
        .clk(clk),
        .rst(~lcd_enable),
        .init(send),
        .opcode(opcode),
        .dst(dst),
        .data(out),

        .lcd_data(lcd_data),
        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw),
        .lcd_en(lcd_en)
    );
endmodule