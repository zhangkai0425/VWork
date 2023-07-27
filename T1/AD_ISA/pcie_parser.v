`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/04/08 15:16:43
// Design Name:
// Module Name: pcie_parser
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

module pcie_parser (
    input 			 pxie_clk,
    input            clk_50m,
    input 			 resetn,

    input   [127:0]  pxie_rddata_in,
    input            pxie_rden_in,
    //pll
    output           pll_reinit_out,
    output           pll_init_en_out,
    output           pll_cfgen_out,
    output [23:0]    pll_cfgdata_out,
    output [1:0]     pll_pinreg_out,
    //adc
    output [1:0]     adc_cfg_numb_out,
    output           adc1_cfgen_out,
    output [23:0]    adc1_cfgdata_out,
    output           adc2_cfgen_out,
    output [23:0]    adc2_cfgdata_out,
    output           adc_trig_out,
    output [7:0]     adc_modereg_out,
    output [15:0]    adc_trig_thresh_out,
    output           adc_calen_out,
    output [15:0]    wave_fre,
    //parameter
    output [13:0]    cycle_out,
    output [13:0]    wave_len_out,
    output [19:0]    delay_out,
    output           tdata_start_out,
    output           dma_start_out,
    output [3:0]     data_mode,
    output [3:0]     analysis_mode,
(*mark_debug="true"*)    output           isa_mode_vld,
    //rst
    output           pll_rstn_out,
    output           adc_rstn_out,
    output           ddr_rstn_out,
    output           pcie_rstn_out,
    output           global_rstn_out,

(*mark_debug="true"*)    output [31:0]   I0,
(*mark_debug="true"*)    output [31:0]   Q0,
(*mark_debug="true"*)    output [31:0]   I1,
(*mark_debug="true"*)    output [31:0]   Q1,

    output [1:0]     test_led
);

wire reset=~resetn;

reg pll_cfgen_r;
reg [23:0] pll_cfgdata_r;
reg adc1_cfgen_r;
reg [23:0] adc1_cfgdata_r;
reg adc2_cfgen_r;
reg [23:0] adc2_cfgdata_r;
reg adc_calen_r;
reg adc_trig_r;
reg [7:0] adc_modereg_r;
reg [15:0] adc_trig_thresh_r;
reg [8:0] adc_ptnum_pre_r;
reg [12:0] adc_ptnum_acq_r;
reg [1:0] pll_pinreg_r;
reg pll_init_en_r;
reg pll_reinit_r;
reg [13:0] wave_len_r;
reg [13:0] cycle_r;
reg [19:0] delay_r;
reg [15:0] wave_fre_r;
reg [3:0] analysis_mode_r;
reg [3:0] data_mode_r;
reg       isa_mode_vld_r;

reg [31:0] I0_r;
reg [31:0] Q0_r;
reg [31:0] I1_r;
reg [31:0] Q1_r;
reg [15:0] I0_l_r;
reg [15:0] I0_h_r;
reg [15:0] Q0_l_r;
reg [15:0] Q0_h_r;
reg [15:0] I1_l_r;
reg [15:0] I1_h_r;
reg [15:0] Q1_l_r;
reg [15:0] Q1_h_r;


reg pll_rstn_r;
reg adc_rstn_r;
reg ddr_rstn_r;
reg pcie_rstn_r;
reg global_rstn_r;

reg [1:0] test_led_r;

reg [31:0]  cmd_1;
reg [31:0]  cmd_2;
reg [31:0]  cmd_3;
reg [31:0]  cmd_4;
wire [127:0] fifo_cmd;
reg         fifo_cmd_en;
(*mark_debug="true"*)reg [31:0]  cmd_data;
(*mark_debug="true"*)reg         cmd_en;
reg [7:0]   cmd_wati_cnt;

reg         dma_start_r;
reg         tdata_start_r;
wire fifo_full;
wire fifo_empty;
cmd_fifo cmd_fifo_inst(
    .rst(reset),
    .wr_clk(pxie_clk),// : IN STD_LOGIC;
    .rd_clk(clk_50m),// : IN STD_LOGIC;
    .din(pxie_rddata_in),// : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    .wr_en(pxie_rden_in),// : IN STD_LOGIC;
    .rd_en(fifo_cmd_en),// : IN STD_LOGIC;
    .dout(fifo_cmd), //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    .full(fifo_full), //: OUT STD_LOGIC;
    .empty(fifo_empty) //: OUT STD_LOGIC
  );

parameter [3:0] ST_START        = 4'h0;
parameter [3:0] ST_RDFIFO       = 4'h1;
parameter [3:0] ST_CMD1         = 4'h2;
parameter [3:0] ST_CMD1_WAIT    = 4'h3;
parameter [3:0] ST_CMD2         = 4'h4;
parameter [3:0] ST_CMD2_WAIT    = 4'h5;
parameter [3:0] ST_CMD3         = 4'h6;
parameter [3:0] ST_CMD3_WAIT    = 4'h7;
parameter [3:0] ST_CMD4         = 4'h8;
parameter [3:0] ST_CMD4_WAIT    = 4'h9;
parameter [3:0] ST_DONE         = 4'ha;
reg [3:0] state;



assign state_rst = reset;
always @ (posedge clk_50m or posedge reset)
begin
    if (reset) begin
        state <= ST_START;
        fifo_cmd_en     <= 1'b0;
        cmd_en          <= 1'b0;
        cmd_data        <= 32'h0;
        cmd_wati_cnt    <= 8'h0;
        cmd_1           <= 32'h0;
        cmd_2           <= 32'h0;
        cmd_3           <= 32'h0;
        cmd_4           <= 32'h0;
    end else begin
        if (state_rst == 1'b1) begin
            state           <= ST_START;
            fifo_cmd_en     <= 1'b0;
            cmd_en          <= 1'b0;
            cmd_wati_cnt    <= 8'h0;
            cmd_data        <= 32'h0;
            cmd_1           <= 32'h0;
            cmd_2           <= 32'h0;
            cmd_3           <= 32'h0;
            cmd_4           <= 32'h0;
        end else begin
            state <= ST_START;
            case (state)
                ST_START: begin
                    cmd_1           <= 32'h0;
                    cmd_2           <= 32'h0;
                    cmd_3           <= 32'h0;
                    cmd_4           <= 32'h0;
                    cmd_wati_cnt    <= 8'h0;
                    cmd_en          <= 1'b0;
                    cmd_data        <= 32'h0;
                    if (fifo_empty == 1'b0)
                    begin
                    fifo_cmd_en     <= 1'b1;
                    state <= ST_RDFIFO;
                    end
                    else begin
                    fifo_cmd_en     <= 1'b0;
                    state <= ST_START;
                    end
                end
                ST_RDFIFO: begin
                    cmd_1           <= fifo_cmd[31:0];
                    cmd_2           <= fifo_cmd[63:32];
                    cmd_3           <= fifo_cmd[95:64];
                    cmd_4           <= fifo_cmd[127:96];
                    fifo_cmd_en     <= 1'b0;
                    cmd_en          <= 1'b0;
                    cmd_data        <= 32'h0;
                    state <= ST_CMD1;
                end
                ST_CMD1: begin
                    cmd_en          <= 1'b1;
                    cmd_data        <= cmd_1;
                    cmd_wati_cnt    <= 8'h0;
                    state <= ST_CMD1_WAIT;
                end
                ST_CMD1_WAIT: begin
                    cmd_en          <= 1'b0;
                    if (cmd_wati_cnt == 8'h7f) begin
                    state <= ST_CMD2;
                    end else begin
                    cmd_wati_cnt <= cmd_wati_cnt + 1'b1;
                    state <= ST_CMD1_WAIT;
                    end
                end
                ST_CMD2: begin
                    cmd_en          <= 1'b1;
                    cmd_data        <= cmd_2;
                    cmd_wati_cnt    <= 8'h0;
                    state <= ST_CMD2_WAIT;
                end
                ST_CMD2_WAIT: begin
                    cmd_en          <= 1'b0;
                    if (cmd_wati_cnt == 8'h7f) begin
                    state <= ST_CMD3;
                    end else begin
                    cmd_wati_cnt <= cmd_wati_cnt + 1'b1;
                    state <= ST_CMD2_WAIT;
                    end
                end
                ST_CMD3: begin
                    cmd_en          <= 1'b1;
                    cmd_data        <= cmd_3;
                    cmd_wati_cnt    <= 8'h0;
                    state <= ST_CMD3_WAIT;
                end
                ST_CMD3_WAIT: begin
                    cmd_en          <= 1'b0;
                    if (cmd_wati_cnt == 8'h7f) begin
                    state <= ST_CMD4;
                    end else begin
                    cmd_wati_cnt <= cmd_wati_cnt + 1'b1;
                    state <= ST_CMD3_WAIT;
                    end
                end
                ST_CMD4: begin
                    cmd_en          <= 1'b1;
                    cmd_data        <= cmd_4;
                    cmd_wati_cnt    <= 8'h0;
                    state <= ST_CMD4_WAIT;
                end
                ST_CMD4_WAIT: begin
                    cmd_en          <= 1'b0;
                    if (cmd_wati_cnt == 8'h7f) begin
                    state <= ST_DONE;
                    end else begin
                    cmd_wati_cnt <= cmd_wati_cnt + 1'b1;
                    state <= ST_CMD4_WAIT;
                    end
                end
                ST_DONE: begin
                    cmd_wati_cnt    <= 8'h0;
                    cmd_en          <= 1'b0;
                    cmd_data        <= 32'h0;
                    state <= ST_START;
                end
                default: state <= ST_START;
            endcase
        end
    end
end

always @ (posedge clk_50m or posedge reset)
begin
    if (reset) begin
        test_led_r          <= 2'b0;
        pll_cfgen_r         <= 1'b0;
        pll_reinit_r        <= 1'b0;
        pll_pinreg_r        <= 2'b11;
        pll_cfgdata_r       <= 24'hFF_FFFF;
        adc1_cfgen_r        <= 1'b0;
        adc1_cfgdata_r      <= 24'hFF_FFFF;
        adc2_cfgen_r        <= 1'b0;
        adc2_cfgdata_r      <= 24'hFF_FFFF;
        adc_trig_r          <= 1'b0;
        adc_modereg_r       <= 8'b0000_0000;
        adc_trig_thresh_r   <= 16'h800;
        tdata_start_r       <= 1'b0;
        pll_init_en_r       <= 1'b0;
        wave_len_r          <= 12'h7ff;//2048ns
        cycle_r             <= 14'h3ff;//1~1000
        delay_r             <= 20'h0;//0~256ns
        pll_rstn_r          <= 1'b0;
        adc_rstn_r          <= 1'b0;
        ddr_rstn_r          <= 1'b0;
        pcie_rstn_r         <= 1'b0;
        global_rstn_r       <= 1'b0;
        wave_fre_r          <= 16'h3e8;
        analysis_mode_r     <= 4'h0;
        isa_mode_vld_r      <= 1'b0;
        data_mode_r         <= 4'h0;
        I0_r                <= 32'h0;
        Q0_r                <= 32'h0;
        I1_r                <= 32'h0;
        Q1_r                <= 32'h0;
        I0_l_r              <= 16'h0;
        Q0_l_r              <= 16'h0;
        I1_l_r              <= 16'h0;
        Q1_l_r              <= 16'h0;
        I0_h_r              <= 16'h0;
        Q0_h_r              <= 16'h0;
        I1_h_r              <= 16'h0;
        Q1_h_r              <= 16'h0;
    end else begin
        adc_modereg_r       <= 8'b0000_0001;
        pll_reinit_r        <= 1'b0;
        pll_pinreg_r        <= 2'b11;
        pll_cfgen_r         <= 1'b0;
        adc1_cfgen_r        <= 1'b0;
        adc2_cfgen_r        <= 1'b0;
        adc_calen_r         <= 1'b0;
        pll_init_en_r       <= 1'b1;
        adc_trig_r          <= 1'b0;
        pll_rstn_r          <= 1'b1;
        adc_rstn_r          <= 1'b1;
        ddr_rstn_r          <= 1'b1;
        pcie_rstn_r         <= 1'b1;
        global_rstn_r       <= 1'b1;
        I0_r                <= {I0_h_r,I0_l_r};
        Q0_r                <= {Q0_h_r,Q0_l_r};
        I1_r                <= {I1_h_r,I1_l_r};
        Q1_r                <= {Q1_h_r,Q1_l_r};

        if (cmd_en == 1'b1) begin
            case (cmd_data[31:28])
                4'h1: begin
                    //global_rstn_r       <= 1'b0;
                end
                4'h2: begin
                    //pll_rstn_r          <= cmd_data[0];
                    //adc_rstn_r          <= cmd_data[1];
                    //ddr_rstn_r          <= cmd_data[2];
                    //pcie_rstn_r         <= cmd_data[3];
                    //global_rstn_r       <= cmd_data[4];
                end
                /*4'h3:begin //0x30000001 is dma start signal. It should be parsed quickly.
                    dma_start_r <= cmd_data[0];
                end*/
                4'h4: begin
                    wave_len_r          <= cmd_data[27:14];//2000ns lenth[27:14] / 4ns
                    cycle_r             <= cmd_data[13:0];//1~1000 (0,cycle-1)
                end
                4'h5: begin
                    case (cmd_data[18:16])
                    3'b000:
                    I0_l_r <= cmd_data[15:0];
                    3'b001:
                    I0_h_r <= cmd_data[15:0];
                    3'b010:
                    Q0_l_r <= cmd_data[15:0];
                    3'b011:
                    Q0_h_r <= cmd_data[15:0];
                    3'b100:
                    I1_l_r <= cmd_data[15:0];
                    3'b101:
                    I1_h_r <= cmd_data[15:0];
                    3'b110:
                    Q1_l_r <= cmd_data[15:0];
                    3'b111:
                    Q1_h_r <= cmd_data[15:0];
                    endcase
                end
                4'h6: begin
                    adc1_cfgen_r        <= 1'b1;
                    adc1_cfgdata_r      <= {3'b010,cmd_data[19:16],1'b0,cmd_data[15:0]};
                end
                4'h7: begin
                    adc2_cfgen_r        <= 1'b1;
                    adc2_cfgdata_r      <= {3'b010,cmd_data[19:16],1'b0,cmd_data[15:0]};
                end
                4'h8: begin
                    wave_fre_r          <= cmd_data[15:0];
                end
                4'h9: begin
                    tdata_start_r       <= cmd_data[0];
                end
                4'ha: begin
                    delay_r             <= cmd_data[19:0];//delay time step 8ns
                end
                4'hb: begin
                    pll_pinreg_r        <= cmd_data[1:0];
                end
                4'hc: begin
                    pll_reinit_r        <= 1'b1;
                end
                4'hd: begin
                    adc_calen_r         <= 1'b1;
                end
                4'he: begin
                    data_mode_r         <= cmd_data[3:0];
                    analysis_mode_r     <= cmd_data[7:4];
                    isa_mode_vld_r      <= cmd_data[8];
                end
                default: begin
                    //pll_cfgen_r         <= 1'b0;
                    adc1_cfgen_r        <= 1'b0;
                    adc2_cfgen_r        <= 1'b0;
                    adc_calen_r         <= 1'b0;
                    adc_trig_r          <= 1'b0;
                end
            endcase
        end
    end
end

parameter [3:0] dma_idle    = 4'b0000;
parameter [3:0] dma_start   = 4'b0001;
parameter [3:0] dma_keep    = 4'b0011;
parameter [3:0] dma_done    = 4'b0010;
reg [3:0] state_dma;
reg [3:0] dma_cnt;
always @(posedge pxie_clk or posedge reset)
begin
    if (reset) begin
        dma_start_r <= 1'b0;
        dma_cnt     <= 4'h0;
        state_dma   <= dma_idle;
    end else begin
        dma_start_r <= 1'b0;
        state_dma   <= dma_idle;
        case(state_dma)
        dma_idle:begin
            dma_start_r <= 1'b0;
            dma_cnt     <= 4'h0;
            state_dma   <= dma_start;
        end
        dma_start:begin
            if ((pxie_rddata_in == 128'h30000001) && pxie_rden_in) begin
                dma_start_r <= 1'b1;
                state_dma   <= dma_keep;
            end else begin
                dma_start_r <= 1'b0;
                state_dma   <= dma_start;
            end
        end
        dma_keep:begin
            dma_start_r <= 1'b1;
            dma_cnt     <= dma_cnt + 1'b1;
            if(dma_cnt == 4'hf)
            begin
                dma_start_r <= 1'b0;
                state_dma   <= dma_done;
            end else begin
                state_dma   <= dma_keep;
            end
        end
        dma_done:begin
            dma_start_r <= 1'b0;
            state_dma   <= dma_idle;
        end
        default: state_dma <= dma_idle;
        endcase
    end
end

assign pll_reinit_out       = pll_reinit_r;
assign pll_init_en_out      = pll_init_en_r;
assign pll_cfgen_out        = pll_cfgen_r;
assign pll_cfgdata_out      = pll_cfgdata_r;
assign pll_pinreg_out       = pll_pinreg_r;

assign adc1_cfgen_out       = adc1_cfgen_r;
assign adc1_cfgdata_out     = adc1_cfgdata_r;
assign adc2_cfgen_out       = adc2_cfgen_r;
assign adc2_cfgdata_out     = adc2_cfgdata_r;
assign adc_trig_out         = adc_trig_r;
assign adc_modereg_out      = adc_modereg_r;
assign adc_trig_thresh_out  = adc_trig_thresh_r;
assign adc_calen_out        = adc_calen_r;

assign tdata_start_out      = tdata_start_r;
assign dma_start_out        = dma_start_r;
assign cycle_out            = cycle_r;
assign wave_len_out         = wave_len_r;
assign delay_out            = delay_r;
assign wave_fre             = wave_fre_r;
assign analysis_mode        = analysis_mode_r;
assign data_mode            = data_mode_r;
assign isa_mode_vld         = isa_mode_vld_r;

assign pll_rstn_out         = pll_rstn_r;
assign adc_rstn_out         = adc_rstn_r;
assign ddr_rstn_out         = ddr_rstn_r;
assign pcie_rstn_out        = pcie_rstn_r;
assign global_rstn_out      = global_rstn_r;

assign I0 = I0_r;
assign Q0 = Q0_r;
assign I1 = I1_r;
assign Q1 = Q1_r;
//test
assign test_led             = test_led_r;
endmodule

