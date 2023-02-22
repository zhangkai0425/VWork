
module axi_slave128#(parameter SV48_CONFIG=0)(
  araddr_s0,
  arburst_s0,
  arcache_s0,
  arid_s0,
  arlen_s0,
  arprot_s0,
  arready_s0,
  arsize_s0,
  arvalid_s0,
  awaddr_s0,
  awburst_s0,
  awcache_s0,
  awid_s0,
  awlen_s0,
  awprot_s0,
  awready_s0,
  awsize_s0,
  awvalid_s0,
  bid_s0,
  bready_s0,
  bresp_s0,
  bvalid_s0,
  pad_cpu_rst_b,
  pll_core_cpuclk,
  rdata_s0,
  rid_s0,
  rlast_s0,
  rready_s0,
  rresp_s0,
  rvalid_s0,
  wdata_s0,
  wid_s0,
  wlast_s0,
  wready_s0,
  wstrb_s0,
  wvalid_s0,
  prog_wen,
  prog_waddr,
  prog_wdata
);


input   [39 :0]  araddr_s0;      
input   [1  :0]  arburst_s0;     
input   [3  :0]  arcache_s0;     
input   [7  :0]  arid_s0;        
input   [7  :0]  arlen_s0;       
input   [2  :0]  arprot_s0;      
input   [2  :0]  arsize_s0;      
input            arvalid_s0;     
input   [39 + SV48_CONFIG:0]  awaddr_s0;      
input   [1  :0]  awburst_s0;     
input   [3  :0]  awcache_s0;     
input   [7  :0]  awid_s0;        
input   [7  :0]  awlen_s0;       
input   [2  :0]  awprot_s0;      
input   [2  :0]  awsize_s0;      
input            awvalid_s0;     
input            bready_s0;      
input            pad_cpu_rst_b;  
input            pll_core_cpuclk; 
input            rready_s0;      
input   [127:0]  wdata_s0;       
input   [7  :0]  wid_s0;         
input            wlast_s0;       
input   [15 :0]  wstrb_s0;       
input            wvalid_s0;      
output           arready_s0;     
output           awready_s0;     
output  [7  :0]  bid_s0;         
output  [1  :0]  bresp_s0;       
output           bvalid_s0;      
output  [127:0]  rdata_s0;       
output  [7  :0]  rid_s0;         
output           rlast_s0;       
output  [1  :0]  rresp_s0;       
output           rvalid_s0;      
output           wready_s0;   

// program write data
input            prog_wen;
input   [19:0]   prog_waddr;
input   [127:0]  prog_wdata;


reg     [7  :0]  arid;           
reg     [7  :0]  arlen;          
reg              arready;        
reg     [7  :0]  awid;           
reg     [7  :0]  awlen;          
reg              awready;        
reg     [7  :0]  bid;            
reg     [1  :0]  cur_state;      
reg     [39 :0]  mem_addr;       
reg              mem_cen;        
reg              mem_cen_0_ff;   
reg              mem_cen_1_ff;   
reg     [127:0]  mem_din;        
wire     [127:0]  mem_dout;       
reg     [15 :0]  mem_wen;        
reg     [1  :0]  next_state;     
reg              read_dly;       
reg     [7  :0]  read_step;      
reg              rvalid;         
reg     [7  :0]  write_step;     


wire    [39 :0]  araddr_s0;      
wire    [7  :0]  arid_s0;        
wire    [7  :0]  arlen_s0;       
wire             arready_s0;     
wire             arvalid_s0;     
//wire    [39 :0]  awaddr_s0; 
wire    [39 + SV48_CONFIG:0]  awaddr_s0;      
wire    [7  :0]  awid_s0;        
wire    [7  :0]  awlen_s0;       
wire             awready_s0;     
wire             awvalid_s0;     
wire    [7  :0]  bid_s0;         
wire             bready_s0;      
wire    [1  :0]  bresp_s0;       
wire             bvalid;         
wire             bvalid_s0;      
wire             mem_cen_0;      
wire             mem_cen_1;      
wire    [127:0]  mem_dout_0;     
wire    [127:0]  mem_dout_1;     
wire    [3  :0]  mem_sel;        
wire             pad_cpu_rst_b;  
wire             pll_core_cpuclk; 
wire    [127:0]  rdata_s0;       
wire             read_over;      
wire    [7  :0]  rid_s0;         
wire             rlast;          
wire             rlast_s0;       
wire             rready_s0;      
wire    [1  :0]  rresp_s0;       
wire             rvalid_s0;      
wire    [127:0]  wdata_s0;       
wire             wrap2_1;        
wire             wrap2_read_en;  
wire             wrap2_write_en; 
wire             wrap4_1;        
wire             wrap4_2;        
wire             wrap4_3;        
wire             wrap4_read_en;  
wire             wrap4_write_en; 
wire             wready;         
wire             wready_s0;      
wire             write_over;     
wire    [15 :0]  wstrb_s0;       
wire             wvalid_s0;      





























