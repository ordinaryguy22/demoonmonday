module dma_controller#(
    parameter STRIDE = 3,
    parameter INITIAL_ADDRS = 15,
    parameter DATA_WIDTH = 8,
    parameter NUM_LAYERS = 384/(3*DATA_WIDTH),
    parameter MAIN_ADDRESS_BITS = $clog2(NUM_LAYERS * 3),
    parameter IB_ADDRESS_BITS = $clog2(NUM_LAYERS * 3 / 2),
    parameter ROWS=16
)(
    input         clk,
    input         reset,
    input       output_ready,
    // Signals from the address decoder
    input         dir,  // Direction {(0) IMCU to memory || (1) memory to IMCU}
    input         type, // (0)Weight or (1)input
    input         data_valid,
    input  [STRIDE-1:0]  imcu_addrs_stride,
    input  [STRIDE-1:0]  dmem_addrs_stride,
    input  [INITIAL_ADDRS-1:0] initial_addrs_data_mem,
    input  [INITIAL_ADDRS-1:0] initial_addrs_imcu,
    input         TEN,
    // Memory connections
    input      [DATA_WIDTH-1:0] ReadDataM,     // Data from main memory (RAM)
    input      [DATA_WIDTH-2:0] final_address, // final address when the data is being transferred from the IMCU to memory  [CPU READ]
    output reg        DMA_WEN,
    output reg        DMA_REN,
    output reg [DATA_WIDTH-1:0] DMA_WData,
    output reg [32-1:0] DMA_ADDRS,
    // IMCU connections
    input      [DATA_WIDTH-1:0] imcu_out,         // Data coming out of the IMCU
    output reg [IB_ADDRESS_BITS-1:0]  address_input_buffer,
    output reg [MAIN_ADDRESS_BITS-1:0]  address_main_memory,
    output reg [DATA_WIDTH-1:0] imcu_mem_in,       // Data going into the IMCU main memory (BL)
    output reg [DATA_WIDTH-1:0] imcu_buffer_in,    // Data going into the IMCU input buffer (BLA)
    output reg        read_imcu,
    output reg        write_imcu,
    output reg        EN_W,Read_EN,W_EN,
    output reg [15:0] EN_IB,
    output reg [ROWS-1:0] EN_WB,
    // flags
    output         TC, // transaction complete
    output         AE, // address error
    output reg        latch_En,
    input             dma_stall ,
    output reg [4:0] address_weight_buffer,
    output reg [7:0] output_counter,
    output reg EN_OB_Read



);

    // Wires for stride increment values
    wire [STRIDE-1:0] increment_value_dmem;
    wire [STRIDE-1:0] increment_value_imcu;
    assign increment_value_dmem = (dmem_addrs_stride == 1) ? 4'h4 : 4'hz;
    assign increment_value_imcu = (imcu_addrs_stride == 1) ? 4'h1 :
                                   (imcu_addrs_stride == 2) ? 4'h2 :
                                  (imcu_addrs_stride == 3) ? 4'h3 : 4'hz;

    reg TC_reg, AE_reg; // for the Tx complete and Adredd errro
    reg[5:0] wb_count;
    reg [63:0] EN_WB_internal;
    wire [63:0] EN_WB_decoded;
    // State encoding (Decimal)
