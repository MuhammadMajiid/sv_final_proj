module fifomem
#(
    parameter WIDTH      = 4,
    parameter DATA_WIDTH = 8,
    parameter MEM_DEPTH  = 2**(WIDTH-1)
)(
    input wclk,
    input logic winc,
    input logic wfull,
    input logic [DATA_WIDTH-1:0] wdata,
    input logic [WIDTH-2:0] waddr,
    input logic [WIDTH-2:0] raddr,

    output logic [DATA_WIDTH-1:0] rdata
);

logic wclk_en;    
logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

always_ff @(posedge wclk) begin
    if (wclk_en) mem[waddr] <= wdata;
end

assign wclk_en = (winc && (!wfull));
assign rdata   = mem[raddr];

endmodule
