
module output_select(
    input clk_hs,
    input rst_n,
    input select_mode, // 0 : fifo mode , 1 : test mode
    input [9:0] edgeA_fifo_in,
    input [9:0] edgeB_fifo_in,
    input [9:0] edgeC_fifo_in,
    input [9:0] edgeD_fifo_in,
    input [9:0] edgeE_fifo_in,
    input [9:0] edgeF_fifo_in,
    input [9:0] edgeG_fifo_in,
    input [9:0] edgeH_fifo_in,
    input edgeA_fifo_valid,
    input edgeB_fifo_valid,
    input edgeC_fifo_valid,
    input edgeD_fifo_valid,
    input edgeE_fifo_valid,
    input edgeF_fifo_valid,
    input edgeG_fifo_valid,
    input edgeH_fifo_valid,
    input [9:0] edgeA_test_in,
    input [9:0] edgeB_test_in,
    input [9:0] edgeC_test_in,
    input [9:0] edgeD_test_in,
    input [9:0] edgeE_test_in,
    input [9:0] edgeF_test_in,
    input [9:0] edgeG_test_in,
    input [9:0] edgeH_test_in,
    input edgeA_test_valid,
    input edgeB_test_valid,
    input edgeC_test_valid,
    input edgeD_test_valid,
    input edgeE_test_valid,
    input edgeF_test_valid,
    input edgeG_test_valid,
    input edgeH_test_valid,
    output reg [7:0] edgeA_out,
    output reg [7:0] edgeB_out,
    output reg [7:0] edgeC_out,
    output reg [7:0] edgeD_out,
    output reg [7:0] edgeE_out,
    output reg [7:0] edgeF_out,
    output reg [7:0] edgeG_out,
    output reg [7:0] edgeH_out,
    output reg selAA, selAB, selAC, selAD,
    output reg selBA, selBB, selBC, selBD,
    output reg selCA, selCB, selCC, selCD,
    output reg selDA, selDB, selDC, selDD,
    output reg selEA, selEB, selEC, selED,
    output reg selFA, selFB, selFC, selFD,
    output reg selGA, selGB, selGC, selGD,
    output reg selHA, selHB, selHC, selHD,
    output reg DAC_selA,
    output reg DAC_selB,
    output reg DAC_selC,
    output reg DAC_selD,
    output reg DAC_selE,
    output reg DAC_selF,
    output reg DAC_selG,
    output reg DAC_selH
);

reg [7:0] edgeA_out_p;
reg [7:0] edgeB_out_p;
reg [7:0] edgeC_out_p;
reg [7:0] edgeD_out_p;
reg [7:0] edgeE_out_p;
reg [7:0] edgeF_out_p;
reg [7:0] edgeG_out_p;
reg [7:0] edgeH_out_p;

reg selAA_p, selAB_p, selAC_p, selAD_p;
reg selBA_p, selBB_p, selBC_p, selBD_p;
reg selCA_p, selCB_p, selCC_p, selCD_p;
reg selDA_p, selDB_p, selDC_p, selDD_p;
reg selEA_p, selEB_p, selEC_p, selED_p;
reg selFA_p, selFB_p, selFC_p, selFD_p;
reg selGA_p, selGB_p, selGC_p, selGD_p;
reg selHA_p, selHB_p, selHC_p, selHD_p;

