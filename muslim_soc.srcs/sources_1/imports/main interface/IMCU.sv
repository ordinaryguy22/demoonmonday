`timescale 1ns / 1ps

module IMCU #(parameter DATA_WIDTH = 8,
              parameter NUM_MULTIPLIERS = 384/(3*DATA_WIDTH),
              parameter MAIN_ADDRESS_BITS = $clog2(NUM_MULTIPLIERS * 3),
              parameter IB_ADDRESS_BITS = $clog2(NUM_MULTIPLIERS * 3 / 2)
              )
              (address_input_buffer,
				address_main_memory,
				BL, 
				BLA, 
				clk,
				IMC,
				EN_IB,
				EN_W,
				read,
				write,
				OUT,
				WL_N,
				WL_SH,
				rst,
				C0L,
				WL_SL,
				mem_out,
				latch_MC_En,
				MC,
				//address output 
				tree_out_lsw,// lower 32 bits of output buffer
				tree_out_msw // upper 32 bits of output buffer
				
				);
				

input [IB_ADDRESS_BITS-1:0] address_input_buffer;
input [MAIN_ADDRESS_BITS-1:0] address_main_memory;
input clk, IMC, EN_IB,EN_W, read,write;
input [DATA_WIDTH-1:0] BL, BLA;
input [NUM_MULTIPLIERS-1:0] OUT; //A
input WL_N, WL_SH,rst;
input [DATA_WIDTH-1:0] C0L, WL_SL;

output [DATA_WIDTH-1:0]mem_out;
output reg   MC,latch_MC_En;
wire [DATA_WIDTH-1:0] Lq [NUM_MULTIPLIERS-1:0];
wire [DATA_WIDTH-1:0] highq [NUM_MULTIPLIERS-1:0];
wire [DATA_WIDTH-1:0] BLB, stored_value_bar1, stored_value_bar2, out1,out2;

wire [DATA_WIDTH:0] S [NUM_MULTIPLIERS-1:0];
wire [DATA_WIDTH:0] S_not [NUM_MULTIPLIERS-1:0];
wire read,write;
wire [(1<<MAIN_ADDRESS_BITS)-1:0] Dout;
assign BLB = ~BL;

wire [(4*DATA_WIDTH)-1:0] m [NUM_MULTIPLIERS-1:0];
output wire [DATA_WIDTH-1:0] tree_out_lsw; //lower significant word[32 bits]
output wire [DATA_WIDTH-1:0] tree_out_msw; //Upper significant word[32 bits]
wire [DATA_WIDTH-1:0] output_port [(1<<MAIN_ADDRESS_BITS)-1:0];




//	//drive the multiplication complete flag
//    reg WL_SL_triggered;
//    always @(posedge clk) begin
//        latch_MC_En <= 1'b0;
//        MC          <= 1'b0;
    
//        if (WL_SL_triggered) begin
//            latch_MC_En <= 1'b1;
//            MC          <= 1'b1;
//        end
    
//        WL_SL_triggered <= (WL_SL[31] == 1);
//    end
    
    always @(*) begin
        latch_MC_En <= 1'b0;
        MC          <= 1'b0;
        if(WL_SL[7] == 1)begin
            latch_MC_En <= 1'b1;
            MC          <= 1'b1;
        end
    end
    
    
    

genvar j;
generate
    for (j = 0; j < NUM_MULTIPLIERS; j = j + 1) begin : assign_m
        assign m[j] = {highq[j], Lq[j]};
    end
endgenerate




Decoder #(.N(MAIN_ADDRESS_BITS), 
          .X(1<<MAIN_ADDRESS_BITS)) d1(address_main_memory ,EN_W, Dout);

genvar i;
generate
    for (i = 0; i < NUM_MULTIPLIERS; i = i + 1) begin : mult_inst
        multiplierNbit #(.DATA_WIDTH(DATA_WIDTH)) mult (
            .clk(clk),
            .BL(BL),
            .BLB(BLB),
            .A(OUT[i]),
            .rst(rst),
            .WL1(Dout[i*3]), .WL2(Dout[i*3+1]), .WL3(Dout[i*3+2]),
            .read(read),
            .write(write),
            .WL_SH(WL_SH),
            .WL_N(WL_N),
            .WL_SL(WL_SL),
            .S(S[i]),       // Assuming S0, S1, ... are indexed
            .S_not(S_not[i]),   // Assuming S_not0, S_not1, ... are indexed
            .Lq(Lq[i]),      // Assuming Lq0, Lq1, ... are indexed
            .highq(highq[i]),   // Assuming highq0, highq1, ... are indexed
            .sramout(output_port[i*3]), 
            .highout(output_port[i*3+1]), 
            .lowout(output_port[i*3+2])
        );
    end
endgenerate


adder_tree u_adder_tree (
    .A1(m[0]),  .A2(m[1]),  .A3(m[2]),  .A4(m[3]),  .A5(m[4]),
    .A6(m[5]),  .A7(m[6]),  .A8(m[7]),  .A9(m[8]),  .A10(m[9]),
    .A11(m[10]), .A12(m[11]), .A13(m[12]), .A14(m[13]), .A15(m[14]),
    .A16(m[15]),
    .tree_out({tree_out_msw,tree_out_lsw})
);



sramcell32bit sc1(clk,Dout[(1<<MAIN_ADDRESS_BITS)-2], BL, read, write, output_port[(1<<MAIN_ADDRESS_BITS)-2]);
sramcell32bit sc2(clk,Dout[(1<<MAIN_ADDRESS_BITS)-1], BL, read, write, output_port[(1<<MAIN_ADDRESS_BITS)-1]);


//wire [63:0] A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, A26, A27, A28, A29, A30, A31, A32, A33, A34, A35, A36, A37, A38, A39, A40, A41, A42;
//wire [63:0] tree_out;

//adder_tree adder(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, A26, A27, A28, A29, A30, A31, A32, A33, A34, A35, A36, A37, A38, A39, A40, A41, A42, tree_out);


endmodule


