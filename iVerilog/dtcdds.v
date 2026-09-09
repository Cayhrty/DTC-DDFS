module dtcdds (
    input clk,
    input clk_hs,
    input rst_n,
    input rst_calc_n,
    input [7:0] dphi_slope,
    input [15:0] iacc_slope,
    input [15:0] inv_delta_phi_Presetp,
    input [17:0] phiApreset,
    input [17:0] phiBpreset,
    input [17:0] phiCpreset,
    input [17:0] phiDpreset,

    input [17:0] dPhiPresetA,
    input [17:0] dPhiPresetB,
    input [17:0] dPhiPresetC,
    input [17:0] dPhiPresetD,
    input output_enable,
//   output [17:0] phiA, //debug output
//   output [17:0] phiB,
//   output [17:0] phiC,
//   output [17:0] phiD,
//   output [15:0] inv_delta_phi,
//   input [3:0] command,
//   input [15:0] frame_len,
//   input [15:0] idle_len,

    output [9:0] edgeA_out, edgeB_out, edgeC_out, edgeD_out, edgeE_out, edgeF_out, edgeG_out, edgeH_out,
    output edgeA_out_valid, edgeB_out_valid, edgeC_out_valid, edgeD_out_valid, edgeE_out_valid, edgeF_out_valid, edgeG_out_valid, edgeH_out_valid
);

wire [13:0] delay_outA;
wire [13:0] delay_outB;
wire [13:0] delay_outC;
wire [13:0] delay_outD;

wire A_valid, B_valid, C_valid, D_valid;

dtcdds_core calc_core ( 
    .clk(clk),
    .rst_n(rst_calc_n),
    .dphi_slope(dphi_slope),
    .iacc_slope(iacc_slope),
    .inv_delta_phi_Preset(inv_delta_phi_Presetp),
    .phiAPreset(phiApreset),
    .phiBPreset(phiBpreset),
    .phiCPreset(phiCpreset),
    .phiDPreset(phiDpreset),
    .deltaPhiAPreset(dPhiPresetA),
    .deltaPhiBPreset(dPhiPresetB),
    .deltaPhiCPreset(dPhiPresetC),
    .deltaPhiDPreset(dPhiPresetD),
    .delay_outA(delay_outA),
    .delay_outB(delay_outB),
    .delay_outC(delay_outC),
    .delay_outD(delay_outD),
    .A_valid_out(A_valid),
    .B_valid_out(B_valid),
    .C_valid_out(C_valid),
    .D_valid_out(D_valid)
    // .phiA(phiA),
    // .phiB(phiB),
    // .phiC(phiC),
    // .phiD(phiD),
    //.inv_delta_phi(inv_delta_phi)
);

// wire rst_sync_out;


// enable_state_machine ensm (
//     .clk(clk),
//     .rst_n(rst_n),
//     .command(command),
//     .frame_len(frame_len),
//     .idle_len(idle_len),
//     //.state(),
//     .enable(output_enable),
//     .reset_calc_module(calc_rst_n)
// );


wire edgeA_interp_valid, edgeB_interp_valid, edgeC_interp_valid, edgeD_interp_valid;

wire [12:0] edgeAA_out, edgeAB_out, edgeAC_out, edgeAD_out,
        edgeAE_out, edgeAF_out, edgeAG_out, edgeAH_out;
wire [12:0] edgeBA_out, edgeBB_out, edgeBC_out, edgeBD_out,
        edgeBE_out, edgeBF_out, edgeBG_out, edgeBH_out;
wire [12:0] edgeCA_out, edgeCB_out, edgeCC_out, edgeCD_out,
        edgeCE_out, edgeCF_out, edgeCG_out, edgeCH_out;
wire [12:0] edgeDA_out, edgeDB_out, edgeDC_out, edgeDD_out,
        edgeDE_out, edgeDF_out, edgeDG_out, edgeDH_out;

