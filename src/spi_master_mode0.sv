module spi_master_mode0 (
    input  logic       clk,
    input  logic       rst,
    input  logic       start,
    input  logic [7:0] data2send,
    input  logic       miso,

    output logic       done,
    output logic       sclk,
    output logic       mosi,
    output logic       cs,
    output logic [7:0] data2receive
);

    typedef enum logic [2:0] {
        IDLE, ASSERT_CS, LOAD_BIT, SCLK_LOW, SCLK_HIGH, NEXT_BIT, FINISH
    } state_t; [cite: 9]

    state_t state, next_state; [cite: 10]
    logic [7:0] shift_reg;
    logic [7:0] recv_reg;
    logic [2:0] bit_cnt;
    logic [1:0] clk_div;
    logic       tick;

    assign tick = (clk_div == 2'b11); [cite: 12]

    always_ff @(posedge clk or posedge rst) begin
        if (rst) clk_div <= 2'b00; [cite: 13]
        else     clk_div <= clk_div + 2'b01;
    end

    // FSM Sequential Logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE; [cite: 15]
            sclk     <= 1'b0;
            cs       <= 1'b1;
            done     <= 1'b0;
            mosi     <= 1'b0;
            shift_reg <= 8'h00;
            recv_reg  <= 8'h00;
            bit_cnt   <= 3'd0;
        end else if (tick) begin
            state <= next_state; [cite: 17]

            case (state)
                IDLE:      done <= 1'b0; [cite: 18]
                
                ASSERT_CS: begin [cite: 19]
                    cs        <= 1'b0;
                    shift_reg <= data2send;
                    bit_cnt   <= 3'd7;
                end

                LOAD_BIT:  mosi <= shift_reg[7];
                
                SCLK_LOW:  sclk <= 1'b0;
                
                SCLK_HIGH: begin [cite: 21-22]
                    sclk     <= 1'b1;
                    recv_reg <= {recv_reg[6:0], miso};
                end

                NEXT_BIT: begin [cite: 23]
                    shift_reg <= {shift_reg[6:0], 1'b0};
                    bit_cnt   <= bit_cnt - 3'd1;
                end

                FINISH: begin [cite: 24]
                    cs   <= 1'b1;
                    sclk <= 1'b0;
                    done <= 1'b1;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    // FSM Combinational Logic
    always_comb begin
        next_state = state; [cite: 25]
        case (state)
            IDLE:      next_state = start ? ASSERT_CS : IDLE; [cite: 26-27]
            ASSERT_CS: next_state = LOAD_BIT;
            LOAD_BIT:  next_state = SCLK_LOW;
            SCLK_LOW:  next_state = SCLK_HIGH;
            SCLK_HIGH: next_state = NEXT_BIT; [cite: 28]
            NEXT_BIT:  next_state = (bit_cnt == 3'd0) ? FINISH : LOAD_BIT;
            FINISH:    next_state = IDLE; [cite: 29]
            default:   next_state = IDLE;
        endcase
    end

    assign data2receive = recv_reg;

endmodule
