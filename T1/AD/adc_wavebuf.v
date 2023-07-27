`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Alibaba
// Engineer: Xing Zhu
//
// Create Date: 2020/05/11 15:09:19
// Design Name:
// Module Name: adc_wavebuf
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

module adc_wavebuf(
    input           clk_pcie_user,
	input 	        reset,
    //
    input           trig_i,
    input [31:0]    wave_fre,
    input           clk_cmd,
    input           dma_start,
    input [13:0]    wave_len_i,
    input [13:0]    cycle_i,
    input [19:0]    delay_i,
    input           prog_full,
    input [3:0]     data_mode,
    input [31:0]   I0,
    input [31:0]   Q0,
    input [31:0]   I1,
    input [31:0]   Q1,
	//adc rx
    input           clk_125M,
    input [95:0]    ch1_data,
    input [95:0]    ch2_data,
    input [95:0]    ch3_data,
    input [95:0]    ch4_data,

    output          trig_fb,
    output  [511:0] adc_data_o,
    output          adc_data_valid_o
    );

reg dma_start_r;
reg dma_start_rr;
reg [13:0] wave_len_r;
reg [13:0] wave_len_rr;
reg [13:0] cycle_r;
reg [13:0] cycle_rr;
reg [19:0] delay_r;
reg [19:0] delay_rr;
reg [3:0]  data_mode_r;
reg [3:0]  data_mode_rr;
reg trig_valid_r;
reg trig_valid_rr;

reg [31:0]   I0_r;
reg [31:0]   Q0_r;
reg [31:0]   I1_r;
reg [31:0]   Q1_r;
reg [31:0]   I0_rr;
reg [31:0]   Q0_rr;
reg [31:0]   I1_rr;
reg [31:0]   Q1_rr;

wire [7:0]  ADC1_data_valid;
wire signed [15:0] ADC1_Idata[7:0];
wire signed [15:0] ADC1_Qdata[7:0];

wire [7:0]  ADC2_data_valid;
wire signed [15:0] ADC2_Idata[7:0];
wire signed [15:0] ADC2_Qdata[7:0];

reg signed [31:0] 	ADC1_I_sum;
reg signed [31:0] 	ADC1_Q_sum;
reg signed [31:0] 	ADC2_I_sum;
reg signed [31:0] 	ADC2_Q_sum;

wire [7:0]  wave_valid;
wire [127:0] data_sin;
wire [127:0] data_cos;

reg  [13:0]     fifo_tx_cnt;
reg  [511:0]    fifo_tx_data;
reg             fifo_tx_en;
reg [15:0]      event_cnt;
reg [19:0]      delay_cnt;

assign adc_data_valid_o = fifo_tx_en;
assign adc_data_o = fifo_tx_data;
reg cmpy_en;
reg wvgen_en;

reg [7:0] state;
parameter st_idle    = 8'b00000000;
parameter st_trig    = 8'b00000001;
parameter st_delay   = 8'b00000010;
parameter st_wait    = 8'b00000100;
parameter st_header  = 8'b00001000;
parameter st_tx      = 8'b00010000;
parameter st_trailer = 8'b00100000;
parameter st_empty   = 8'b01000000;
parameter st_done    = 8'b10000000;

always @(posedge clk_125M or posedge reset) begin
    if (reset) begin
        fifo_tx_data    <= 512'h0;
        fifo_tx_en      <= 1'b0;
        fifo_tx_cnt     <= 14'b0;
        event_cnt       <= 16'h0;
        delay_cnt       <= 20'h0;
        cmpy_en         <= 1'b0;
        wvgen_en        <= 1'b0;
        ADC1_I_sum		<= 32'h0;
        ADC1_Q_sum		<= 32'h0;
        ADC2_I_sum		<= 32'h0;
        ADC2_Q_sum		<= 32'h0;
        dds_rstn        <= 1'b1;
        state <= st_idle;
    end
    else begin
        state <= st_idle;
        case(state)
            st_idle: begin
                cmpy_en         <= 1'b0;
                wvgen_en        <= 1'b0;
                fifo_tx_en      <= 1'b0;
                fifo_tx_cnt     <= 14'h0;
                delay_cnt       <= 20'h0;
                ADC1_I_sum		<= 32'h0;
        		ADC1_Q_sum		<= 32'h0;
        		ADC2_I_sum		<= 32'h0;
        		ADC2_Q_sum		<= 32'h0;
                dds_rstn        <= 1'b1;
                if (dma_start_r) begin
                    state <= st_trig;
                end else begin
                    state <= st_idle;
                end
            end
            st_trig: begin
                fifo_tx_en      <= 1'b0;
                cmpy_en         <= 1'b0;
                wvgen_en        <= 1'b0;
                delay_cnt       <= 20'h0;
                ADC1_I_sum      <= 32'h0;
                ADC1_Q_sum      <= 32'h0;
                ADC2_I_sum      <= 32'h0;
                ADC2_Q_sum      <= 32'h0;
                dds_rstn        <= 1'b0;
                if (prog_full == 1'b0 && trig_valid_r == 1'b1) begin //trig_valid_r trig_i
                    state <= st_delay;
                end
                else begin
                    state <= st_trig;
                end
            end
            st_delay:begin
                delay_cnt   <= delay_cnt + 1'b1;
                if (delay_cnt == delay_r-4'h8) begin
                    dds_rstn        <= 1'b1;
                    wvgen_en        <= 1'b1;
                end else begin
                    wvgen_en        <= 1'b0;
                end

                if (delay_cnt == delay_r) begin
                	cmpy_en    <= 1'b1;
                    state <= st_header;
                end else begin
                    state <= st_delay;
                end
            end
            st_header: begin // transfer data packet header
                cmpy_en         <= 1'b1;
                wvgen_en        <= 1'b0;
                fifo_tx_cnt         <= 14'd0;
                fifo_tx_en          <= data_mode_r==1'b1 ?1'b0:1'b1;
                fifo_tx_data        <= {event_cnt,240'h0b0c1234567887654321aa5500eb55aaeb011234567887654321aa5501eb,
                                        256'h55aaeb021234567887654321aa5502eb55aaeb031234567887654321aa5503eb};
                state               <= st_tx;
            end
            st_tx: begin
                if (fifo_tx_cnt == (wave_len_r[13:3]-4'h2))
                begin
                    fifo_tx_en          <= 1'b0;
                    state               <= st_trailer;
                end else begin
                // default value of data mode is 0
                    ADC1_I_sum <= ADC1_I_sum + ADC1_Idata_0_7;
                    ADC1_Q_sum <= ADC1_Q_sum + ADC1_Qdata_0_7;
                    ADC2_I_sum <= ADC2_I_sum + ADC2_Idata_0_7;
                    ADC2_Q_sum <= ADC2_Q_sum + ADC2_Qdata_0_7;
                    fifo_tx_data<= {    ch1_data[11:0],4'b0001,ch1_data[23:12],4'b0001,ch1_data[35:24],4'b0001,ch1_data[47:36],4'b0001,
                                        ch1_data[59:48],4'b0001,ch1_data[71:60],4'b0001,ch1_data[83:72],4'b0001,ch1_data[95:84],4'b0001,
                                        ch2_data[11:0],4'b0010,ch2_data[23:12],4'b0010,ch2_data[35:24],4'b0010,ch2_data[47:36],4'b0010,
                                        ch2_data[59:48],4'b0010,ch2_data[71:60],4'b0010,ch2_data[83:72],4'b0010,ch2_data[95:84],4'b0010,
                                        ch3_data[11:0],4'b0100,ch3_data[23:12],4'b0100,ch3_data[35:24],4'b0100,ch3_data[47:36],4'b0100,
                                        ch3_data[59:48],4'b0100,ch3_data[71:60],4'b0100,ch3_data[83:72],4'b0100,ch3_data[95:84],4'b0100,
                                        ch4_data[11:0],4'b1000,ch4_data[23:12],4'b1000,ch4_data[35:24],4'b1000,ch4_data[47:36],4'b1000,
                                        ch4_data[59:48],4'b1000,ch4_data[71:60],4'b1000,ch4_data[83:72],4'b1000,ch4_data[95:84],4'b1000};
                    fifo_tx_en          <= data_mode_r==1'b1 ?1'b0:1'b1;
                    fifo_tx_cnt         <= fifo_tx_cnt + 1'b1;
                    state               <= st_tx;
                end
            end
            st_trailer: begin // transfer data packet trailer
                cmpy_en             <= 1'b0;
                wvgen_en            <= 1'b0;
                dds_rstn            <= 1'b0;
                fifo_tx_en          <= 1'b1;
                event_cnt           <= event_cnt + 1'b1;
                fifo_tx_data        <= {256'h55aaeb041234567887654321aa5502eb55aaeb031234567887654321aa5505eb,
                                        ADC1_I_sum,ADC1_Q_sum,ADC2_I_sum,ADC2_Q_sum,128'h55aaeb031234567887654321aa5507eb};
                state               <= st_empty;
            end
            st_empty: begin
                cmpy_en             <= 1'b0;
                wvgen_en            <= 1'b0;
                fifo_tx_en          <= 1'b0;
                if (event_cnt == cycle_r) begin
                    state  <= st_done;
                end
                else begin
                	state <= st_trig;
                end
            end
            st_done : begin
                event_cnt           <= 16'h0;
                fifo_tx_en          <= 1'b0;
                state               <= st_idle;
            end
        endcase
    end
end

always @(posedge clk_125M or posedge reset) begin
    if (reset) begin
        // reset
        dma_start_r     <= 1'b0;
        dma_start_rr    <= 1'b0;
        delay_r         <= 20'h4;
        delay_rr        <= 20'h4;
        wave_len_r      <= 14'h3e8;
        wave_len_rr     <= 14'h3e8;
        cycle_r         <= 14'h3e8;
        cycle_rr        <= 14'h3e8;
        data_mode_r     <= 4'h0;
        data_mode_rr    <= 4'h0;
    end
    else begin
        delay_r         <= delay_rr;
        // delay_rr        <= delay_i;
        dma_start_r     <= dma_start_rr;
        dma_start_rr    <= dma_start;
        wave_len_r      <= wave_len_rr;
        wave_len_rr     <= wave_len_i;
        cycle_r         <= cycle_rr;
        cycle_rr        <= cycle_i;
        data_mode_r     <= data_mode_rr;
        data_mode_rr    <= data_mode; //data_mode
        I0_r            <= I0_rr;
        I0_rr           <= I0;
        Q0_r            <= Q0_rr;
        Q0_rr           <= Q0;
        I1_r            <= I1_rr;
        I1_rr           <= I1;
        Q1_r            <= Q1_rr;
        Q1_rr           <= Q1;
        if (delay_i < 20'h8) begin
            delay_rr        <= 20'h8;
        end else begin
            delay_rr        <= delay_i;
        end
    end
end

always @(negedge clk_125M or posedge reset) begin
    if (reset) begin
        // reset
        trig_valid_r    <= 1'b0;
        trig_valid_rr   <= 1'b0;
    end
    else begin
        trig_valid_r    <= trig_valid_rr;
        trig_valid_rr   <= trig_i;
    end
end

//demodulation

genvar i;
generate
for (i=0;i<8;i=i+1)
begin:cmpyadc1
cmpy_0 cmpy_instadc1(
    .aclk               (clk_125M),
    .aresetn            (!reset),
    .s_axis_a_tvalid    (cmpy_en),  // cmpy_en
    .s_axis_a_tdata     ({ch2_data[11+12*i:12*i],4'b0000,ch1_data[11+12*i:12*i],4'b0000}),
    .s_axis_b_tvalid    (wave_valid[i]),  //
    .s_axis_b_tdata     ({data_sin[15+16*i:16*i],data_cos[15+16*i:16*i]}),   //
    .m_axis_dout_tvalid (ADC1_data_valid[i]),
    .m_axis_dout_tdata  ({ADC1_Qdata[i],ADC1_Idata[i]})
    );
end
endgenerate

reg signed [16:0] ADC1_Idata_01;
reg signed [16:0] ADC1_Idata_23;
reg signed [16:0] ADC1_Idata_45;
reg signed [16:0] ADC1_Idata_67;
reg signed [17:0] ADC1_Idata_0_3;
reg signed [17:0] ADC1_Idata_4_7;
reg signed [18:0] ADC1_Idata_0_7;

reg signed [16:0] ADC1_Qdata_01;
reg signed [16:0] ADC1_Qdata_23;
reg signed [16:0] ADC1_Qdata_45;
reg signed [16:0] ADC1_Qdata_67;
reg signed [17:0] ADC1_Qdata_0_3;
reg signed [17:0] ADC1_Qdata_4_7;
reg signed [18:0] ADC1_Qdata_0_7;

always @(negedge clk_125M or posedge reset) begin
    if (reset) begin
        // reset
        ADC1_Idata_01    <= 17'b0;
        ADC1_Idata_23    <= 17'b0;
        ADC1_Idata_45    <= 17'b0;
        ADC1_Idata_67    <= 17'b0;
        ADC1_Idata_0_3   <= 18'b0;
        ADC1_Idata_4_7   <= 18'b0;
        ADC1_Idata_0_7   <= 19'b0;

        ADC1_Qdata_01    <= 17'b0;
        ADC1_Qdata_23    <= 17'b0;
        ADC1_Qdata_45    <= 17'b0;
        ADC1_Qdata_67    <= 17'b0;
        ADC1_Qdata_0_3   <= 18'b0;
        ADC1_Qdata_4_7   <= 18'b0;
        ADC1_Qdata_0_7   <= 19'b0;
    end
    else begin
        ADC1_Idata_01   <= ADC1_Idata[0] + ADC1_Idata[1];
        ADC1_Idata_23   <= ADC1_Idata[2] + ADC1_Idata[3];
        ADC1_Idata_45   <= ADC1_Idata[4] + ADC1_Idata[5];
        ADC1_Idata_67   <= ADC1_Idata[6] + ADC1_Idata[7];
        ADC1_Idata_0_3  <= ADC1_Idata_01 + ADC1_Idata_23;
        ADC1_Idata_4_7  <= ADC1_Idata_45 + ADC1_Idata_67;
        ADC1_Idata_0_7  <= ADC1_Idata_0_3+ ADC1_Idata_4_7;

        ADC1_Qdata_01   <= ADC1_Qdata[0] + ADC1_Qdata[1];
        ADC1_Qdata_23   <= ADC1_Qdata[2] + ADC1_Qdata[3];
        ADC1_Qdata_45   <= ADC1_Qdata[4] + ADC1_Qdata[5];
        ADC1_Qdata_67   <= ADC1_Qdata[6] + ADC1_Qdata[7];
        ADC1_Qdata_0_3  <= ADC1_Qdata_01 + ADC1_Qdata_23;
        ADC1_Qdata_4_7  <= ADC1_Qdata_45 + ADC1_Qdata_67;
        ADC1_Qdata_0_7  <= ADC1_Qdata_0_3+ ADC1_Qdata_4_7;
    end
end

genvar j;
generate
for (j=0;j<8;j=j+1)
begin:cmpyadc2
cmpy_0 cmpy_instadc2(
    .aclk               (clk_125M),
    .aresetn            (!reset),
    .s_axis_a_tvalid    (cmpy_en),  // cmpy_en
    .s_axis_a_tdata     ({ch4_data[11+12*j:12*j],4'b0000,ch3_data[11+12*j:12*j],4'b0000}),
    .s_axis_b_tvalid    (wave_valid[j]),  //
    .s_axis_b_tdata     ({data_sin[15+16*j:16*j],data_cos[15+16*j:16*j]}),  //
    .m_axis_dout_tvalid (ADC2_data_valid[j]),
    .m_axis_dout_tdata  ({ADC2_Qdata[j],ADC2_Idata[j]})
    );
end
endgenerate

reg signed [16:0] ADC2_Idata_01;
reg signed [16:0] ADC2_Idata_23;
reg signed [16:0] ADC2_Idata_45;
reg signed [16:0] ADC2_Idata_67;
reg signed [17:0] ADC2_Idata_0_3;
reg signed [17:0] ADC2_Idata_4_7;
reg signed [18:0] ADC2_Idata_0_7;

reg signed [16:0] ADC2_Qdata_01;
reg signed [16:0] ADC2_Qdata_23;
reg signed [16:0] ADC2_Qdata_45;
reg signed [16:0] ADC2_Qdata_67;
reg signed [17:0] ADC2_Qdata_0_3;
reg signed [17:0] ADC2_Qdata_4_7;
reg signed [18:0] ADC2_Qdata_0_7;

always @(negedge clk_125M or posedge reset) begin
    if (reset) begin
        // reset
        ADC2_Idata_01    <= 17'b0;
        ADC2_Idata_23    <= 17'b0;
        ADC2_Idata_45    <= 17'b0;
        ADC2_Idata_67    <= 17'b0;
        ADC2_Idata_0_3   <= 18'b0;
        ADC2_Idata_4_7   <= 18'b0;
        ADC2_Idata_0_7   <= 19'b0;

        ADC2_Qdata_01    <= 17'b0;
        ADC2_Qdata_23    <= 17'b0;
        ADC2_Qdata_45    <= 17'b0;
        ADC2_Qdata_67    <= 17'b0;
        ADC2_Qdata_0_3   <= 18'b0;
        ADC2_Qdata_4_7   <= 18'b0;
        ADC2_Qdata_0_7   <= 19'b0;
    end
    else begin
        ADC2_Idata_01   <= ADC2_Idata[0] + ADC2_Idata[1];
        ADC2_Idata_23   <= ADC2_Idata[2] + ADC2_Idata[3];
        ADC2_Idata_45   <= ADC2_Idata[4] + ADC2_Idata[5];
        ADC2_Idata_67   <= ADC2_Idata[6] + ADC2_Idata[7];
        ADC2_Idata_0_3  <= ADC2_Idata_01 + ADC2_Idata_23;
        ADC2_Idata_4_7  <= ADC2_Idata_45 + ADC2_Idata_67;
        ADC2_Idata_0_7  <= ADC2_Idata_0_3+ ADC2_Idata_4_7;

        ADC2_Qdata_01   <= ADC2_Qdata[0] + ADC2_Qdata[1];
        ADC2_Qdata_23   <= ADC2_Qdata[2] + ADC2_Qdata[3];
        ADC2_Qdata_45   <= ADC2_Qdata[4] + ADC2_Qdata[5];
        ADC2_Qdata_67   <= ADC2_Qdata[6] + ADC2_Qdata[7];
        ADC2_Qdata_0_3  <= ADC2_Qdata_01 + ADC2_Qdata_23;
        ADC2_Qdata_4_7  <= ADC2_Qdata_45 + ADC2_Qdata_67;
        ADC2_Qdata_0_7  <= ADC2_Qdata_0_3+ ADC2_Qdata_4_7;
    end
end

// generate sinewave

// phase continuous from trigger
// sinewave_gen sinewave_gen_inst(
//     .clk        (clk_125M),
//     .rstn       (!reset),
//     .gen_trig   (trig_valid_r),
//     .gen_length (wave_len_r[13:0]+delay_r<<3),
//     .wave_fre   (wave_fre),     //fre = wave_fre * 0.1 MHz
//     .wave_valid (wave_valid),
//     .ram_sinout (data_sin),
//     .ram_cosout (data_cos)
//     );

// phase continuous after delay
// sinewave_gen sinewave_gen_inst(
//     .clk        (clk_125M),
//     .rstn       (!reset),
//     .gen_trig   (wvgen_en),
//     .gen_length (wave_len_r[13:0]+8'h2a),
//     .wave_fre   (wave_fre),     //fre = wave_fre * 0.1 MHz
//     .wave_valid (wave_valid),
//     .ram_sinout (data_sin),
//     .ram_cosout (data_cos)
//     );
reg dds_rstn;
wave_gen_dds wave_gen_dds_inst(
    .clk        (clk_125M),
    .rstn       (!reset),
    .trig       (wvgen_en),
    .dds_rstn   (dds_rstn),
    .dds_freq   (wave_fre), //31:28 +/- 27:0 freq
    .wave_sine  (data_sin),
    .wave_cosine(data_cos),
    .wave_valid (wave_valid)
    );



(*mark_debug="true"*)reg [31:0] qubit_state_cnt;
(*mark_debug="true"*)reg        qubit_state_valid;
// Qubit state judgment and X
always @(posedge clk_125M or posedge reset) begin
if (reset) begin
    // reset
    qubit_state_cnt <= 32'h0;
    qubit_state_valid <= 1'b0;
end
else begin

    if (qs_valid) begin //add qubit judgment
        qubit_state_cnt <= qubit_state_cnt+qstate;
    end else if (state==st_idle) begin
        qubit_state_cnt <= 0;
    end else begin
        qubit_state_cnt <= qubit_state_cnt;
    end

    if (state==st_done) begin
        qubit_state_valid <= 1'b1;
    end else begin
        qubit_state_valid <= 1'b0;
    end
end

end

wire qs_valid;
wire qstate;
qubit_state1_cnt qubit_state1_cnt_inst(
    .clk    (clk_125M),
    .rstn   (!reset),
    .data_en(state==st_trailer),
    .Idata  (ADC1_Q_sum),
    .Qdata  (ADC1_I_sum),
    .I0     (I0_r),
    .Q0     (Q0_r),
    .I1     (I1_r),
    .Q1     (Q1_r),

    .valid  (qs_valid),
    .qstate (qstate)

    );

reg trig_fb_r;
always @(posedge clk_125M or posedge reset) begin
if (reset) begin
    trig_fb_r <= 1'b0;
end else begin
    if (qs_valid==1 && qstate==1) begin
        trig_fb_r <= 1'b1;
    end else begin
        trig_fb_r <= 1'b0;
    end
end

end

assign trig_fb = trig_fb_r;

endmodule