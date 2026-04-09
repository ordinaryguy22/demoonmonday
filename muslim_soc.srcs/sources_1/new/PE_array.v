


module PE_array  #(parameter DATA_WIDTH = 8,
              parameter NUM_MULTIPLIERS = 384/(3*DATA_WIDTH),
              parameter MAIN_ADDRESS_BITS = $clog2(NUM_MULTIPLIERS * 3),
              parameter IB_ADDRESS_BITS = $clog2(NUM_MULTIPLIERS * 3 / 2)
              )
              (
/*     address_input_buffer,
                             address_main_memory,
                             address_weight_buffer,
                             BL, 
                             BLA, 
                             W_EN, 
                             Read_EN,
                             clk,
                             IMC,
                             EN_IB,
                             EN_W,
                             read,
                             write,
                             mem_out,
                             latch_MC_En,
                             MC*/
                                 input [IB_ADDRESS_BITS-1:0] address_input_buffer,
                                 input [MAIN_ADDRESS_BITS-1:0] address_main_memory,
                                 input clk, MAC,EN_W, read,write,
                                 input [15:0] EN_IB,
                                 input [DATA_WIDTH-1:0] BL, BLA,
                                 input Read_EN,W_EN,
                                 input EN_OB_Read,
                                 input [15:0] EN_WB,
                                 input EN_W_tc,W_EN_tc,write_imcu_tc,read_imcu_tc,Read_EN_tc,DMA_WEN_tc,DMA_REN_tc,EN_IB_internal_tc,latch_En_tc,
                                 input [7:0] imcu_mem_in_tc,
                                 input [4:0] address_weight_buffer,
                                 input [7:0] output_counter,                                 
                                 output [DATA_WIDTH-1:0] WL_SL,
                                 output WL_N,
                                 output WL_SH,
                                 output [DATA_WIDTH-1:0]mem_out,
                                 output    MC ,
                                 output  latch_MC_En,
                                 output reg output_ready,
                                 input [DATA_WIDTH-1:0] ReadDataM                           

    );
    

        wire [DATA_WIDTH-1:0] MAC_result [15:0];
        
        wire latch_MC_En_internal [15:0];
        wire MC_internal [15:0];
        wire [DATA_WIDTH-1:0] Lq [NUM_MULTIPLIERS-1:0];
        wire [DATA_WIDTH-1:0] highq [NUM_MULTIPLIERS-1:0];
        wire [DATA_WIDTH-1:0] BLB,  stored_value_bar1, stored_value_bar2, out1,out2;
        wire [DATA_WIDTH-1:0] C0L;
        wire [7:0] iter_count;
        wire [7:0] iter_no;
        
        
        
        wire [DATA_WIDTH:0] S [NUM_MULTIPLIERS-1:0];
        wire [DATA_WIDTH:0] S_not [NUM_MULTIPLIERS-1:0];

        wire rst;