edge_interp edge_interpolator (
    .clk(clk),
    .rst_n(rst_n),
    .edgeA_in(delay_outA),
    .edgeB_in(delay_outB),
    .edgeC_in(delay_outC),
    .edgeD_in(delay_outD),
    .edgeA_in_valid(A_valid & output_enable),
    .edgeB_in_valid(B_valid & output_enable),
    .edgeC_in_valid(C_valid & output_enable),
    .edgeD_in_valid(D_valid & output_enable),

    .edgeAA_out(edgeAA_out),
    .edgeAB_out(edgeAB_out),
    .edgeAC_out(edgeAC_out),
    .edgeAD_out(edgeAD_out),
    .edgeAE_out(edgeAE_out),
    .edgeAF_out(edgeAF_out),
    .edgeAG_out(edgeAG_out),
    .edgeAH_out(edgeAH_out),

    .edgeBA_out(edgeBA_out),
    .edgeBB_out(edgeBB_out),
    .edgeBC_out(edgeBC_out),
    .edgeBD_out(edgeBD_out),
    .edgeBE_out(edgeBE_out),
    .edgeBF_out(edgeBF_out),
    .edgeBG_out(edgeBG_out),
    .edgeBH_out(edgeBH_out),

    .edgeCA_out(edgeCA_out),
    .edgeCB_out(edgeCB_out),
    .edgeCC_out(edgeCC_out),
    .edgeCD_out(edgeCD_out),
    .edgeCE_out(edgeCE_out),
    .edgeCF_out(edgeCF_out),
    .edgeCG_out(edgeCG_out),
    .edgeCH_out(edgeCH_out),

    .edgeDA_out(edgeDA_out),
    .edgeDB_out(edgeDB_out),
    .edgeDC_out(edgeDC_out),
    .edgeDD_out(edgeDD_out),
    .edgeDE_out(edgeDE_out),
    .edgeDF_out(edgeDF_out),
    .edgeDG_out(edgeDG_out),
    .edgeDH_out(edgeDH_out),

    .edgeA_out_valid(edgeA_interp_valid),
    .edgeB_out_valid(edgeB_interp_valid),
    .edgeC_out_valid(edgeC_interp_valid),
    .edgeD_out_valid(edgeD_interp_valid)

);


edge_p2s_logic fifo_module (
    .clk(clk),
    .clk_hs(clk_hs),
    .rst_n(rst_n),
    .edgeAA_in(edgeAA_out),
    .edgeAB_in(edgeAB_out),
    .edgeAC_in(edgeAC_out),
    .edgeAD_in(edgeAD_out),
    .edgeAE_in(edgeAE_out),
    .edgeAF_in(edgeAF_out),
    .edgeAG_in(edgeAG_out),
    .edgeAH_in(edgeAH_out),
    .edgeBA_in(edgeBA_out),
    .edgeBB_in(edgeBB_out),
    .edgeBC_in(edgeBC_out),
    .edgeBD_in(edgeBD_out),
    .edgeBE_in(edgeBE_out),
    .edgeBF_in(edgeBF_out),
    .edgeBG_in(edgeBG_out),
    .edgeBH_in(edgeBH_out),
    .edgeCA_in(edgeCA_out),
    .edgeCB_in(edgeCB_out),
    .edgeCC_in(edgeCC_out),
    .edgeCD_in(edgeCD_out),
    .edgeCE_in(edgeCE_out),
    .edgeCF_in(edgeCF_out),
    .edgeCG_in(edgeCG_out),
    .edgeCH_in(edgeCH_out),
    .edgeDA_in(edgeDA_out),
    .edgeDB_in(edgeDB_out),
    .edgeDC_in(edgeDC_out),
    .edgeDD_in(edgeDD_out),
    .edgeDE_in(edgeDE_out),
    .edgeDF_in(edgeDF_out),
    .edgeDG_in(edgeDG_out),
    .edgeDH_in(edgeDH_out),
    .edgeA_in_valid(edgeA_interp_valid),
    .edgeB_in_valid(edgeB_interp_valid),
    .edgeC_in_valid(edgeC_interp_valid),
    .edgeD_in_valid(edgeD_interp_valid),
    .edgeA_out(edgeA_out),
    .edgeB_out(edgeB_out),
    .edgeC_out(edgeC_out),
    .edgeD_out(edgeD_out),
    .edgeE_out(edgeE_out),
    .edgeF_out(edgeF_out),
    .edgeG_out(edgeG_out),
    .edgeH_out(edgeH_out),
    .edgeA_out_valid(edgeA_out_valid),
    .edgeB_out_valid(edgeB_out_valid),
    .edgeC_out_valid(edgeC_out_valid),
    .edgeD_out_valid(edgeD_out_valid),
    .edgeE_out_valid(edgeE_out_valid),
    .edgeF_out_valid(edgeF_out_valid),
    .edgeG_out_valid(edgeG_out_valid),
    .edgeH_out_valid(edgeH_out_valid)
);

endmodule
