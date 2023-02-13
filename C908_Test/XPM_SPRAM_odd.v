

// XPM_MEMORY instantiation template for Single Port RAM configurations
// Refer to the targeted device family architecture libraries guide for XPM_MEMORY documentation
// =======================================================================================================================

// Parameter usage table, organized as follows:
// +---------------------------------------------------------------------------------------------------------------------+
// | Parameter name       | Data type          | Restrictions, if applicable                                             |
// |---------------------------------------------------------------------------------------------------------------------|
// | Description                                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// +---------------------------------------------------------------------------------------------------------------------+
// | ADDR_WIDTH_A         | Integer            | Range: 1 - 20. Default value = 6.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the width of the port A address port addra, in bits.                                                        |
// | Must be large enough to access the entire memory from port A, i.e. = $clog2(MEMORY_SIZE/[WRITE|READ]_DATA_WIDTH_A). |
// +---------------------------------------------------------------------------------------------------------------------+
// | AUTO_SLEEP_TIME      | Integer            | Range: 0 - 15. Default value = 0.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Number of clka cycles to auto-sleep, if feature is available in architecture                                        |
// | 0 - Disable auto-sleep feature                                                                                      |
// | 3-15 - Number of auto-sleep latency cycles                                                                          |
// | Do not change from the value provided in the template instantiation                                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | BYTE_WRITE_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | To enable byte-wide writes on port A, specify the byte width, in bits-                                              |
// | 8- 8-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 8                                |
// | 9- 9-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 9                                |
// | Or to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | ECC_MODE             | String             | Allowed values: no_ecc, both_encode_and_decode, decode_only, encode_only. Default value = no_ecc.|
// |---------------------------------------------------------------------------------------------------------------------|
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_INIT_FILE     | String             | Default value = none.                                                   |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify "none" (including quotes) for no memory initialization, or specify the name of a memory initialization file-|
// | Enter only the name of the file with .mem extension, including quotes but without path (e.g. "my_file.mem").        |
// | File format must be ASCII and consist of only hexadecimal values organized into the specified depth by              |
// | narrowest data width generic value of the memory. See the Memory File (MEM) section for more                        |
// | information on the syntax. Initialization of memory happens through the file name specified only when parameter     |
// | MEMORY_INIT_PARAM value is equal to "".                                                                             |
// | When using XPM_MEMORY in a project, add the specified file to the Vivado project as a design source.                |
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_INIT_PARAM    | String             | Default value = 0.                                                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify "" or "0" (including quotes) for no memory initialization through parameter, or specify the string          |
// | containing the hex characters.Enter only hex characters and each location separated by delimiter(,).                |
// | Parameter format must be ASCII and consist of only hexadecimal values organized into the specified depth by         |
// | narrowest data width generic value of the memory. For example, if the narrowest data width is 8, and the depth of   |
// | memory is 8 locations, then the parameter value should be passed as shown below.                                    |
// | parameter MEMORY_INIT_PARAM = "AB,CD,EF,1,2,34,56,78"                                                               |
// | |                   |                                                                                               |
// | 0th                7th                                                                                              |
// | location            location.                                                                                       |
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_OPTIMIZATION  | String             | Allowed values: true, false. Default value = true.                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify "true" to enable the optimization of unused memory or bits in the memory structure. Specify "false" to      |
// | disable the optimization of unused memory or bits in the memory structure.                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_PRIMITIVE     | String             | Allowed values: auto, block, distributed, ultra. Default value = auto.  |
// |---------------------------------------------------------------------------------------------------------------------|
// | Designate the memory primitive (resource type) to use-                                                              |
// |                                                                                                                     |
// |  "auto"- Allow Vivado Synthesis to choose                                                                           |
// |   "distributed"- Distributed memory                                                                                 |
// |   "block"- Block memory                                                                                             |
// |   "ultra"- Ultra RAM memory                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_SIZE          | Integer            | Range: 2 - 150994944. Default value = 2048.                             |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the total memory array size, in bits.                                                                       |
// | For example, enter 65536 for a 2kx32 RAM.                                                                           |
// |                                                                                                                     |
// |  When ECC is enabled and set to "encode_only", then the memory size has to be multiples of READ_DATA_WIDTH_A        |
// |   When ECC is enabled and set to "decode_only", then the memory size has to be multiples of WRITE_DATA_WIDTH_A      |
// | .                                                                                                                   |
// +---------------------------------------------------------------------------------------------------------------------+
// | MESSAGE_CONTROL      | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify 1 to enable the dynamic message reporting such as collision warnings, and 0 to disable the message reporting|
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_DATA_WIDTH_A    | Integer            | Range: 1 - 4608. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the width of the port A read data output port douta, in bits.                                               |
// | The values of READ_DATA_WIDTH_A and WRITE_DATA_WIDTH_A must be equal.                                               |
// | When ECC is enabled and set to "encode_only", then READ_DATA_WIDTH_A has to be multiples of 72-bits                 |
// | When ECC is enabled and set to "decode_only" or "both_encode_and_decode", then READ_DATA_WIDTH_A has to be          |
// | multiples of 64-bits.                                                                                               |
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_LATENCY_A       | Integer            | Range: 0 - 100. Default value = 2.                                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the number of register stages in the port A read data pipeline. Read data output to port douta takes this   |
// | number of clka cycles.                                                                                              |
// | To target block memory, a value of 1 or larger is required- 1 causes use of memory latch only; 2 causes use of      |
// | output register. To target distributed memory, a value of 0 or larger is required- 0 indicates combinatorial output.|
// | Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.                  |
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_RESET_VALUE_A   | String             | Default value = 0.                                                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the reset value of the port A final output register stage in response to rsta input port is assertion.      |
// | As this parameter is a string, please specify the hex values inside double quotes. As an example,                   |
// | If the read data width is 8, then specify READ_RESET_VALUE_A = "EA";                                                |
// | When ECC is enabled, then reset value is not supported.                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | USE_MEM_INIT         | Integer            | Range: 0 - 1. Default value = 1.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify 1 to enable the generation of below message and 0 to disable the generation of below message completely.    |
// | Note- This message gets generated only when there is no Memory Initialization specified either through file or      |
// | Parameter.                                                                                                          |
// | INFO - MEMORY_INIT_FILE and MEMORY_INIT_PARAM together specifies no memory initialization.                          |
// | Initial memory contents will be all 0s.                                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | WAKEUP_TIME          | String             | Allowed values: disable_sleep, use_sleep_pin. Default value = disable_sleep.|
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify "disable_sleep" to disable dynamic power saving option, and specify "use_sleep_pin" to enable the           |
// | dynamic power saving option                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | WRITE_DATA_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the width of the port A write data input port dina, in bits.                                                |
// | The values of WRITE_DATA_WIDTH_A and READ_DATA_WIDTH_A must be equal.                                               |
// | When ECC is enabled and set to "encode_only" or "both_encode_and_decode", then WRITE_DATA_WIDTH_A has to be         |
// | multiples of 64-bits                                                                                                |
// | When ECC is enabled and set to "decode_only", then WRITE_DATA_WIDTH_A has to be multiples of 72-bits.               |
// +---------------------------------------------------------------------------------------------------------------------+
// | WRITE_MODE_A         | String             | Allowed values: read_first, no_change, write_first. Default value = read_first.|
// |---------------------------------------------------------------------------------------------------------------------|
// | Write mode behavior for port A output data port, douta.                                                             |
// +---------------------------------------------------------------------------------------------------------------------+

