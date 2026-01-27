module baudgenr(
  input wire         i_arst_n,       //  Active low reset.
  input wire         i_clk,          //  The System's main clock 200MHz.
  input wire  [5:0]  i_prescale,   //  Baud Rate agreed upon by the Tx and Rx units.

  output reg         o_clk_scaled    //  Clocking output for the other modules.
);

//  Internal declarations
reg [2:0]  final_value;  //  Holds the number of ticks for each BaudRate.
reg [2:0]  clock_ticks;  //  Counts untill it equals final_value, Timer principle.

//  Encoding the different Baud Rates
localparam sampl8  = 6'd8,
           sampl16 = 6'd16,
           sampl32 = 6'd32;

//  BaudRate 4-1 Mux
always_comb
begin
    unique case (i_prescale)
      //  All these ratio ticks are calculated for 200MHz Clock,
      //  The values shall change with the change of the clock frequency.
      sampl8 : final_value = 3'd2;     //  8  sample rate.
      sampl16: final_value = 3'd1;     //  16 sample rate.
      sampl32: final_value = 3'd0;     //  32 sample rate.
      default: final_value = 3'd2;     //  8  sample rate.
    endcase
end

//  Timer logic
always_ff @(negedge i_arst_n, posedge i_clk) begin
  if(!i_arst_n) begin
    clock_ticks   <= 3'd0;
    o_clk_scaled  <= 1'b0;
  end
  else begin
    if(clock_ticks == (final_value-1)) begin
      o_clk_scaled  <= ~o_clk_scaled;
      clock_ticks   <= 3'd0;
    end
    else clock_ticks   <= clock_ticks + 1'd1;
  end
end

endmodule