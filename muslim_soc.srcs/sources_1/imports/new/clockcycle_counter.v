module clockcycle_counter (
    input wire clk,         // Clock signal
    input wire rst,         // Reset signal (active high)
    output reg [31:0] count // 32-bit counter output
);

    always @(posedge clk or negedge rst) begin
        if (rst==0)
            count <= 32'd0;      // Reset counter to zero
        else
            count <= count + 1;  // Increment by one
    end

endmodule
