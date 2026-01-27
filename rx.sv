module rx (
    input  logic         i_clk,       //  The System's main i_clk.
    input  logic         i_arst_n,    //  Active low reset.
    input  logic         i_rx_in,     //  Serial data recieved from the transmitter.
    input  logic         i_par_typ,   //  Parity type agreed upon by the Tx and Rx units.
    input  logic         i_par_en,
    input  logic [5:0]   i_prescale,

    output logic         o_done_flag,   //  Outputs logic 1 when data is recieved
    output logic [1:0]   o_error_flag,  //  Consits of two bits {StopError_Flag,ParityError_Flag}, each bit is a flag for an error
    output logic [7:0]   o_data_out     //  The 8-bits data separated from the frame.
);

//  Intermediate wires
logic [10:0] w_data_parll; //  data_out parallel comes from the SIPO unit.
logic w_recieved_flag;     //  works as an enable for deframe unit.
logic w_par_bit;           //  The Parity bit from the Deframe unit to the ErrorCheck unit.
logic w_str_bit;           //  The Start bit from the Deframe unit to the ErrorCheck unit.
logic w_stp_bit;           //  The Stop bit from the Deframe unit to the ErrorCheck unit.
logic w_clk_scaled;

// oversampling clock generator
baudgenr u_1 (
    .i_arst_n(i_arst_n),
    .i_clk(i_clk),
    .i_prescale(i_prescale),

    .o_clk_scaled(w_clk_scaled)
);

//  Shift Register Unit Instance
sipo u_2(
    //  Inputs
    .i_arst_n(i_arst_n),
    .i_rx_in(i_rx_in),
    .i_clk(w_clk_scaled),
    .i_prescale(i_prescale),

    //  Outputs
    .o_active_flag(o_active_flag),
    .o_recieved_flag(w_recieved_flag),
    .o_data_parll(w_data_parll)
);

//  Error Checking Unit Instance
error_check u_4(
    //  Inputs
    .i_arst_n(i_arst_n),
    .i_par_typ(i_par_typ),
    .i_par_en(i_par_en),
    .i_enable(w_recieved_flag),
    .i_raw_data(w_data_parll[8:1]),
    .i_parity_bit(w_data_parll[9]),
    .i_stop_bit(w_data_parll[10]),

    //  Output
    .o_data(o_data_out),
    .o_done_flag(o_done_flag),
    .o_error_flag(o_error_flag)
);

endmodule
