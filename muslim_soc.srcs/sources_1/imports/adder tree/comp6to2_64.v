module comp6to2_64(x1, x2, x3, x4, x5, x6, totalSum);

input [63:0] x1, x2, x3, x4, x5, x6;
output [63:0] totalSum;
wire  [63:0] sum, carry;
wire [63:0] temp;
wire [63:0] cout1, cout2, cout3;
wire Cout;

compressor6to2 c0(x1[0], x2[0], x3[0], x4[0], x5[0], x6[0], 0, 0, 0, cout1[0], cout2[0], cout3[0], sum[0], carry[0]);
compressor6to2 c1(x1[1], x2[1], x3[1], x4[1], x5[1], x6[1], cout1[0], cout2[0], cout3[0], cout1[1], cout2[1], cout3[1], sum[1], carry[1]);
compressor6to2 c2(x1[2], x2[2], x3[2], x4[2], x5[2], x6[2], cout1[1], cout2[1], cout3[1], cout1[2], cout2[2], cout3[2], sum[2], carry[2]);
compressor6to2 c3(x1[3], x2[3], x3[3], x4[3], x5[3], x6[3], cout1[2], cout2[2], cout3[2], cout1[3], cout2[3], cout3[3], sum[3], carry[3]);
compressor6to2 c4(x1[4], x2[4], x3[4], x4[4], x5[4], x6[4], cout1[3], cout2[3], cout3[3], cout1[4], cout2[4], cout3[4], sum[4], carry[4]);
compressor6to2 c5(x1[5], x2[5], x3[5], x4[5], x5[5], x6[5], cout1[4], cout2[4], cout3[4], cout1[5], cout2[5], cout3[5], sum[5], carry[5]);
compressor6to2 c6(x1[6], x2[6], x3[6], x4[6], x5[6], x6[6], cout1[5], cout2[5], cout3[5], cout1[6], cout2[6], cout3[6], sum[6], carry[6]);
compressor6to2 c7(x1[7], x2[7], x3[7], x4[7], x5[7], x6[7], cout1[6], cout2[6], cout3[6], cout1[7], cout2[7], cout3[7], sum[7], carry[7]);
compressor6to2 c8(x1[8], x2[8], x3[8], x4[8], x5[8], x6[8], cout1[7], cout2[7], cout3[7], cout1[8], cout2[8], cout3[8], sum[8], carry[8]);
compressor6to2 c9(x1[9], x2[9], x3[9], x4[9], x5[9], x6[9], cout1[8], cout2[8], cout3[8], cout1[9], cout2[9], cout3[9], sum[9], carry[9]);
compressor6to2 c10(x1[10], x2[10], x3[10], x4[10], x5[10], x6[10], cout1[9], cout2[9], cout3[9], cout1[10], cout2[10], cout3[10], sum[10], carry[10]);
compressor6to2 c11(x1[11], x2[11], x3[11], x4[11], x5[11], x6[11], cout1[10], cout2[10], cout3[10], cout1[11], cout2[11], cout3[11], sum[11], carry[11]);
compressor6to2 c12(x1[12], x2[12], x3[12], x4[12], x5[12], x6[12], cout1[11], cout2[11], cout3[11], cout1[12], cout2[12], cout3[12], sum[12], carry[12]);
compressor6to2 c13(x1[13], x2[13], x3[13], x4[13], x5[13], x6[13], cout1[12], cout2[12], cout3[12], cout1[13], cout2[13], cout3[13], sum[13], carry[13]);
compressor6to2 c14(x1[14], x2[14], x3[14], x4[14], x5[14], x6[14], cout1[13], cout2[13], cout3[13], cout1[14], cout2[14], cout3[14], sum[14], carry[14]);
compressor6to2 c15(x1[15], x2[15], x3[15], x4[15], x5[15], x6[15], cout1[14], cout2[14], cout3[14], cout1[15], cout2[15], cout3[15], sum[15], carry[15]);
compressor6to2 c16(x1[16], x2[16], x3[16], x4[16], x5[16], x6[16], cout1[15], cout2[15], cout3[15], cout1[16], cout2[16], cout3[16], sum[16], carry[16]);
compressor6to2 c17(x1[17], x2[17], x3[17], x4[17], x5[17], x6[17], cout1[16], cout2[16], cout3[16], cout1[17], cout2[17], cout3[17], sum[17], carry[17]);
compressor6to2 c18(x1[18], x2[18], x3[18], x4[18], x5[18], x6[18], cout1[17], cout2[17], cout3[17], cout1[18], cout2[18], cout3[18], sum[18], carry[18]);
compressor6to2 c19(x1[19], x2[19], x3[19], x4[19], x5[19], x6[19], cout1[18], cout2[18], cout3[18], cout1[19], cout2[19], cout3[19], sum[19], carry[19]);
compressor6to2 c20(x1[20], x2[20], x3[20], x4[20], x5[20], x6[20], cout1[19], cout2[19], cout3[19], cout1[20], cout2[20], cout3[20], sum[20], carry[20]);
compressor6to2 c21(x1[21], x2[21], x3[21], x4[21], x5[21], x6[21], cout1[20], cout2[20], cout3[20], cout1[21], cout2[21], cout3[21], sum[21], carry[21]);
compressor6to2 c22(x1[22], x2[22], x3[22], x4[22], x5[22], x6[22], cout1[21], cout2[21], cout3[21], cout1[22], cout2[22], cout3[22], sum[22], carry[22]);
compressor6to2 c23(x1[23], x2[23], x3[23], x4[23], x5[23], x6[23], cout1[22], cout2[22], cout3[22], cout1[23], cout2[23], cout3[23], sum[23], carry[23]);
compressor6to2 c24(x1[24], x2[24], x3[24], x4[24], x5[24], x6[24], cout1[23], cout2[23], cout3[23], cout1[24], cout2[24], cout3[24], sum[24], carry[24]);
compressor6to2 c25(x1[25], x2[25], x3[25], x4[25], x5[25], x6[25], cout1[24], cout2[24], cout3[24], cout1[25], cout2[25], cout3[25], sum[25], carry[25]);
compressor6to2 c26(x1[26], x2[26], x3[26], x4[26], x5[26], x6[26], cout1[25], cout2[25], cout3[25], cout1[26], cout2[26], cout3[26], sum[26], carry[26]);
compressor6to2 c27(x1[27], x2[27], x3[27], x4[27], x5[27], x6[27], cout1[26], cout2[26], cout3[26], cout1[27], cout2[27], cout3[27], sum[27], carry[27]);
compressor6to2 c28(x1[28], x2[28], x3[28], x4[28], x5[28], x6[28], cout1[27], cout2[27], cout3[27], cout1[28], cout2[28], cout3[28], sum[28], carry[28]);
compressor6to2 c29(x1[29], x2[29], x3[29], x4[29], x5[29], x6[29], cout1[28], cout2[28], cout3[28], cout1[29], cout2[29], cout3[29], sum[29], carry[29]);
compressor6to2 c30(x1[30], x2[30], x3[30], x4[30], x5[30], x6[30], cout1[29], cout2[29], cout3[29], cout1[30], cout2[30], cout3[30], sum[30], carry[30]);
compressor6to2 c31(x1[31], x2[31], x3[31], x4[31], x5[31], x6[31], cout1[30], cout2[30], cout3[30], cout1[31], cout2[31], cout3[31], sum[31], carry[31]);
compressor6to2 c32(x1[32], x2[32], x3[32], x4[32], x5[32], x6[32], cout1[31], cout2[31], cout3[31], cout1[32], cout2[32], cout3[32], sum[32], carry[32]);
compressor6to2 c33(x1[33], x2[33], x3[33], x4[33], x5[33], x6[33], cout1[32], cout2[32], cout3[32], cout1[33], cout2[33], cout3[33], sum[33], carry[33]);
compressor6to2 c34(x1[34], x2[34], x3[34], x4[34], x5[34], x6[34], cout1[33], cout2[33], cout3[33], cout1[34], cout2[34], cout3[34], sum[34], carry[34]);
compressor6to2 c35(x1[35], x2[35], x3[35], x4[35], x5[35], x6[35], cout1[34], cout2[34], cout3[34], cout1[35], cout2[35], cout3[35], sum[35], carry[35]);
compressor6to2 c36(x1[36], x2[36], x3[36], x4[36], x5[36], x6[36], cout1[35], cout2[35], cout3[35], cout1[36], cout2[36], cout3[36], sum[36], carry[36]);
compressor6to2 c37(x1[37], x2[37], x3[37], x4[37], x5[37], x6[37], cout1[36], cout2[36], cout3[36], cout1[37], cout2[37], cout3[37], sum[37], carry[37]);
compressor6to2 c38(x1[38], x2[38], x3[38], x4[38], x5[38], x6[38], cout1[37], cout2[37], cout3[37], cout1[38], cout2[38], cout3[38], sum[38], carry[38]);
compressor6to2 c39(x1[39], x2[39], x3[39], x4[39], x5[39], x6[39], cout1[38], cout2[38], cout3[38], cout1[39], cout2[39], cout3[39], sum[39], carry[39]);
compressor6to2 c40(x1[40], x2[40], x3[40], x4[40], x5[40], x6[40], cout1[39], cout2[39], cout3[39], cout1[40], cout2[40], cout3[40], sum[40], carry[40]);
compressor6to2 c41(x1[41], x2[41], x3[41], x4[41], x5[41], x6[41], cout1[40], cout2[40], cout3[40], cout1[41], cout2[41], cout3[41], sum[41], carry[41]);
compressor6to2 c42(x1[42], x2[42], x3[42], x4[42], x5[42], x6[42], cout1[41], cout2[41], cout3[41], cout1[42], cout2[42], cout3[42], sum[42], carry[42]);
compressor6to2 c43(x1[43], x2[43], x3[43], x4[43], x5[43], x6[43], cout1[42], cout2[42], cout3[42], cout1[43], cout2[43], cout3[43], sum[43], carry[43]);
compressor6to2 c44(x1[44], x2[44], x3[44], x4[44], x5[44], x6[44], cout1[43], cout2[43], cout3[43], cout1[44], cout2[44], cout3[44], sum[44], carry[44]);
compressor6to2 c45(x1[45], x2[45], x3[45], x4[45], x5[45], x6[45], cout1[44], cout2[44], cout3[44], cout1[45], cout2[45], cout3[45], sum[45], carry[45]);
compressor6to2 c46(x1[46], x2[46], x3[46], x4[46], x5[46], x6[46], cout1[45], cout2[45], cout3[45], cout1[46], cout2[46], cout3[46], sum[46], carry[46]);
compressor6to2 c47(x1[47], x2[47], x3[47], x4[47], x5[47], x6[47], cout1[46], cout2[46], cout3[46], cout1[47], cout2[47], cout3[47], sum[47], carry[47]);
compressor6to2 c48(x1[48], x2[48], x3[48], x4[48], x5[48], x6[48], cout1[47], cout2[47], cout3[47], cout1[48], cout2[48], cout3[48], sum[48], carry[48]);
compressor6to2 c49(x1[49], x2[49], x3[49], x4[49], x5[49], x6[49], cout1[48], cout2[48], cout3[48], cout1[49], cout2[49], cout3[49], sum[49], carry[49]);
compressor6to2 c50(x1[50], x2[50], x3[50], x4[50], x5[50], x6[50], cout1[49], cout2[49], cout3[49], cout1[50], cout2[50], cout3[50], sum[50], carry[50]);
compressor6to2 c51(x1[51], x2[51], x3[51], x4[51], x5[51], x6[51], cout1[50], cout2[50], cout3[50], cout1[51], cout2[51], cout3[51], sum[51], carry[51]);
compressor6to2 c52(x1[52], x2[52], x3[52], x4[52], x5[52], x6[52], cout1[51], cout2[51], cout3[51], cout1[52], cout2[52], cout3[52], sum[52], carry[52]);
compressor6to2 c53(x1[53], x2[53], x3[53], x4[53], x5[53], x6[53], cout1[52], cout2[52], cout3[52], cout1[53], cout2[53], cout3[53], sum[53], carry[53]);
compressor6to2 c54(x1[54], x2[54], x3[54], x4[54], x5[54], x6[54], cout1[53], cout2[53], cout3[53], cout1[54], cout2[54], cout3[54], sum[54], carry[54]);
compressor6to2 c55(x1[55], x2[55], x3[55], x4[55], x5[55], x6[55], cout1[54], cout2[54], cout3[54], cout1[55], cout2[55], cout3[55], sum[55], carry[55]);
compressor6to2 c56(x1[56], x2[56], x3[56], x4[56], x5[56], x6[56], cout1[55], cout2[55], cout3[55], cout1[56], cout2[56], cout3[56], sum[56], carry[56]);
compressor6to2 c57(x1[57], x2[57], x3[57], x4[57], x5[57], x6[57], cout1[56], cout2[56], cout3[56], cout1[57], cout2[57], cout3[57], sum[57], carry[57]);
compressor6to2 c58(x1[58], x2[58], x3[58], x4[58], x5[58], x6[58], cout1[57], cout2[57], cout3[57], cout1[58], cout2[58], cout3[58], sum[58], carry[58]);
compressor6to2 c59(x1[59], x2[59], x3[59], x4[59], x5[59], x6[59], cout1[58], cout2[58], cout3[58], cout1[59], cout2[59], cout3[59], sum[59], carry[59]);
compressor6to2 c60(x1[60], x2[60], x3[60], x4[60], x5[60], x6[60], cout1[59], cout2[59], cout3[59], cout1[60], cout2[60], cout3[60], sum[60], carry[60]);
compressor6to2 c61(x1[61], x2[61], x3[61], x4[61], x5[61], x6[61], cout1[60], cout2[60], cout3[60], cout1[61], cout2[61], cout3[61], sum[61], carry[61]);
compressor6to2 c62(x1[62], x2[62], x3[62], x4[62], x5[62], x6[62], cout1[61], cout2[61], cout3[61], cout1[62], cout2[62], cout3[62], sum[62], carry[62]);
compressor6to2 c63(x1[63], x2[63], x3[63], x4[63], x5[63], x6[63], cout1[62], cout2[62], cout3[62], cout1[63], cout2[63], cout3[63], sum[63], carry[63]);

assign temp = 2*carry;

CLA64bit add(sum, temp, 0, totalSum, Cout);


endmodule

