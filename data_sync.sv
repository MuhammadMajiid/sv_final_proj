module data_sync
#(
    parameter NO_STAGES = 3,
    parameter BUS       = 4
)
(
    input  logic           i_clk,
    input  logic           i_arst_n,
    input  logic           i_bus_enable,
    input  logic [BUS-1:0] i_async_bus,
    output logic [BUS-1:0] o_synced_bus,
    output logic           o_enable_pulse
);

logic w_pulse_gen_in, w_pulse_gen_out, dff_enable_pulse;
logic w_q_pg, w_nq_pg;
logic [BUS-1:0] sync_data_in, dff_data_out;

// Syncing BUS_ENABLE signal stages
bit_sync #(.NO_STAGES(NO_STAGES), .BUS(1)) stgs (
    .i_clk(i_clk),
    .i_arst_n(i_arst_n),
    .i_async_bit(i_bus_enable),

    .o_synced_bit(w_pulse_gen_in)
);

// pulse gen logic
dff #(.BUS(1)) u_pg1 (
    .i_clk(i_clk),
    .i_arst_n(i_arst_n),
    .i_d(w_pulse_gen_in),
    .o_q(w_q_pg)
);

not (w_nq_pg, w_q_pg);

and (w_pulse_gen_out, w_nq_pg, w_pulse_gen_in);

dff #(.BUS(1)) u_pg2 (
    .i_clk(i_clk),
    .i_arst_n(i_arst_n),
    .i_d(w_pulse_gen_out),
    .o_q(dff_enable_pulse)
);

// Syncing BUS
mux2X1 #(.BUS(BUS)) u_d (
    .in_0(dff_data_out),
    .in_1(i_async_bus),
    .sel(w_pulse_gen_out),
    .out(sync_data_in)
);

dff #(.BUS(BUS)) u_data (
    .i_clk(i_clk),
    .i_arst_n(i_arst_n),
    .i_d(sync_data_in),
    .o_q(dff_data_out)
);

// output
assign o_synced_bus   = dff_data_out;
assign o_enable_pulse = dff_enable_pulse;

endmodule
