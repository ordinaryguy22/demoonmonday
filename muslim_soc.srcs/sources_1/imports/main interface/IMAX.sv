////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*														       *
//*							WRAPPER							       *
//*														       *
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module IMAX (                     // In-Memory Accelerator Exchange               
              
             // Master 
             input  [7:0] DMA_ReadData, 
             output DMA_Write,
	         output DMA_Read,	
	         output [7:0] DMA_WriteData, 
	         output [31:0] DMA_Address,
             output Master_Route_Out,
             output Master_Route_In,

             // Slave             
             input              clk_i,         // clock
             input              reset_n,
         //  input              rst_i,         // reset 
             input              cyc_i,         // cycle
             input              stb_i,         // strobe
  	     input       [31:0] adr_i,         // address
  	     input              we_i,          // write enable
	     input       [31:0] dat_i,         // data input
  	     output      [31:0] dat_o,         // data output
 	     output             ack_o,          // normal bus termination

             //Interrupt Signals
             output             DMA_ireq,
             output             dma_has_access,
             input              dma_stall
	    
);             
     // wire             Transfer_Complete;
  	 // wire              Multiplication_Complete;
	//  wire                 Address_Error;
     // assign DMA_ireq = (Transfer_Complete | Multiplication_Complete | Address_Error) ;
      

      wire wb_acc, mem_write,mem_read ;
      assign wb_acc = cyc_i & stb_i;
      assign mem_write = wb_acc &  we_i;
      assign mem_read  = wb_acc & ~we_i;
      assign ack_o = wb_acc;
      
      assign Master_Route_Out = DMA_Write;
      assign Master_Route_In  = DMA_Read;


      main_interface DMA_IMCU_UNIT (
                                    .clk(clk_i) ,
                                    .reset_n(reset_n),
                                     // Slave Interface Signals 
                                    .ALUResultM(adr_i),        //Input
                                    .WriteDataM(dat_i) ,       //Input
                                    .MemWriteM(mem_write),     //Input
                                    .MemReadM(mem_read),       //Input
                                    .DATA_OUT(dat_o),          //Output 

                                    // Master Interface Signals
                                    .DMA_WEN(DMA_Write),          //Output
                                    .DMA_REN(DMA_Read),           //Output
                                    .DMA_RData(DMA_ReadData),     //Input
                                    .DMA_WData(DMA_WriteData),    //Output
                                    .DMA_ADDRS(DMA_Address),      //Output

                                    //Interrupt Signals
                                  //  .TC(Transfer_Complete),        //Output
				                   // .MC(Multiplication_Complete),  //Output
				                    //.AE(Address_Error),             //Output
				                    .Interrupt(DMA_ireq),
				    .dma_has_access(dma_has_access),
                          .dma_stall(dma_stall)

);
endmodule






  






















