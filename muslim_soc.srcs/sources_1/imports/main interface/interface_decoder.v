module interface_decoder (
	 input          clk,
	 input          MemWriteM,
	 input          MemReadM,
	 input reset_n,
    input  [31:0]  Address,
    input  [31:0]  Data,
	 output reg[31:0]  DATA_OUT,
	 
	 //DMA flags
	 input          TC,
	 input          MC,
	 input          AE,
	 input          latch_En,
	 input          latch_MC_En,
	 //ouputs from DMA control register-1
	 output       dir,
	 output       type,
	 output       valid,
	 output [2:0] dmem_addrs_stride,
	 output [2:0] imcu_addrs_stride,
	 
	 //ouputs from DMA control register-2
	 output [14:0]initial_addrs_data_mem,
	 output [14:0]initial_addrs_imcu,
	 
	 //ouputs from DMA control register-3
	 output       TEN,
	 output [30:0]final_address,
	 
	 //outputs for IMCU
	 output IMC,
	 output Interrupt,
	  
	 // adder tree output
	 input [7:0] output_buffer_lsw, //lower 32 bits of output buffer
	 input [7:0] output_buffer_msw //top 32 bits of output buffer
);
	
   localparam ADDRS_CTRL_REG1 = 32'h30000000;
   localparam ADDRS_CTRL_REG2 = 32'h30000004;
   localparam ADDRS_CTRL_REG3 = 32'h30000008;
   localparam ADDRS_FLAG_REG  = 32'h3000000C;
   localparam ADDRS_MUL_EN    = 32'h30000010;
   localparam ADDRS_OUTPUT_BUFFER_LSW = 32'h30000014;
   localparam ADDRS_OUTPUT_BUFFER_MSW = 32'h30000018;
   
     reg [8:0] dma_ctrl_reg1;     
	 reg [31:0] dma_ctrl_reg2;
	 reg [31:0] dma_ctrl_reg3;
	 reg [31:0] dma_flag_reg;
	 reg [31:0] mul_en_reg;    // multiplication enable register
	 
	 
	 //output assignments control register-1
	 assign dir               = dma_ctrl_reg1[0];
	 assign type              = dma_ctrl_reg1[1];
	 assign valid             = dma_ctrl_reg1[2];
	 assign dmem_addrs_stride = dma_ctrl_reg1[5:3];
	 assign imcu_addrs_stride = dma_ctrl_reg1[8:6];
	 
	 //output assignments control register-2
	 assign initial_addrs_data_mem = dma_ctrl_reg2[15:0];
	 assign initial_addrs_imcu     = dma_ctrl_reg2[31:16];
	 
	 //output assignments control register-3
	 assign TEN           = dma_ctrl_reg3[0];
	 assign final_address = dma_ctrl_reg3[31:1];
	 wire clear_TC_flag = ((Address ==ADDRS_FLAG_REG) && Data[0] && MemWriteM) ? 1'b1: 1'b0;
	 wire clear_MC_flag = ((Address ==ADDRS_FLAG_REG) && Data[1] && MemWriteM) ? 1'b1: 1'b0;
	 wire clear_AE_flag = ((Address ==ADDRS_FLAG_REG) && Data[2] && MemWriteM) ? 1'b1: 1'b0;
	 wire TCq,MCq,AEq;
	 
	 //output assignments for multiplication enable register
	 assign IMC = mul_en_reg[0];
	 
	 // output assignemnts for flag register
	 FLAGS flags_inst (
        .clk(clk), 
		  .En(latch_En),
		  .En_MC(latch_MC_En),
        .reset1(clear_TC_flag | ~reset_n), 
        .reset2(clear_MC_flag | ~reset_n), 
        .reset3(clear_AE_flag | ~reset_n), 
        .d1(TC),        
        .d2(MC),        
        .d3(AE),        
        .q1(TCq),         
        .q2(MCq),         
        .q3(AEq)         
    );
	 
	 
	 assign Interrupt = TCq | MCq | AEq;
	 always@(*)begin
			dma_flag_reg = {28'b0, AEq, MCq, TCq};
	 end
	 //output data for reading the output buffer and dma_flag_reg
//	 assign DATA_OUT = (MemReadM & (Address == ADDRS_FLAG_REG)) ? dma_flag_reg : 32'bz;
         
    always @(*)begin
           DATA_OUT = 32'b0; 
           if(MemReadM)begin //removing the read dependency 
               case(Address)
                   ADDRS_FLAG_REG:          DATA_OUT = dma_flag_reg;
                   ADDRS_OUTPUT_BUFFER_LSW: DATA_OUT = output_buffer_lsw;
                   ADDRS_OUTPUT_BUFFER_MSW: DATA_OUT = output_buffer_msw;
                   default: DATA_OUT = 32'b0;
               endcase
           end
      end

    // Write to the memory locations are synchronized with clock
    always @(posedge clk) begin
        if (MemWriteM) begin
            case (Address)
                ADDRS_CTRL_REG1: dma_ctrl_reg1 <= Data; 
                ADDRS_CTRL_REG2: dma_ctrl_reg2 <= Data; 
                ADDRS_CTRL_REG3: dma_ctrl_reg3 <= Data;
                ADDRS_MUL_EN   : mul_en_reg    <= Data;
                default: begin
                    dma_ctrl_reg1 <= dma_ctrl_reg1;
                    dma_ctrl_reg2 <= dma_ctrl_reg2;
                    dma_ctrl_reg3 <= dma_ctrl_reg3;
                    mul_en_reg    <= mul_en_reg;
                end
            endcase
        end
    end

endmodule


module FLAGS (
    input wire clk,
	 input wire En,    // enable the AE and TC latches
	 input wire En_MC, // enable the MC latch
    input wire reset1,         
    input wire reset2,         
    input wire reset3,         
    input wire d1,             
    input wire d2,             
    input wire d3,            
    output reg q1,             
    output reg q2,             
    output reg q3              
);

    always @(posedge clk or posedge reset1) begin
        if (reset1)
            q1 <= 1'b0;        // Reset latch 1 to 0
        else if(En)
            q1 <= d1;          // Latch data for q1
    end
    always @(posedge clk or posedge reset2) begin
        if (reset2)
            q2 <= 1'b0;        // Reset latch 2 to 0
        else if(En_MC)
            q2 <= d2;          // Latch data for q2
    end
    always @(posedge clk or posedge reset3) begin
        if (reset3)
            q3 <= 1'b0;        // Reset latch 3 to 0
        else if(En)
            q3 <= d3;          // Latch data for q3
    end
endmodule
