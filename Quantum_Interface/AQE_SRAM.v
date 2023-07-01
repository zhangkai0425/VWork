
module AQE_SRAM#(parameter SV48_CONFIG=0)(
  araddr_s1,
  arburst_s1,
  arcache_s1,
  arid_s1,
  arlen_s1,
  arprot_s1,
  arready_s1,
  arsize_s1,
  arvalid_s1,
  awaddr_s1,
  awburst_s1,
  awcache_s1,
  awid_s1,
  awlen_s1,
  awprot_s1,
  awready_s1,
  awsize_s1,
  awvalid_s1,
  bid_s1,
  bready_s1,
  bresp_s1,
  bvalid_s1,
  pad_cpu_rst_b,
  pll_core_cpuclk,
  rdata_s1,
  rid_s1,
  rlast_s1,
  rready_s1,
  rresp_s1,
  rvalid_s1,
  wdata_s1,
  wid_s1,
  wlast_s1,
  wready_s1,
  wstrb_s1,
  wvalid_s1,

  // self defined signals
  prog_wen,
  prog_wdata,
  prog_waddr,
  dram1_portb_wen,
  dram1_portb_din,
  dram1_portb_dout,
  dram1_portb_addr,
  mmio_addr,
  mmio_data,
  ram_wen
);


input   [39 :0]  araddr_s1;      
input   [1  :0]  arburst_s1;     
input   [3  :0]  arcache_s1;     
input   [7  :0]  arid_s1;        
input   [7  :0]  arlen_s1;       
input   [2  :0]  arprot_s1;      
input   [2  :0]  arsize_s1;      
input            arvalid_s1;     
input   [39 + SV48_CONFIG:0]  awaddr_s1;      
input   [1  :0]  awburst_s1;     
input   [3  :0]  awcache_s1;     
input   [7  :0]  awid_s1;        
input   [7  :0]  awlen_s1;       
input   [2  :0]  awprot_s1;      
input   [2  :0]  awsize_s1;      
input            awvalid_s1;     
input            bready_s1;      
input            pad_cpu_rst_b;  
input            pll_core_cpuclk; 
input            rready_s1;      
input   [127:0]  wdata_s1;       
input   [7  :0]  wid_s1;         
input            wlast_s1;       
input   [15 :0]  wstrb_s1;       
input            wvalid_s1;      
output           arready_s1;     
output           awready_s1;     
output  [7  :0]  bid_s1;         
output  [1  :0]  bresp_s1;       
output           bvalid_s1;      
output  [127:0]  rdata_s1;       
output  [7  :0]  rid_s1;         
output           rlast_s1;       
output  [1  :0]  rresp_s1;       
output           rvalid_s1;      
output           wready_s1;   

// self defined signals
input            prog_wen;
input   [19:0]   prog_waddr;
input   [127:0]  prog_wdata;

input   [15:0]   dram1_portb_wen;
input   [127:0]  dram1_portb_din;
output  [127:0]  dram1_portb_dout;
input   [19:0]   dram1_portb_addr;

output  [39:0 ]   mmio_addr;
output  [127:0]   mmio_data;
output  [15:0 ]   ram_wen  ;


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
wire    [127:0]  mem_dout;       
reg     [15 :0]  mem_wen;        
reg     [1  :0]  next_state;     
reg              read_dly;       
reg     [7  :0]  read_step;      
reg              rvalid;         
reg     [7  :0]  write_step;     


wire    [39 :0]  araddr_s1;      
wire    [7  :0]  arid_s1;        
wire    [7  :0]  arlen_s1;       
wire             arready_s1;     
wire             arvalid_s1;     
//wire    [39 :0]  awaddr_s1; 
wire    [39 + SV48_CONFIG:0]  awaddr_s1;      
wire    [7  :0]  awid_s1;        
wire    [7  :0]  awlen_s1;       
wire             awready_s1;     
wire             awvalid_s1;     
wire    [7  :0]  bid_s1;         
wire             bready_s1;      
wire    [1  :0]  bresp_s1;       
wire             bvalid;         
wire             bvalid_s1;      
wire             mem_cen_0;      
wire             mem_cen_1;      
wire    [127:0]  mem_dout_0;     
wire    [127:0]  mem_dout_1;     
wire    [3  :0]  mem_sel;        
wire             pad_cpu_rst_b;  
wire             pll_core_cpuclk; 
wire    [127:0]  rdata_s1;       
wire             read_over;      
wire    [7  :0]  rid_s1;         
wire             rlast;          
wire             rlast_s1;       
wire             rready_s1;      
wire    [1  :0]  rresp_s1;       
wire             rvalid_s1;      
wire    [127:0]  wdata_s1;       
wire             wrap2_1;        
wire             wrap2_read_en;  
wire             wrap2_write_en; 
wire             wrap4_1;        
wire             wrap4_2;        
wire             wrap4_3;        
wire             wrap4_read_en;  
wire             wrap4_write_en; 
wire             wready;         
wire             wready_s1;      
wire             write_over;     
wire    [15 :0]  wstrb_s1;       
wire             wvalid_s1;      