always @(posedge clk_hs or negedge rst_n) begin
    if(~rst_n) begin
        edgeA_out <= 8'b0;
        edgeB_out <= 8'b0;
        edgeC_out <= 8'b0;
        edgeD_out <= 8'b0;
        edgeE_out <= 8'b0;
        edgeF_out <= 8'b0;
        edgeG_out <= 8'b0;
        edgeH_out <= 8'b0;
        selAA <= 1'b0; selAB <= 1'b0; selAC <= 1'b0; selAD <= 1'b0;
        selBA <= 1'b0; selBB <= 1'b0; selBC <= 1'b0; selBD <= 1'b0;
        selCA <= 1'b0; selCB <= 1'b0; selCC <= 1'b0; selCD <= 1'b0;
        selDA <= 1'b0; selDB <= 1'b0; selDC <= 1'b0; selDD <= 1'b0;
        selEA <= 1'b0; selEB <= 1'b0; selEC <= 1'b0; selED <= 1'b0;
        selFA <= 1'b0; selFB <= 1'b0; selFC <= 1'b0; selFD <= 1'b0;
        selGA <= 1'b0; selGB <= 1'b0; selGC <= 1'b0; selGD <= 1'b0;
        selHA <= 1'b0; selHB <= 1'b0; selHC <= 1'b0; selHD <= 1'b0;
    end
    else begin
        edgeA_out <= edgeA_out_p;
        edgeB_out <= edgeB_out_p;
        edgeC_out <= edgeC_out_p;
        edgeD_out <= edgeD_out_p;
        edgeE_out <= edgeE_out_p;
        edgeF_out <= edgeF_out_p;
        edgeG_out <= edgeG_out_p;
        edgeH_out <= edgeH_out_p;
        selAA <= selAA_p; selAB <= selAB_p; selAC <= selAC_p; selAD <= selAD_p;
        selBA <= selBA_p; selBB <= selBB_p; selBC <= selBC_p; selBD <= selBD_p;
        selCA <= selCA_p; selCB <= selCB_p; selCC <= selCC_p; selCD <= selCD_p;
        selDA <= selDA_p; selDB <= selDB_p; selDC <= selDC_p; selDD <= selDD_p;
        selEA <= selEA_p; selEB <= selEB_p; selEC <= selEC_p; selED <= selED_p;
        selFA <= selFA_p; selFB <= selFB_p; selFC <= selFC_p; selFD <= selFD_p;
        selGA <= selGA_p; selGB <= selGB_p; selGC <= selGC_p; selGD <= selGD_p;
        selHA <= selHA_p; selHB <= selHB_p; selHC <= selHC_p; selHD <= selHD_p;
    end
end