// Port usage table, organized as follows:
// +---------------------------------------------------------------------------------------------------------------------+
// | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
// |---------------------------------------------------------------------------------------------------------------------|
// | Description                                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// +---------------------------------------------------------------------------------------------------------------------+
// | addra          | Input     | ADDR_WIDTH_A                          | clka    | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Address for port A write and read operations.                                                                       |
// +---------------------------------------------------------------------------------------------------------------------+
// | clka           | Input     | 1                                     | NA      | Rising edge | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Clock signal for port A.                                                                                            |
// +---------------------------------------------------------------------------------------------------------------------+
// | dbiterra       | Output    | 1                                     | clka    | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Status signal to indicate double bit error occurrence on the data output of port A.                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | dina           | Input     | WRITE_DATA_WIDTH_A                    | clka    | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Data input for port A write operations.                                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | douta          | Output    | READ_DATA_WIDTH_A                     | clka    | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Data output for port A read operations.                                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | ena            | Input     | 1                                     | clka    | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Memory enable signal for port A.                                                                                    |
// | Must be high on clock cycles when read or write operations are initiated. Pipelined internally.                     |
// +---------------------------------------------------------------------------------------------------------------------+
// | injectdbiterra | Input     | 1                                     | clka    | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in  |
// | "decode_only" mode).                                                                                                |
// +---------------------------------------------------------------------------------------------------------------------+
// | injectsbiterra | Input     | 1                                     | clka    | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in  |
// | "decode_only" mode).                                                                                                |
// +---------------------------------------------------------------------------------------------------------------------+
// | regcea         | Input     | 1                                     | clka    | Active-high | Tie to 1'b1            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Clock Enable for the last register stage on the output data path.                                                   |
// +---------------------------------------------------------------------------------------------------------------------+
// | rsta           | Input     | 1                                     | clka    | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Reset signal for the final port A output register stage.                                                            |
// | Synchronously resets output port douta to the value specified by parameter READ_RESET_VALUE_A.                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | sbiterra       | Output    | 1                                     | clka    | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Status signal to indicate single bit error occurrence on the data output of port A.                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | sleep          | Input     | 1                                     | NA      | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | sleep signal to enable the dynamic power saving feature.                                                            |
// +---------------------------------------------------------------------------------------------------------------------+
// | wea            | Input     | WRITE_DATA_WIDTH_A                    | clka    | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used.                     |
// | In byte-wide write configurations, each bit controls the writing one byte of dina to address addra.                 |
// | For example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.   |
// +---------------------------------------------------------------------------------------------------------------------+


