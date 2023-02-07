





















module err_gen(
  hburst_s3,
  hmastlock,
  hprot_s3,
  hrdata_s3,
  hready_s3,
  hresp_s3,
  hsel_s3,
  hsize_s3,
  htrans_s3,
  hwdata_s3,
  hwrite_s3,
  pad_cpu_rst_b,
  pll_core_cpuclk
);


input   [2  :0]  hburst_s3;      
input            hmastlock;      
input   [3  :0]  hprot_s3;       
input            hsel_s3;        
input   [2  :0]  hsize_s3;       
input   [1  :0]  htrans_s3;      
input   [127:0]  hwdata_s3;      
input            hwrite_s3;      
input            pad_cpu_rst_b;  
input            pll_core_cpuclk; 
output  [127:0]  hrdata_s3;      
output           hready_s3;      
output  [1  :0]  hresp_s3;       


reg              hready_s3;      


wire    [127:0]  hrdata_s3;      
wire    [1  :0]  hresp_s3;       
wire             hsel_s3;        
wire             pad_cpu_rst_b;  
wire             pll_core_cpuclk; 




















assign hresp_s3[1:0]  =  2'b01 ;

always @(posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
    begin
      hready_s3 <= 1'b0;
    end
  else if(hsel_s3)
    begin
      hready_s3 <= 1'b0;
    end
  else
    begin
      hready_s3 <= 1'b1;     
    end
end






assign hrdata_s3[127:0] = 128'b0;

endmodule