//        wire [NUM_MULTIPLIERS-1:0] OUT [49:0]; //A
        wire [799:0] OUT;
        wire [(1<<MAIN_ADDRESS_BITS)-1:0] Dout;
        wire [DATA_WIDTH-1:0] OUT_WB;
        assign BLB = ~BL;
        
        wire [NUM_MULTIPLIERS-1:0] OUT_IB [15:0];
        wire [DATA_WIDTH-1:0] output_buffer_lsw [15:0]; //lower significant word[32 bits]
        wire [DATA_WIDTH-1:0] output_buffer_msw [15:0]; //Upper significant word[32 bits]
        wire [DATA_WIDTH-1:0] output_port [(1<<MAIN_ADDRESS_BITS)-1:0];
        wire [(2*DATA_WIDTH*16*16)-1:0] m;
        
        reg EN_W_i,W_EN_i,write_imcu_i,read_imcu_i,Read_EN_i,DMA_WEN_i,DMA_REN_i,EN_IB_internal_i,latch_En_i;
        reg [7:0] imcu_mem_in_i;
   
    initial begin
     output_ready = 0;

    end
    
    always@(posedge clk) begin
    if(MAC)
    begin
    EN_W_i =EN_W_tc;
    W_EN_i = W_EN_tc;
    write_imcu_i = write_imcu_tc;
    read_imcu_i = read_imcu_tc;
    Read_EN_i = Read_EN_tc;
    DMA_WEN_i = DMA_WEN_tc;
    DMA_REN_i = DMA_REN_tc;
    EN_IB_internal_i = EN_IB_internal_tc;
    latch_En_i = latch_En_tc;
    imcu_mem_in_i = imcu_mem_in_tc;
    end
    else
    EN_W_i =EN_W;
    W_EN_i = W_EN;
    write_imcu_i = write;
    read_imcu_i = read;
    Read_EN_i = Read_EN;
    end
    
    genvar i;
    generate 
    for (i=0;i<16;i=i+1)begin:rows_inst
    PE_Tiles_16 PE_rows(
                         .WL_N(WL_N), .WL_SH(WL_SH),.WL_SL(WL_SL),
                         .rst(rst),
                         .address_input_buffer(address_input_buffer),
                           .address_main_memory(address_main_memory),
                           .address_weight_buffer(address_weight_buffer),

                           .BL(BL), //weightsssss
                           .BLA(BLA), //inputttttt
                           .clk(clk), //ok
                           .IMC(IMC), //ok
                           .EN_IB(EN_IB),
                           .Read_EN(Read_EN_i),
                           .W_EN(EN_WB[i]),
                           .iter_no(iter_no),
                           .EN_W(EN_W_i),
                           .OUT_IB(OUT),
                           .read(read_imcu_i),
                           .write(write_imcu_i),
                           .mem_out(imcu_out), 
                           .latch_MC_En(latch_MC_En),
                           .MC(MC),
                           .MAC_result(MAC_result[i]),
.m( m[(i+1)*(2*DATA_WIDTH*16)-1 : i*(2*DATA_WIDTH*16)] )
            );
       end
       endgenerate
  reg [DATA_WIDTH-1:0] IB_input;
  always@(posedge clk) begin
  if(output_ready)
  IB_input <= out_buffer;
  else
  IB_input <= BLA;
  end
  
  genvar s;
  generate
     for(s=0;s<16;s=s+1) begin: IB_Gen
         INPUT_BUFFER #(.ADDR(IB_ADDRESS_BITS),
                        .DATA_WIDTH(DATA_WIDTH),
                        .X(400))
                        IB1(clk,address_input_buffer, IB_input, EN_IB[s],C0L,OUT[s*16+:16]);
     end
   endgenerate
   
   
   timing_control_imac   #(.DATA_WIDTH(DATA_WIDTH))timing_controller (.clk(clk), .MAC(MAC), 
   .iter_count(iter_count),
   .address_weight_buffer(address_weight_buffer),
   .address_main_memory(address_main_memory),
   .initial_addrs_imcu(initial_addrs_imcu),
   .EN_IB(EN_IB),
   .EN_WB(EN_WB),
   .WL_N(WL_N), .WL_SH(WL_SH),
   .rst(rst),
   .iter_no(iter_no),
   .C0L(C0L), .WL_SL(WL_SL));

    
    // Pre-slice flattened m into 256 entries of 16 bits
    wire [15:0] m_array [0:255];
    genvar W;
    generate 
        for(W = 0; W < 256; W = W + 1)begin : packing
            assign m_array[W] = m[(W+1)*16-1 : W*16];
            end
    endgenerate


// ----------------------------
// Output_Buffer Signals
// ----------------------------
reg [7:0] write_counter;   // 0..255
reg W_EN_buffer;
reg writing;
wire [15:0] out_buffer;

// Instantiate Output_Buffer
Output_Buffer #(
    .ADDR(8),
    .DATA_WIDTH(16),
    .DEPTH(256)
) OUTBUF (
    .clk(clk),
    .Address(write_counter),
    .in(m_array[write_counter]),   // ? legal now
    .W_EN(W_EN_buffer),
    .Read_EN(EN_OB_Read),
    .OUT(out_buffer)
);

// ----------------------------
// Sequential Write Logic
// ----------------------------
always @(posedge clk) begin
    if(output_ready)
        write_counter <= output_counter;
    if(MC) begin       // set start_write = 1 to trigger
        write_counter <= 0;
        W_EN_buffer <= 1;
        writing <= 1;
    end
    else if(writing) begin
        if(write_counter == 255) begin
            writing <= 0;
            W_EN_buffer <= 0;
            output_ready <= 1;
        end
        else
            write_counter <= write_counter + 1;
    end
    
end

PE_Controller controller (
    .iter_count(iter_count)    
    );


   
endmodule

 
