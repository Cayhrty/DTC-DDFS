module chip_top(
    input clk,
    input clk_hs,

    input wire spi_csn_pad,
    input wire spi_rstn_pad,
    input wire spi_sck_pad,
    input wire spi_mosi_pad,
    output wire spi_miso_pad,

    output [7:0] edgeA_out, edgeB_out, edgeC_out, edgeD_out, edgeE_out, edgeF_out, edgeG_out, edgeH_out,
    output selAA, selAB, selAC, selAD,
    output selBA, selBB, selBC, selBD,
    output selCA, selCB, selCC, selCD,
    output selDA, selDB, selDC, selDD,
    output selEA, selEB, selEC, selED,
    output selFA, selFB, selFC, selFD,
    output selGA, selGB, selGC, selGD,
    output selHA, selHB, selHC, selHD,
    output DAC_selA, 
    output DAC_selB, 
    output DAC_selC, 
    output DAC_selD, 
    output DAC_selE, 
    output DAC_selF, 
    output DAC_selG, 
    output DAC_selH
);

wire [79*8-1:0] slv_reg_out;

spi_slv_top spi_control0(
    .csn_pad(spi_csn_pad),
    .rstn_pad(spi_rstn_pad),
    .sck_pad(spi_sck_pad),
    .mosi_pad(spi_mosi_pad),
    .miso_pad(spi_miso_pad),
    .slv_reg_out(slv_reg_out)
);

wire rst_sync_out;
reset_sync rst_syn (
    .clk(clk),
    .rst_n(slv_reg_out[236]),
    .reset_out(rst_sync_out)
);

wire rst_sync_out_hs;
reset_sync rst_syn_hs (
    .clk(clk_hs),
    .rst_n(slv_reg_out[236]),
    .reset_out(rst_sync_out_hs)
);

wire [9:0] edgeA_calc_out, edgeB_calc_out, edgeC_calc_out, edgeD_calc_out,
        edgeE_calc_out, edgeF_calc_out, edgeG_calc_out, edgeH_calc_out;
wire edgeA_out_calc_valid, edgeB_out_calc_valid, edgeC_out_calc_valid, edgeD_out_calc_valid,
    edgeE_out_calc_valid, edgeF_out_calc_valid, edgeG_out_calc_valid, edgeH_out_calc_valid;

wire calc_rst_n;
wire output_enable;

enable_state_machine ensm (
    .clk(clk),
    .rst_n(rst_sync_out),
    .command(slv_reg_out[235:232]),
    .frame_len(slv_reg_out[263:248]),
    .idle_len(slv_reg_out[279:264]),
    //.state(),
    .enable(output_enable),
    .reset_calc_module(calc_rst_n)
);


dtcdds u_dtcdds (
    .clk(clk),
    .clk_hs(clk_hs),
    .rst_n(rst_sync_out),
    .rst_calc_n(calc_rst_n),
    .output_enable(output_enable),

    .dphi_slope(slv_reg_out[7:0]),
    .iacc_slope(slv_reg_out[23:8]),
    .inv_delta_phi_Presetp(slv_reg_out[39:24]),
    // 8x 24bit , 6 empty each are not connected
    .phiApreset(slv_reg_out[57:40]),
    .phiBpreset(slv_reg_out[81:64]),
    .phiCpreset(slv_reg_out[105:88]),
    .phiDpreset(slv_reg_out[129:112]),

    .dPhiPresetA(slv_reg_out[153:136]),
    .dPhiPresetB(slv_reg_out[177:160]),
    .dPhiPresetC(slv_reg_out[201:184]),
    .dPhiPresetD(slv_reg_out[225:208]),

    .edgeA_out(edgeA_calc_out),
    .edgeB_out(edgeB_calc_out),
    .edgeC_out(edgeC_calc_out),
    .edgeD_out(edgeD_calc_out),
    .edgeE_out(edgeE_calc_out),
    .edgeF_out(edgeF_calc_out),
    .edgeG_out(edgeG_calc_out),
    .edgeH_out(edgeH_calc_out),

    .edgeA_out_valid(edgeA_out_calc_valid),
    .edgeB_out_valid(edgeB_out_calc_valid),
    .edgeC_out_valid(edgeC_out_calc_valid),
    .edgeD_out_valid(edgeD_out_calc_valid),
    .edgeE_out_valid(edgeE_out_calc_valid),
    .edgeF_out_valid(edgeF_out_calc_valid),
    .edgeG_out_valid(edgeG_out_calc_valid),
    .edgeH_out_valid(edgeH_out_calc_valid)
);

wire [9:0] edgeA_ram_out, edgeB_ram_out, edgeC_ram_out, edgeD_ram_out,
        edgeE_ram_out, edgeF_ram_out, edgeG_ram_out, edgeH_ram_out;
        
wire edgeA_out_ram_valid, edgeB_out_ram_valid, edgeC_out_ram_valid, edgeD_out_ram_valid,
     edgeE_out_ram_valid, edgeF_out_ram_valid, edgeG_out_ram_valid, edgeH_out_ram_valid;

