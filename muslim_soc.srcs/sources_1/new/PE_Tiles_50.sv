

// PE_ROW
module PE_Tiles_16 #(parameter DATA_WIDTH = 8,
              parameter NUM_MULTIPLIERS = 384/(3*DATA_WIDTH),
              parameter MAIN_ADDRESS_BITS = $clog2(NUM_MULTIPLIERS * 3),
              parameter IB_ADDRESS_BITS = $clog2(NUM_MULTIPLIERS * 3 / 2)
              )(
        /*        address_input_buffer,
				address_main_memory,
				address_weight_buffer,
				BL, 
				BLA, */
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB0,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB1,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB2,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB3,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB4,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB5,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB6,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB7,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB8,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB9,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB10,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB11,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB12,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB13,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB14,
//				input  [NUM_MULTIPLIERS-1:0] OUT_IB15,


		/*	    W_EN, 
				Read_EN,
				clk,
				IMC,
				EN_IB,
				EN_W,
				read,
				write,
				mem_out,
				latch_MC_En,
				MC,
				MAC_result*/
				input [IB_ADDRESS_BITS-1:0] address_input_buffer,
                    input [MAIN_ADDRESS_BITS-1:0] address_main_memory,
                    input [799:0] OUT_IB,
                    input clk, IMC,EN_W, read,write,
                    input [15:0] EN_IB,
                    input [DATA_WIDTH-1:0] BL, BLA,
                    input Read_EN,W_EN,
                    input [4:0] address_weight_buffer,
                    input WL_N,
                    input WL_SH,
                    input [DATA_WIDTH-1:0] WL_SL,
                    input rst,
                    input [7:0] iter_no,

                    
                    output [DATA_WIDTH-1:0]mem_out,
                    output reg   MC ,
                    output reg latch_MC_En ,
                    output [DATA_WIDTH-1:0] MAC_result,
                    output [(2*DATA_WIDTH*16)-1:0] m

    );
    

    
    wire latch_MC_En_internal [15:0];
    wire MC_internal [15:0];
    wire [DATA_WIDTH-1:0] Lq [NUM_MULTIPLIERS-1:0];
    wire [DATA_WIDTH-1:0] highq [NUM_MULTIPLIERS-1:0];
    wire [DATA_WIDTH-1:0] BLB,  stored_value_bar1, stored_value_bar2, out1,out2;
    wire [DATA_WIDTH-1:0] C0L;
    
    
    
    wire [DATA_WIDTH:0] S [NUM_MULTIPLIERS-1:0];
    wire [DATA_WIDTH:0] S_not [NUM_MULTIPLIERS-1:0];

//    wire [NUM_MULTIPLIERS-1:0] OUT [49:0]; //A
    wire [(1<<MAIN_ADDRESS_BITS)-1:0] Dout;
    wire [DATA_WIDTH-1:0] OUT_WB;
    assign BLB = ~BL;
    
    wire [DATA_WIDTH-1:0] output_buffer_lsw [15:0]; //lower significant word[32 bits]
    wire [DATA_WIDTH-1:0] output_buffer_msw [15:0]; //Upper significant word[32 bits]
    wire [DATA_WIDTH-1:0] output_port [(1<<MAIN_ADDRESS_BITS)-1:0];

    
genvar i;
generate    
    for(i=0;i<16;i=i+1) begin: IMCU_Gen
    IMCU IMCU_init (
    .address_input_buffer(address_input_buffer), //ok
    .address_main_memory(address_main_memory), //ok
    .BL(OUT_WB),//ok
    .BLA(BLA),//ok
    .clk(clk),//ok
    .IMC(IMC),//ok
    .EN_IB(EN_IB[i]),//ok
    .EN_W(EN_W),//ok
    .read(read),//ok
    .write(write),//ok
    .mem_out(imcu), 
    .OUT(OUT_IB[i*16+:16]), //remove this hardwire
    .WL_N(WL_N),
    .WL_SH(WL_SH),
    .rst(rst),
    .C0L(C0L),
    .WL_SL(WL_SL),
    .latch_MC_En(latch_MC_En_internal[i]),//ok
    .MC(MC_internal[i]),//ok
    .tree_out_lsw(output_buffer_lsw[i]),// lower 8 bits of output buffer
    .tree_out_msw(output_buffer_msw[i]) // upper 8 bits of output buffer
    );
    end
    endgenerate
    
