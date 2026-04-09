`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2025 11:59:13 PM
// Design Name: 
// Module Name: CELL_ARRAY
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

module CELL_ARRAY #(parameter DATA_WIDTH = 8) (
    input clk,
    input WL,
    input [DATA_WIDTH-1:0] BL,
    input [DATA_WIDTH-1:0] C0L,
    output reg OUT_buffer
);
    
 reg [DATA_WIDTH-1:0] data;
    always @(posedge clk)begin
        if(WL) data <= BL;
    end
integer j;   
    always @(*) begin
        OUT_buffer = 1'b0;
        for ( j = 0; j < DATA_WIDTH; j = j + 1) begin
            if (C0L[j] == 1'b1) begin
                OUT_buffer = data[j];
            end 
        end
    end
    
endmodule

