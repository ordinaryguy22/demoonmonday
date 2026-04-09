`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 10:01:20 PM
// Design Name: 
// Module Name: full_adder
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

module full_adder (
    input  A, B, Ci,       // Inputs: A, B, and Carry-in
    output S, S_not,        // Outputs: Sum and its complement
    output Co, Co_not       // Outputs: Carry-out and its complement
);
    // Behavioral logic for Sum (S) and Carry-out (Co)
    assign S = A ^ B ^ Ci;  // Sum is the XOR of A, B, and Ci
    assign Co = (A & B) | (Ci & (A ^ B)); // Carry-out logic

    // Complement outputs
    assign S_not = ~S;      // Complement of Sum
    assign Co_not = ~Co;    // Complement of Carry-out
endmodule