// xpm_memory_spram : In order to incorporate this function into the design,
//     Verilog      : the following instance declaration needs to be placed
//     instance     : in the body of the design code.  The instance name
//   declaration    : (xpm_memory_spram_inst) and/or the port declarations within the
//       code       : parenthesis may be changed to properly reference and
//                  : connect this function to the design.  All inputs
//                  : and outputs must be connected.

//  Please reference the appropriate libraries guide for additional information on the XPM modules.

//  <-----Cut code below this line---->

   // xpm_memory_spram: Single Port RAM
   // Xilinx Parameterized Macro, version 2018.2
 
module XPM_SPRAM_odd #(
        parameter MEMORY_PRIMITIVE = "auto",   //"auto","block","distributed","ultra"
        parameter MEMORY_INIT_FILE = "none",      // String
        parameter BYTE_WRITE_EN = 0,      // DECIMAL
        parameter ADDR_WIDTH_A = 32,
        parameter READ_LATENCY_A = 1,
        parameter WRITE_DATA_WIDTH_A = 32,        // DECIMAL
        parameter READ_DATA_WIDTH_A  = 32
	)
	(
  rsta     ,   clka     ,
  wea     ,  ena       ,addra     , dina      , douta      ,   parity_err  //at rd_clk
);   
   

//////////////////////////////////////////////

    localparam WE_WIDTH_A   = BYTE_WRITE_EN ? WRITE_DATA_WIDTH_A/8 : 1;
    
    input                            rsta     ; 
    input                            clka     ;
    input  [WE_WIDTH_A-1:0]          wea     ;
    input                            ena       ;
    input  [ADDR_WIDTH_A-1:0]        addra     ;
    input  [WRITE_DATA_WIDTH_A-1:0]  dina      ;
    output [READ_DATA_WIDTH_A-1:0]     douta      ;
    output reg                         parity_err ; //at rd_clk
    
    genvar i;
    
    reg   ena_d1;
    reg   ena_d2;  
    wire  ena_parity_check;
     
     always @(posedge clka or posedge rsta)
     begin
         if(rsta) begin
             ena_d1 <= 1'b0;
             ena_d2 <= 1'b0;
         end
         else  begin
             ena_d1 <= ena;
             ena_d2 <= ena_d1;
         end
     end
    assign ena_parity_check = (READ_LATENCY_A==1) ? ena_d1 : ena_d2;
 /////////////////////////////////////////////////////////////////
 
   generate  if(BYTE_WRITE_EN) begin:byte_wr_ram
        wire [9*WRITE_DATA_WIDTH_A/8-1:0] din_parity; 
        wire [9*READ_DATA_WIDTH_A/8:0]  dout_parity;
        
         for(i=0;i<WRITE_DATA_WIDTH_A/8;i=i+1) begin:din_dou_gen_A
            assign din_parity[(i+1)*9-1:i*9] = {^dina[(i+1)*8-1:i*8],  dina[(i+1)*8-1:i*8]};
            assign douta[(i+1)*8-1:i*8] = dout_parity[(i+1)*9-2:i*9];
         end
   
        
         always@(posedge clka or posedge rsta) 
            if(rsta)
              parity_err <= 1'b0;
            else if((^dout_parity) && (ena_parity_check == 1'b1))
              parity_err <= 1'b1;

       
    xpm_memory_spram #(
      .ADDR_WIDTH_A(ADDR_WIDTH_A),               // DECIMAL
      .AUTO_SLEEP_TIME(0),            // DECIMAL
      .BYTE_WRITE_WIDTH_A(9),        // DECIMAL
      .ECC_MODE("no_ecc"),            // String
      .MEMORY_INIT_FILE(MEMORY_INIT_FILE),      // String
      .MEMORY_INIT_PARAM(""),        // String
      .MEMORY_OPTIMIZATION("true"),   // String
      .MEMORY_PRIMITIVE(MEMORY_PRIMITIVE),      // String
      .MEMORY_SIZE((2**ADDR_WIDTH_A)*(9*WRITE_DATA_WIDTH_A/8)),             // DECIMAL
      .MESSAGE_CONTROL(0),            // DECIMAL
      .READ_DATA_WIDTH_A(9*READ_DATA_WIDTH_A/8),         // DECIMAL
      .READ_LATENCY_A(READ_LATENCY_A),             // DECIMAL
      .READ_RESET_VALUE_A("0"),       // String
      .USE_MEM_INIT(1),               // DECIMAL
      .WAKEUP_TIME("disable_sleep"),  // String
      .WRITE_DATA_WIDTH_A((9*WRITE_DATA_WIDTH_A/8)),        // DECIMAL
      .WRITE_MODE_A("read_first")//("no_change")      // String
   )
   xpm_memory_spram_inst (
      .dbiterra(),             // 1-bit output: Status signal to indicate double bit error occurrence
                                       // on the data output of port B.

      .douta(dout_parity),                   // READ_DATA_WIDTH_A-bit output: Data output for port B read operations.
      .sbiterra(),             // 1-bit output: Status signal to indicate single bit error occurrence
                                       // on the data output of port B.

      .addra(addra),                   // ADDR_WIDTH_A-bit input: Address for port A write operations.
      .clka(clka),                     // 1-bit input: Clock signal for port A. Also clocks port B when
                                       // parameter CLOCKING_MODE is "common_clock".

      .dina(din_parity),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      .ena(ena),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
                                       // cycles when write operations are initiated. Pipelined internally.

      .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .regcea(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
                                       // data path.

      .rsta(1'b0),                     // 1-bit input: Reset signal for the final port B output register stage.
                                       // Synchronously resets output port doutb to the value specified by
                                       // parameter READ_RESET_VALUE_B.

      .sleep(1'b0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
      .wea(wea)                        // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
                                       // data port dina. 1 bit wide when word-wide writes are used. In
                                       // byte-wide write configurations, each bit controls the writing one
                                       // byte of dina to address addra. For example, to synchronously write
                                       // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
                                       // 4'b0010.

   ); 
 end
 else begin:normal_ram
 
   wire [WRITE_DATA_WIDTH_A:0] din_parity; 
       wire [READ_DATA_WIDTH_A:0]  dout_parity;
        
          assign din_parity = {^dina,dina};
 
      
       assign douta = dout_parity[READ_DATA_WIDTH_A-1:0];
  
       
        always@(posedge clka or posedge rsta) 
           if(rsta)
             parity_err <= 1'b0;
           else if((^dout_parity) && (ena_parity_check == 1'b1))
             parity_err <= 1'b1;

      
   xpm_memory_spram #(
     .ADDR_WIDTH_A(ADDR_WIDTH_A),               // DECIMAL
     .AUTO_SLEEP_TIME(0),            // DECIMAL
     .BYTE_WRITE_WIDTH_A((WRITE_DATA_WIDTH_A+1)),        // DECIMAL
     .ECC_MODE("no_ecc"),            // String
     .MEMORY_INIT_FILE(MEMORY_INIT_FILE),      // String
     .MEMORY_INIT_PARAM(""),        // String
     .MEMORY_OPTIMIZATION("true"),   // String
     .MEMORY_PRIMITIVE(MEMORY_PRIMITIVE),      // String
     .MEMORY_SIZE((2**ADDR_WIDTH_A)*(WRITE_DATA_WIDTH_A+1)),             // DECIMAL
     .MESSAGE_CONTROL(0),            // DECIMAL
     .READ_DATA_WIDTH_A(READ_DATA_WIDTH_A+1),         // DECIMAL
     .READ_LATENCY_A(READ_LATENCY_A),             // DECIMAL
     .READ_RESET_VALUE_A("0"),       // String
     .USE_MEM_INIT(1),               // DECIMAL
     .WAKEUP_TIME("disable_sleep"),  // String
     .WRITE_DATA_WIDTH_A((WRITE_DATA_WIDTH_A+1)),        // DECIMAL
     .WRITE_MODE_A("read_first")//("no_change")      // String
  )
  xpm_memory_spram_inst (
     .dbiterra(),             // 1-bit output: Status signal to indicate double bit error occurrence
                                      // on the data output of port B.

     .douta(dout_parity),                   // READ_DATA_WIDTH_A-bit output: Data output for port B read operations.
     .sbiterra(),             // 1-bit output: Status signal to indicate single bit error occurrence
                                      // on the data output of port B.

     .addra(addra),                   // ADDR_WIDTH_A-bit input: Address for port A write operations.
     .clka(clka),                     // 1-bit input: Clock signal for port A. Also clocks port B when
                                      // parameter CLOCKING_MODE is "common_clock".

     .dina(din_parity),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
     .ena(ena),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
                                      // cycles when write operations are initiated. Pipelined internally.

     .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                      // ECC enabled (Error injection capability is not available in
                                      // "decode_only" mode).

     .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                      // ECC enabled (Error injection capability is not available in
                                      // "decode_only" mode).

     .regcea(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
                                      // data path.

     .rsta(1'b0),                     // 1-bit input: Reset signal for the final port B output register stage.
                                      // Synchronously resets output port doutb to the value specified by
                                      // parameter READ_RESET_VALUE_B.

     .sleep(1'b0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
     .wea(wea)                        // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
                                      // data port dina. 1 bit wide when word-wide writes are used. In
                                      // byte-wide write configurations, each bit controls the writing one
                                      // byte of dina to address addra. For example, to synchronously write
                                      // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
                                      // 4'b0010.

  ); 
 
 
 end
 endgenerate      
    

  
    
endmodule				
				
				