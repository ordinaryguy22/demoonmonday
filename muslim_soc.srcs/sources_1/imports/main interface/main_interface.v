module main_interface(
	input        clk,
	input        reset_n,
	input [31:0] ALUResultM,
	input [31:0] WriteDataM,
	input        MemReadM,
	input        MemWriteM,
	// Memory controll signls
	output DMA_WEN,
	output DMA_REN,
	//memory data/adddress
	input  [7:0] DMA_RData, // Data from memory to IMCU [Write Cycle]
	output [7:0] DMA_WData, // Data from IMCU to memory [READ cycle]
	output [31:0] DMA_ADDRS, // address for datamemory indexing 
	//output to pipeline register
	output [31:0] DATA_OUT,  ///??????
	//interrupt signals
	//output TC,
	//output MC,
	//output AE,
	output  Interrupt,
	
	output  reg dma_has_access,
	input dma_stall
);

	//wires
	wire TC;
	wire MC;
	wire AE;
	wire latch_En;
	wire dir;
	wire type;
	wire data_valid;
	wire TEN;
	wire read_imcu;
	wire write_imcu;
	wire EN_W;
	wire [49:0] EN_IB;
	wire rst;
	wire start;
	wire IMC;
	wire Read_EN,W_EN;
	wire latch_MC_En;
	wire [2:0]  dmem_addrs_stride;
	wire [2:0]  imcu_addrs_stride;
	wire [14:0] initial_addrs_data_mem;
	wire [14:0] initial_addrs_imcu;
	wire [30:0] final_address;
	wire [4:0]  address_input_buffer;
	wire [5:0]  address_main_memory;
    wire [7:0] imcu_mem_in;
	wire [7:0] imcu_buffer_in;
	wire [7:0] imcu_out;
	wire [7:0] output_buffer_lsw; //lower 32 bits of output buffer
	wire [7:0] output_buffer_msw; //top 32 bits of output buffer
    wire [15:0] MAC_Result;
    wire [4:0] address_weight_buffer;
    wire [15:0] EN_WB;
    wire output_ready;
    wire [7:0] output_counter;
    wire EN_OB_Read;
    
    
	interface_decoder interface_decoder_init (
        .clk(clk),
        .MemWriteM(MemWriteM),
        .reset_n(reset_n),
        .MemReadM(MemReadM),
        .Address(ALUResultM),
        .Data(WriteDataM),
        .DATA_OUT(DATA_OUT),
        .TC(TC),
        .MC(MC),
        .AE(AE),
        .latch_En(latch_En),
		.latch_MC_En(latch_MC_En),
        .dir(dir),
        .type(type),
        .valid(data_valid),
        .dmem_addrs_stride(dmem_addrs_stride),
        .imcu_addrs_stride(imcu_addrs_stride),
        .initial_addrs_data_mem(initial_addrs_data_mem),
        .initial_addrs_imcu(initial_addrs_imcu),
        .TEN(TEN),
        .final_address(final_address),
		  .IMC(IMC),
		  .Interrupt(Interrupt),
		  .output_buffer_lsw(output_buffer_lsw),
		  .output_buffer_msw(output_buffer_msw)
    );
	 
	 // When TEN goes High first reset the DMA state machine and then start the transfer
	 START_FSM uut (
        .clk(clk),     
        .imc(TEN),     
        .rst(rst),     
        .start(start)  
    );

	 assign DMA_WData = imcu_out;
	 
	 dma_controller dma_controller_init (
		 .clk                (clk),
		 .reset              (rst), // rst
		 .dir                (dir),
		 .type               (type),
		 .data_valid         (data_valid),
		 .imcu_addrs_stride  (imcu_addrs_stride),
		 .dmem_addrs_stride  (dmem_addrs_stride),
		 .initial_addrs_data_mem (initial_addrs_data_mem),
		 .initial_addrs_imcu (initial_addrs_imcu),
		 .TEN                (start), //start
		 .ReadDataM          (DMA_RData),
		 .final_address      (final_address),
		 .DMA_WEN            (DMA_WEN),
		 .DMA_REN            (DMA_REN),
		 .DMA_WData          (),
		 .DMA_ADDRS          (DMA_ADDRS),     
		 .imcu_out           (imcu_out),     
		 .address_input_buffer (address_input_buffer),
		 .address_main_memory (address_main_memory),  
		 .imcu_mem_in        (imcu_mem_in),            
		 .imcu_buffer_in     (imcu_buffer_in),       
		 .read_imcu          (read_imcu),              
		 .write_imcu         (write_imcu),             
		 .EN_W               (EN_W), 
		 .EN_WB              (EN_WB),                 
		 .EN_IB              (EN_IB),                  
		 .TC                 (TC),                   
		 .AE                 (AE),                     
		 .latch_En           (latch_En),
		// .dma_has_access(),//.dma_has_access(dma_has_access),
		 .dma_stall          (dma_stall)  ,
		.Read_EN(Read_EN),
        .W_EN(W_EN),
		 .address_weight_buffer (address_weight_buffer) , 
		 .output_ready(output_ready),
		 .output_counter(output_counter),                
		 .EN_OB_Read(EN_OB_Read)
	);
	

	
	PE_array PE_init(                   
                     .address_input_buffer(address_input_buffer),
                       .address_main_memory(address_main_memory),
                       .BL(DMA_RData), //weightsssss
                       .BLA(DMA_RData), //inputttttt
                       .clk(clk),
                       .MAC(IMC),
                       .EN_IB(EN_IB),
                       .EN_W(EN_W),
                       .EN_WB(EN_WB),
                       .Read_EN(Read_EN),
                       .W_EN(W_EN),
                       .read(read_imcu),
                       .write(write_imcu),
                       .mem_out(imcu_out), 
                       .latch_MC_En(latch_MC_En),
                       .MC(MC),
//                       .MAC_result(MAC_Result) , 
                       .address_weight_buffer(address_weight_buffer)  ,
                       	 .output_ready(output_ready),
                           .output_counter(output_counter) ,            
                           .EN_OB_Read(EN_OB_Read)
        );
	
//	always @(posedge clk, negedge reset_n) begin 
always @(*) begin //running combinationally
	   if(~reset_n) begin 
	       dma_has_access <= 1'b0;
	   end else if(TC | MC) begin
	       dma_has_access <= 1'b0; 
	   end else if(TEN) begin 
	       dma_has_access <= 1'b1;
	       end
	   else  begin
	       dma_has_access <= 1'b0; end
	       
	   end
	
	
endmodule 