//genvar s;
//generate
//    for(s=0;s<50;s=s+1) begin: IB_Gen
//    INPUT_BUFFER #(.ADDR(IB_ADDRESS_BITS),
//                       .DATA_WIDTH(DATA_WIDTH),
//                       .X(NUM_MULTIPLIERS)) IB1(clk,address_input_buffer, BLA, EN_IB[s],C0L,OUT[s]);
//    end
//endgenerate



WEIGHT_BUFFER WB(clk,address_weight_buffer, BL, iter_no, OUT_WB,Read_EN,W_EN);

//accumulator accu1(clk,Address, m[0] , accu_OUT, Read_EN,MC);
//accumulator accu2(clk,Address, m[1] , accu_OUT, Read_EN,MC);
//accumulator accu3(clk,Address, m[2] , accu_OUT, Read_EN,MC);
//accumulator accu4(clk,Address,m[3] , accu_OUT, Read_EN,MC);
//accumulator accu5(clk,Address, m[4] , accu_OUT, Read_EN,MC);
//accumulator accu6(clk,Address, m[5] , accu_OUT, Read_EN,MC);
//accumulator accu7(clk,Address, m[6] , accu_OUT, Read_EN,MC);
//accumulator accu8(clk,Address, m[7] , accu_OUT, Read_EN,MC);
//accumulator accu9(clk,Address, m[8] , accu_OUT, Read_EN,MC);
//accumulator accu10(clk,Address, m[9] , accu_OUT, Read_EN,MC);
//accumulator accu11(clk,Address, m[10] , accu_OUT, Read_EN,MC);
//accumulator accu12(clk,Address, m[11] , accu_OUT, Read_EN,MC);
//accumulator accu13(clk,Address, m[12] , accu_OUT, Read_EN,MC);
//accumulator accu14(clk,Address, m[13] , accu_OUT, Read_EN,MC);
//accumulator accu15(clk,Address, m[14] , accu_OUT, Read_EN,MC);
//accumulator accu16(clk,Address, m[15] , accu_OUT, Read_EN,MC);


//Timing_control #(.DATA_WIDTH(DATA_WIDTH)) TC1(clk, IMC, WL_N, WL_SH, rst, C0L, WL_SL);



genvar j;
generate
    for (j = 0; j < 16; j = j + 1) begin : assign_m
        assign m[j*16 +: 16] = {output_buffer_msw[j], output_buffer_lsw[j]};
    end
endgenerate

  
//adder_tree_50 u_adder_tree (
//    .A1 (m[0]),   .A2 (m[1]),   .A3 (m[2]),   .A4 (m[3]),   .A5 (m[4]),
//    .A6 (m[5]),   .A7 (m[6]),   .A8 (m[7]),   .A9 (m[8]),   .A10(m[9]),
//    .A11(m[10]),  .A12(m[11]),  .A13(m[12]),  .A14(m[13]),  .A15(m[14]),
//    .A16(m[15]),  .A17(m[16]),  .A18(m[17]),  .A19(m[18]),  .A20(m[19]),
//    .A21(m[20]),  .A22(m[21]),  .A23(m[22]),  .A24(m[23]),  .A25(m[24]),
//    .A26(m[25]),  .A27(m[26]),  .A28(m[27]),  .A29(m[28]),  .A30(m[29]),
//    .A31(m[30]),  .A32(m[31]),  .A33(m[32]),  .A34(m[33]),  .A35(m[34]),
//    .A36(m[35]),  .A37(m[36]),  .A38(m[37]),  .A39(m[38]),  .A40(m[39]),
//    .A41(m[40]),  .A42(m[41]),  .A43(m[42]),  .A44(m[43]),  .A45(m[44]),
//    .A46(m[45]),  .A47(m[46]),  .A48(m[47]),  .A49(m[48]),  .A50(m[49]),

//    .tree_out(MAC_result)
//);

 logic temp[0:15]; // temporary signals for the AND chain

    // initialize first element
    assign temp[0] = MC_internal[0];

    genvar k;
    generate
        for (k = 1; k < 16; k = k + 1) begin : and_chain
            assign temp[k] = temp[k-1] & MC_internal[k];
        end
    endgenerate

    assign MC = temp[15]; // final AND of all 50 signals

 logic temp2[0:15]; // temporary signals for the AND chain

    // initialize first element
    assign temp2[0] = latch_MC_En_internal[0];

    genvar l;
    generate
        for (l = 1; l < 16; l = l + 1) begin : and_chain2
            assign temp2[l] = temp2[l-1] & latch_MC_En_internal[l];
        end
    endgenerate

    assign latch_MC_En = temp2[15]; // final AND of all 50 signals
    
endmodule