localparam RESET                  = 0,    // 0
           
           
           WRITE_WEIGHT_initial   = 1,    // 1
           WRITE_WEIGHT           = 2,    // 2
           CHECK_COMPLETE_W       = 3,    // 3
           WRITE_WEIGHT_FINAL     = 4,    // 4
           
           WRITE_INPUT_initial    = 5,    // 5
           WRITE_INPUT            = 6,    // 6
           CHECK_COMPLETE_IB      = 7,    // 7
           WRITE_INPUT_FINAL      = 8,    // 8
           
           IMCU_to_memory_initial = 9,    // 9
           IMCU_to_memory         = 10,   // 10
           CHECK_COMPLETE_MEM     = 11,   // 11
           IMCU_to_memory_FINAL   = 12,   // 12
           
           ERROR                  = 13,   // 13
           DONE                   = 14,   // 14
           LOAD_WEIGHT_initial     =15,
           LOAD_WEIGHT_final       =16,
           LOAD_WEIGHT             =17,
           CHECK_COMPLETE_final    =18,
           WRITE_INPUT_FROM_OUTPUT_INITIAL = 19,
           WRITE_INPUT_FROM_OUTPUT = 20,
           WRITE_INPUT_FROM_OUTPUT_FINAL = 21,
           CHECK_COMPLETE_IB_OUTPUT = 22;
           
    // State registers
    reg [4:0] state, next_state;
    reg [63:0] EN_IB_internal;
    wire [63:0]EN_IB_decoded;
    reg [4:0] out_count;
    
    // Sequential logic: State Register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= RESET;
        else if (~dma_stall)
            state <= next_state;
        //increment logic to aviod race condition
        case(state)
        RESET: begin
                DMA_ADDRS            <= 0;
                address_main_memory  <= 0;
                address_weight_buffer <= 0;
                output_counter <= 0;
                EN_IB <= EN_IB_internal;
                EN_WB<=EN_WB_internal;
        end
        LOAD_WEIGHT_initial: begin
               DMA_ADDRS            <= initial_addrs_data_mem+(32'd16*wb_count*32'd4);
            address_weight_buffer <= 0;
            EN_WB <= EN_WB_decoded;
            EN_IB <= EN_IB_internal;

        end
        
        LOAD_WEIGHT: begin
        address_weight_buffer <= address_weight_buffer + 5'b1 ;
        DMA_ADDRS            <= DMA_ADDRS + increment_value_dmem;
        EN_WB<=EN_WB_decoded;
        EN_IB <= EN_IB_internal;
        end
        CHECK_COMPLETE_final: begin
        end
        LOAD_WEIGHT_final: begin
                        wb_count<=wb_count+6'd1;
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
         WRITE_INPUT_FROM_OUTPUT_INITIAL: begin
                address_input_buffer <= 6'b0;
                EN_IB <= EN_IB_decoded;
                EN_WB <= EN_WB_internal;
                out_count <= 5'd0;

 
 
         end
         WRITE_INPUT_FROM_OUTPUT: begin
                 output_counter = ib_count * 16 + out_count ; address_input_buffer <= address_input_buffer + 1'b1;
                 EN_IB <= EN_IB_decoded;
                 EN_WB <= EN_WB_internal;
                 out_count <= out_count + 5'd1;

 
         end
         WRITE_INPUT_FROM_OUTPUT_FINAL: begin
              ib_count             <= ib_count + 6'd1;
         end
         
        WRITE_INPUT_initial: begin
               DMA_ADDRS            <= initial_addrs_data_mem+(32'd16*ib_count*32'd4);
               address_input_buffer <= 6'b0;
               EN_IB <= EN_IB_decoded;
               EN_WB <= EN_WB_internal;


        end
        WRITE_INPUT: begin
                DMA_ADDRS            <= DMA_ADDRS + increment_value_dmem;
                address_input_buffer <= address_input_buffer + 1'b1;
                EN_IB <= EN_IB_decoded;
                EN_WB <= EN_WB_internal;

        end
        WRITE_INPUT_FINAL: begin
             ib_count             <= ib_count + 6'd1;

        end
        IMCU_to_memory_initial: begin
                DMA_ADDRS            <= initial_addrs_data_mem;
                address_main_memory  <= initial_addrs_imcu;
        end
        IMCU_to_memory: begin
                DMA_ADDRS            <= DMA_ADDRS           + increment_value_dmem;
                address_main_memory  <= address_main_memory + increment_value_imcu;
        end 
        
        endcase
    end
    
    //drive the TC and AE flags
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            
            TC_reg  <= 1'b0;
            AE_reg  <= 1'b0;
        end else if (~dma_stall) begin
            
    
            // TC_reg: set when DONE, hold value otherwise
            if (next_state == DONE)
                TC_reg <= 1'b1;
            else
                TC_reg <= TC_reg;
    
            // AE_reg: set when ERROR, hold value otherwise
            if (next_state == ERROR)
                AE_reg <= 1'b1;
            else
                AE_reg <= AE_reg;
        end else begin
            // Ensure outputs hold value during stall
            TC_reg <= TC_reg;
            AE_reg <= AE_reg;
        end
    end


    assign TC = TC_reg;
    assign AE = AE_reg;

    reg [5:0] ib_count;
    
    
    
    // Combinational logic: Next State Logic
    always @(*) begin
        case (state)
            RESET: begin
            if(output_ready)
            begin
            next_state = WRITE_INPUT_FROM_OUTPUT_INITIAL;
            end
            else if (TEN && data_valid) begin
                    if (dir == 0)
                        next_state = IMCU_to_memory_initial;
                    else if (type == 0)
