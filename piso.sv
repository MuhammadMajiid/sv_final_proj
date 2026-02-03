module piso
    (
        input logic           i_clk,        //  Clocking signal
        input logic           i_arst_n,     //  Active low reset.
        input logic           i_data_valid, //  An enable to start sending data.
        input logic           i_par_en,
        input logic           i_par_bit,    //  The parity bit from the Parity unit.
        input logic [7:0]     i_p_data,     //  The data input.
    
        output logic 	      o_tx, 	    //  Serial transmitter's data out
        output logic 	      o_busy        //  high when Tx is transmitting, low when idle.
    );

    //  Internal declarations
    logic [3:0]   stop_count;
    logic [10:0]  frame_r;
    logic [10:0]  frame_man;
    logic         count_full;

    //  Encoding the states
    typedef enum logic {IDLE, ACTIVE} states_t;
    states_t next_state;

    //  Frame generation
    always_ff @(posedge i_clk, negedge i_arst_n) begin
        if (!i_arst_n)          frame_r <= {11{1'b1}};
        else begin
            if (i_data_valid && (next_state == IDLE)) begin
                if (i_par_en)   frame_r <= {1'b1,i_par_bit,i_p_data,1'b0};
                else            frame_r <= {2'b11,i_p_data,1'b0};
            end
            else                frame_r <= frame_man;
        end
    end

    // Counter logic
    always_ff @(posedge i_clk, negedge i_arst_n) begin
        if      (!i_arst_n)                          stop_count <= 4'd0;
        else if ((next_state == IDLE) || count_full) stop_count <= 4'd0;
        else                                         stop_count <= stop_count + 4'd1;
    end

    assign count_full = (stop_count == 4'd10);

    //  Transmission logic FSM
    always_ff @(posedge i_clk, negedge i_arst_n) begin
        if (!i_arst_n) next_state   <= IDLE;
        else
        begin
            if ((next_state == IDLE)) begin
                if (i_data_valid) next_state   <= ACTIVE;
                else              next_state   <= IDLE;
            end
            else begin
                if (count_full) next_state   <= IDLE;
                else            next_state   <= ACTIVE;
            end
        end 
    end

    always_comb begin
        frame_man = frame_r;
        if (!i_arst_n) begin
            o_tx    = 1'b1;
            o_busy  = 1'b0;
        end
        else begin
            if ((next_state == ACTIVE)) begin
                o_tx    = frame_man[0];
                o_busy      = 1'b1;
                frame_man = frame_r >> 1;
            end
            else begin
                o_tx    = 1'b1;
                o_busy      = 1'b0;
            end
        end
    end

endmodule