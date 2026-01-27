module system
#(
    parameter REGF_DEPTH      = 16, // RF Depth, default 16 *Do not change*
    parameter ALU_FUN         = 4,  // ALU Operand Function Width, default 4 *Do not change*
    parameter REGF_WIDTH      = 8,  // RF BUS Width, default 8 *Do not change*
    parameter ALU_BUSA        = 8,  // ALU Operand A BUS Width, default 8 *Do not change*
    parameter ALU_BUSB        = 8,  // ALU Operand B BUS Width, default 8 *Do not change*
    parameter FIFO_DATA_WIDTH = 8,  // FIFO Data BUS Width, default 8 *Do not change*
    parameter FIFO_WIDTH      = 4,  // FIFO Address Width , default 4 *Do not change*
    parameter SYNC_BUS        = 8,  // DATA Sync BUS Width, default 8 *Do not change*
    parameter SYNC_NO_STAGES  = 2,  // FF NO. Stages  
    parameter RST_NO_STAGES   = 2,  // FF NO. Stages
    parameter CLKDIV_WIDTH    = 6   // Div Ratio BUS Width for TX clkdiv, default 6 *Do not change*
)
(
    input  logic i_sys_clk,  // Input System Clock of 100MHz
    input  logic i_uart_clk, // Input UART Clock of 3.6864MHz
    input  logic i_arst_n,   // Input Async Active-Low Reset
    input  logic i_rx_in,    // Input RX Master command

    output logic o_tx_out,   // Output TX Master
    output logic o_busy,     // Output TX Master busy flag
    output logic o_par_err,  // Output Parity Check of the RX Command
    output logic o_stp_err   // Output Stop bit Check of the RX Command
);

// Interconnects
logic w_ff_full;
logic w_rd_valid;
logic w_out_valid;
logic w_rx_d_valid;
logic w_tx_p_valid;
logic w_alu_en;
logic w_clk_en;
logic w_wr_en;
logic w_rd_en;
logic w_clk_div_en;
logic w_rst_sync1;
logic w_rst_sync2;
logic w_tx_clk;
logic w_rinc;
logic w_ff_empty;
logic w_done_rec;
logic w_alu_clk;

logic [3:0]  w_alu_fun;
logic [3:0]  w_address;
logic [7:0]  w_rd_data;
logic [7:0]  w_p_data;
logic [7:0]  w_wr_data;
logic [7:0]  w_tx_p_data;
logic [7:0]  w_fifo_out_data;
logic [7:0]  w_rx;
logic [7:0]  w_reg0;
logic [7:0]  w_reg1;
logic [7:0]  w_reg2;
logic [7:0]  w_reg3;
logic [15:0] w_alu_out;

sys_ctrl u_brain (
    .i_clk(i_sys_clk),
    .i_arst_n(w_rst_sync1),
    .i_ff_full(w_ff_full),
    .i_rd_valid(w_rd_valid),
    .i_out_valid(w_out_valid),
    .i_rx_d_valid(w_rx_d_valid),
    .i_rd_data(w_rd_data),
    .i_p_data(w_p_data),
    .i_alu_out(w_alu_out),

    .o_alu_fun(w_alu_fun),
    .o_address(w_address),
    .o_wr_data(w_wr_data),
    .o_tx_p_data(w_tx_p_data),
    .o_tx_p_valid(w_tx_p_valid),
    .o_alu_en(w_alu_en),
    .o_clk_en(w_clk_en),
    .o_wr_en(w_wr_en),
    .o_rd_en(w_rd_en),
    .o_clk_div_en(w_clk_div_en)
);

