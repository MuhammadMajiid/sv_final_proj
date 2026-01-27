module tx (
    input  logic        i_clk,       //  The main system's clock.
    input  logic        i_arst_n,     //  Active low reset.
    input  logic        i_data_valid,  //  An enable to start i_data_validing data.
    input  logic        i_par_typ,     //  Parity type agreed upon by the Tx and Rx units.
    input  logic        i_par_en,
    input  logic  [7:0] i_p_data,      //  The data input.

    output logic        o_tx,     //  Serial transmitter's data out.
    output logic        o_busy         //  high when Tx is transmitting, low when idle.
);

//  Interconnections
logic w_par_bit;

//Parity unit instantiation 
parity u_parity(
    //  Inputs
    .i_arst_n(i_arst_n),
    .i_p_data(i_p_data),
    .i_par_typ(i_par_typ),
    .i_data_valid(i_data_valid),
    
    //  Output
    .o_par_bit(w_par_bit)
);

//  PISO shift register unit instantiation
piso u_piso(
    //  Inputs
    .i_clk(i_clk),
    .i_arst_n(i_arst_n),
    .i_data_valid(i_data_valid),
    .i_par_en(i_par_en),
    .i_par_bit(w_par_bit),
    .i_p_data(i_p_data),

    //  Outputs
    .o_tx(o_tx),
    .o_busy(o_busy)
);

endmodule
