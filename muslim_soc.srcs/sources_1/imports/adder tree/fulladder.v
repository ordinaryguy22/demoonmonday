module halfadder(
    input x,y,
    output sum,carry
);

xor(sum,x,y);
and(carry,x,y);

endmodule


module fulladder(
    input x,y,z,
    output sum,carry
);

wire c, s, c1;

halfadder HA1(x,y,s,c);
halfadder HA2(z,s,sum,c1);

or OR(carry, c,  c1);

endmodule
