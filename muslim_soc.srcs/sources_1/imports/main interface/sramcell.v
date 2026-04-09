module sramcell(
    input clk,    // Global clock
    input WL,     // Word Line (Enables Read/Write)
    input BL,     // Bit Line (Data to write)
    input BLB,    // Bit Line Bar (Complement of BL)
    input read,   // Read enable
    input write,  // Write enable
    output reg stored_value,       // Stored bit
    output reg stored_value_bar,  // Complement of stored value
    output reg out                 // Output when reading
);

// Write operation (synchronous to global clock)
always @(posedge clk) begin
    if (WL && write) begin
        stored_value <= BL;  // Write data when WL and write are active
        stored_value_bar <= BLB;
    end
end

// Read operation (combinational)
always @(*) begin
    if (WL && read) 
        out = stored_value;  // Output stored value on read
    else 
        out = 1'b0;          // Avoid high-impedance state for FPGA
end

endmodule
