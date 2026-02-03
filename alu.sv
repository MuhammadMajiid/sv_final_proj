//-----------------Design-----------------\\
module alu
#(
    parameter FUN = 4,
    parameter BUSA = 8,
    parameter BUSB = 8,
    parameter BUSR = BUSA + BUSB
)(
    input  logic            i_clk,
    input  logic            i_arst_n,
    input  logic            i_enable,
    input  logic [FUN-1:0]  i_alu_fun,
    input  logic [BUSA-1:0] i_operan_a,  //  From REGFILE[0]
    input  logic [BUSB-1:0] i_operan_b,  //  From REGFILE[1]

    output logic [BUSR-1:0] o_alu_res,
    output logic            o_valid
);

//-----------------Encodings-----------------\\
localparam  ADD   = 4'b0000,
            SUB   = 4'b0001,
            MUL   = 4'b0010,
            DIV   = 4'b0011,
            AND   = 4'b0100,
            OR    = 4'b0101,
            NAND  = 4'b0110,
            NOR   = 4'b0111,
            XOR   = 4'b1000,
            XNOR  = 4'b1001,
            CMPE  = 4'b1010,
            CMPG  = 4'b1011,
            CMPL  = 4'b1100,
            SLL   = 4'b1101,
            SLR   = 4'b1110;

//-----------------ALU Logic-----------------\\
always_comb begin
    if (i_enable) begin
        o_valid   = 1'b1;
        case (i_alu_fun)
            // Arithmitic Operations
            ADD : o_alu_res = i_operan_a + i_operan_b;
            SUB : o_alu_res = i_operan_a - i_operan_b;
            MUL : o_alu_res = i_operan_a * i_operan_b;
            DIV : o_alu_res = i_operan_a / i_operan_b;
            // Logical Operations
            AND : o_alu_res = i_operan_a & i_operan_b;
            OR  : o_alu_res = i_operan_a | i_operan_b;
            XOR : o_alu_res = i_operan_a ^ i_operan_b;
            NAND: o_alu_res = ~(i_operan_a & i_operan_b);
            NOR : o_alu_res = ~(i_operan_a | i_operan_b);
            XNOR: o_alu_res = ~(i_operan_a ^ i_operan_b);
            // Comparator Operations
            CMPE: o_alu_res = (i_operan_a == i_operan_b);
            CMPG: o_alu_res = (i_operan_a > i_operan_b)? 'd2: 'b0;
            CMPL: o_alu_res = (i_operan_a < i_operan_b)? 'd3: 'b0;
            // Shift Operations
            SLL : o_alu_res = i_operan_a << 1;
            SLR : o_alu_res = i_operan_a >> 1;
            // Default Output
            default: o_alu_res = 'b0;
        endcase
    end
    else begin
        o_alu_res = 'd0;
        o_valid   = 1'b0;
    end
end
// always_ff @(posedge i_clk, negedge i_arst_n) begin
//     if (!i_arst_n) begin
//         o_alu_res <= 'd0;
//         o_valid   <= 1'b0;
//     end
//     else if (i_enable) begin
//         o_valid   <= 1'b1;
//         case (i_alu_fun)
//             // Arithmitic Operations
//             ADD : o_alu_res <= i_operan_a + i_operan_b;
//             SUB : o_alu_res <= i_operan_a - i_operan_b;
//             MUL : o_alu_res <= i_operan_a * i_operan_b;
//             DIV : o_alu_res <= i_operan_a / i_operan_b;
//             // Logical Operations
//             AND : o_alu_res <= i_operan_a & i_operan_b;
//             OR  : o_alu_res <= i_operan_a | i_operan_b;
//             XOR : o_alu_res <= i_operan_a ^ i_operan_b;
//             NAND: o_alu_res <= ~(i_operan_a & i_operan_b);
//             NOR : o_alu_res <= ~(i_operan_a | i_operan_b);
//             XNOR: o_alu_res <= ~(i_operan_a ^ i_operan_b);
//             // Comparator Operations
//             CMPE: o_alu_res <= (i_operan_a == i_operan_b);
//             CMPG: o_alu_res <= (i_operan_a > i_operan_b)? 'd2: 'b0;
//             CMPL: o_alu_res <= (i_operan_a < i_operan_b)? 'd3: 'b0;
//             // Shift Operations
//             SLL : o_alu_res <= i_operan_a << 1;
//             SLR : o_alu_res <= i_operan_a >> 1;
//             // Default Output
//             default: o_alu_res <= 'b0;
//         endcase
//     end
//     else begin
//         o_alu_res <= 'd0;
//         o_valid   <= 1'b0;
//     end
// end

endmodule
