`timescale 1ns / 1ps
module mux #(
    parameter WIDTH = 32, 
    parameter SEL_BITS = 7,                 // Data width
    parameter NUM_INPUTS = 1<<SEL_BITS           // Number of inputs
    // Number of selection bits (calculated automatically)
)(
    input  wire [WIDTH-1:0] in [NUM_INPUTS-1:0], // Array of inputs
    input  wire [SEL_BITS-1:0] sel,         // Select signal
    output wire [WIDTH-1:0] out             // Output signal
);

    assign out = in[sel]; // Direct selection

endmodule
