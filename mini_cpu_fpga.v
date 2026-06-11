module mini_cpu_fpga (
    input wire                    clk,
    input wire                btn_rst,
    input wire               btn_send,
    input wire [17:0]      switch_bus,

    output wire [7:0]        lcd_data,
    output wire                lcd_rs,
    output wire                lcd_rw,
    output wire                lcd_en,
    output wire                lcd_on,
    output wire              lcd_blon,

    output wire [17:0] switch_led_bus,
    output wire [7:0]  ledg_bus
 );

    // sys_status
    localparam [1:0]
        SYS_OFF     = 2'b00,
        SYS_INIT    = 2'b01,
        SYS_RUNNING = 2'b10,
        SYS_READY   = 2'b11;

    wire [2:0]  opcode;
    wire [3:0]  dst;
    wire [15:0] out;
    wire        lcd_enable;
    wire        rst;
    wire        send;
    wire [1:0]  sys_status;

    // Turn off the leds when CPU is off
    assign switch_led_bus = (sys_status != SYS_OFF) ? switch_bus : 0;
    assign ledg_bus[4] = (sys_status != SYS_OFF) ? ~btn_send : 0;

    assign ledg_bus[6] = ~btn_rst; // This led is turned on even when the CPU is off

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
        .out(out),
        .sys_status(sys_status)
    );

    lcd_controller lcd_ctl0(
        .clk(clk),
        .rst(rst), 
        .update_trigger(lcd_enable), 
        .opcode(opcode),
        .dst(dst),
        .data(out),
        .sys_status(sys_status),

        .lcd_data(lcd_data),
        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw),
        .lcd_en(lcd_en),
        .lcd_on(lcd_on),
        .lcd_blon(lcd_blon)
    );
endmodule