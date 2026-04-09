module CLA64bit(a, b, cin, sum, cout);
input [63:0] a, b;
input cin;
output [63:0] sum;
output cout;

wire c1, c2, c3, c4, c5, c6, c7;

CLA8bit cla1(a[7:0], b[7:0], cin, sum[7:0], c1);
CLA8bit cla2(a[15:8], b[15:8], c1, sum[15:8], c2);
CLA8bit cla3(a[23:16], b[23:16], c2, sum[23:16], c3);
CLA8bit cla4(a[31:24], b[31:24], c3, sum[31:24], c4);
CLA8bit cla5(a[39:32], b[39:32], c4, sum[39:32], c5);
CLA8bit cla6(a[47:40], b[47:40], c5, sum[47:40], c6);
CLA8bit cla7(a[55:48], b[55:48], c6, sum[55:48], c7);
CLA8bit cla8(a[63:56], b[63:56], c7, sum[63:56], cout);

endmodule
