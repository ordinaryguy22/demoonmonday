

module WEIGHT_BUFFER #(parameter ADDR = 5,parameter DATA_WIDTH = 8,
                  
                      parameter X=400)
                      (clk,Address, BL ,iter_no, OUT, Read_EN,W_EN); // EN IS AN INPUT TOO
input [ADDR-1:0] Address;
input [DATA_WIDTH-1:0] BL, iter_no;
input clk;
input Read_EN;
input W_EN;
output reg [DATA_WIDTH-1:0] OUT;




reg [DATA_WIDTH-1 :0] weight_data [X-1:0]  ;
reg [DATA_WIDTH-1:0] BL_reg;

integer i;
initial begin
for(i =0;i<16;i=i+1) begin
weight_data[i]<=0;
end

end

always@(posedge clk)begin
//BL_reg <= BL;
if(W_EN) begin
weight_data[Address] <= BL;
end

else if (Read_EN) 
OUT<=weight_data[iter_no*Address];

else begin
OUT<=8'b0;
end

end


endmodule
