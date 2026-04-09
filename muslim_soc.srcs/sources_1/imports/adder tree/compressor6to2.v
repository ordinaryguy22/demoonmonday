module compressor6to2(x1, x2, x3, x4, x5, x6, cin1, cin2, cin3, cout1, cout2, cout3, sum, carry);

input  x1, x2, x3, x4, x5, x6;
output  sum, carry;
input cin1, cin2, cin3;
output cout1, cout2, cout3;
wire s1, s2, s3;

fulladder fa0(x1, x2, x3, s1, cout2 );
fulladder fa1(x4, x5, x6, s2, cout1 );
fulladder fa2(s1, cin1, cin2, s3, cout3);
fulladder fa3(s3, s2, cin3, sum, carry);


endmodule
