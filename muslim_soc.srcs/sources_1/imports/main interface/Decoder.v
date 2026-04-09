`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 12:27:35 AM
// Design Name: 
// Module Name: Decoder
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

module Decoder #(
    parameter N =2,  // Number of input bits
    parameter X =4  // Number of output bits (X ? N^2)
)(
    input wire [N-1:0] in,   // N-bit input
    input EN,
    output reg [X-1:0] out   // X-bit output
);

    always @(*) begin
            // Initialize all outputs to 0
             if (!EN) begin
            out = 0;end
              else begin
              
              out = 0;
              out[in] = 1'b1;   // Activate the corresponding output if within range
              end
        end      
endmodule