parameter IDLE  = 2'b00;
parameter WRITE = 2'b01;
parameter WRITE_RESP = 2'b10;
parameter READ  = 2'b11;

assign  rdata_s0[127:0] = mem_dout[127:0];
assign  rid_s0[7:0] = arid[7:0];
assign  rlast_s0 = rlast;
assign  rresp_s0[1:0] = 2'b0;
assign  rvalid_s0 = rvalid;
assign  arready_s0 = arready;
assign  wready_s0 = wready;
assign  awready_s0 = awready;
assign  bid_s0[7:0] = bid[7:0];
assign  bresp_s0[1:0] = 2'b0;
assign  bvalid_s0 = bvalid;
assign  bvalid = (cur_state[1:0] == WRITE_RESP);

assign  read_over = (read_step[7:0] == arlen[7:0]) ? 1'b1 : 1'b0;
assign  write_over = (write_step[7:0] == awlen[7:0]) ? 1'b1 : 1'b0;

always@(posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
    cur_state[1:0] <= IDLE;
  else
    cur_state[1:0] <= next_state[1:0];
end


always @( wvalid_s0
       or write_over
       or bready_s0
       or arvalid_s0
       or wready
       or cur_state[1:0]
       or rvalid
       or rready_s0
       or awvalid_s0
       or read_over
       or bvalid)
begin
    next_state[1:0] = IDLE;
    case(cur_state[1:0])
    IDLE:
      begin
        if(arvalid_s0)
            next_state[1:0] = READ;
        else if(awvalid_s0)
            next_state[1:0] = WRITE;
        else
            next_state[1:0] = IDLE;
      end
    READ:
      begin
        if(read_over && rvalid && rready_s0)
            next_state[1:0] = IDLE;
        else
            next_state[1:0] = READ;
      end
    WRITE:
      begin
        if(write_over && wvalid_s0 && wready)
            next_state[1:0] = WRITE_RESP;
        else
            next_state[1:0] = WRITE;
      end
    WRITE_RESP:
      begin
        if(bvalid && bready_s0)
            next_state[1:0] = IDLE;
        else
            next_state[1:0] = WRITE_RESP;
      end
    default:
      begin
            next_state[1:0] = 2'bxx;
      end
    endcase

end


always@ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b) begin

      arid[7:0] <= 8'b0;
      arlen[7:0] <= 8'b0;

      awid[7:0] <= 8'b0;
      awlen[7:0] <= 8'b0;
  end
  else if(cur_state==IDLE) begin

      arid[7:0] <= arid_s0[7:0];
      arlen[7:0] <= arlen_s0[7:0];

      awid[7:0] <= awid_s0[7:0];
      awlen[7:0] <= awlen_s0[7:0];
  end
end


always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      read_step[7:0] <= 8'b0;
  else if(next_state[1:0] == IDLE)
      read_step[7:0] <= 8'b0;
  else if((cur_state[1:0] == READ) && rready_s0 && rvalid)
      read_step[7:0] <= read_step[7:0] + 1'b1;
  else 
      read_step[7:0] <= read_step[7:0];
end


always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      write_step[7:0] <= 8'b0;
  else if(next_state[1:0] == IDLE)
      write_step[7:0] <= 8'b0;
  else if((cur_state[1:0] == WRITE) && wvalid_s0 && wready)
      write_step[7:0] <= write_step[7:0] + 1'b1;
  else 
      write_step[7:0] <= write_step[7:0];
end


