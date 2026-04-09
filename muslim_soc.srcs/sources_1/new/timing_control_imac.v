
module timing_control_imac #(parameter DATA_WIDTH = 8) (
    input clk, MAC, 
    input [7:0] iter_count,
    output reg [4:0] address_weight_buffer,
    output reg [5:0] address_main_memory,
    input initial_addrs_imcu,
    output reg [49:0] EN_IB,
    output reg EN_WB,
    output reg WL_N, WL_SH,
    output reg rst,
    output  [7:0] iter_no,
    output [DATA_WIDTH-1:0] C0L, WL_SL
);
    
    // Internal registers
    reg  EN_IB_internal;
    reg  EN_WB_internal;
    reg [DATA_WIDTH-1:0] C0L_reg;
    reg [DATA_WIDTH:0] WL_SL_reg;
    reg [7:0] iter_no_i;
    reg [7:0] ReadDataM;
    
    assign iter_no = iter_no_i;
    
    // State encoding
    localparam IDEL        = 4'b000;
    localparam RESET       = 4'b001;
    localparam INIT        = 4'b010;
    localparam ADD         = 4'b011;
    localparam GEN_PP      = 4'b100;
    localparam STORE_HIGH  = 4'b101;
    localparam STORE_LOW   = 4'b110;
    localparam DONE        = 4'b111;
    localparam END         = 4'b1000;
    localparam WRITE_WEIGHT_initial = 4'b1001;
    localparam WRITE_WEIGHT  = 4'b1010;
    localparam WRITE_WEIGHT_final = 4'b1011;
    localparam CHECK_COMPLETE_W = 4'b1100;
   
    
    
    reg EN_W,W_EN,write_imcu,read_imcu,Read_EN,DMA_WEN,DMA_REN,latch_En;
    reg [7:0] imcu_mem_in;
    wire [2:0] increment_value_imcu = 3'd4;
    
    // FSM registers with synthesis keep hint
    (* keep = "true" *) reg [3:0] current_state;
    (* keep = "true" *) reg [3:0] next_state;
    
    // Output assignments
    assign C0L = C0L_reg;
    assign WL_SL = (current_state == STORE_HIGH) ? WL_SL_reg[DATA_WIDTH:1] : {DATA_WIDTH{1'b0}};
    
    // Combinational next state logic
    always @(*) begin
        case (current_state)
            IDEL:        next_state = MAC ? RESET : IDEL;
            RESET:       next_state = INIT;
            INIT:        next_state = ADD;
            ADD:         next_state = STORE_HIGH;
            STORE_HIGH:  next_state = WL_SL_reg[DATA_WIDTH-1] ? DONE : GEN_PP;
            GEN_PP:      next_state = ADD;
            DONE:        next_state = (iter_no_i >= iter_count) ? END : WRITE_WEIGHT_initial;
            END:         next_state = IDEL;
            WRITE_WEIGHT_initial: next_state = WRITE_WEIGHT;
            WRITE_WEIGHT: next_state = CHECK_COMPLETE_W;
            CHECK_COMPLETE_W: next_state = WRITE_WEIGHT_final;
            WRITE_WEIGHT_final: next_state = INIT;
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
            RESET:       begin rst = 1'b1; iter_no_i = 8'b0; end
            ADD:         WL_N = 1'b1;
            STORE_HIGH: begin
                WL_N  = 1'b1;
                WL_SH = 1'b1;
              
            end
            WRITE_WEIGHT_initial: begin
//                DMA_ADDRS            = initial_addrs_data_mem;
//                address_main_memory  = initial_addrs_imcu;
//                TC                   = 1'b0;
//                AE                   = 1'b0;
                EN_W                 = 1'b1;
                Read_EN                 =1'b1;
                W_EN                    =1'b0;
                write_imcu           = 1'b1;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB_internal                = 50'b0;
                latch_En             = 1'b0;
                imcu_mem_in          = ReadDataM;  // data from memory to IMCU[weight layer]
            end
    
            WRITE_WEIGHT: begin
//                DMA_ADDRS            = DMA_ADDRS + increment_value_dmem;
//                address_main_memory  = address_main_memory + increment_value_imcu;
//                TC                   = 1'b0;
//                AE                   = 1'b0;
               Read_EN                 =1'b1;
                EN_W                 = 1'b1;
                W_EN                    =1'b0;
                write_imcu           = 1'b1;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB_internal                = 50'b0;
                latch_En             = 1'b0;
                imcu_mem_in          = ReadDataM;
            end
    
            CHECK_COMPLETE_W: begin
//                TC                   = 1'b0;
//                AE                   = 1'b0;
                EN_W                 = 1'b1;
                W_EN                    =1'b0;
                Read_EN                 =1'b1;
                write_imcu           = 1'b1;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB_internal                = 50'b0;
                latch_En             = 1'b0;
            end
           WRITE_WEIGHT_final: begin // hold the write signal for the final Transaction
//                TC                   = 1'b0;
//                AE                   = 1'b0;
                EN_W                 = 1'b1;
                 W_EN                    =1'b0;
                write_imcu           = 1'b1;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB_internal                = 50'b0;
                latch_En             = 1'b0;
                Read_EN                 =1'b0;
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
            DONE: begin
            iter_no_i = iter_no_i+1;
            end
            WRITE_WEIGHT_initial: begin
                     address_weight_buffer <= 0;
                     address_main_memory  <= initial_addrs_imcu;
                    EN_IB <= EN_IB_internal;
                   EN_WB<=EN_WB_internal;
    
            end
            WRITE_WEIGHT:begin
                   // DMA_ADDRS            <= DMA_ADDRS + increment_value_dmem;
                     address_weight_buffer <= address_weight_buffer + 5'b1 ;
                    address_main_memory  <= address_main_memory + increment_value_imcu;
                    EN_IB <= EN_IB_internal;
                   EN_WB<=EN_WB_internal;
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