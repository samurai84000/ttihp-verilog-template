module tt_um_top (
    input  logic [7:0] ui_in,    // Dedicated inputs
    output logic [7:0] uo_out,   // Dedicated outputs
    input  logic [7:0] uio_in,   // IOs: Input path
    output logic [7:0] uio_out,  // IOs: Output path
    output logic [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  logic       ena,      // always 1 when the design is powered
    input  logic       clk,      // clock
    input  logic       rst_n     // reset_n - low to reset
);

    // 1. Reset Logic: Invert the active-low rst_n for your active-high logic
    logic rst;
    assign rst = !rst_n;

    // 2. Mapping the 12-bit ADC Data
    // We use the 8 bidirectional pins (uio_in) and 4 dedicated inputs (ui_in)
    logic [11:0] combined_adc_data;
    assign combined_adc_data = {uio_in[7:0], ui_in[7:4]};

    // 3. Bidirectional Pin Configuration
    // Since we are using uio as inputs for the ADC, we set Output Enable to 0
    assign uio_oe  = 8'b00000000; 
    assign uio_out = 8'b00000000;

    // 4. Instantiate your System Logic
    top user_project (
        .clk(clk),
        .rst(rst),
        .wakeup(ui_in[1]),       // Input 1
        .adc_EOC(ui_in[2]),      // Input 2
        .MISO(ui_in[3]),         // Input 3
        .adc_data(combined_adc_data),

        .spi_clk(uo_out[0]),     // Output 0
        .MOSI(uo_out[1]),        // Output 1
        .FRAM_cs(uo_out[2]),     // Output 2
        .LoRA_cs(uo_out[3]),     // Output 3
        .adc_conv_start(uo_out[4]), // Output 4
        .en_sensor_vcc(uo_out[5]),  // Output 5
        .en_radio_vcc(uo_out[6]),   // Output 6
        .ana_ctrl(uo_out[7:5])      // Outputs 5, 6, 7 (shared)
    );

endmodule
