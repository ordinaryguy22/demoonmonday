`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2025 04:09:01 PM
// Design Name: 
// Module Name: START_FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module START_FSM(

    input clk,

    input imc,

    output reg rst,

    output reg start

);

    // State encoding           // State description

    parameter IDLE    = 2'b00;  // Wait for the IMC to go high 

    parameter RESET   = 2'b01;  // Set the rst and reset the start signal

    parameter START   = 2'b10;  // Reset the rst and set the start signal

    parameter ALLDONE = 2'b11;  // Wait until the IMC goes low



    reg [1:0] current_state, next_state;



    always @(posedge clk) begin

        current_state <= next_state;

    end



    always @(*) begin

        // Default outputs

        rst = 0;

        start = 0;



        case (current_state)

            IDLE: begin

                if (imc)

                    next_state = RESET;

                else 

                    next_state = IDLE;

            end

            

            RESET: begin

                rst = 1;

                start = 0;

                next_state = START;

            end

            

            START: begin

                rst = 0;

                start = 1;

                next_state = ALLDONE;

            end



            ALLDONE: begin

                rst = 0;

                start = 0;

                next_state = (!imc) ? IDLE : ALLDONE;

            end



            default: 

                next_state = IDLE;

        endcase

    end



endmodule




