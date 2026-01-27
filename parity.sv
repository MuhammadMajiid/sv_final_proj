module parity
  (
    input  logic         i_arst_n,      //  Active low reset.
    input  logic  [7:0]  i_p_data,      //  The data input from the Inlogic unit.
    input  logic         i_data_valid,
    input  logic         i_par_typ,     //  Parity type agreed upon by the Tx and Rx units.

    output logic         o_par_bit      //  The parity bit output for the frame.
  );

  //  Encoding for the parity types
  enum logic {ODD = 1, EVEN = 0} st;

  always_comb
  begin : ParityGen
    if (!i_arst_n) o_par_bit = 1'b0;
    else begin
      if(i_data_valid) begin
        unique case (i_par_typ)
        ODD:     o_par_bit = (^i_p_data)? 1'b0 : 1'b1;
        EVEN:    o_par_bit = (^i_p_data)? 1'b1 : 1'b0; 
        endcase
      end
      else o_par_bit = 1'b0;
    end
  end

endmodule
