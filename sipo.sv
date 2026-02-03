module sipo
  (
    input  logic         i_arst_n,         //  Active low reset.
    input  logic         i_rx_in,          //  Serial Data recieved from the transmitter.
    input  logic         i_clk,            //  The clocking input comes from the sampling unit.
    input  logic  [5:0]  i_prescale,     //  signal specifies the oversampling value.

    output logic          o_active_flag,    //  outputs logic 1 when data is in progress.
    output logic          o_recieved_flag,  //  outputs a signal enables the deframe unit. 
    output logic  [10:0]  o_data_parll      //  outputs the 11-bit parallel frame.
  );
  //  Internal
  logic [5:0]  final_value;
  logic [4:0]  center_value;
  logic [3:0]  frame_counter;
  logic [4:0]  stop_count;
  logic [2:0]  test_data;
  logic        sampled_bit;

  //  Encoding the states of the reciever
  typedef enum logic[1:0] {IDLE, CENTER, FRAME} states_t;
  states_t next_state;

  // Constants
  localparam sampl8  = 6'd8,
            sampl16 = 6'd16,
            sampl32 = 6'd32;

  // prescaling
  always_comb begin
    unique case (i_prescale)
      sampl8 : begin
        center_value = 5'd4;     //  8  sample rate.
        final_value  = 6'd8;
      end
      sampl16: begin
        center_value = 5'd8;     //  16 sample rate.
        final_value  = 6'd16;
      end 
      sampl32: begin
        center_value = 5'd16;    //  32 sample rate.
        final_value  = 6'd32;
      end
      default: begin
        center_value = 5'd4;     //  8  sample rate.
        final_value  = 6'd8;
      end
    endcase
  end

  // oversampling
  always_comb begin
    case (test_data)
      3'b000 : sampled_bit = 1'b0;
      3'b001 : sampled_bit = 1'b0;
      3'b010 : sampled_bit = 1'b0;
      3'b011 : sampled_bit = 1'b1;
      3'b100 : sampled_bit = 1'b0;
      3'b101 : sampled_bit = 1'b1;
      3'b110 : sampled_bit = 1'b1;
      3'b111 : sampled_bit = 1'b1;
    endcase
  end

  //  FSM with Asynchronous Reset logic
  always_ff @(posedge i_clk, negedge i_arst_n) 
  begin
    if (!i_arst_n) begin
      next_state      <= IDLE;
      o_data_parll    <= {11{1'b1}};
      stop_count      <= 4'd0;
      frame_counter   <= 4'd0;
      test_data       <= 3'b0;
      o_recieved_flag <= 1'b0;
      o_active_flag   <= 1'b0;
    end
    else begin
      unique case (next_state)

        IDLE : begin
          // o_data_parll    <= {11{1'b1}};
          stop_count      <= 4'd0;
          frame_counter   <= 4'd0;
          o_recieved_flag <= 1'b0;
          o_active_flag   <= 1'b0;
          if(!i_rx_in) begin
            next_state    <= CENTER;
            o_active_flag <= 1'b1;
          end
          else begin
            next_state    <= IDLE;
            o_active_flag <= 1'b0;
          end
        end

        CENTER : begin
          if(stop_count == (center_value-1)) begin
            test_data[0]     <= i_rx_in;
            stop_count       <= 4'd0;
            o_data_parll[10] <= sampled_bit;
            next_state       <= FRAME;
          end
          else if(stop_count == (center_value-2)) begin
            test_data[1]     <= i_rx_in;
            stop_count       <= stop_count + 4'b1;
            next_state       <= CENTER;
          end
          else if(stop_count == (center_value-3)) begin
            test_data[2]     <= i_rx_in;
            stop_count       <= stop_count + 4'b1;
            next_state       <= CENTER;
          end
          else begin
            stop_count  <= stop_count + 4'b1;
            next_state  <= CENTER;
          end
        end

        FRAME : begin
          if(frame_counter == 4'd10) begin
            frame_counter   <= 4'd0;
            o_recieved_flag <= 1'b1;
            next_state      <= IDLE;
            o_active_flag   <= 1'b0;
          end
          else begin
            if(stop_count == (final_value-1)) begin
              test_data[0]   <= i_rx_in;
              frame_counter  <= frame_counter + 4'b1;
              o_data_parll   <= {sampled_bit,o_data_parll[10:1]};
              stop_count     <= 4'd0;
              next_state     <= FRAME;
            end
            else if(stop_count == (final_value-2)) begin
              test_data[1]   <= i_rx_in;
              stop_count     <= stop_count + 4'b1;
              next_state     <= FRAME;
            end
            else if(stop_count == (final_value-3)) begin
              test_data[2]   <= i_rx_in;
              stop_count     <= stop_count + 4'b1;
              next_state     <= FRAME;
            end
            else 
            begin
              stop_count <= stop_count + 4'b1;
              next_state <= FRAME;
            end
          end
        end

        default : begin
          o_data_parll    <= {11{1'b1}};
          stop_count      <= 4'd0;
          frame_counter   <= 4'd0;
          o_recieved_flag <= 1'b0;
          o_active_flag   <= 1'b0;
          next_state      <= IDLE;
        end
      endcase
    end
  end

endmodule