module bit_sync
#(
    parameter NO_STAGES = 3,
    parameter BUS       = 1
)
(
    input  logic           i_clk,
    input  logic           i_arst_n,
    input  logic [BUS-1:0] i_async_bit,
    output logic [BUS-1:0] o_synced_bit
);

logic [NO_STAGES:0] stages;
genvar i;

// setup
assign stages[0]    = i_async_bit;

// stages logic
generate
    for ( i=0 ; i<NO_STAGES ; i=i+1 ) begin
        dff #(.BUS(BUS)) u_i(
            .i_clk(i_clk),
            .i_arst_n(i_arst_n),
            .i_d(stages[i]),
            .o_q(stages[i+1])
        );
    end
endgenerate

// output
assign o_synced_bit = stages[NO_STAGES];

endmodule
