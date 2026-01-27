//-----------------Design-----------------\\
module reg_file
//-----------------Parameters-----------------\\
#(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter DEPTH_BUS = $clog2(DEPTH)
)
//-----------------Ports-----------------\\
(
    input  logic                 i_clk,            //  System' clock.
    input  logic                 i_arst_n,         //  Async Active low reset
    input  logic                 i_write_enable,   //  Write enable.
    input  logic                 i_read_enable,    //  read enable.
    input  logic [DEPTH_BUS-1:0] i_address,        //  src_a address.
    input  logic [WIDTH-1:0]     i_write_data,     //  the data to be written in the rf.

    output logic  [WIDTH-1:0]     o_read_data,      //  the data to be read from the rf.
    output logic [WIDTH-1:0]     o_reg0,           //  Reserved for ALU operand A
    output logic [WIDTH-1:0]     o_reg1,           //  Reserved for ALU operand B
    output logic [WIDTH-1:0]     o_reg2,           //  Reserved for UART Config {prescale, parity type, parity enable}
    output logic [WIDTH-1:0]     o_reg3,           //  Reserved for Div Ratio
    output logic                  o_rd_valid        //  Valid Data for read operation
    
);
//-----------------Register-----------------\\
logic [WIDTH-1:0] registers [0:DEPTH-1];
integer i;

//-----------------Write Operation *Syncronously*-----------------\\
always_ff @(posedge i_clk, negedge i_arst_n) 
begin
    if (!i_arst_n) begin
        for ( i=0 ; i<DEPTH ; i=i+1) begin
            registers[i] <= 'b0;
        end
    end
    else begin
        if (i_write_enable && !i_read_enable) registers[i_address] <= i_write_data;
    end
end

assign o_reg0 = registers[0];
assign o_reg1 = registers[1];
assign o_reg2 = registers[2];
assign o_reg3 = registers[3];

//-----------------Read Operation *combinationally*-----------------\\
always_comb begin
    o_read_data = (i_read_enable && !i_write_enable)? registers[i_address] : 'b0;
    o_rd_valid  = (i_read_enable && !i_write_enable);
end

endmodule
