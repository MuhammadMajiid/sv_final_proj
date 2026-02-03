module reset_sync 
#(
    parameter NO_STAGES = 3
)
(
    input  logic i_clk,
    input  logic i_arst_n,
    output logic o_synced_rst
);

logic [NO_STAGES-1:0] stages;
genvar i;

assign stages[0] = 1;

// stages logic
generate
    for ( i=0 ; i<NO_STAGES-1 ; i=i+1 ) begin
        dff #(.BUS(1)) u_i (
            .i_clk(i_clk),
            .i_arst_n(i_arst_n),
            .i_d(stages[i]),
            .o_q(stages[i+1])
        );
    end
endgenerate

// output
assign o_synced_rst = stages[NO_STAGES-1];

endmodule
