module pulse_gen
//-----------------Ports-----------------\\
(
    input  logic i_clk, 
    input  logic i_arst_n,
    input  logic i_lvl_sig,    // enable for the pulse

    output logic  o_pulse_sig   // high pulse for 1 clk cycle, at the posedge of the i_lvl_sig
);
//-----------------Inernal declarations-----------------\\
logic [1:0] stages;

always_ff @(posedge i_clk, negedge i_arst_n) begin
    if (!i_arst_n) stages <= 2'b0;
    else           stages <= {stages[0],i_lvl_sig};
end

always_ff @(posedge i_clk, negedge i_arst_n) begin
    if      (!i_arst_n)       o_pulse_sig <= 1'b0;
    else if (stages == 2'b01) o_pulse_sig <= 1'b1;
    else                      o_pulse_sig <= 1'b0;
end

endmodule
