module error_check
  (
    input logic         i_arst_n,        //  Active low reset.
    input logic         i_enable,        //  enable from the sipo unit for the flags.
    input logic         i_par_en,
    input logic         i_parity_bit,    //  The parity bit from the frame for comparison.
    input logic         i_stop_bit,      //  The Stop bit from the frame for comparison.
    input logic         i_par_typ,       //  Parity type agreed upon by the Tx and Rx units.
    input logic  [7:0]  i_raw_data,      //  The 8-bits data separated from the data frame.

    //  bus of two bits, each bit is a flag for an error
    //  error_flag[0] ParityError flag
    //  error_flag[1] StopError flag.
    output logic [1:0]   o_error_flag,
    output logic         o_done_flag,
    output logic [7:0]   o_data
  );

  //  Internal
  logic error_parity;


  // parity check
  assign error_parity = i_par_typ? !(((^i_raw_data) && !i_parity_bit) || (!(^i_raw_data) && i_parity_bit)) : !((!(^i_raw_data) && !i_parity_bit) || ((^i_raw_data) && i_parity_bit));

  // flags logic
  always_comb begin
    if (!i_arst_n) begin
      o_error_flag = 2'b00;
    end
    else begin
      if (i_enable) begin
        o_error_flag[1] = !(i_stop_bit);
        if (i_par_en) o_error_flag[0] = error_parity;
        else          o_error_flag[0] = 1'b0;
      end
      else begin 
        o_error_flag = 2'b00;
      end
    end
  end

  // output logic
  always_comb begin
    if (i_enable && (o_error_flag == 2'b00)) begin 
      o_data      = i_raw_data;
      o_done_flag = 1'b1;
    end
    else begin
      o_data      = 8'b1111_1111;
      o_done_flag = 1'b0;
    end
  end

endmodule