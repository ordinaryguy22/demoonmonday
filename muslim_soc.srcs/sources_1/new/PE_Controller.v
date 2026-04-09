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
    input clk,
    output [7:0] iter_count
    
    );
    
    localparam  outputs = 16,
                PEs = 256;
                
    reg [7:0] filterspan = 3;
    reg [7:0] channels = 16;
    reg [7:0] imagespan = 30;
    
    assign iter_count = filterspan*filterspan;
    
    reg [8:0] local = 0;
    always @ (posedge clk) begin
    local = imagespan - outputs;
    if(local>0)
    //assign addresses 
    local = local;//placeholder
    else if (local<0)
    
    end
    
endmodule
