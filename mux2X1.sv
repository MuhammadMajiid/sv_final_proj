module mux2X1
#(
    parameter BUS = 3
)
(
    input  logic [BUS-1:0] in_0,
    input  logic [BUS-1:0] in_1,
    input  logic           sel,
    output logic [BUS-1:0] out
);

assign out = sel ? in_1 : in_0;

endmodule
