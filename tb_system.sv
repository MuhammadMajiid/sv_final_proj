`timescale 1ns/1ps
module tb_system;

//--------------------------Global Parameters--------------------------//
parameter REGF_DEPTH      = 16; // RF Depth; default 16 *Do not change*
parameter ALU_FUN         = 4;  // ALU Operand Function Width; default 4 *Do not change*
parameter REGF_WIDTH      = 8;  // RF BUS Width; default 8 *Do not change*
parameter ALU_BUSA        = 8;  // ALU Operand A BUS Width; default 8 *Do not change*
parameter ALU_BUSB        = 8;  // ALU Operand B BUS Width; default 8 *Do not change*
parameter FIFO_DATA_WIDTH = 8;  // FIFO Data BUS Width; default 8 *Do not change*
parameter FIFO_WIDTH      = 5;  // FIFO Address Width ; default 4 *Do not change*
parameter SYNC_BUS        = 8;  // DATA Sync BUS Width; default 8 *Do not change*
parameter SYNC_NO_STAGES  = 2;  // FF NO. Stages  
parameter RST_NO_STAGES   = 2;  // FF NO. Stages
parameter CLKDIV_WIDTH    = 6;  // Div Ratio BUS Width for TX clkdiv; default 6 *Do not change*

//--------------------------Local Parameters--------------------------//
parameter SYS_CLKPER  = 10.0;       // 100MHz
parameter UART_CLKPER = 271.26;     // 3.6864 MHz
parameter TX_CLKPER   = 8680.56;    // 115200 Hz
parameter FILE_ITR    = 26;
parameter FRAME_ITR   = 11;
parameter READ_FILE   = "test.txt"; 
parameter WRITE_FILE  = "out.txt";
parameter CHECK_FILE  = "expec_out.txt"; 
parameter STOP_TIME   = (5)*1000_000;


//--------------------------ROM--------------------------//
logic [7:0] rd_mem [0:63];
logic [7:0] wr_mem [0:15];
logic [7:0] expec_out_mem [0:15];
logic [10:0] tb_tx_out_reg;

//--------------------------Internals--------------------------//
logic tx_clk;
logic [10:0] frame;
integer i,j,k, fh;
integer m=0;

//--------------------------Top Interface--------------------------//
logic tb_sys_clk;
logic tb_uart_clk;
logic tb_arst_n;
logic tb_rx_in;

logic tb_tx_out;
logic tb_par_err;
logic tb_stp_err;
logic tb_busy;

//--------------------------DUT--------------------------//
system #(
    .REGF_DEPTH(REGF_DEPTH),
    .ALU_FUN(ALU_FUN),
    .REGF_WIDTH(REGF_WIDTH),
    .ALU_BUSA(ALU_BUSA),
    .ALU_BUSB(ALU_BUSB),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH),
    .FIFO_WIDTH(FIFO_WIDTH),
    .SYNC_BUS(SYNC_BUS),
    .SYNC_NO_STAGES(SYNC_NO_STAGES),
    .RST_NO_STAGES(RST_NO_STAGES),
    .CLKDIV_WIDTH(CLKDIV_WIDTH)
    ) dut (
    .i_sys_clk(tb_sys_clk),
    .i_uart_clk(tb_uart_clk),
    .i_arst_n(tb_arst_n),
    .i_rx_in(tb_rx_in),

    .o_tx_out(tb_tx_out),
    .o_busy(tb_busy),
    .o_par_err(tb_par_err),
    .o_stp_err(tb_stp_err)
);

//--------------------------Init--------------------------//
initial begin
    {tb_sys_clk, tb_uart_clk, tb_arst_n, tb_rx_in} = 4'b0001;
    tx_clk = 1'b0;
    $readmemh(READ_FILE, rd_mem);
    $readmemh(CHECK_FILE, expec_out_mem);
end

//--------------------------Clocking--------------------------//
initial forever #(SYS_CLKPER/2.0)   tb_sys_clk  = ~tb_sys_clk;
initial forever #(UART_CLKPER/2.0)  tb_uart_clk = ~tb_uart_clk;
initial forever #(TX_CLKPER/2.0)    tx_clk      = ~tx_clk;

//--------------------------Providing Input for the system--------------------------//
initial begin
    @(negedge tb_sys_clk);
    tb_arst_n = 1'b1;

    for (i=0; i<FILE_ITR ; i=i+1 ) begin
        //-----------------------------------------
        // Tx Modelling for Input
        frame = {2'b11,rd_mem[i],1'b0};
        for (j=0; j<FRAME_ITR ; j=j+1 ) begin
            @(negedge tx_clk);
            tb_rx_in = frame[j];
        end
        //-----------------------------------------  
    end
end

//--------------------------Write Output--------------------------//
always @(negedge tx_clk) begin
    if (tb_busy) begin     
        tb_tx_out_reg = 'h7ff;
        // Rx Modelling for Output
        for (k=0 ; k<FRAME_ITR ; k=k+1) begin
            @(posedge tx_clk);
            tb_tx_out_reg = {tb_tx_out,tb_tx_out_reg[10:1]};
        end
        wr_mem[m] = tb_tx_out_reg[8:1];
        //----------------------------------------- 
        // write output in a file
        fh = $fopen(WRITE_FILE, "a");
        if (wr_mem[m] == expec_out_mem[m]) begin 
            $fdisplay(fh, "%t:  OUTPUT = %h   ==   EXPECTED = %h   >> Test %0d PASSED", $time, wr_mem[m], expec_out_mem[m], m);
            $display(fh, "%t:  OUTPUT = %h   ==   EXPECTED = %h   >> Test %0d PASSED", $time, wr_mem[m], expec_out_mem[m], m);
        end
        else $fdisplay(fh,"%t:  OUTPUT = %b   !=   EXPECTED = %b   >> Test %0d FAILED", $time, wr_mem[m], expec_out_mem[m], m);
        $fclose(fh);
        m = m + 1;
        //-----------------------------------------
    end
end

//--------------------------Dump--------------------------//
initial
begin
    $dumpfile("system_vcd.vcd");
    $dumpvars;
end

//--------------------------Stop Simulation--------------------------//
initial begin
    #(STOP_TIME) $stop;
end

endmodule
