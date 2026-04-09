`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 12:30:51 AM
// Design Name: 
// Module Name: INPUT_BUFFER
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

module INPUT_BUFFER #(parameter ADDR = $clog2(X),parameter DATA_WIDTH = 8,
                      parameter X=400)
                      (clk,Address, BL ,EN, iter_no, C0L, actual_OUT);
input [ADDR-1:0] Address;
input [DATA_WIDTH-1:0] BL , C0L;
input clk, EN;
input iter_no;
output reg [16-1:0] actual_OUT;



wire [X-1:0] OUT;
wire [X-1 :0] DOUT;


Decoder #(.N(ADDR),.X(X))AddressDecoder(Address ,EN, DOUT);

genvar i;
generate
    for (i = 0; i < X; i = i + 1) begin : cell_array
        CELL_ARRAY L (clk,DOUT[i], BL, C0L,OUT[i]);
    end
endgenerate

integer f;
always@(*)
begin
for (f=0;f<16;f=f+1) begin
actual_OUT[f] <= OUT[f*iter_no];
end
end

endmodule
