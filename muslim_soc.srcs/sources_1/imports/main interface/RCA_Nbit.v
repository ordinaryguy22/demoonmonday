`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 10:00:43 PM
// Design Name: 
// Module Name: rca32bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module  RCA_Nbit #(parameter WIDTH = 32) (
    input  [WIDTH-1:0] M,
    input  [WIDTH-1:0] N,
    output [WIDTH:0]   S,
    output [WIDTH:0]   S_not
);
    wire [WIDTH:0] Carry;
    assign Carry[0] = 1'b0; // Initial carry-in is 0

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : RCA
            full_adder fa (
                .A(M[i]),
                .B(N[i]),
                .Ci(Carry[i]),
                .S(S[i]),
                .S_not(S_not[i]),
                .Co(Carry[i+1]),
                .Co_not() // Unused in this case
            );
        end
    endgenerate

    assign S[WIDTH] = Carry[WIDTH]; // Final carry-out
    assign S_not[WIDTH] = ~Carry[WIDTH]; // Final carry-out complement
endmodule