assign wrap2_read_en = (cur_state[1:0]==READ)&&(arlen[7:0]==8'b0001);
assign wrap2_write_en = (cur_state[1:0]==WRITE)&&(awlen[7:0]==8'b0001);
assign wrap4_read_en = (cur_state[1:0]==READ)&&(arlen[7:0]==8'b0011);
assign wrap4_write_en = (cur_state[1:0]==WRITE)&&(awlen[7:0]==8'b0011);


assign wrap2_1 = (mem_addr[4]==1'b1)&&(((read_step[7:0]==8'h0)&&wrap2_read_en)||
                 ((write_step[7:0]==8'h0)&&wrap2_write_en));


assign wrap4_1 = (mem_addr[5:4]==2'b11)&&(((read_step[7:0]==8'h0)&&wrap4_read_en)||
                 ((write_step[7:0]==8'h0)&&wrap4_write_en));


assign wrap4_2 = (mem_addr[5:4]==2'b11)&&(((read_step[7:0]==8'h01)&&wrap4_read_en)||
                 ((write_step[7:0]==8'h01)&&wrap4_write_en));


assign wrap4_3 = (mem_addr[5:4]==2'b11)&&(((read_step[7:0]==8'h02)&&wrap4_read_en)||
                 ((write_step[7:0]==8'h02)&&wrap4_write_en));

always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
    begin
      mem_addr[39:0] <= 40'b0;
    end
  else if((cur_state[1:0] == IDLE) && arvalid_s0)
    begin
      mem_addr[39:0] <= araddr_s0[39:0];
    end
  else if((cur_state[1:0] == IDLE) && awvalid_s0)
    begin
      mem_addr[39:0] <= awaddr_s0[39:0];
    end
  else if((wrap4_1 || wrap4_2 || wrap4_3) && 
          ((wvalid_s0 && wready) || (rready_s0 && rvalid)))
    begin
      mem_addr[39:0] <= mem_addr[39:0] - 40'h30;
    end
  else if((wrap2_1) &&
          ((wvalid_s0 && wready) || (rready_s0 && rvalid)))
    begin
      mem_addr[39:0] <= mem_addr[39:0] - 40'h10;
    end
  else if((wvalid_s0 && wready) || (rready_s0 && rvalid))
    begin
      mem_addr[39:0] <= mem_addr[39:0] + 40'h10;
    end
end


assign wready = (cur_state[1:0]==WRITE);


always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      read_dly <= 1'b0;
  else if((arvalid_s0 && arready) || (rvalid && rready_s0))
      read_dly <= 1'b1;
  else
      read_dly <= 1'b0;
end

always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      rvalid <= 1'b0;
  else if((cur_state[1:0] == READ) && read_dly)
      rvalid <= 1'b1;
  else if(rvalid && rready_s0)
      rvalid <= 1'b0;
end



assign rlast = ((read_step[7:0]==arlen[7:0]) && rvalid);



always @( arvalid_s0
       or cur_state[1:0])
begin
      arready = 1'b0;
      awready = 1'b0;
  case(cur_state[1:0])
  IDLE:
    begin
      if(arvalid_s0)
        arready = 1'b1;
      else
        awready = 1'b1;
    end
  READ:
    begin
      arready = 1'b0;
      awready = 1'b0;
    end
  WRITE:
    begin
      arready = 1'b0;
      awready = 1'b0;
    end
  WRITE_RESP:
    begin
      arready = 1'b0;
      awready = 1'b0;
    end
  default:
    begin
      arready = 1'bx;
      awready = 1'bx;
    end
  endcase

end



always @( awid
       or cur_state[1:0])
begin
  case(cur_state[1:0])
  IDLE:
    begin
      bid[7:0] = 8'b0;
    end
  READ:
    begin
      bid[7:0] = 8'b0;
    end
  WRITE:
    begin
      bid[7:0] = 8'b0;
    end
  WRITE_RESP:
    begin
      bid[7:0] = awid;
    end
  default:
    begin
      bid[7:0] = 8'bxxxxx;
    end
  endcase

end



always @( cur_state
       or wdata_s0[127:0]
       or wvalid_s0
       or wready
       or wstrb_s0[15:0])
begin
  if(cur_state == READ)
    begin
      mem_cen = 1'b0;
      mem_wen[15:0] = 16'hffff;
      mem_din[127:0] = 128'b0;
    end
  else if(wvalid_s0 && wready)
    begin
      mem_cen = 1'b0;
      mem_wen[15:0] = ~wstrb_s0[15:0];
      mem_din[127:0] = wdata_s0[127:0];
    end
  else
    begin
      mem_cen = 1'b1;
      mem_wen[15:0] = 16'hffff;
      mem_din[127:0] = 128'b0;
    end

end

wire     [127:0]  mem_dout_test;  
wire     [127:0]  mem_ram_din;
assign mem_ram_din[127:0] = prog_wen ? prog_wdata[127:0] : mem_din[127:0];

f_spsram_large x_f_spsram_large (
  .A                 (mem_addr[24:4]   ),
  .CEN               (mem_cen          ),
  .CLK               (pll_core_cpuclk  ),
  .D                 (mem_ram_din[127:0]   ),
  .Q                 (mem_dout_test[127:0]  ),
  .WEN               (mem_wen[15:0]    )
);


wire iram_par_err; // debug signal
// change of addra:according to f_spsram_large module
wire [19:0] init_addr;
reg [19:0] addr_holding;
wire [19:0] mem_addra;
assign init_addr = mem_addr[23:4];

always@(posedge pll_core_cpuclk)
begin
  if(!mem_cen) begin
    addr_holding[19:0] <= init_addr[19:0];
  end
end

assign mem_addra[19:0] = prog_wen ? prog_waddr[19:0] : mem_cen ? addr_holding[19:0]
                                  : init_addr[19:0];

wire [15:0] ram_wen;
assign ram_wen[0] = prog_wen | !mem_cen && !mem_wen[0];
assign ram_wen[1] = prog_wen | !mem_cen && !mem_wen[1];
assign ram_wen[2] = prog_wen | !mem_cen && !mem_wen[2];
assign ram_wen[3] = prog_wen | !mem_cen && !mem_wen[3];
assign ram_wen[4] = prog_wen | !mem_cen && !mem_wen[4];
assign ram_wen[5] = prog_wen | !mem_cen && !mem_wen[5];
assign ram_wen[6] = prog_wen | !mem_cen && !mem_wen[6];
assign ram_wen[7] = prog_wen | !mem_cen && !mem_wen[7];
assign ram_wen[8] = prog_wen | !mem_cen && !mem_wen[8];
assign ram_wen[9] = prog_wen | !mem_cen && !mem_wen[9];
assign ram_wen[10] = prog_wen | !mem_cen && !mem_wen[10];
assign ram_wen[11] = prog_wen | !mem_cen && !mem_wen[11];
assign ram_wen[12] = prog_wen | !mem_cen && !mem_wen[12];
assign ram_wen[13] = prog_wen | !mem_cen && !mem_wen[13];
assign ram_wen[14] = prog_wen | !mem_cen && !mem_wen[14];
assign ram_wen[15] = prog_wen | !mem_cen && !mem_wen[15];

wire [7:0] ram0_dout;
wire [7:0] ram1_dout;
wire [7:0] ram2_dout;
wire [7:0] ram3_dout;
wire [7:0] ram4_dout;
wire [7:0] ram5_dout;
wire [7:0] ram6_dout;
wire [7:0] ram7_dout;
wire [7:0] ram8_dout;
wire [7:0] ram9_dout;
wire [7:0] ram10_dout;
wire [7:0] ram11_dout;
wire [7:0] ram12_dout;
wire [7:0] ram13_dout;
wire [7:0] ram14_dout;
wire [7:0] ram15_dout;

assign mem_dout[127:0] = prog_wen ? 128'ha001a001a001a001a001a001a001a001 : { ram15_dout[7:0],ram14_dout[7:0],ram13_dout[7:0],ram12_dout[7:0],
                    ram11_dout[7:0],ram10_dout[7:0],ram9_dout[7:0],ram8_dout[7:0],
                    ram7_dout[7:0],ram6_dout[7:0],ram5_dout[7:0],ram4_dout[7:0],
                    ram3_dout[7:0],ram2_dout[7:0],ram1_dout[7:0],ram0_dout[7:0] };

// change to here end
unified_SPRAM #(
        .MEMORY_PRIMITIVE("block"),   //"auto","block","distributed","ultra"
        .MEMORY_INIT_FILE("iRAM_init.mem"),      // String
        .BYTE_WRITE_EN(0),
        .ADDR_WIDTH_A(20), //15
        .READ_LATENCY_A(1),
        .WRITE_DATA_WIDTH_A(128),        // DECIMAL
        .READ_DATA_WIDTH_A(128)
	) inst_iram(
    .rsta       (!pad_cpu_rst_b),
    .clka       (pll_core_cpuclk),
    .wea        (|ram_wen[15:0]),
    .ena        (1'b1),
    .addra      (mem_addra[19:0]), //ram_addr[14:0]
    .dina       (mem_ram_din[127:0]),
    .douta      ({ram0_dout[7:0],ram1_dout[7:0],ram2_dout[7:0],ram3_dout[7:0],
                  ram4_dout[7:0],ram5_dout[7:0],ram6_dout[7:0],ram7_dout[7:0],
                  ram8_dout[7:0],ram9_dout[7:0],ram10_dout[7:0],ram11_dout[7:0],
                  ram12_dout[7:0],ram13_dout[7:0],ram14_dout[7:0],ram15_dout[7:0]}),
    .parity_err (iram_par_err) //at rd_clk
);

endmodule