always @(posedge clk_hs) begin
    if(select_mode == 1'b0) begin // fifo mode
            edgeA_out_p <= edgeA_fifo_in[7:0];
            edgeB_out_p <= edgeB_fifo_in[7:0];
            edgeC_out_p <= edgeC_fifo_in[7:0];
            edgeD_out_p <= edgeD_fifo_in[7:0];
            edgeE_out_p <= edgeE_fifo_in[7:0];
            edgeF_out_p <= edgeF_fifo_in[7:0];
            edgeG_out_p <= edgeG_fifo_in[7:0];
            edgeH_out_p <= edgeH_fifo_in[7:0];
    end
    else begin // test mode
            edgeA_out_p <= edgeA_test_in[7:0];
            edgeB_out_p <= edgeB_test_in[7:0];
            edgeC_out_p <= edgeC_test_in[7:0];
            edgeD_out_p <= edgeD_test_in[7:0];
            edgeE_out_p <= edgeE_test_in[7:0];
            edgeF_out_p <= edgeF_test_in[7:0];
            edgeG_out_p <= edgeG_test_in[7:0];
            edgeH_out_p <= edgeH_test_in[7:0];
    end
end

always @(posedge clk_hs or negedge rst_n) begin
    if(~rst_n) begin
        selAA_p <= 1'b0; selAB_p <= 1'b0; selAC_p <= 1'b0; selAD_p <= 1'b0;
        selBA_p <= 1'b0; selBB_p <= 1'b0; selBC_p <= 1'b0; selBD_p <= 1'b0;
        selCA_p <= 1'b0; selCB_p <= 1'b0; selCC_p <= 1'b0; selCD_p <= 1'b0;
        selDA_p <= 1'b0; selDB_p <= 1'b0; selDC_p <= 1'b0; selDD_p <= 1'b0;
        selEA_p <= 1'b0; selEB_p <= 1'b0; selEC_p <= 1'b0; selED_p <= 1'b0;
        selFA_p <= 1'b0; selFB_p <= 1'b0; selFC_p <= 1'b0; selFD_p <= 1'b0;
        selGA_p <= 1'b0; selGB_p <= 1'b0; selGC_p <= 1'b0; selGD_p <= 1'b0;
        selHA_p <= 1'b0; selHB_p <= 1'b0; selHC_p <= 1'b0; selHD_p <= 1'b0;
    end
    else begin
        if(select_mode == 1'b0) begin // fifo mode
            // edgeA_out_p <= edgeA_fifo_in[7:0];
            // edgeB_out_p <= edgeB_fifo_in[7:0];
            // edgeC_out_p <= edgeC_fifo_in[7:0];
            // edgeD_out_p <= edgeD_fifo_in[7:0];
            // edgeE_out_p <= edgeE_fifo_in[7:0];
            // edgeF_out_p <= edgeF_fifo_in[7:0];
            // edgeG_out_p <= edgeG_fifo_in[7:0];
            // edgeH_out_p <= edgeH_fifo_in[7:0];

            // A block
            if(edgeA_fifo_valid == 1'b1)begin
                case (edgeA_fifo_in[9:8])
                    2'b00: begin selAA_p <= 1'b1; selAB_p <= 1'b0; selAC_p <= 1'b0; selAD_p <= 1'b0; end
                    2'b01: begin selAA_p <= 1'b0; selAB_p <= 1'b1; selAC_p <= 1'b0; selAD_p <= 1'b0; end
                    2'b10: begin selAA_p <= 1'b0; selAB_p <= 1'b0; selAC_p <= 1'b1; selAD_p <= 1'b0; end
                    2'b11: begin selAA_p <= 1'b0; selAB_p <= 1'b0; selAC_p <= 1'b0; selAD_p <= 1'b1; end
                endcase
            end else begin
                selAA_p <= 1'b0; selAB_p <= 1'b0; selAC_p <= 1'b0; selAD_p <= 1'b0;
            end

            // B block
            if(edgeB_fifo_valid == 1'b1)begin
                case (edgeB_fifo_in[9:8])
                    2'b00: begin selBA_p <= 1'b1; selBB_p <= 1'b0; selBC_p <= 1'b0; selBD_p <= 1'b0; end
                    2'b01: begin selBA_p <= 1'b0; selBB_p <= 1'b1; selBC_p <= 1'b0; selBD_p <= 1'b0; end
                    2'b10: begin selBA_p <= 1'b0; selBB_p <= 1'b0; selBC_p <= 1'b1; selBD_p <= 1'b0; end
                    2'b11: begin selBA_p <= 1'b0; selBB_p <= 1'b0; selBC_p <= 1'b0; selBD_p <= 1'b1; end
                endcase
            end else begin
                selBA_p <= 1'b0; selBB_p <= 1'b0; selBC_p <= 1'b0; selBD_p <= 1'b0;
            end

            // C block
            if(edgeC_fifo_valid == 1'b1)begin
                case (edgeC_fifo_in[9:8])
                    2'b00: begin selCA_p <= 1'b1; selCB_p <= 1'b0; selCC_p <= 1'b0; selCD_p <= 1'b0; end
                    2'b01: begin selCA_p <= 1'b0; selCB_p <= 1'b1; selCC_p <= 1'b0; selCD_p <= 1'b0; end
                    2'b10: begin selCA_p <= 1'b0; selCB_p <= 1'b0; selCC_p <= 1'b1; selCD_p <= 1'b0; end
                    2'b11: begin selCA_p <= 1'b0; selCB_p <= 1'b0; selCC_p <= 1'b0; selCD_p <= 1'b1; end
                endcase
            end else begin
                selCA_p <= 1'b0; selCB_p <= 1'b0; selCC_p <= 1'b0; selCD_p <= 1'b0;
            end

            // D block
            if(edgeD_fifo_valid == 1'b1)begin
                case (edgeD_fifo_in[9:8])
                    2'b00: begin selDA_p <= 1'b1; selDB_p <= 1'b0; selDC_p <= 1'b0; selDD_p <= 1'b0; end
                    2'b01: begin selDA_p <= 1'b0; selDB_p <= 1'b1; selDC_p <= 1'b0; selDD_p <= 1'b0; end
                    2'b10: begin selDA_p <= 1'b0; selDB_p <= 1'b0; selDC_p <= 1'b1; selDD_p <= 1'b0; end
                    2'b11: begin selDA_p <= 1'b0; selDB_p <= 1'b0; selDC_p <= 1'b0; selDD_p <= 1'b1; end
                endcase
            end else begin
                selDA_p <= 1'b0; selDB_p <= 1'b0; selDC_p <= 1'b0; selDD_p <= 1'b0;
            end

            // E block
            if(edgeE_fifo_valid == 1'b1)begin
                case (edgeE_fifo_in[9:8])
                    2'b00: begin selEA_p <= 1'b1; selEB_p <= 1'b0; selEC_p <= 1'b0; selED_p <= 1'b0; end
                    2'b01: begin selEA_p <= 1'b0; selEB_p <= 1'b1; selEC_p <= 1'b0; selED_p <= 1'b0; end
                    2'b10: begin selEA_p <= 1'b0; selEB_p <= 1'b0; selEC_p <= 1'b1; selED_p <= 1'b0; end
                    2'b11: begin selEA_p <= 1'b0; selEB_p <= 1'b0; selEC_p <= 1'b0; selED_p <= 1'b1; end
                endcase
            end else begin
                selEA_p <= 1'b0; selEB_p <= 1'b0; selEC_p <= 1'b0; selED_p <= 1'b0;
            end

            // F block
            if(edgeF_fifo_valid == 1'b1)begin
                case (edgeF_fifo_in[9:8])
                    2'b00: begin selFA_p <= 1'b1; selFB_p <= 1'b0; selFC_p <= 1'b0; selFD_p <= 1'b0; end
                    2'b01: begin selFA_p <= 1'b0; selFB_p <= 1'b1; selFC_p <= 1'b0; selFD_p <= 1'b0; end
                    2'b10: begin selFA_p <= 1'b0; selFB_p <= 1'b0; selFC_p <= 1'b1; selFD_p <= 1'b0; end
                    2'b11: begin selFA_p <= 1'b0; selFB_p <= 1'b0; selFC_p <= 1'b0; selFD_p <= 1'b1; end
                endcase
            end else begin
                selFA_p <= 1'b0; selFB_p <= 1'b0; selFC_p <= 1'b0; selFD_p <= 1'b0;
            end

            // G block
            if(edgeG_fifo_valid == 1'b1)begin
                case (edgeG_fifo_in[9:8])
                    2'b00: begin selGA_p <= 1'b1; selGB_p <= 1'b0; selGC_p <= 1'b0; selGD_p <= 1'b0; end
                    2'b01: begin selGA_p <= 1'b0; selGB_p <= 1'b1; selGC_p <= 1'b0; selGD_p <= 1'b0; end
                    2'b10: begin selGA_p <= 1'b0; selGB_p <= 1'b0; selGC_p <= 1'b1; selGD_p <= 1'b0; end
                    2'b11: begin selGA_p <= 1'b0; selGB_p <= 1'b0; selGC_p <= 1'b0; selGD_p <= 1'b1; end
                endcase
            end else begin
                selGA_p <= 1'b0; selGB_p <= 1'b0; selGC_p <= 1'b0; selGD_p <= 1'b0;
            end

            // H block
            if(edgeH_fifo_valid == 1'b1)begin
                case (edgeH_fifo_in[9:8])
                    2'b00: begin selHA_p <= 1'b1; selHB_p <= 1'b0; selHC_p <= 1'b0; selHD_p <= 1'b0; end
                    2'b01: begin selHA_p <= 1'b0; selHB_p <= 1'b1; selHC_p <= 1'b0; selHD_p <= 1'b0; end
                    2'b10: begin selHA_p <= 1'b0; selHB_p <= 1'b0; selHC_p <= 1'b1; selHD_p <= 1'b0; end
                    2'b11: begin selHA_p <= 1'b0; selHB_p <= 1'b0; selHC_p <= 1'b0; selHD_p <= 1'b1; end
                endcase
            end else begin
                selHA_p <= 1'b0; selHB_p <= 1'b0; selHC_p <= 1'b0; selHD_p <= 1'b0;
            end
        end
        else begin // test mode
            // edgeA_out_p <= edgeA_test_in[7:0];
            // edgeB_out_p <= edgeB_test_in[7:0];
            // edgeC_out_p <= edgeC_test_in[7:0];
            // edgeD_out_p <= edgeD_test_in[7:0];
            // edgeE_out_p <= edgeE_test_in[7:0];
            // edgeF_out_p <= edgeF_test_in[7:0];
            // edgeG_out_p <= edgeG_test_in[7:0];
            // edgeH_out_p <= edgeH_test_in[7:0];

            // A block
            if(edgeA_test_valid == 1'b1)begin
                case (edgeA_test_in[9:8])
                    2'b00: begin selAA_p <= 1'b1; selAB_p <= 1'b0; selAC_p <= 1'b0; selAD_p <= 1'b0; end
                    2'b01: begin selAA_p <= 1'b0; selAB_p <= 1'b1; selAC_p <= 1'b0; selAD_p <= 1'b0; end
                    2'b10: begin selAA_p <= 1'b0; selAB_p <= 1'b0; selAC_p <= 1'b1; selAD_p <= 1'b0; end
                    2'b11: begin selAA_p <= 1'b0; selAB_p <= 1'b0; selAC_p <= 1'b0; selAD_p <= 1'b1; end
                endcase
            end else begin
                selAA_p <= 1'b0; selAB_p <= 1'b0; selAC_p <= 1'b0; selAD_p <= 1'b0;
            end

            // B block
            if(edgeB_test_valid == 1'b1)begin
                case (edgeB_test_in[9:8])
                    2'b00: begin selBA_p <= 1'b1; selBB_p <= 1'b0; selBC_p <= 1'b0; selBD_p <= 1'b0; end
                    2'b01: begin selBA_p <= 1'b0; selBB_p <= 1'b1; selBC_p <= 1'b0; selBD_p <= 1'b0; end
                    2'b10: begin selBA_p <= 1'b0; selBB_p <= 1'b0; selBC_p <= 1'b1; selBD_p <= 1'b0; end
                    2'b11: begin selBA_p <= 1'b0; selBB_p <= 1'b0; selBC_p <= 1'b0; selBD_p <= 1'b1; end
                endcase
            end else begin
                selBA_p <= 1'b0; selBB_p <= 1'b0; selBC_p <= 1'b0; selBD_p <= 1'b0;
            end

            // C block
            if(edgeC_test_valid == 1'b1)begin
                case (edgeC_test_in[9:8])
                    2'b00: begin selCA_p <= 1'b1; selCB_p <= 1'b0; selCC_p <= 1'b0; selCD_p <= 1'b0; end
                    2'b01: begin selCA_p <= 1'b0; selCB_p <= 1'b1; selCC_p <= 1'b0; selCD_p <= 1'b0; end
                    2'b10: begin selCA_p <= 1'b0; selCB_p <= 1'b0; selCC_p <= 1'b1; selCD_p <= 1'b0; end
                    2'b11: begin selCA_p <= 1'b0; selCB_p <= 1'b0; selCC_p <= 1'b0; selCD_p <= 1'b1; end
                endcase
            end else begin
                selCA_p <= 1'b0; selCB_p <= 1'b0; selCC_p <= 1'b0; selCD_p <= 1'b0;
            end

            // D block
            if(edgeD_test_valid == 1'b1)begin
                case (edgeD_test_in[9:8])
                    2'b00: begin selDA_p <= 1'b1; selDB_p <= 1'b0; selDC_p <= 1'b0; selDD_p <= 1'b0; end
                    2'b01: begin selDA_p <= 1'b0; selDB_p <= 1'b1; selDC_p <= 1'b0; selDD_p <= 1'b0; end
                    2'b10: begin selDA_p <= 1'b0; selDB_p <= 1'b0; selDC_p <= 1'b1; selDD_p <= 1'b0; end
                    2'b11: begin selDA_p <= 1'b0; selDB_p <= 1'b0; selDC_p <= 1'b0; selDD_p <= 1'b1; end
                endcase
            end else begin
                selDA_p <= 1'b0; selDB_p <= 1'b0; selDC_p <= 1'b0; selDD_p <= 1'b0;
            end

            // E block
            if(edgeE_test_valid == 1'b1)begin
                case (edgeE_test_in[9:8])
                    2'b00: begin selEA_p <= 1'b1; selEB_p <= 1'b0; selEC_p <= 1'b0; selED_p <= 1'b0; end
                    2'b01: begin selEA_p <= 1'b0; selEB_p <= 1'b1; selEC_p <= 1'b0; selED_p <= 1'b0; end
                    2'b10: begin selEA_p <= 1'b0; selEB_p <= 1'b0; selEC_p <= 1'b1; selED_p <= 1'b0; end
                    2'b11: begin selEA_p <= 1'b0; selEB_p <= 1'b0; selEC_p <= 1'b0; selED_p <= 1'b1; end
                endcase
            end else begin
                selEA_p <= 1'b0; selEB_p <= 1'b0; selEC_p <= 1'b0; selED_p <= 1'b0;
            end

            // F block
            if(edgeF_test_valid == 1'b1)begin
                case (edgeF_test_in[9:8])
                    2'b00: begin selFA_p <= 1'b1; selFB_p <= 1'b0; selFC_p <= 1'b0; selFD_p <= 1'b0; end
                    2'b01: begin selFA_p <= 1'b0; selFB_p <= 1'b1; selFC_p <= 1'b0; selFD_p <= 1'b0; end
                    2'b10: begin selFA_p <= 1'b0; selFB_p <= 1'b0; selFC_p <= 1'b1; selFD_p <= 1'b0; end
                    2'b11: begin selFA_p <= 1'b0; selFB_p <= 1'b0; selFC_p <= 1'b0; selFD_p <= 1'b1; end
                endcase
            end else begin
                selFA_p <= 1'b0; selFB_p <= 1'b0; selFC_p <= 1'b0; selFD_p <= 1'b0;
            end

            // G block
            if(edgeG_test_valid == 1'b1)begin
                case (edgeG_test_in[9:8])
                    2'b00: begin selGA_p <= 1'b1; selGB_p <= 1'b0; selGC_p <= 1'b0; selGD_p <= 1'b0; end
                    2'b01: begin selGA_p <= 1'b0; selGB_p <= 1'b1; selGC_p <= 1'b0; selGD_p <= 1'b0; end
                    2'b10: begin selGA_p <= 1'b0; selGB_p <= 1'b0; selGC_p <= 1'b1; selGD_p <= 1'b0; end
                    2'b11: begin selGA_p <= 1'b0; selGB_p <= 1'b0; selGC_p <= 1'b0; selGD_p <= 1'b1; end
                endcase
            end else begin
                selGA_p <= 1'b0; selGB_p <= 1'b0; selGC_p <= 1'b0; selGD_p <= 1'b0;
            end

            // H block
            if(edgeH_test_valid == 1'b1)begin
                case (edgeH_test_in[9:8])
                    2'b00: begin selHA_p <= 1'b1; selHB_p <= 1'b0; selHC_p <= 1'b0; selHD_p <= 1'b0; end
                    2'b01: begin selHA_p <= 1'b0; selHB_p <= 1'b1; selHC_p <= 1'b0; selHD_p <= 1'b0; end
                    2'b10: begin selHA_p <= 1'b0; selHB_p <= 1'b0; selHC_p <= 1'b1; selHD_p <= 1'b0; end
                    2'b11: begin selHA_p <= 1'b0; selHB_p <= 1'b0; selHC_p <= 1'b0; selHD_p <= 1'b1; end
                endcase
            end else begin
                selHA_p <= 1'b0; selHB_p <= 1'b0; selHC_p <= 1'b0; selHD_p <= 1'b0;
            end
        end
    end
end

always @(posedge clk_hs or negedge rst_n) begin

    if(~rst_n) begin
        DAC_selA <= 1'b0;
        DAC_selB <= 1'b0;
        DAC_selC <= 1'b0;
        DAC_selD <= 1'b0;
        DAC_selE <= 1'b0;
        DAC_selF <= 1'b0;
        DAC_selG <= 1'b0;
        DAC_selH <= 1'b0;
    end
    else begin
        DAC_selA <= (select_mode==1'b0) ? (edgeA_fifo_in[9:8] ==2'b00 && edgeA_fifo_valid):(edgeA_test_in[9:8] ==2'b00 && edgeA_test_valid);
        DAC_selB <= (select_mode==1'b0) ? (edgeB_fifo_in[9:8] ==2'b00 && edgeB_fifo_valid):(edgeB_test_in[9:8] ==2'b00 && edgeB_test_valid);
        DAC_selC <= (select_mode==1'b0) ? (edgeC_fifo_in[9:8] ==2'b00 && edgeC_fifo_valid):(edgeC_test_in[9:8] ==2'b00 && edgeC_test_valid);
        DAC_selD <= (select_mode==1'b0) ? (edgeD_fifo_in[9:8] ==2'b00 && edgeD_fifo_valid):(edgeD_test_in[9:8] ==2'b00 && edgeD_test_valid);
        DAC_selE <= (select_mode==1'b0) ? (edgeE_fifo_in[9:8] ==2'b00 && edgeE_fifo_valid):(edgeE_test_in[9:8] ==2'b00 && edgeE_test_valid);
        DAC_selF <= (select_mode==1'b0) ? (edgeF_fifo_in[9:8] ==2'b00 && edgeF_fifo_valid):(edgeF_test_in[9:8] ==2'b00 && edgeF_test_valid);
        DAC_selG <= (select_mode==1'b0) ? (edgeG_fifo_in[9:8] ==2'b00 && edgeG_fifo_valid):(edgeG_test_in[9:8] ==2'b00 && edgeG_test_valid);
        DAC_selH <= (select_mode==1'b0) ? (edgeH_fifo_in[9:8] ==2'b00 && edgeH_fifo_valid):(edgeH_test_in[9:8] ==2'b00 && edgeH_test_valid);
    end
end

endmodule