parameter SMEM_WIDTH = 22;


























parameter IDLE  = 2'b00;
parameter WRITE = 2'b01;
parameter WRITE_RESP = 2'b10;
parameter READ  = 2'b11;

assign  rdata_s1[127:0] = mem_dout[127:0];
assign  rid_s1[7:0] = arid[7:0];
assign  rlast_s1 = rlast;
assign  rresp_s1[1:0] = 2'b0;
assign  rvalid_s1 = rvalid;
assign  arready_s1 = arready;
assign  wready_s1 = wready;
assign  awready_s1 = awready;
assign  bid_s1[7:0] = bid[7:0];
assign  bresp_s1[1:0] = 2'b0;
assign  bvalid_s1 = bvalid;
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


always @( wvalid_s1
       or write_over
       or bready_s1
       or arvalid_s1
       or wready
       or cur_state[1:0]
       or rvalid
       or rready_s1
       or awvalid_s1
       or read_over
       or bvalid)
begin
    next_state[1:0] = IDLE;
    case(cur_state[1:0])
    IDLE:
      begin
        if(arvalid_s1)
            next_state[1:0] = READ;
        else if(awvalid_s1)
            next_state[1:0] = WRITE;
        else
            next_state[1:0] = IDLE;
      end
    READ:
      begin
        if(read_over && rvalid && rready_s1)
            next_state[1:0] = IDLE;
        else
            next_state[1:0] = READ;
      end
    WRITE:
      begin
        if(write_over && wvalid_s1 && wready)
            next_state[1:0] = WRITE_RESP;
        else
            next_state[1:0] = WRITE;
      end
    WRITE_RESP:
      begin
        if(bvalid && bready_s1)
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

      arid[7:0] <= arid_s1[7:0];
      arlen[7:0] <= arlen_s1[7:0];

      awid[7:0] <= awid_s1[7:0];
      awlen[7:0] <= awlen_s1[7:0];
  end
end


always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      read_step[7:0] <= 8'b0;
  else if(next_state[1:0] == IDLE)
      read_step[7:0] <= 8'b0;
  else if((cur_state[1:0] == READ) && rready_s1 && rvalid)
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
  else if((cur_state[1:0] == WRITE) && wvalid_s1 && wready)
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
  else if((cur_state[1:0] == IDLE) && arvalid_s1)
    begin
      mem_addr[39:0] <= araddr_s1[39:0];
    end
  else if((cur_state[1:0] == IDLE) && awvalid_s1)
    begin
      mem_addr[39:0] <= awaddr_s1[39:0];
    end
  else if((wrap4_1 || wrap4_2 || wrap4_3) && 
          ((wvalid_s1 && wready) || (rready_s1 && rvalid)))
    begin
      mem_addr[39:0] <= mem_addr[39:0] - 40'h30;
    end
  else if((wrap2_1) &&
          ((wvalid_s1 && wready) || (rready_s1 && rvalid)))
    begin
      mem_addr[39:0] <= mem_addr[39:0] - 40'h10;
    end
  else if((wvalid_s1 && wready) || (rready_s1 && rvalid))
    begin
      mem_addr[39:0] <= mem_addr[39:0] + 40'h10;
    end
end


assign wready = (cur_state[1:0]==WRITE);


always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      read_dly <= 1'b0;
  else if((arvalid_s1 && arready) || (rvalid && rready_s1))
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
  else if(rvalid && rready_s1)
      rvalid <= 1'b0;
end



assign rlast = ((read_step[7:0]==arlen[7:0]) && rvalid);



always @( arvalid_s1
       or cur_state[1:0])
begin
      arready = 1'b0;
      awready = 1'b0;
  case(cur_state[1:0])
  IDLE:
    begin
      if(arvalid_s1)
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
       or wdata_s1[127:0]
       or wvalid_s1
       or wready
       or wstrb_s1[15:0])
begin
  if(cur_state == READ)
    begin
      mem_cen = 1'b0;
      mem_wen[15:0] = 16'hffff;
      mem_din[127:0] = 128'b0;
    end
  else if(wvalid_s1 && wready)
    begin
      mem_cen = 1'b0;
      mem_wen[15:0] = ~wstrb_s1[15:0];
      mem_din[127:0] = wdata_s1[127:0];
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

