module clk_div 
#(
  parameter WIDTH = 8
)
(
  input logic i_clk,
  input logic i_arst_n,
  input logic i_clk_en,
  input logic [(WIDTH-1):0] i_div_ratio,

  output logic o_div_clk
);
logic  [(WIDTH-1):0] counter;
logic [(WIDTH-1):0] temp;
logic clk_div_en;

// Intialization
assign temp       = i_div_ratio >> 1;
assign clk_div_en = (i_clk_en && !((i_div_ratio == 0) || (i_div_ratio == 1)));

//  logic for even N/2, 40H:60L
always_ff @(posedge i_clk, negedge i_arst_n) begin
  if (!i_arst_n) begin
    counter    <= 'd0;
    o_div_clk  <= 1'b1;
  end
  else begin
    if(clk_div_en) begin
      if (counter == (temp - 1'b1)) begin
        o_div_clk <= ~o_div_clk;
        counter   <= 'd0;
      end
      else counter   <= counter + 1'b1;
    end
    else begin
      counter    <= 'd0;
      o_div_clk  <= 1'b0;
    end
  end
end

endmodule
