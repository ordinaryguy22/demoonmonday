module accumulator #(parameter ADDR = 5,parameter DATA_WIDTH = 16,
                  
                      parameter X=16)
                      (clk,/*Address*/, PE_out , accu_OUT, Read_EN,W_EN); // EN IS AN INPUT TOO
//input [ADDR-1:0] Address;
input [DATA_WIDTH-1:0] PE_out;
input clk;
input Read_EN;
input W_EN;
output reg [DATA_WIDTH-1:0] accu_OUT;

reg [DATA_WIDTH-1 :0] accu;
reg [DATA_WIDTH-1:0] BL_reg;

integer i;
initial begin
accu<=0;
end

always@(posedge clk)begin
//BL_reg <= BL;
if(W_EN) begin
accu <= accu + PE_out;
end

else if (Read_EN) 
accu_OUT<=accu;

else begin
accu_OUT<=8'b0;
end

end


endmodule
