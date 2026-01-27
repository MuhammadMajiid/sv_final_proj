module dual_ngray_cntr  // style #2
#(
    parameter WIDTH = 4
)
(
    input logic clk,
    input logic rst_n,
    input logic inc,
    input logic en,      // full for write ptr module or empty for read ptr module

    output logic [WIDTH-2:0] binaddr,
    output logic  [WIDTH-1:0] grptr
);

logic  [WIDTH-1:0] bin_reg;
logic [WIDTH-1:0] bnext, gnext;
logic inc_en;

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        grptr   <= 'b0;
        bin_reg <= 'b0;
    end
    else begin
        grptr   <= gnext;
        bin_reg <= bnext;
    end
end

assign inc_en = (inc && (!en));
assign bnext = bin_reg + inc_en;
assign gnext = (bnext >> 1) ^ bnext; // bin2gray
assign binaddr = bin_reg[WIDTH-2:0];

endmodule
