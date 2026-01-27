module clk_gated(
    input  logic i_clk,
    input  logic i_enable,

    output logic o_gated_clk
);

assign o_gated_clk = i_enable? i_clk : 1'b0;
    
endmodule
