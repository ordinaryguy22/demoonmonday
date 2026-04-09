module lowlayercell(
    input wire clk,            // Clock signal
    input wire WL,             // Word line
    input wire WL_SL,          // Word line shift
    input wire write,          // Write enable
    input wire read,           // Read enable
    input wire BL,             // Bit line
    input wire BLB,            // Bit line bar
    input wire S,              // Input data
    output reg stored_value,   // Stored value
   // output reg stored_value_bar, // Stored value bar
    output wire out            // Output (combinational read)
);
    // Sequential process for write and shift operations
    always @(posedge clk) begin
        if (WL && write) begin
            // Write operation
//            stored_value <= BL;
           // stored_value_bar <= BLB;
        end else if (WL_SL) begin
            // Shift operation
            stored_value <= S;
           // stored_value_bar <= ~S;
        end
    end
    // Combinational read process
    assign out = (WL && read) ? stored_value : 1'bz;
endmodule