//                        next_state = WRITE_WEIGHT_initial;
                          next_state = LOAD_WEIGHT_initial;

                    else
                        next_state = WRITE_INPUT_initial;
                end 
           else begin
                    next_state = RESET;
                end
            end
    
            LOAD_WEIGHT_initial: next_state = LOAD_WEIGHT;
            LOAD_WEIGHT_final: next_state = (wb_count==6'd16)?WRITE_WEIGHT_initial:LOAD_WEIGHT_initial;
            LOAD_WEIGHT: next_state = CHECK_COMPLETE_final;
            CHECK_COMPLETE_final: next_state = (address_weight_buffer == 5'd16)? LOAD_WEIGHT_final:LOAD_WEIGHT;
            WRITE_WEIGHT_initial: next_state = CHECK_COMPLETE_W;
            WRITE_WEIGHT:         next_state = CHECK_COMPLETE_W;
            
            
            //change 0.0.0.1
            CHECK_COMPLETE_W:     next_state = (address_weight_buffer == 8'd16) ? WRITE_WEIGHT_FINAL : WRITE_WEIGHT ;
            WRITE_WEIGHT_FINAL:   next_state = DONE;
            
            
            WRITE_INPUT_initial:  next_state = CHECK_COMPLETE_IB;
            WRITE_INPUT:          next_state = CHECK_COMPLETE_IB;
            CHECK_COMPLETE_IB:    next_state = (address_input_buffer == 6'd16) ? WRITE_INPUT_FINAL:WRITE_INPUT ;
            WRITE_INPUT_FINAL:    next_state = (ib_count==6'd16)?DONE:WRITE_INPUT_initial;
            
            WRITE_INPUT_FROM_OUTPUT_INITIAL:  next_state = CHECK_COMPLETE_IB_OUTPUT;
            WRITE_INPUT_FROM_OUTPUT:          next_state = CHECK_COMPLETE_IB_OUTPUT;
            CHECK_COMPLETE_IB_OUTPUT:    next_state = (address_input_buffer == 6'd16) ? WRITE_INPUT_FROM_OUTPUT_FINAL:WRITE_INPUT_FROM_OUTPUT ;

            WRITE_INPUT_FROM_OUTPUT_FINAL:    next_state = (ib_count==6'd16)?DONE:WRITE_INPUT_FROM_OUTPUT_INITIAL;
            
            IMCU_to_memory_initial: next_state = CHECK_COMPLETE_MEM;
            IMCU_to_memory:         next_state = CHECK_COMPLETE_MEM;
            CHECK_COMPLETE_MEM:     next_state = (DMA_ADDRS == final_address || output_ready) ? IMCU_to_memory_FINAL : 
                                                  (address_main_memory > 8'd127) ? ERROR : IMCU_to_memory;
            IMCU_to_memory_FINAL:   next_state = DONE;
            
            ERROR: next_state = RESET;
            DONE:  next_state = RESET;
    
            default: next_state = RESET;
        endcase
    end
    
    Decoder #(.N(6), 
              .X(1<<6)) d1(ib_count ,1, EN_IB_decoded);
              
              
    Decoder #(.N(6), 
              .X(1<<6)) d2(wb_count ,1, EN_WB_decoded);
    // Combinational logic: Output Logic
    always @(*) begin
        // Default values to prevent latch inference
        DMA_WData           = {DATA_WIDTH{1'b0}};
        DMA_WEN             = 1'b0;
        DMA_REN             = 1'b0;
        imcu_mem_in         = {DATA_WIDTH{1'b0}};
        imcu_buffer_in      = {DATA_WIDTH{1'b0}};
        read_imcu           = 1'b0;
        write_imcu          = 1'b0;
        EN_W                = 1'b0;
        EN_IB_internal      = 50'b0;
        latch_En            = 1'b0;
        EN_WB_internal = 64'b0;
        EN_OB_Read = 1'b0;
//        AE                  = 1'b0;
//        TC                  = 1'b0;
        case (state)
            RESET: begin
//                DMA_ADDRS             = {DATA_WIDTH{1'b0}};
                DMA_WData             = {DATA_WIDTH{1'b0}};
                DMA_WEN               = 1'b0;
                DMA_REN               = 1'b0;
//                address_input_buffer  = 6'b0;
//                address_main_memory   = 8'b0; 
                imcu_mem_in           = {DATA_WIDTH{1'b0}};
                imcu_buffer_in        = {DATA_WIDTH{1'b0}};
                read_imcu             = 1'b0;
                write_imcu            = 1'b0;
                EN_W                  = 1'b0;
               ib_count = 6'd0;
               wb_count = 6'd0;

                EN_IB_internal                 = 50'b0;
                latch_En              = 1'b0;
                W_EN                   =1'b0;
                        EN_WB_internal = 64'b0;

            end
            
            LOAD_WEIGHT_initial:begin 
            W_EN=1'b1;
            EN_W                 = 1'b1;
            Read_EN                 =1'b0;
            write_imcu           = 1'b1;
            read_imcu            = 1'b0;
            DMA_WEN              = 1'b0;
            DMA_REN              = 1'b1;
            EN_IB_internal                = 50'b0;

            latch_En             = 1'b0;
            imcu_mem_in          = ReadDataM;  // data from memory to IMCU[weight layer]
            end 
            LOAD_WEIGHT_final: begin
            W_EN=1'b0;
            EN_W                 = 1'b1;
            write_imcu           = 1'b1;
            read_imcu            = 1'b0;
            DMA_WEN              = 1'b0;
            DMA_REN              = 1'b1;
            EN_IB_internal                = 50'b0;
            latch_En             = 1'b0;
            Read_EN                 =1'b0;
            end
            LOAD_WEIGHT: begin
            W_EN=1'b1;
            Read_EN                 =1'b0;
             EN_W                 = 1'b1;
             write_imcu           = 1'b1;
             read_imcu            = 1'b0;
             DMA_WEN              = 1'b0;
             DMA_REN              = 1'b1;
             EN_IB_internal                = 50'b0;
             latch_En             = 1'b0;
             imcu_mem_in          = ReadDataM;
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
           WRITE_WEIGHT_FINAL: begin // hold the write signal for the final Transaction
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
           WRITE_INPUT_FROM_OUTPUT_INITIAL: begin
//                TC                   = 1'b0;
//                AE                   = 1'b0;
               EN_W                 = 1'b0;
               EN_OB_Read           = 1'b1;
                W_EN                    =1'b0;
                Read_EN                 =1'b0;
               write_imcu           = 1'b0;
               read_imcu            = 1'b0;
               DMA_WEN              = 1'b0;
               DMA_REN              = 1'b1;
//                EN_IB                = 1'b1;
//                ib_count             = 6'b0;
               //DMA_ADDRS            = initial_addrs_data_mem;
               //address_input_buffer = 6'b0;
//                EN_IB                = 1'b1;
               latch_En             = 1'b0;
               imcu_buffer_in       = ReadDataM;
           end
   
           WRITE_INPUT_FROM_OUTPUT: begin
//                TC                   = 1'b0;
//                AE                   = 1'b0;
               EN_W                 = 1'b0;
               EN_OB_Read           = 1'b1;
                W_EN                    =1'b0;
                Read_EN                 =1'b0;
               write_imcu           = 1'b0;
               read_imcu            = 1'b0;
               DMA_WEN              = 1'b0;
               DMA_REN              = 1'b1;
//                EN_IB                = 1'b1;
//                DMA_ADDRS            = DMA_ADDRS + increment_value_dmem;
//                address_input_buffer = address_input_buffer + 1'b1;
//                EN_IB                = 1'b1;
               latch_En             = 1'b0;
               imcu_buffer_in       = ReadDataM;  // data from memory to IMCU[input buffer]
           end
   

   
           WRITE_INPUT_FROM_OUTPUT_FINAL: begin  // hold the write signal for the final Transaction
//                TC                   = 1'b0;
//                AE                   = 1'b0;
               EN_W                 = 1'b0;
               EN_OB_Read           = 1'b0;
                W_EN                    =1'b0;
                Read_EN                 =1'b0;
               write_imcu           = 1'b0;
               read_imcu            = 1'b0;
               DMA_WEN              = 1'b0;
               DMA_REN              = 1'b1;

//                EN_IB                = 1'b1;
               latch_En             = 1'b0;
           end
    
    
            WRITE_INPUT_initial: begin
//                TC                   = 1'b0;
//                AE                   = 1'b0;
                EN_W                 = 1'b0;
                 W_EN                    =1'b0;
                 Read_EN                 =1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
//                EN_IB                = 1'b1;
//                ib_count             = 6'b0;
                //DMA_ADDRS            = initial_addrs_data_mem;
                //address_input_buffer = 6'b0;
//                EN_IB                = 1'b1;
                latch_En             = 1'b0;
                imcu_buffer_in       = ReadDataM;
            end
    
            WRITE_INPUT: begin
//                TC                   = 1'b0;
//                AE                   = 1'b0;
                EN_W                 = 1'b0;
                 W_EN                    =1'b0;
                 Read_EN                 =1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
//                EN_IB                = 1'b1;
//                DMA_ADDRS            = DMA_ADDRS + increment_value_dmem;
//                address_input_buffer = address_input_buffer + 1'b1;
//                EN_IB                = 1'b1;
                latch_En             = 1'b0;
                imcu_buffer_in       = ReadDataM;  // data from memory to IMCU[input buffer]
            end
    
            CHECK_COMPLETE_IB: begin
//                TC                   = 1'b0;
//                AE                   = 1'b0;
                EN_W                 = 1'b0;
                 W_EN                    =1'b0;
                 Read_EN                 =1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
//                EN_IB                = 1'b1;
                latch_En             = 1'b0;
            end
            
            CHECK_COMPLETE_IB_OUTPUT: begin
//                TC                   = 1'b0;
//                AE                   = 1'b0;
                EN_W                 = 1'b0;
                 W_EN                    =1'b0;
                 Read_EN                 =1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
//                EN_IB                = 1'b1;
                latch_En             = 1'b0;
            end
    
            WRITE_INPUT_FINAL: begin  // hold the write signal for the final Transaction
//                TC                   = 1'b0;
//                AE                   = 1'b0;
                EN_W                 = 1'b0;
                 W_EN                    =1'b0;
                 Read_EN                 =1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;

//                EN_IB                = 1'b1;
                latch_En             = 1'b0;
            end
    
    
            IMCU_to_memory_initial: begin
//                DMA_ADDRS            = initial_addrs_data_mem;
//                address_main_memory  = initial_addrs_imcu;
//                AE                   = 1'b0;
//                TC                   = 1'b0;
                EN_W                 = 1'b1;
                 W_EN                    =1'b0;
                 Read_EN                 =1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b1;
                DMA_WEN              = 1'b1;
                DMA_REN              = 1'b0;
                EN_IB                = 50'b0;
                latch_En             = 1'b0;
                DMA_WData            = imcu_out;
            end

            IMCU_to_memory: begin
//                DMA_ADDRS            = DMA_ADDRS           + increment_value_dmem;
//                address_main_memory  = address_main_memory + increment_value_imcu;
//                AE                   = 1'b0;
//                TC                   = 1'b0;
                EN_W                 = 1'b1;
                write_imcu           = 1'b0;
                W_EN                    =1'b0;
                Read_EN                 =1'b0;
                read_imcu            = 1'b1;
                DMA_WEN              = 1'b1;
                DMA_REN              = 1'b0;
                EN_IB                = 50'b0;
                latch_En             = 1'b0;
                DMA_WData            = imcu_out;
            end    
            CHECK_COMPLETE_MEM: begin
//                AE                   = 1'b0;
//                TC                   = 1'b0;
                EN_W                 = 1'b1;
                 W_EN                    =1'b0;
                write_imcu           = 1'b0;
                Read_EN                 =1'b0;
                read_imcu            = 1'b1;
                DMA_WEN              = 1'b1;
                DMA_REN              = 1'b0;
                EN_IB                = 50'b0;
                latch_En             = 1'b0;
            end    
            IMCU_to_memory_FINAL: begin
//                AE                   = 1'b0;
//                TC                   = 1'b0;
                EN_W                 = 1'b1;
                 W_EN                    =1'b0;
                 Read_EN                 =1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b1;
                DMA_WEN              = 1'b1;
                DMA_REN              = 1'b0;
                EN_IB                = 50'b0;
                latch_En             = 1'b0;
            end 
            
            ERROR: begin
//                AE                   = 1'b1;
//                TC                   = 1'b0;
                EN_W                 = 1'b0;
                Read_EN                 =1'b0;
                write_imcu           = 1'b0;
                 W_EN                    =1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b0;
                EN_IB                = 1'b0;
                latch_En             = 1'b1;
            end
    
            DONE: begin
//                TC                   = 1'b1;
                EN_W                 = 1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                 W_EN                    =1'b0;
                 Read_EN                 =1'b0;
                DMA_REN              = 1'b0;
                EN_IB                = 1'b0;
                latch_En             = 1'b1;
            end
    
            default: ;
        endcase
    end
endmodule



/*
module dma_controller#(
    parameter STRIDE = 3,
    parameter INITIAL_ADDRS = 15,
    parameter DATA_WIDTH = 32,
    parameter NUM_LAYERS = 4100/(3*DATA_WIDTH),
    parameter MAIN_ADDRESS_BITS = $clog2(NUM_LAYERS * 3),
    parameter IB_ADDRESS_BITS = $clog2(NUM_LAYERS * 3 / 2)
)(
    input         clk,
    input         reset,
    // Signals from the address decoder
    input         dir,  // Direction {(0) IMCU to memory || (1) memory to IMCU}
    input         type, // (0)Weight or (1)input
    input         data_valid,
    input  [STRIDE-1:0]  imcu_addrs_stride,
    input  [STRIDE-1:0]  dmem_addrs_stride,
    input  [INITIAL_ADDRS-1:0] initial_addrs_data_mem,
    input  [INITIAL_ADDRS-1:0] initial_addrs_imcu,
    input         TEN,
    // Memory connections
    input      [DATA_WIDTH-1:0] ReadDataM,     // Data from main memory (RAM)
    input      [DATA_WIDTH-2:0] final_address, // final address when the data is being transferred from the IMCU to memory  [CPU READ]
    output reg        DMA_WEN,
    output reg        DMA_REN,
    output reg [DATA_WIDTH-1:0] DMA_WData,
    output reg [DATA_WIDTH-1:0] DMA_ADDRS,
    // IMCU connections
    input      [DATA_WIDTH-1:0] imcu_out,         // Data coming out of the IMCU
    output reg [IB_ADDRESS_BITS-1:0]  address_input_buffer,
    output reg [MAIN_ADDRESS_BITS-1:0]  address_main_memory,
    output reg [DATA_WIDTH-1:0] imcu_mem_in,       // Data going into the IMCU main memory (BL)
    output reg [DATA_WIDTH-1:0] imcu_buffer_in,    // Data going into the IMCU input buffer (BLA)
    output reg        read_imcu,
    output reg        write_imcu,
    output reg        EN_W,
    output reg        EN_IB,
    // flags
    output reg        TC, // transaction complete
    output reg        AE, // address error
    output reg        latch_En,
    input             dma_stall 
);

    // Wires for stride increment values
    wire [STRIDE-1:0] increment_value_dmem;
    wire [STRIDE-1:0] increment_value_imcu;
    assign increment_value_dmem = (dmem_addrs_stride == 1) ? 4'h4 : 4'hz;
    assign increment_value_imcu = (imcu_addrs_stride == 1) ? 4'h1 :
                                   (imcu_addrs_stride == 2) ? 4'h2 :
                                  (imcu_addrs_stride == 3) ? 4'h3 : 4'hz;

    // State encoding (Decimal)
localparam RESET                  = 0,    // 0

           WRITE_WEIGHT_initial   = 1,    // 1
           WRITE_WEIGHT           = 2,    // 2
           CHECK_COMPLETE_W       = 3,    // 3
           WRITE_WEIGHT_FINAL     = 4,    // 4
           
           WRITE_INPUT_initial    = 5,    // 5
           WRITE_INPUT            = 6,    // 6
           CHECK_COMPLETE_IB      = 7,    // 7
           WRITE_INPUT_FINAL      = 8,    // 8
           
           IMCU_to_memory_initial = 9,    // 9
           IMCU_to_memory         = 10,   // 10
           CHECK_COMPLETE_MEM     = 11,   // 11
           IMCU_to_memory_FINAL   = 12,   // 12
           
           ERROR                  = 13,   // 13
           DONE                   = 14;   // 14

    
    // State registers
    reg [3:0] state, next_state;
    
    // Sequential logic: State Register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= RESET;
        else if (~dma_stall)
            state <= next_state;
        //increment logic to aviod race condition
        case(state)
        WRITE_WEIGHT:begin
                DMA_ADDRS            <= DMA_ADDRS + increment_value_dmem;
                address_main_memory  <= address_main_memory + increment_value_imcu;
        end    
        WRITE_INPUT: begin
                DMA_ADDRS            <= DMA_ADDRS + increment_value_dmem;
                address_input_buffer <= address_input_buffer + 1'b1;
        end
        IMCU_to_memory: begin
                DMA_ADDRS            <= DMA_ADDRS           + increment_value_dmem;
                address_main_memory  <= address_main_memory + increment_value_imcu;
        end 
        
        endcase
    end
    
    // Combinational logic: Next State Logic
    always @(*) begin
        case (state)
            RESET: begin
                if (TEN && data_valid) begin
                    if (dir == 0)
                        next_state = IMCU_to_memory_initial;
                    else if (type == 0)
                        next_state = WRITE_WEIGHT_initial;
                    else
                        next_state = WRITE_INPUT_initial;
                end else begin
                    next_state = RESET;
                end
            end
    
            WRITE_WEIGHT_initial: next_state = CHECK_COMPLETE_W;
            WRITE_WEIGHT:         next_state = CHECK_COMPLETE_W;
            CHECK_COMPLETE_W:     next_state = (address_main_memory == 8'd123) ? WRITE_WEIGHT_FINAL : WRITE_WEIGHT ;
            WRITE_WEIGHT_FINAL:   next_state = DONE;
            
            
            WRITE_INPUT_initial:  next_state = CHECK_COMPLETE_IB;
            WRITE_INPUT:          next_state = CHECK_COMPLETE_IB;
            CHECK_COMPLETE_IB:    next_state = (address_input_buffer == 6'd41) ? WRITE_INPUT_FINAL:WRITE_INPUT ;
            WRITE_INPUT_FINAL:    next_state = DONE;
            
            IMCU_to_memory_initial: next_state = CHECK_COMPLETE_MEM;
            IMCU_to_memory:         next_state = CHECK_COMPLETE_MEM;
            CHECK_COMPLETE_MEM:     next_state = (DMA_ADDRS == final_address) ? IMCU_to_memory_FINAL : 
                                                  (address_main_memory > 8'd127) ? ERROR : IMCU_to_memory;
            IMCU_to_memory_FINAL:   next_state = DONE;
            
            ERROR: next_state = RESET;
            DONE:  next_state = RESET;
    
            default: next_state = RESET;
        endcase
    end
    
    // Combinational logic: Output Logic
    always @(*) begin
        case (state)
            RESET: begin
                DMA_ADDRS             = {DATA_WIDTH{1'b0}};
                DMA_WData             = {DATA_WIDTH{1'b0}};
                DMA_WEN               = 1'b0;
                DMA_REN               = 1'b0;
                address_input_buffer  = 6'b0;
                address_main_memory   = 8'b0;
                imcu_mem_in           = {DATA_WIDTH{1'b0}};
                imcu_buffer_in        = {DATA_WIDTH{1'b0}};
                read_imcu             = 1'b0;
                write_imcu            = 1'b0;
                EN_W                  = 1'b0;
                EN_IB                 = 1'b0;
                latch_En              = 1'b0;
            end
    
            WRITE_WEIGHT_initial: begin
                DMA_ADDRS            = initial_addrs_data_mem;
                address_main_memory  = initial_addrs_imcu;
                TC                   = 1'b0;
                AE                   = 1'b0;
                EN_W                 = 1'b1;
                write_imcu           = 1'b1;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB                = 1'b0;
                latch_En             = 1'b0;
                imcu_mem_in          = ReadDataM;  // data from memory to IMCU[weight layer]
            end
    
            WRITE_WEIGHT: begin
//                DMA_ADDRS            = DMA_ADDRS + increment_value_dmem;
//                address_main_memory  = address_main_memory + increment_value_imcu;
                TC                   = 1'b0;
                AE                   = 1'b0;
                EN_W                 = 1'b1;
                write_imcu           = 1'b1;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB                = 1'b0;
                latch_En             = 1'b0;
                imcu_mem_in          = ReadDataM;
            end
    
            CHECK_COMPLETE_W: begin
                TC                   = 1'b0;
                AE                   = 1'b0;
                EN_W                 = 1'b1;
                write_imcu           = 1'b1;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB                = 1'b0;
                latch_En             = 1'b0;
            end
           WRITE_WEIGHT_FINAL: begin // hold the write signal for the final Transaction
                TC                   = 1'b0;
                AE                   = 1'b0;
                EN_W                 = 1'b1;
                write_imcu           = 1'b1;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB                = 1'b0;
                latch_En             = 1'b0;
           end
    
    
            WRITE_INPUT_initial: begin
                TC                   = 1'b0;
                AE                   = 1'b0;
                EN_W                 = 1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB                = 1'b1;
                DMA_ADDRS            = initial_addrs_data_mem;
                address_input_buffer = 6'b0;
                EN_IB                = 1'b1;
                latch_En             = 1'b0;
                imcu_buffer_in       = ReadDataM;
            end
    
            WRITE_INPUT: begin
                TC                   = 1'b0;
                AE                   = 1'b0;
                EN_W                 = 1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB                = 1'b1;
//                DMA_ADDRS            = DMA_ADDRS + increment_value_dmem;
//                address_input_buffer = address_input_buffer + 1'b1;
                EN_IB                = 1'b1;
                latch_En             = 1'b0;
                imcu_buffer_in       = ReadDataM;  // data from memory to IMCU[input buffer]
            end
    
            CHECK_COMPLETE_IB: begin
                TC                   = 1'b0;
                AE                   = 1'b0;
                EN_W                 = 1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB                = 1'b1;
                latch_En             = 1'b0;
            end
    
            WRITE_INPUT_FINAL: begin  // hold the write signal for the final Transaction
                TC                   = 1'b0;
                AE                   = 1'b0;
                EN_W                 = 1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b1;
                EN_IB                = 1'b1;
                latch_En             = 1'b0;
            end
    
    
            IMCU_to_memory_initial: begin
                DMA_ADDRS            = initial_addrs_data_mem;
                address_main_memory  = initial_addrs_imcu;
                AE                   = 1'b0;
                TC                   = 1'b0;
                EN_W                 = 1'b1;
                write_imcu           = 1'b0;
                read_imcu            = 1'b1;
                DMA_WEN              = 1'b1;
                DMA_REN              = 1'b0;
                EN_IB                = 1'b0;
                latch_En             = 1'b0;
                DMA_WData            = imcu_out;
            end

            IMCU_to_memory: begin
//                DMA_ADDRS            = DMA_ADDRS           + increment_value_dmem;
//                address_main_memory  = address_main_memory + increment_value_imcu;
                AE                   = 1'b0;
                TC                   = 1'b0;
                EN_W                 = 1'b1;
                write_imcu           = 1'b0;
                read_imcu            = 1'b1;
                DMA_WEN              = 1'b1;
                DMA_REN              = 1'b0;
                EN_IB                = 1'b0;
                latch_En             = 1'b0;
                DMA_WData            = imcu_out;
            end    
            CHECK_COMPLETE_MEM: begin
                AE                   = 1'b0;
                TC                   = 1'b0;
                EN_W                 = 1'b1;
                write_imcu           = 1'b0;
                read_imcu            = 1'b1;
                DMA_WEN              = 1'b1;
                DMA_REN              = 1'b0;
                EN_IB                = 1'b0;
                latch_En             = 1'b0;
            end    
            IMCU_to_memory_FINAL: begin
                AE                   = 1'b0;
                TC                   = 1'b0;
                EN_W                 = 1'b1;
                write_imcu           = 1'b0;
                read_imcu            = 1'b1;
                DMA_WEN              = 1'b1;
                DMA_REN              = 1'b0;
                EN_IB                = 1'b0;
                latch_En             = 1'b0;
            end 
            
            ERROR: begin
                AE                   = 1'b1;
                TC                   = 1'b0;
                EN_W                 = 1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b0;
                EN_IB                = 1'b0;
                latch_En             = 1'b1;
            end
    
            DONE: begin
                TC                   = 1'b1;
                EN_W                 = 1'b0;
                write_imcu           = 1'b0;
                read_imcu            = 1'b0;
                DMA_WEN              = 1'b0;
                DMA_REN              = 1'b0;
                EN_IB                = 1'b0;
                latch_En             = 1'b1;
            end
    
            default: ;
        endcase
    end
endmodule



*/



