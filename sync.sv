module sync
#(
    parameter WIDTH = 4
)
(
    input clk,
    input logic rst_n,
    input logic [WIDTH-1:0] in,

    output logic [WIDTH-1:0] out_synced
);

logic [WIDTH-1:0] stg_1, stg_2;

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        stg_1 <= 'b0;
        stg_2 <= 'b0;
    end
    else begin
        stg_1 <= in;
        stg_2 <= stg_1;
    end
end

assign out_synced = stg_2;

endmodule