output_select output_sel_inst0(
    .clk_hs(clk_hs),
    .rst_n(rst_sync_out_hs),
    .select_mode(slv_reg_out[238]),
    .edgeA_fifo_in(edgeA_calc_out),
    .edgeB_fifo_in(edgeB_calc_out),
    .edgeC_fifo_in(edgeC_calc_out),
    .edgeD_fifo_in(edgeD_calc_out),
    .edgeE_fifo_in(edgeE_calc_out),
    .edgeF_fifo_in(edgeF_calc_out),
    .edgeG_fifo_in(edgeG_calc_out),
    .edgeH_fifo_in(edgeH_calc_out),
    .edgeA_fifo_valid(edgeA_out_calc_valid),
    .edgeB_fifo_valid(edgeB_out_calc_valid),
    .edgeC_fifo_valid(edgeC_out_calc_valid),
    .edgeD_fifo_valid(edgeD_out_calc_valid),
    .edgeE_fifo_valid(edgeE_out_calc_valid),
    .edgeF_fifo_valid(edgeF_out_calc_valid),
    .edgeG_fifo_valid(edgeG_out_calc_valid),
    .edgeH_fifo_valid(edgeH_out_calc_valid),

    .edgeA_test_in(edgeA_ram_out),
    .edgeB_test_in(edgeB_ram_out),
    .edgeC_test_in(edgeC_ram_out),
    .edgeD_test_in(edgeD_ram_out),
    .edgeE_test_in(edgeE_ram_out),
    .edgeF_test_in(edgeF_ram_out),
    .edgeG_test_in(edgeG_ram_out),
    .edgeH_test_in(edgeH_ram_out),
    .edgeA_test_valid(edgeA_out_ram_valid),
    .edgeB_test_valid(edgeB_out_ram_valid),
    .edgeC_test_valid(edgeC_out_ram_valid),
    .edgeD_test_valid(edgeD_out_ram_valid),
    .edgeE_test_valid(edgeE_out_ram_valid),
    .edgeF_test_valid(edgeF_out_ram_valid),
    .edgeG_test_valid(edgeG_out_ram_valid),
    .edgeH_test_valid(edgeH_out_ram_valid),

    .edgeA_out(edgeA_out),
    .edgeB_out(edgeB_out),
    .edgeC_out(edgeC_out),
    .edgeD_out(edgeD_out),
    .edgeE_out(edgeE_out),
    .edgeF_out(edgeF_out),
    .edgeG_out(edgeG_out),
    .edgeH_out(edgeH_out),
    .selAA(selAA), .selAB(selAB), .selAC(selAC), .selAD(selAD),
    .selBA(selBA), .selBB(selBB), .selBC(selBC), .selBD(selBD),
    .selCA(selCA), .selCB(selCB), .selCC(selCC), .selCD(selCD),
    .selDA(selDA), .selDB(selDB), .selDC(selDC), .selDD(selDD),
    .selEA(selEA), .selEB(selEB), .selEC(selEC), .selED(selED),
    .selFA(selFA), .selFB(selFB), .selFC(selFC), .selFD(selFD),
    .selGA(selGA), .selGB(selGB), .selGC(selGC), .selGD(selGD),
    .selHA(selHA), .selHB(selHB), .selHC(selHC), .selHD(selHD),
    .DAC_selA(DAC_selA),
    .DAC_selB(DAC_selB),
    .DAC_selC(DAC_selC),
    .DAC_selD(DAC_selD),
    .DAC_selE(DAC_selE),
    .DAC_selF(DAC_selF),
    .DAC_selG(DAC_selG),
    .DAC_selH(DAC_selH)
);


wire test_mode_enable = slv_reg_out[237];
wire ram_cs = slv_reg_out[239];
wire [7:0] edge_out_ram_valid;


assign edgeA_out_ram_valid = edge_out_ram_valid[0];
assign edgeB_out_ram_valid = edge_out_ram_valid[1];
assign edgeC_out_ram_valid = edge_out_ram_valid[2];
assign edgeD_out_ram_valid = edge_out_ram_valid[3];
assign edgeE_out_ram_valid = edge_out_ram_valid[4];
assign edgeF_out_ram_valid = edge_out_ram_valid[5];
assign edgeG_out_ram_valid = edge_out_ram_valid[6];
assign edgeH_out_ram_valid = edge_out_ram_valid[7];

testmode_ram u_testmode_ram(
    .clk(clk),
    .clk_hs(clk_hs),
    .cs_n (ram_cs),
    .test_mode_enable(test_mode_enable),
    .ram_wr_addr(slv_reg_out[243:240]),
    .ram_wr_en(slv_reg_out[244]),
    .ram_data_in(slv_reg_out[631:280]),
    .edgeA_out(edgeA_ram_out),
    .edgeB_out(edgeB_ram_out),
    .edgeC_out(edgeC_ram_out),
    .edgeD_out(edgeD_ram_out),
    .edgeE_out(edgeE_ram_out),
    .edgeF_out(edgeF_ram_out),
    .edgeG_out(edgeG_ram_out),
    .edgeH_out(edgeH_ram_out),
    .edge_out_valid (edge_out_ram_valid)
);


endmodule

