module CLA8bit (a, b, cin, sum, cout);
  input [7:0] a, b;
  input cin;
  output [7:0] sum;
  output cout;

  wire [7:0] g, p;
  wire [8:0] c;

  //generate and propagate signals
  assign g = a & b;
  assign p = a ^ b;

  //carry lookahead logic
  assign c[0] = cin;
  assign c[1] = g[0] | (p[0] & c[0]);
  assign c[2] = g[1] | (p[1] & c[1]) | (g[0] & p[1] & c[0]);
  assign c[3] = g[2] | (p[2] & c[2]) | (g[1] & p[2] & c[1]) | (g[0] & p[2] & p[1] & c[0]);
  assign c[4] = g[3] | (p[3] & c[3]) | (g[2] & p[3] & c[2]) | (g[1] & p[3] & p[2] & c[2]) | (g[0] & p[3] & p[2] & p[1] & c[0]);
  assign c[5] = g[4] | (p[4] & c[4]) | (g[3] & p[4] & c[3]) | (g[2] & p[4] & p[3] & c[3]) | (g[1] & p[4] & p[3] & p[2] & c[2]) | (g[0] & p[4] & p[3] & p[2] & p[1] & c[0]);
  assign c[6] = g[5] | (p[5] & c[5]) | (g[4] & p[5] & c[4]) | (g[3] & p[5] & p[4] & c[4]) | (g[2] & p[5] & p[4] & p[3] & c[3]) | (g[1] & p[5] & p[4] & p[3] & p[2] & c[2]) | (g[0] & p[5] & p[4] & p[3] & p[2] & p[1] & c[0]);
  assign c[7] = g[6] | (p[6] & c[6]) | (g[5] & p[6] & c[5]) | (g[4] & p[6] & p[5] & c[5]) | (g[3] & p[6] & p[5] & p[4] & c[4]) | (g[2] & p[6] & p[5] & p[4] & p[3] & c[3]) | (g[1] & p[6] & p[5] & p[4] & p[3] & p[2] & c[2]) | (g[0] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & c[0]);
  assign c[8] = g[7] | (p[7] & c[7]) | (g[6] & p[7] & c[6]) | (g[5] & p[7] & p[6] & c[6]) | (g[4] & p[7] & p[6] & p[5] & c[5]) | (g[3] & p[7] & p[6] & p[5] & p[4] & c[4]) | (g[2] & p[7] & p[6] & p[5] & p[4] & p[3] & c[3]) | (g[1] & p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & c[2]) | (g[0] & p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & c[0]);
  
  //sum
  assign sum = a ^ b ^ c;
  assign cout = c[8];
endmodule
