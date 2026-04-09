module adder_tree(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16,tree_out);
input [15:0] A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16;
output [31:0] tree_out;


wire [63:0] sum1, sum2, sum3, sum4, sum5, sum6;
wire cout1, cout2, cout3, cout4, cout5, cout6, cout;

//adder7input i1(A1, A2, A3, A4, A5, A6, A7, sum1, cout1);
//adder7input i2(A8, A9, A10, A11, A12, A13, A14, sum2, cout2);
//adder7input i3(A15, A16, A17, A18, A19, A20, A21, sum3, cout3);
//assign sum3 = A15 + A16;

assign tree_out = A1 + A2 + A3 + A4 + A5 + A6 + A7 + A8 + A9 + A10 + A11 + A12 + A13 + A14 + A15 + A16;

endmodule



