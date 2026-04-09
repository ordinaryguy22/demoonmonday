`timescale 1ns / 1ps



module highlayercell(
    input wire clk,        // Clock signal
    input wire rst,        // Reset signal
    input wire WL,         // Word line
    input wire WL_SH,      // Word line shift
    input wire WL_N,       // Word line negative
    input wire BL,         // Bit line
    input wire BLB,        // Bit line bar
    input wire S,          // Input data
    input wire read,      // Read enable
    input wire write,     // Write enable
    output reg N,          // Output data
    output reg stored_value, // Stored value
   // output reg stored_value_bar, // Stored value bar
    output reg out         // Output
);

    // Internal registers
    reg temp, temp_bar;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset condition
            stored_value <= 1'b0;
         //   stored_value_bar <= 1'b1;
            temp <= 1'b0;
            temp_bar <= 1'b1;
            N <= 1'b0;
            out <= 1'bz;
        end else begin
            // Update stored_value and stored_value_bar
            if (WL && write) begin
               // stored_value <= BL;
           //     stored_value_bar <= BLB;
            end else if (WL_SH ) begin
                stored_value <= S;
            end

            // Update temp and temp_bar
            temp <= stored_value;
         //   temp_bar <= stored_value_bar;

            // Update N
            if (WL_N && ~WL_SH) begin
                N <= stored_value;
            end else begin
                N <= temp;
            end

            // Update out
            if (WL && read) begin
                out <= stored_value;
            end else begin
                out <= 1'bz;
            end
        end
    end

endmodule

