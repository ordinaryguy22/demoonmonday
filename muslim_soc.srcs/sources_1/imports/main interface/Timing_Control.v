
module Timing_control #(parameter DATA_WIDTH = 8) (
    input clk, IMC,
    output reg WL_N, WL_SH,
    output reg rst,
    output [DATA_WIDTH-1:0] C0L, WL_SL
);
    
    // Internal registers
    reg [DATA_WIDTH-1:0] C0L_reg;
    reg [DATA_WIDTH:0] WL_SL_reg;
    
    // State encoding
    localparam IDEL        = 3'b000;
    localparam RESET       = 3'b001;
    localparam INIT        = 3'b010;
    localparam ADD         = 3'b011;
    localparam GEN_PP      = 3'b100;
    localparam STORE_HIGH  = 3'b101;
    localparam STORE_LOW   = 3'b110;
    localparam DONE        = 3'b111;
    
    // FSM registers with synthesis keep hint
    (* keep = "true" *) reg [2:0] current_state;
    (* keep = "true" *) reg [2:0] next_state;
    
    // Output assignments
    assign C0L = C0L_reg;
    assign WL_SL = (current_state == STORE_HIGH) ? WL_SL_reg[DATA_WIDTH:1] : {DATA_WIDTH{1'b0}};
    
    // Combinational next state logic
    always @(*) begin
        case (current_state)
            IDEL:        next_state = IMC ? RESET : IDEL;
            RESET:       next_state = INIT;
            INIT:        next_state = ADD;
            ADD:         next_state = STORE_HIGH;
            STORE_HIGH:  next_state = WL_SL_reg[DATA_WIDTH] ? DONE : GEN_PP;
            GEN_PP:      next_state = ADD;
            DONE:        next_state = IMC ? DONE : IDEL;
            default:     next_state = IDEL;
        endcase
    end
    
    // Combinational output logic
    always @(*) begin
        // Default outputs
        WL_N = 1'b0;
        WL_SH = 1'b0;
        rst = 1'b0;
        
        case (current_state)
            RESET:       rst = 1'b1;
            ADD:         WL_N = 1'b1;
            STORE_HIGH: begin
                WL_N  = 1'b1;
                WL_SH = 1'b1;
            end
            // Other states use default values
        endcase
    end
    
    // Sequential logic (flip-flops)
    always @(posedge clk) begin
        current_state <= next_state;
        
        case (next_state)
            IDEL, RESET, DONE: begin
                C0L_reg <= {DATA_WIDTH{1'b0}};
                WL_SL_reg <= {DATA_WIDTH{1'b0}};
            end
            INIT: begin
                C0L_reg <= {{(DATA_WIDTH-1){1'b0}}, 1'b1};
                WL_SL_reg <= {{(DATA_WIDTH){1'b0}}, 1'b1};
            end
            STORE_HIGH: begin
                WL_SL_reg <= {WL_SL_reg[DATA_WIDTH-1:0], 1'b0};
            end
            GEN_PP: begin
                C0L_reg <= {C0L_reg[DATA_WIDTH-2:0], 1'b0};
            end
        endcase
    end
    
endmodule









/*
module Timing_control #(parameter DATA_WIDTH = 32) (
    input clk, IMC,
    output reg WL_N, WL_SH,
    output reg rst,
    output [DATA_WIDTH-1:0] C0L, WL_SL
);
    
    // Internal registers
    reg [DATA_WIDTH-1:0] C0L_reg;
    reg [DATA_WIDTH:0] WL_SL_reg;
    
    // State encoding
    parameter IDEL = 3'b000;
    parameter RESET = 3'b001;
    parameter INIT = 3'b010;
    parameter ADD = 3'b011;
    parameter GEN_PP = 3'b100;
    parameter STORE_HIGH = 3'b101;
    parameter STORE_LOW = 3'b110;
    parameter DONE = 3'b111;
    
    reg [2:0] current_state, next_state;
    
    // Output assignments
    assign C0L = C0L_reg;
    assign WL_SL = (current_state == STORE_HIGH) ? WL_SL_reg[DATA_WIDTH:1] : {DATA_WIDTH{1'b0}};
    
    // Combinational next state logic
    always @(*) begin
        case (current_state)
            IDEL:    next_state = IMC ? RESET : IDEL;
            RESET:   next_state = INIT;
            INIT:    next_state = ADD;
            ADD:     next_state = STORE_HIGH;
            STORE_HIGH: next_state = WL_SL_reg[DATA_WIDTH] ? DONE : GEN_PP;
            GEN_PP:  next_state = ADD;
            DONE:    next_state = IMC ? DONE : IDEL;
            default: next_state = IDEL;
        endcase
    end
    
    // Combinational output logic
    always @(*) begin
        // Default outputs
        WL_N = 1'b0;
        WL_SH = 1'b0;
        rst = 1'b0;
        
        case (current_state)
            RESET:   rst = 1'b1;
            ADD:     WL_N = 1'b1;
            STORE_HIGH: begin
                WL_N = 1'b1;
                WL_SH = 1'b1;
            end
            // Other states use default values
        endcase
    end
    
    // Sequential logic (flip-flops)
    always @(posedge clk) begin
        current_state <= next_state;
        
        case (next_state)
            IDEL: begin
                C0L_reg <= {DATA_WIDTH{1'b0}};
                WL_SL_reg <= {DATA_WIDTH{1'b0}};
            end
            RESET: begin
                C0L_reg <= {DATA_WIDTH{1'b0}};
                WL_SL_reg <= {DATA_WIDTH{1'b0}};
            end
            INIT: begin
                C0L_reg <= {{(DATA_WIDTH-1){1'b0}}, 1'b1};
                WL_SL_reg <= {{(DATA_WIDTH){1'b0}}, 1'b1};
            end
            STORE_HIGH: begin
                WL_SL_reg <= {WL_SL_reg[DATA_WIDTH-1:0], 1'b0};
            end
            GEN_PP: begin
                C0L_reg <= {C0L_reg[DATA_WIDTH-2:0], 1'b0};
            end
            DONE: begin
                C0L_reg <= {DATA_WIDTH{1'b0}};
                WL_SL_reg <= {DATA_WIDTH{1'b0}};
            end
        endcase
    end
    
endmodule


*/



































































/*
module Timing_control #(parameter DATA_WIDTH = 32) (
    input clk, IMC,
    output reg WL_N, WL_SH,
    output reg rst,
    output [DATA_WIDTH-1:0] C0L, WL_SL
);
    
    // Shift register for C0L and WL_SL
    reg [DATA_WIDTH-1:0] C0L_reg;
    reg [DATA_WIDTH:0] WL_SL_reg;
    assign C0L = C0L_reg;
    
    // State encoding
    parameter IDEL = 3'b000;
    parameter RESET = 3'b001;
    parameter INIT = 3'b010;
    parameter ADD = 3'b011;
    parameter GEN_PP = 3'b100;  // Shift C0L
    parameter STORE_HIGH = 3'b101;
    parameter STORE_LOW = 3'b110; // Shift WL_SH
    parameter DONE = 3'b111;
    
    reg [2:0] current_state, next_state;
    
    assign WL_SL = (current_state == STORE_HIGH) ? WL_SL_reg[DATA_WIDTH:1] : {DATA_WIDTH{1'b0}};
    
    always @(current_state, IMC) begin
        case (current_state)
            IDEL: begin
                C0L_reg = {DATA_WIDTH{1'b0}};
                rst = 1'b0;
                WL_SL_reg = {DATA_WIDTH{1'b0}};
                WL_N = 1'b0;
                WL_SH = 1'b0;
                next_state = (IMC) ? RESET : IDEL;
            end
            RESET: begin
                C0L_reg = {DATA_WIDTH{1'b0}};
                rst = 1'b1;
                WL_SL_reg = {DATA_WIDTH{1'b0}};
                WL_N = 1'b0;
                WL_SH = 1'b0;
                next_state = INIT;
            end
            INIT: begin
                C0L_reg = {{(DATA_WIDTH-1){1'b0}}, 1'b1};
                rst = 1'b0;
                WL_SL_reg = {{(DATA_WIDTH-1){1'b0}}, 1'b1};
                WL_N = 1'b0;
                WL_SH = 1'b0;
                next_state = ADD;
            end
            ADD: begin
                WL_N = 1'b1;
                WL_SH = 1'b0;
                next_state = STORE_HIGH;
            end
            STORE_HIGH: begin
                WL_N = 1'b1;
                WL_SH = 1'b1;
                WL_SL_reg = {WL_SL_reg[DATA_WIDTH-1:0], 1'b0};
                next_state = (WL_SL[DATA_WIDTH-1]) ? DONE : GEN_PP;
            end
            GEN_PP: begin
                WL_N = 1'b0;
                WL_SH = 1'b0;
                C0L_reg = {C0L_reg[DATA_WIDTH-2:0], 1'b0};
                next_state = ADD;
            end
            DONE: begin
                C0L_reg = {DATA_WIDTH{1'b0}};
                rst = 1'b0;
                WL_SL_reg = {DATA_WIDTH{1'b0}};
                WL_N = 1'b0;
                WL_SH = 1'b0;
                next_state = (IMC) ? DONE : IDEL;
            end
            default: next_state = IDEL;
        endcase
    end
    
    always @(posedge clk) begin
        current_state <= next_state;
    end
    
endmodule
*/