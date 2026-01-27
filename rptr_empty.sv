module rptr_empty
#(
    parameter WIDTH = 4
)
(
    input rclk,
    input logic rrst_n,
    input logic rinc,
    input logic  [WIDTH-1:0] rq2_wptr,

    output logic [WIDTH-2:0] raddr,
    output logic [WIDTH-1:0] rptr,
    output logic rempty
);

logic  r_empty_w; // read empty logic
logic rempty_val;

dual_ngray_cntr #(WIDTH) r_unit (
    .clk(rclk),
    .rst_n(rrst_n),
    .inc(rinc),
    .en(r_empty_w),

    .binaddr(raddr),
    .grptr(rptr)
);

// Empty flag logic
assign rempty_val = (rptr == rq2_wptr);
always_ff @(posedge rclk, negedge rrst_n) begin
    if (!rrst_n) r_empty_w <= 1'b1;
    else         r_empty_w <= rempty_val;
end
assign rempty = r_empty_w;

endmodule