reg_file #(
    .WIDTH(REGF_WIDTH), 
    .DEPTH(REGF_DEPTH)
    )
     u_memory(
    .i_clk(i_sys_clk),
    .i_arst_n(w_rst_sync1),
    .i_write_enable(w_wr_en),
    .i_read_enable(w_rd_en),
    .i_address(w_address),
    .i_write_data(w_wr_data),

    .o_read_data(w_rd_data),
    .o_reg0(w_reg0),
    .o_reg1(w_reg1),
    .o_reg2(w_reg2),
    .o_reg3(w_reg3),
    .o_rd_valid(w_rd_valid)
);

alu #(
    .BUSA(ALU_BUSA),
    .BUSB(ALU_BUSB),
    .FUN(ALU_FUN)
    ) 
    u_compute (
    .i_clk(w_alu_clk),
    .i_arst_n(w_rst_sync1),
    .i_enable(w_alu_en),
    .i_alu_fun(w_alu_fun),
    .i_operan_a(w_reg0),
    .i_operan_b(w_reg1),

    .o_alu_res(w_alu_out),
    .o_valid(w_out_valid)
);

async_fifo #(
    .WIDTH(FIFO_WIDTH), 
    .DATA_WIDTH(FIFO_DATA_WIDTH)
    ) 
    u_async_intrface (
    .wclk(i_sys_clk),
    .rclk(w_tx_clk),
    .wrst_n(w_rst_sync1),
    .rrst_n(w_rst_sync2),
    .winc(w_tx_p_valid),
    .rinc(w_rinc),
    .wdata(w_tx_p_data),

    .rdata(w_fifo_out_data),
    .wfull(w_ff_full),
    .rempty(w_ff_empty)
);

tx u_uart_tx (
    .i_clk(w_tx_clk),
    .i_arst_n(w_rst_sync2),
    .i_data_valid(~w_ff_empty),
    .i_par_typ(w_reg2[1]),
    .i_par_en(w_reg2[0]),
    .i_p_data(w_fifo_out_data),

    .o_tx(o_tx_out),
    .o_busy(w_busy)
);

assign o_busy = w_busy;

rx u_uart_rx (
    .i_clk(i_uart_clk),
    .i_arst_n(w_rst_sync2),
    .i_rx_in(i_rx_in),
    .i_par_typ(w_reg2[1]),
    .i_par_en(w_reg2[0]),
    .i_prescale(w_reg2[7:2]),

    .o_done_flag(w_done_rec),
    .o_error_flag({o_stp_err,o_par_err}),
    .o_data_out(w_rx)
);

clk_gated u_clk_gated (
    .i_clk(i_sys_clk),
    .i_enable(w_clk_en),

    .o_gated_clk(w_alu_clk)
);

data_sync #(
    .NO_STAGES(SYNC_NO_STAGES),
    .BUS(SYNC_BUS)
    ) 
    u_data_sync (
    .i_clk(i_sys_clk),
    .i_arst_n(w_rst_sync1),
    .i_bus_enable(w_done_rec),
    .i_async_bus(w_rx),

    .o_synced_bus(w_p_data),
    .o_enable_pulse(w_rx_d_valid)
);

pulse_gen u_pulse (
    .i_clk(w_tx_clk),
    .i_arst_n(w_rst_sync1),
    .i_lvl_sig(w_busy),

    .o_pulse_sig(w_rinc)
);

reset_sync #(.NO_STAGES(RST_NO_STAGES)) u1_rst_sync (
    .i_clk(i_sys_clk),
    .i_arst_n(i_arst_n),

    .o_synced_rst(w_rst_sync1)
);

reset_sync #(.NO_STAGES(RST_NO_STAGES)) u2_rst_sync (
    .i_clk(i_uart_clk),
    .i_arst_n(i_arst_n),

    .o_synced_rst(w_rst_sync2)
);

clk_div #(.WIDTH(CLKDIV_WIDTH)) u_freq_div (
    .i_clk(i_uart_clk),
    .i_arst_n(w_rst_sync2),
    .i_clk_en(w_clk_div_en),
    .i_div_ratio(w_reg3[5:0]),

    .o_div_clk(w_tx_clk)
);

endmodule
