//////////////////////////////////////////////////////////////////////////////////
// Company: Alibaba Quantum Lab
// Engineer: ZhuXing
//
// Create Date: 2020/03/30 15:49:27
// Design Name:
// Module Name: pcie_mdl
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ps / 1ps

module pcie_mdl #
  (
   parameter PL_LINK_CAP_MAX_LINK_WIDTH          = 4,            // 1- X1; 2 - X2; 4 - X4; 8 - X8
   parameter PL_SIM_FAST_LINK_TRAINING           = "FALSE",      // Simulation Speedup
   parameter PL_LINK_CAP_MAX_LINK_SPEED          = 2,             // 1- GEN1; 2 - GEN2; 4 - GEN3
   parameter C_DATA_WIDTH                        = 128 ,
   parameter EXT_PIPE_SIM                        = "FALSE",  // This Parameter has effect on selecting Enable External PIPE Interface in GUI.
   parameter C_ROOT_PORT                         = "FALSE",      // PCIe block is in root port mode
   parameter C_DEVICE_NUMBER                     = 0,            // Device number for Root Port configurations only
   parameter AXIS_CCIX_RX_TDATA_WIDTH     = 256,
   parameter AXIS_CCIX_TX_TDATA_WIDTH     = 256,
   parameter AXIS_CCIX_RX_TUSER_WIDTH     = 46,
   parameter AXIS_CCIX_TX_TUSER_WIDTH     = 46
   )
   (
    output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txp,
    output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txn,
    input [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  pci_exp_rxp,
    input [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  pci_exp_rxn,

//VU9P_TUL_EX_String= FALSE




    input            sys_clk_p,
    input            sys_clk_n,
    input            sys_rst_n,

    input [C_DATA_WIDTH-1:0]    c2h_tdata,
    input            c2h_tvalid,
    input            c2h_tlast,
    input [15:0]     c2h_tkeep,
    output           c2h_tready,

    output           pcie_user_clk,
    output [C_DATA_WIDTH-1:0]   h2c_data,
    output           h2c_valid
 );

   //-----------------------------------------------------------------------------------------------------------------------


   // Local Parameters derived from user selection
   localparam integer            USER_CLK_FREQ         = ((PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? 5 : 4);
   localparam TCQ = 1;
   localparam C_S_AXI_ID_WIDTH = 4;
   localparam C_M_AXI_ID_WIDTH = 4;
   localparam C_S_AXI_DATA_WIDTH = C_DATA_WIDTH;
   localparam C_M_AXI_DATA_WIDTH = C_DATA_WIDTH;
   localparam C_S_AXI_ADDR_WIDTH = 64;
   localparam C_M_AXI_ADDR_WIDTH = 64;
   localparam C_NUM_USR_IRQ  = 1;

   wire              user_lnk_up;

   //----------------------------------------------------------------------------------------------------------------//
   //  AXI Interface                                                                                                 //
   //----------------------------------------------------------------------------------------------------------------//

   wire              user_clk;
   wire              user_resetn;

  // Wires for Avery HOT/WARM and COLD RESET
   wire              avy_sys_rst_n_c;
   wire              avy_cfg_hot_reset_out;
   reg               avy_sys_rst_n_g;
   reg               avy_cfg_hot_reset_out_g;
   assign avy_sys_rst_n_c = avy_sys_rst_n_g;
   assign avy_cfg_hot_reset_out = avy_cfg_hot_reset_out_g;
   initial begin
      avy_sys_rst_n_g = 1;
      avy_cfg_hot_reset_out_g =0;
   end



  //----------------------------------------------------------------------------------------------------------------//
  //    System(SYS) Interface                                                                                       //
  //----------------------------------------------------------------------------------------------------------------//

    wire                                    sys_clk;
    wire                                    sys_clk_gt;
    wire                                    sys_rst_n_c;

  // User Clock LED Heartbeat
     reg [25:0]            user_clk_heartbeat;
     reg [((2*C_NUM_USR_IRQ)-1):0]    usr_irq_function_number=0;
     reg [C_NUM_USR_IRQ-1:0]         usr_irq_req = 0;
     wire [C_NUM_USR_IRQ-1:0]          usr_irq_ack;

      //-- AXI Master Write Address Channel
     wire [C_M_AXI_ADDR_WIDTH-1:0] m_axi_awaddr;
     wire [C_M_AXI_ID_WIDTH-1:0] m_axi_awid;
     wire [2:0]      m_axi_awprot;
     wire [1:0]      m_axi_awburst;
     wire [2:0]      m_axi_awsize;
     wire [3:0]      m_axi_awcache;
     wire [7:0]      m_axi_awlen;
     wire        m_axi_awlock;
     wire        m_axi_awvalid;
     wire        m_axi_awready;

     //-- AXI Master Write Data Channel
     wire [C_M_AXI_DATA_WIDTH-1:0]     m_axi_wdata;
     wire [(C_M_AXI_DATA_WIDTH/8)-1:0] m_axi_wstrb;
     wire              m_axi_wlast;
     wire              m_axi_wvalid;
     wire              m_axi_wready;
     //-- AXI Master Write Response Channel
     wire              m_axi_bvalid;
     wire              m_axi_bready;
     wire [C_M_AXI_ID_WIDTH-1 : 0]     m_axi_bid ;
     wire [1:0]                        m_axi_bresp ;

     //-- AXI Master Read Address Channel
     wire [C_M_AXI_ID_WIDTH-1 : 0]     m_axi_arid;
     wire [C_M_AXI_ADDR_WIDTH-1:0]     m_axi_araddr;
     wire [7:0]                        m_axi_arlen;
     wire [2:0]                        m_axi_arsize;
     wire [1:0]                        m_axi_arburst;
     wire [2:0]            m_axi_arprot;
     wire              m_axi_arvalid;
     wire              m_axi_arready;
     wire              m_axi_arlock;
     wire [3:0]            m_axi_arcache;

     //-- AXI Master Read Data Channel
     wire [C_M_AXI_ID_WIDTH-1 : 0]   m_axi_rid;
     wire [C_M_AXI_DATA_WIDTH-1:0]   m_axi_rdata;
     wire [1:0]          m_axi_rresp;
     wire            m_axi_rvalid;
     wire            m_axi_rready;





//////////////////////////////////////////////////  LITE
   //-- AXI Master Write Address Channel
    wire [31:0] m_axil_awaddr;
    wire [2:0]  m_axil_awprot;
    wire  m_axil_awvalid;
    wire  m_axil_awready;

    //-- AXI Master Write Data Channel
    wire [31:0] m_axil_wdata;
    wire [3:0]  m_axil_wstrb;
    wire  m_axil_wvalid;
    wire  m_axil_wready;
    //-- AXI Master Write Response Channel
    wire  m_axil_bvalid;
    wire  m_axil_bready;
    //-- AXI Master Read Address Channel
    wire [31:0] m_axil_araddr;
    wire [2:0]  m_axil_arprot;
    wire  m_axil_arvalid;
    wire  m_axil_arready;
    //-- AXI Master Read Data Channel
    wire [31:0] m_axil_rdata;
    wire [1:0]  m_axil_rresp;
    wire  m_axil_rvalid;
    wire  m_axil_rready;
    wire [1:0]  m_axil_bresp;

    wire [2:0]    msi_vector_width;
    wire          msi_enable;

      // AXI streaming ports
    wire [C_DATA_WIDTH-1:0] m_axis_h2c_tdata_0;
    wire      m_axis_h2c_tlast_0;
    wire      m_axis_h2c_tvalid_0;
    wire      m_axis_h2c_tready_0;
    wire [C_DATA_WIDTH/8-1:0] m_axis_h2c_tkeep_0;
    wire [C_DATA_WIDTH-1:0] s_axis_c2h_tdata_0;
    wire s_axis_c2h_tlast_0;
    wire s_axis_c2h_tvalid_0;
    wire s_axis_c2h_tready_0;
    wire [C_DATA_WIDTH/8-1:0] s_axis_c2h_tkeep_0;

    wire [3:0]                  leds;

 wire free_run_clock;

  wire [5:0]                          cfg_ltssm_state;

  // Ref clock buffer
  IBUFDS_GTE2 refclk_ibuf (.O(sys_clk), .ODIV2(), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));
  // Reset buffer
  IBUF   sys_reset_n_ibuf (.O(sys_rst_n_c), .I(sys_rst_n));







  // Core Top Level Wrapper
  xdma_0 xdma_0_i
     (
      //---------------------------------------------------------------------------------------//
      //  PCI Express (pci_exp) Interface                                                      //
      //---------------------------------------------------------------------------------------//
      .sys_rst_n       ( sys_rst_n_c ),
      .sys_clk         ( sys_clk ),

      // Tx
      .pci_exp_txn     ( pci_exp_txn ),
      .pci_exp_txp     ( pci_exp_txp ),

      // Rx
      .pci_exp_rxn     ( pci_exp_rxn ),
      .pci_exp_rxp     ( pci_exp_rxp ),



      // AXI streaming ports
      .s_axis_c2h_tdata_0(c2h_tdata), //
      .s_axis_c2h_tlast_0(c2h_tlast), //
      .s_axis_c2h_tvalid_0(c2h_tvalid), //
      .s_axis_c2h_tready_0(c2h_tready), //
      .s_axis_c2h_tkeep_0(c2h_tkeep), //
      .m_axis_h2c_tdata_0(m_axis_h2c_tdata_0),
      .m_axis_h2c_tlast_0(m_axis_h2c_tlast_0),
      .m_axis_h2c_tvalid_0(m_axis_h2c_tvalid_0),
      .m_axis_h2c_tready_0(1'b1), //
      .m_axis_h2c_tkeep_0(m_axis_h2c_tkeep_0),

      // LITE interface
      //-- AXI Master Write Address Channel
      .m_axil_awaddr    (m_axil_awaddr),
      .m_axil_awprot    (m_axil_awprot),
      .m_axil_awvalid   (m_axil_awvalid),
      .m_axil_awready   (m_axil_awready),
      //-- AXI Master Write Data Channel
      .m_axil_wdata     (m_axil_wdata),
      .m_axil_wstrb     (m_axil_wstrb),
      .m_axil_wvalid    (m_axil_wvalid),
      .m_axil_wready    (m_axil_wready),
      //-- AXI Master Write Response Channel
      .m_axil_bvalid    (m_axil_bvalid),
      .m_axil_bresp     (m_axil_bresp),
      .m_axil_bready    (m_axil_bready),
      //-- AXI Master Read Address Channel
      .m_axil_araddr    (m_axil_araddr),
      .m_axil_arprot    (m_axil_arprot),
      .m_axil_arvalid   (m_axil_arvalid),
      .m_axil_arready   (m_axil_arready),
      .m_axil_rdata     (m_axil_rdata),
      //-- AXI Master Read Data Channel
      .m_axil_rresp     (m_axil_rresp),
      .m_axil_rvalid    (m_axil_rvalid),
      .m_axil_rready    (m_axil_rready),




      .usr_irq_req       (usr_irq_req),
      .usr_irq_ack       (usr_irq_ack),
      .msi_enable        (msi_enable),
      .msi_vector_width  (msi_vector_width),


     // Config managemnet interface
      .cfg_mgmt_addr  ( 19'b0 ),
      .cfg_mgmt_write ( 1'b0 ),
      .cfg_mgmt_write_data ( 32'b0 ),
      .cfg_mgmt_byte_enable ( 4'b0 ),
      .cfg_mgmt_read  ( 1'b0 ),
      .cfg_mgmt_read_data (),
      .cfg_mgmt_read_write_done (),
      .cfg_mgmt_type1_cfg_reg_access ( 1'b0 ),




      //-- AXI Global
      .axi_aclk        ( user_clk ),
      .axi_aresetn     ( user_resetn ),






      .user_lnk_up     ( user_lnk_up )
    );


  // XDMA taget application
  xdma_app #(
    .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH)
  ) xdma_app_i (

      // AXI Lite Master Interface connections
      .s_axil_awaddr  (m_axil_awaddr[31:0]),
      .s_axil_awvalid (m_axil_awvalid),
      .s_axil_awready (m_axil_awready),
      .s_axil_wdata   (m_axil_wdata[31:0]),    // block fifo for AXI lite only 31 bits.
      .s_axil_wstrb   (m_axil_wstrb[3:0]),
      .s_axil_wvalid  (m_axil_wvalid),
      .s_axil_wready  (m_axil_wready),
      .s_axil_bresp   (m_axil_bresp),
      .s_axil_bvalid  (m_axil_bvalid),
      .s_axil_bready  (m_axil_bready),
      .s_axil_araddr  (m_axil_araddr[31:0]),
      .s_axil_arvalid (m_axil_arvalid),
      .s_axil_arready (m_axil_arready),
      .s_axil_rdata   (m_axil_rdata),   // block ram for AXI Lite is only 31 bits
      .s_axil_rresp   (m_axil_rresp),
      .s_axil_rvalid  (m_axil_rvalid),
      .s_axil_rready  (m_axil_rready),

      .user_clk(user_clk),
      .user_resetn(user_resetn),
      .user_lnk_up(user_lnk_up),
      .sys_rst_n(sys_rst_n_c),

      .leds()
  );

assign h2c_data = m_axis_h2c_tdata_0;
assign h2c_valid = m_axis_h2c_tvalid_0;
assign pcie_user_clk = user_clk;
endmodule
