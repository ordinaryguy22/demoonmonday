`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2025 10:53:34 PM
// Design Name: 
// Module Name: sramcell32bit
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
module sramcell32bit(clk,WL, BL, read,write, out);
input clk,WL; // word line
input [31:0] BL; // bit line
wire [31:0] BLB; // bit line bar
input read,write;
output [31:0]out;
reg [31:0]stored_value_bar, stored_value;
assign BLB = ~BL;


 // Sequential write operation
    always @(posedge clk) begin
        if (WL && write) begin
            stored_value <= BL;
            stored_value_bar <= BLB;
        end
    end
    // Combinational read operation
    assign out = (WL && read) ? stored_value : 1'bz;

endmodule