// f_spsram_32768x128  x_f_spsram_32768x128_L (
//   .A               (mem_addr[24:4] ),
//   .CEN             (mem_cen        ),
//   .CLK             (pll_core_cpuclk),
//   .D               (mem_ram_din[127:0] ),
//   .Q               (mem_dout_test[127:0]),
//   .WEN             (mem_wen[15:0]  )
// );

// change of addra:according to f_spsram



wire [19:0] init_addr;
reg  [19:0] addr_holding;
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
wire [39:0] mmio_addr;
wire [127:0] mmio_data;
assign mmio_addr = {16'h0002,mem_addra,4'h0};
assign mmio_data = mem_ram_din;
wire [15:0] ram_wen;

assign ram_wen[0] = prog_wen | (!mem_cen && !mem_wen[0]);
assign ram_wen[1] = prog_wen | (!mem_cen && !mem_wen[1]);
assign ram_wen[2] = prog_wen | (!mem_cen && !mem_wen[2]);
assign ram_wen[3] = prog_wen | (!mem_cen && !mem_wen[3]);
assign ram_wen[4] = prog_wen | (!mem_cen && !mem_wen[4]);
assign ram_wen[5] = prog_wen | (!mem_cen && !mem_wen[5]);
assign ram_wen[6] = prog_wen | (!mem_cen && !mem_wen[6]);
assign ram_wen[7] = prog_wen | (!mem_cen && !mem_wen[7]);
assign ram_wen[8] = prog_wen | (!mem_cen && !mem_wen[8]);
assign ram_wen[9] = prog_wen | (!mem_cen && !mem_wen[9]);
assign ram_wen[10] = prog_wen | (!mem_cen && !mem_wen[10]);
assign ram_wen[11] = prog_wen | (!mem_cen && !mem_wen[11]);
assign ram_wen[12] = prog_wen | (!mem_cen && !mem_wen[12]);
assign ram_wen[13] = prog_wen | (!mem_cen && !mem_wen[13]);
assign ram_wen[14] = prog_wen | (!mem_cen && !mem_wen[14]);
assign ram_wen[15] = prog_wen | (!mem_cen && !mem_wen[15]);

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

// notice the order
assign mem_dout[127:0] = prog_wen ? 128'ha001a001a001a001a001a001a001a001 : { ram0_dout[7:0],ram1_dout[7:0],ram2_dout[7:0],ram3_dout[7:0],
                    ram4_dout[7:0],ram5_dout[7:0],ram6_dout[7:0],ram7_dout[7:0],
                    ram8_dout[7:0],ram9_dout[7:0],ram10_dout[7:0],ram11_dout[7:0],
                    ram12_dout[7:0],ram13_dout[7:0],ram14_dout[7:0],ram15_dout[7:0] };


// change to here end


// System ram used before in E906
parameter addr_width_value = 10;
unified_TDPRAM #(
     .MEMORY_PRIMITIVE("block"),   //"auto","block","distributed","ultra"
     .CLOCKING_MODE("common_clock"),
     .MEMORY_INIT_FILE("sRAM_init.mem"),      // String
     .BYTE_WRITE_EN(0),      // DECIMAL
     .READ_LATENCY_A(1),
     .READ_LATENCY_B(2),
     .ADDR_WIDTH_A(addr_width_value), //10
     .ADDR_WIDTH_B(addr_width_value), //10
     .WRITE_DATA_WIDTH_A(128),        // DECIMAL
     .WRITE_DATA_WIDTH_B(128),        // DECIMAL
     .READ_DATA_WIDTH_A(128),
     .READ_DATA_WIDTH_B(128)
	) x_inst_sharemem (
.rsta(!pad_cpu_rst_b),
.rstb(!pad_cpu_rst_b),
.clka(pll_core_cpuclk),
.wea(|ram_wen[15:0]),
.ena(1'b1),
.addra(mem_addra[addr_width_value-1:0]),
.dina(mem_ram_din[127:0]),
.douta({ram0_dout[7:0],ram1_dout[7:0],ram2_dout[7:0],ram3_dout[7:0],
                  ram4_dout[7:0],ram5_dout[7:0],ram6_dout[7:0],ram7_dout[7:0],
                  ram8_dout[7:0],ram9_dout[7:0],ram10_dout[7:0],ram11_dout[7:0],
                  ram12_dout[7:0],ram13_dout[7:0],ram14_dout[7:0],ram15_dout[7:0]}),
.clkb(pll_core_cpuclk),
.addrb(dram1_portb_addr[addr_width_value-1:0]),
.dinb(dram1_portb_din),
.web(dram1_portb_wen),
.enb(1'b1),
.doutb(dram1_portb_dout),
.parity_err()
);

endmodule



