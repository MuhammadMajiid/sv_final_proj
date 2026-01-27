module  dff 
#(
    parameter BUS = 1
)
(
    input  logic           i_clk,
    input  logic           i_arst_n,
    input  logic [BUS-1:0] i_d,
    output logic  [BUS-1:0] o_q
);

always_ff @(posedge i_clk, negedge i_arst_n) begin
    if(~i_arst_n) o_q <= 'b0;
    else          o_q <= i_d; 
end

endmodule
