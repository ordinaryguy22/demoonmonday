module Output_Buffer #(
    parameter ADDR = 8,          // 256 locations
    parameter DATA_WIDTH = 16,   // each entry stores 16-bit multiplied result
    parameter DEPTH = 256
)(
    input clk,
    input [ADDR-1:0] Address,
    input [DATA_WIDTH-1:0] in,
    input W_EN,
    input Read_EN,
    output reg [DATA_WIDTH-1:0] OUT
);

    reg [DATA_WIDTH-1:0] output_cells [0:DEPTH-1];
    integer i;

    initial begin
        for(i = 0; i < DEPTH; i = i+1)
            output_cells[i] = 0;
    end

    always @(posedge clk) begin
        if(W_EN)
            output_cells[Address] <= in;
        else if(Read_EN)
            OUT <= output_cells[Address];
        else
            OUT <= 0;
    end

endmodule
