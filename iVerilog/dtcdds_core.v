
module dtcdds_core(
  input clk, 
  input rst_n, 
  input [7:0] dphi_slope,
  input [17:0]  phiAPreset,phiBPreset,phiCPreset,phiDPreset,
  input [17:0]  deltaPhiAPreset,deltaPhiBPreset,deltaPhiCPreset,deltaPhiDPreset,
  input [15:0] inv_delta_phi_Preset,
  input [15:0] iacc_slope,
  // delay_out , 4 x PARALLEL ,2x delay
  output reg [13:0] delay_outA,delay_outB,delay_outC,delay_outD,
  ///output reg [17:0] phiA,phiB,phiC,phiD,
  //output reg [15:0] inv_delta_phi,
  output reg A_valid_out, B_valid_out, C_valid_out, D_valid_out
  //selA,selB,selC,selD
);

//  output selA,selB,selC,selD;
reg [17:0] phiA,phiB,phiC,phiD;
reg [15:0] inv_delta_phi;

reg A_valid, B_valid, C_valid, D_valid;
reg A_valid_delay, B_valid_delay, C_valid_delay, D_valid_delay;

reg [17:0] last_phiA, last_phiB, last_phiC, last_phiD;
reg [26:0] delay_out_internalA,delay_out_internalB,delay_out_internalC,delay_out_internalD;
reg [7:0]  delta_phi_slope;
reg [17:0] delta_phiA,delta_phiB,delta_phiC,delta_phiD;
reg [23:0] indexAccumulator;
reg phiA_overflow,phiB_overflow,phiC_overflow,phiD_overflow;
reg [15:0] inv_delta_phi_delay,inv_delta_phi_delay2;
//  reg [17:0] phiA,phiB,phiC,phiD;
reg [14:0] phiA_delay,phiB_delay,phiC_delay,phiD_delay;
reg [14:0] phiA_delay2,phiB_delay2,phiC_delay2,phiD_delay2;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        delta_phi_slope <= dphi_slope;

        phiA <= phiAPreset;
        phiB <= phiBPreset;
        phiC <= phiCPreset;
        phiD <= phiDPreset;

        last_phiA <= phiAPreset;
        last_phiB <= phiBPreset;
        last_phiC <= phiCPreset;
        last_phiD <= phiDPreset;

        delta_phiA <= deltaPhiAPreset;
        delta_phiB <= deltaPhiBPreset;
        delta_phiC <= deltaPhiCPreset;
        delta_phiD <= deltaPhiDPreset;

        phiA_delay <= 14'h3FFF - (phiA[17:4]) +1'b1;
        phiB_delay <= 14'h3FFF - (phiB[17:4]) +1'b1;
        phiC_delay <= 14'h3FFF - (phiC[17:4]) +1'b1;
        phiD_delay <= 14'h3FFF - (phiD[17:4]) +1'b1;

        phiA_delay2 <= phiA_delay;
        phiB_delay2 <= phiB_delay;
        phiC_delay2 <= phiC_delay;
        phiD_delay2 <= phiD_delay;

        A_valid_out <= 1'b0;
        B_valid_out <= 1'b0;
        C_valid_out <= 1'b0;
        D_valid_out <= 1'b0;

        A_valid_delay <= 1'b0;
        B_valid_delay <= 1'b0;
        C_valid_delay <= 1'b0;
        D_valid_delay <= 1'b0;

    end
    else begin
        // phi 18bit with 18 bit fraction , unsigned
        // delta_phi 18bit with 20 bit fraction , unsigned
        // delta_phi_slope 8bit 
        // 右侧部分整体右移了2bit，原因是20bit时有两个高位没有使用，因此截断了高2bit
        phiA <= phiA + ({delta_phiA[17:2],2'b00})+ (delta_phi_slope[7:1]);
        phiB <= phiB + ({delta_phiB[17:2],2'b00})+ (delta_phi_slope[7:1]);
        phiC <= phiC + ({delta_phiC[17:2],2'b00})+ (delta_phi_slope[7:1]);
        phiD <= phiD + ({delta_phiD[17:2],2'b00})+ (delta_phi_slope[7:1]);

        last_phiA <= phiA;
        last_phiB <= phiB;
        last_phiC <= phiC;
        last_phiD <= phiD;

        A_valid <= (last_phiB < last_phiA);
        B_valid <= (last_phiC < last_phiB) ;
        C_valid <= (last_phiD < last_phiC);
        D_valid <= (phiA <last_phiD);

        A_valid_delay <= A_valid;
        B_valid_delay <= B_valid;
        C_valid_delay <= C_valid;
        D_valid_delay <= D_valid;

        A_valid_out <= A_valid_delay;
        B_valid_out <= B_valid_delay;
        C_valid_out <= C_valid_delay;
        D_valid_out <= D_valid_delay;

        delta_phiA <= delta_phiA + delta_phi_slope;
        delta_phiB <= delta_phiB + delta_phi_slope;
        delta_phiC <= delta_phiC + delta_phi_slope;
        delta_phiD <= delta_phiD + delta_phi_slope;

        phiA_delay <= 14'h3FFF - (phiA[17:4]) +1'b1;
        phiB_delay <= 14'h3FFF - (phiB[17:4]) +1'b1;
        phiC_delay <= 14'h3FFF - (phiC[17:4]) +1'b1;
        phiD_delay <= 14'h3FFF - (phiD[17:4]) +1'b1;

        phiA_delay2 <= phiA_delay;
        phiB_delay2 <= phiB_delay;
        phiC_delay2 <= phiC_delay;
        phiD_delay2 <= phiD_delay;
    end
end

reg [31:0] product1;
reg [31:0] product2;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        inv_delta_phi <= inv_delta_phi_Preset;
        inv_delta_phi_delay <= inv_delta_phi_Preset;
        inv_delta_phi_delay2 <= inv_delta_phi_Preset;

        product1 <= inv_delta_phi*inv_delta_phi;
        product2 <= indexAccumulator[23:8]*product1[31:16];
        indexAccumulator <= 24'h80_0000 + (iacc_slope); // 0.5
    end
    else begin
        // inv_delta_phi 16bit with 15 bit fraction  , unsigned
        // indexAccumulator is indexAccumulator 24bit with 24bit fraction ,unsigned

        inv_delta_phi <= {2'b00,inv_delta_phi_delay2,1'b0} - {product2[31:16],1'b0};
        inv_delta_phi_delay <= inv_delta_phi;
        inv_delta_phi_delay2 <= inv_delta_phi_delay;

        product1 <= inv_delta_phi*inv_delta_phi;
        product2 <= indexAccumulator[23:8]*product1[31:16];

        indexAccumulator <=  indexAccumulator + iacc_slope;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        delay_out_internalA <= 0;
        delay_out_internalB <= 0;
        delay_out_internalC <= 0;
        delay_out_internalD <= 0;
        delay_outA <= 0;
        delay_outB <= 0;
        delay_outC <= 0;
        delay_outD <= 0;
    end 
    else begin
        delay_out_internalA <= ( phiA_delay2[14:0] )*inv_delta_phi[15:3];
        delay_out_internalB <= ( phiB_delay2[14:0] )*inv_delta_phi[15:3];
        delay_out_internalC <= ( phiC_delay2[14:0] )*inv_delta_phi[15:3];
        delay_out_internalD <= ( phiD_delay2[14:0] )*inv_delta_phi[15:3];

        // delayout saturation calculation
        delay_outA <= delay_out_internalA[26] ? 14'h3FFF :(delay_out_internalA [25:12]);
        delay_outB <= delay_out_internalB[26] ? 14'h3FFF :(delay_out_internalB [25:12]);
        delay_outC <= delay_out_internalC[26] ? 14'h3FFF :(delay_out_internalC [25:12]);
        delay_outD <= delay_out_internalD[26] ? 14'h3FFF :(delay_out_internalD [25:12]);
    end
end

endmodule