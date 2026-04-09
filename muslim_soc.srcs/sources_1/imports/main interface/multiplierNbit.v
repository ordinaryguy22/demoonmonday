`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 10:53:50 PM
// Design Name: 
// Module Name: multiplierNbit
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
module multiplierNbit #(parameter DATA_WIDTH = 32)(clk,BL, BLB, A, rst, WL1, WL2, WL3, read,write, WL_SH, WL_N, WL_SL, S, S_not, Lq, highq,sramout,highout,lowout);
input [DATA_WIDTH-1:0] BL, BLB;
input A, rst,clk;
input WL1, WL2, WL3,write,read; // read, WL1 are common read and word line of sram cells rspc 
input WL_SH, WL_N;  // read, WL2 are common read and word line of high layer cells rspc
input [DATA_WIDTH-1:0] WL_SL ;
output [DATA_WIDTH:0] S, S_not;  //ripple carry adder output
output [DATA_WIDTH-1:0] Lq, highq; //outputs for the adder tree
output [DATA_WIDTH-1:0] sramout,highout,lowout; 
wire [DATA_WIDTH-1:0] highq_bar; 
wire [DATA_WIDTH-1:0] W_bar, W; 
wire [DATA_WIDTH-1:0] Lq_bar;
wire [DATA_WIDTH-1:0] M, N;
wire  A_not;
assign A_not = ~A;

genvar i;
generate
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin : lowlayercell_array
        lowlayercell cell_inst (
            .clk(clk),
            .WL(WL3),
            .WL_SL(WL_SL[i]),
            .write(write),
            .read(read),
            .BL(BL[i]),
            .BLB(BLB[i]),
            .S(S[0]),
            .stored_value(Lq[i]),
            //.stored_value_bar(Lq_bar[i]),
            .out(lowout[i])
        );
    end
endgenerate



genvar j;
generate
    for (j = 0; j < DATA_WIDTH; j = j + 1) begin : sramcell_array
        sramcell cell_inst (
            .clk(clk),
            .WL(WL1),
            .BL(BL[j]),
            .BLB(BLB[j]),
            .read(read),
            .write(write),
            .stored_value(W[j]),
            .stored_value_bar(W_bar[j]),
            .out(sramout[j])
        );
    end
endgenerate



genvar k;

generate

    for (k = 0; k < DATA_WIDTH; k = k + 1) begin : nor_array

        nor nor_inst (M[k], W_bar[k], A_not);

    end

endgenerate

genvar l;
generate
    for (l = 0; l < DATA_WIDTH; l = l + 1) begin : highlayercell_array
        highlayercell hlc_inst (
            .clk(clk),
            .rst(rst),
            .WL(WL2),
            .WL_SH(WL_SH),
            .WL_N(WL_N),
            .BL(BL[l]),
            .BLB(BLB[l]),
            .S(S[l+1]),
            .read(read),
            .write(write),
            .N(N[l]),
            .stored_value(highq[l]),
          //  .stored_value_bar(highq_bar[l]),
            .out(highout[l])
        );
    end
endgenerate

RCA_Nbit #(.WIDTH(DATA_WIDTH)) adder2(M, N, S, S_not);

endmodule
