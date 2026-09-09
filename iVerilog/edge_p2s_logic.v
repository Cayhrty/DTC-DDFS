module edge_p2s_logic(
    input clk,
    input clk_hs, // 2.5 GHz clock
    input rst_n,

    input [12:0] edgeAA_in,
    input [12:0] edgeAB_in,
    input [12:0] edgeAC_in,
    input [12:0] edgeAD_in,
    input [12:0] edgeAE_in,
    input [12:0] edgeAF_in,
    input [12:0] edgeAG_in,
    input [12:0] edgeAH_in,
    input [12:0] edgeBA_in,
    input [12:0] edgeBB_in,
    input [12:0] edgeBC_in,
    input [12:0] edgeBD_in,
    input [12:0] edgeBE_in,
    input [12:0] edgeBF_in,
    input [12:0] edgeBG_in,
    input [12:0] edgeBH_in,
    input [12:0] edgeCA_in,
    input [12:0] edgeCB_in,
    input [12:0] edgeCC_in,
    input [12:0] edgeCD_in,
    input [12:0] edgeCE_in,
    input [12:0] edgeCF_in,
    input [12:0] edgeCG_in,
    input [12:0] edgeCH_in,
    input [12:0] edgeDA_in,
    input [12:0] edgeDB_in,
    input [12:0] edgeDC_in,
    input [12:0] edgeDD_in,
    input [12:0] edgeDE_in,
    input [12:0] edgeDF_in,
    input [12:0] edgeDG_in,
    input [12:0] edgeDH_in,

    input  edgeA_in_valid,
    input  edgeB_in_valid,
    input  edgeC_in_valid,
    input  edgeD_in_valid,


    // output to final Analog controller
    output [9:0] edgeA_out,
    output [9:0] edgeB_out,
    output [9:0] edgeC_out,
    output [9:0] edgeD_out,
    output [9:0] edgeE_out,
    output [9:0] edgeF_out,
    output [9:0] edgeG_out,
    output [9:0] edgeH_out,
    output edgeA_out_valid,
    output edgeB_out_valid,
    output edgeC_out_valid,
    output edgeD_out_valid,
    output edgeE_out_valid,
    output edgeF_out_valid,
    output edgeG_out_valid,
    output edgeH_out_valid
);


parallel_to_serial_fifo fifoA (
    .clk_slow(clk),
    .clk_fast(clk_hs),
    .rst_n(rst_n),
    .edgeA_in(edgeAA_in),
    .edgeB_in(edgeBA_in),
    .edgeC_in(edgeCA_in),
    .edgeD_in(edgeDA_in),
    .edgeA_valid(edgeA_in_valid),
    .edgeB_valid(edgeB_in_valid),
    .edgeC_valid(edgeC_in_valid),
    .edgeD_valid(edgeD_in_valid),
    .dac_edge_out(edgeA_out), // output to DTC Analog controller
    .dac_edge_out_valid(edgeA_out_valid) // output valid signal
);

parallel_to_serial_fifo fifoB (
    .clk_slow(clk),
    .clk_fast(clk_hs),
    .rst_n(rst_n),
    .edgeA_in(edgeAB_in),
    .edgeB_in(edgeBB_in),
    .edgeC_in(edgeCB_in),
    .edgeD_in(edgeDB_in),
    .edgeA_valid(edgeA_in_valid),
    .edgeB_valid(edgeB_in_valid),
    .edgeC_valid(edgeC_in_valid),
    .edgeD_valid(edgeD_in_valid),
    .dac_edge_out(edgeB_out),
    .dac_edge_out_valid(edgeB_out_valid) // output valid signal
);

parallel_to_serial_fifo fifoC (
    .clk_slow(clk),
    .clk_fast(clk_hs),
    .rst_n(rst_n),
    .edgeA_in(edgeAC_in),
    .edgeB_in(edgeBC_in),
    .edgeC_in(edgeCC_in),
    .edgeD_in(edgeDC_in),
    .edgeA_valid(edgeA_in_valid),
    .edgeB_valid(edgeB_in_valid),
    .edgeC_valid(edgeC_in_valid),
    .edgeD_valid(edgeD_in_valid),
    .dac_edge_out(edgeC_out),
    .dac_edge_out_valid(edgeC_out_valid) // output valid signal
);

parallel_to_serial_fifo fifoD (
    .clk_slow(clk),
    .clk_fast(clk_hs),
    .rst_n(rst_n),
    .edgeA_in(edgeAD_in),
    .edgeB_in(edgeBD_in),
    .edgeC_in(edgeCD_in),
    .edgeD_in(edgeDD_in),
    .edgeA_valid(edgeA_in_valid),
    .edgeB_valid(edgeB_in_valid),
    .edgeC_valid(edgeC_in_valid),
    .edgeD_valid(edgeD_in_valid),
    .dac_edge_out(edgeD_out),
    .dac_edge_out_valid(edgeD_out_valid) // output valid signal
);

parallel_to_serial_fifo fifoE (
    .clk_slow(clk),
    .clk_fast(clk_hs),
    .rst_n(rst_n),
    .edgeA_in(edgeAE_in),
    .edgeB_in(edgeBE_in),
    .edgeC_in(edgeCE_in),
    .edgeD_in(edgeDE_in),
    .edgeA_valid(edgeA_in_valid),
    .edgeB_valid(edgeB_in_valid),
    .edgeC_valid(edgeC_in_valid),
    .edgeD_valid(edgeD_in_valid),
    .dac_edge_out(edgeE_out),
    .dac_edge_out_valid(edgeE_out_valid) // output valid signal
);

parallel_to_serial_fifo fifoF (
    .clk_slow(clk),
    .clk_fast(clk_hs),
    .rst_n(rst_n),
    .edgeA_in(edgeAF_in),
    .edgeB_in(edgeBF_in),
    .edgeC_in(edgeCF_in),
    .edgeD_in(edgeDF_in),
    .edgeA_valid(edgeA_in_valid),
    .edgeB_valid(edgeB_in_valid),
    .edgeC_valid(edgeC_in_valid),
    .edgeD_valid(edgeD_in_valid),
    .dac_edge_out(edgeF_out),
    .dac_edge_out_valid(edgeF_out_valid) // output valid signal
);

parallel_to_serial_fifo fifoG (
    .clk_slow(clk),
    .clk_fast(clk_hs),
    .rst_n(rst_n),
    .edgeA_in(edgeAG_in),
    .edgeB_in(edgeBG_in),
    .edgeC_in(edgeCG_in),
    .edgeD_in(edgeDG_in),
    .edgeA_valid(edgeA_in_valid),
    .edgeB_valid(edgeB_in_valid),
    .edgeC_valid(edgeC_in_valid),
    .edgeD_valid(edgeD_in_valid),
    .dac_edge_out(edgeG_out),
    .dac_edge_out_valid(edgeG_out_valid) // output valid signal
);

parallel_to_serial_fifo fifoH (
    .clk_slow(clk),
    .clk_fast(clk_hs),
    .rst_n(rst_n),
    .edgeA_in(edgeAH_in),
    .edgeB_in(edgeBH_in),
    .edgeC_in(edgeCH_in),
    .edgeD_in(edgeDH_in),
    .edgeA_valid(edgeA_in_valid),
    .edgeB_valid(edgeB_in_valid),
    .edgeC_valid(edgeC_in_valid),
    .edgeD_valid(edgeD_in_valid),
    .dac_edge_out(edgeH_out),
    .dac_edge_out_valid(edgeH_out_valid) // output valid signal
);

endmodule