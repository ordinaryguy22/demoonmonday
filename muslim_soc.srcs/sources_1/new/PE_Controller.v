`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 01:50:26 PM
// Design Name: 
// Module Name: PE_Controller
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


module PE_Controller(
    output [7:0] iter_count
    
    );
    
    localparam  outputs = 16,
                
    reg [7:0] filterspan = 3;
    reg [7:0] channels = 16;
    reg [7:0] imagespan = 30;
    
    assign iter_count = filterspan*filterspan;
    
endmodule
