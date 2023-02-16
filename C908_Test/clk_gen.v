
module clk_gen(
  clkrst_b,
  i_pad_clk,
  clk_en,
  psel,
  penable,
  prdata,
  pwdata,
  pwrite,

  gate_en0,
  gate_en1,

  pad_biu_clkratio,
  per_clk,
  cpu_clk
);


input           clkrst_b;        
input           i_pad_clk;       
input           penable;         
input           psel;            
input   [2 :0]  pwdata;          
input           pwrite;         
input           gate_en0;      
input           gate_en1;      
output          clk_en;          
output  [3 :0]  pad_biu_clkratio; 
output          per_clk;         
output          cpu_clk;         
output  [31:0]  prdata;          


wire    [31:0]  prdata;          


wire            clk_en;          
wire            clkrst_b;        
wire            i_pad_clk;       
wire    [3 :0]  pad_biu_clkratio; 
wire            penable;         
wire            per_clk;         
wire            cpu_clk;         
wire            psel;            
wire    [2 :0]  pwdata;          
wire            pwrite;          

// configure parameter for system clock dividor
// 0 not support
//
// default 1:1. all case can run in this configuration
// 1 = 1:1
//
// some case may run fail
// 2 = 2:1
// 3 = 3:1
// 4 = 4:1
// 5 = 5:1
//........
// 7 = 7:1
parameter [3:0] SYS_CLK_RATIO = 4'h1;
parameter [3:0] CPU_CLK_RATIO = 4'hf;


reg [3:0]  cnt; 
reg        cnt_zero; 
wire       sys_clk;
always @(posedge i_pad_clk or negedge clkrst_b)
begin
  if(!clkrst_b)
    cnt[3:0] <= 4'b0;
  else if(cnt == (SYS_CLK_RATIO - 1))
    cnt[3:0] <= 4'b0;
  else
    cnt[3:0] <= cnt[3:0] + 4'd1;
end

//------------------- clk delay with CPU_CLK ---- -
// "<=" --> "="
// 20220627 
always @(posedge i_pad_clk or negedge clkrst_b)
begin
  if(!clkrst_b)
    cnt_zero =  1'b1;
  else if(cnt == (SYS_CLK_RATIO - 1))
    cnt_zero =  1'b1;
  else
    cnt_zero =  1'b0;
end


assign sys_clk = (SYS_CLK_RATIO == 1) ?  i_pad_clk
                                 :  cnt_zero;

assign  prdata[31:0]          = {27'b0,SYS_CLK_RATIO};
assign  pad_biu_clkratio[3:0] = SYS_CLK_RATIO;

reg [3:0] div_cnt;
reg       slow_clk; 
always @(posedge i_pad_clk or negedge clkrst_b) begin
  if (!clkrst_b) begin
    div_cnt     <= CPU_CLK_RATIO;
    slow_clk    <= 1'b0;
  end
  else begin
    if(div_cnt != 4'h0) begin
      div_cnt   <= div_cnt - 1;
      slow_clk  <= slow_clk;
    end
    else begin
      div_cnt   <= CPU_CLK_RATIO;
      slow_clk  <= ~slow_clk;
    end
  end
end

assign per_clk = sys_clk;
`ifndef CLOCK_DIV_TEST
assign #0.1 clk_en  = (SYS_CLK_RATIO == 1) ? 1'b1 : 
                      (SYS_CLK_RATIO == 2) ? cnt_zero : (cnt == SYS_CLK_RATIO - 2);
assign cpu_clk = gate_en0 ? slow_clk : (gate_en1 ? 1'b0 : i_pad_clk);
`else
reg   per_clk_r_gate_en0;
wire  tmp_gate_en0;
assign #0.1 tmp_gate_en0 = gate_en0;

always @(posedge per_clk or negedge clkrst_b) begin
  if (!clkrst_b) begin
    per_clk_r_gate_en0    <= #0.1 1'b0;
  end
  else begin
    per_clk_r_gate_en0    <= #0.1 tmp_gate_en0;
  end
end

wire  tmp_per_clk_r_gate_en0;
reg   pad_clk_r_gate_en0;
reg   pad_clk_rr_gate_en0;
reg   pad_clk_rrr_gate_en0;

assign #0.1 tmp_per_clk_r_gate_en0 = per_clk_r_gate_en0;

always @(posedge i_pad_clk or negedge clkrst_b) begin
  if (!clkrst_b) begin
    pad_clk_r_gate_en0    <= #0.1 1'b0;
    pad_clk_rr_gate_en0   <= #0.1 1'b0;
    pad_clk_rrr_gate_en0  <= #0.1 1'b0;
  end
  else begin
    pad_clk_r_gate_en0    <= #0.1 tmp_per_clk_r_gate_en0;
    pad_clk_rr_gate_en0   <= #0.1 pad_clk_r_gate_en0;
    pad_clk_rrr_gate_en0  <= #0.1 pad_clk_rr_gate_en0;
  end
end

assign #0.1 clk_en  = pad_clk_rr_gate_en0 ? 1 : (SYS_CLK_RATIO == 1) ? 1'b1 : 
                      (SYS_CLK_RATIO == 2) ? cnt_zero : (cnt == SYS_CLK_RATIO - 2);
assign cpu_clk = pad_clk_rrr_gate_en0 ? sys_clk : i_pad_clk;
`endif

endmodule


