`timescale 1ns/1ps

module chip_top_tb();

 // Testbench signals
reg clk;
reg clk_hs;
reg spi_csn_pad;
reg spi_rstn_pad;
reg spi_sck_pad;
reg spi_mosi_pad;
wire spi_miso_pad;

wire [7:0] edgeA_out, edgeB_out, edgeC_out, edgeD_out, edgeE_out, edgeF_out, edgeG_out, edgeH_out;
wire selAA, selAB, selAC, selAD;
wire selBA, selBB, selBC, selBD;
wire selCA, selCB, selCC, selCD;
wire selDA, selDB, selDC, selDD;
wire selEA, selEB, selEC, selED;
wire selFA, selFB, selFC, selFD;
wire selGA, selGB, selGC, selGD;
wire selHA, selHB, selHC, selHD;

wire DAC_SELAA, DAC_SELAB, DAC_SELAC, DAC_SELAD;
wire DAC_SELBA, DAC_SELBB, DAC_SELBC, DAC_SELBD;
wire DAC_SELCA, DAC_SELCB, DAC_SELCC, DAC_SELCD;
wire DAC_SELDA, DAC_SELDB, DAC_SELDC, DAC_SELDD;
wire DAC_SELEA, DAC_SELEB, DAC_SELEC, DAC_SELED;
wire DAC_SELFA, DAC_SELFB, DAC_SELFC, DAC_SELFD;
wire DAC_SELGA, DAC_SELGB, DAC_SELGC, DAC_SELGD;
wire DAC_SELHA, DAC_SELHB, DAC_SELHC, DAC_SELHD;

// File export
integer fp_w;
integer fp_w2;

initial begin
    // fp_w = $fopen("calc_core_data_out.txt", "w");
    // $fdisplay(fp_w, "delay_outA, delay_outB, delay_outC, delay_outD, phiA, phiB, phiC, phiD, inv_delta_phi",);

     fp_w2 = $fopen("final_p2s_data_out.txt", "w");
     $fdisplay(fp_w2, " edgeA_out, edgeB_out, edgeC_out, edgeD_out, edgeE_out, edgeF_out, edgeG_out, edgeH_out, selAA, selAB, selAC, selAD, selBA, selBB, selBC, selBD, selCA, selCB, selCC, selCD, selDA, selDB, selDC, selDD, selEA, selEB, selEC, selED, selFA, selFB, selFC, selFD, selGA, selGB, selGC, selGD, selHA, selHB, selHC, selHD",);
end

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, chip_top_tb);
end

initial begin
    #19202.1 $display ("The final time is (%0d ns)", $time);
    $fclose(fp_w);
    $fclose(fp_w2);
    $finish;            // Quit the simulation
end


// always @(posedge clk) begin
//     if (clk) begin
//         $fdisplay(fp_w, "%d %d %d %d %d %d %d %d %d", delay_outA, delay_outB, delay_outC, delay_outD,phiA, phiB, phiC, phiD,inv_delta_phi);
//     end
// end

always @(posedge clk_hs) begin
    if (clk_hs) begin
        $fdisplay(fp_w2, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", edgeA_out, edgeB_out, edgeC_out, edgeD_out, edgeE_out, edgeF_out, edgeG_out, edgeH_out, selAA, selAB, selAC, selAD, selBA, selBB, selBC, selBD, selCA, selCB, selCC, selCD, selDA, selDB, selDC, selDD, selEA, selEB, selEC, selED, selFA, selFB, selFC, selFD, selGA, selGB, selGC, selGD, selHA, selHB, selHC, selHD);
    end
end     

// Instantiate the DUT
// NOTE: DAC_SEL** removed ,because three of them are same with SEL**, ONLY one ramain to reduce power
chip_top uut (
    .clk(clk),
    .clk_hs(clk_hs),
    .spi_csn_pad(spi_csn_pad),
    .spi_rstn_pad(spi_rstn_pad),
    .spi_sck_pad(spi_sck_pad),
    .spi_mosi_pad(spi_mosi_pad),
    .spi_miso_pad(spi_miso_pad),
    .edgeA_out(edgeA_out), .edgeB_out(edgeB_out), .edgeC_out(edgeC_out), .edgeD_out(edgeD_out),
    .edgeE_out(edgeE_out), .edgeF_out(edgeF_out), .edgeG_out(edgeG_out), .edgeH_out(edgeH_out),
    .selAA(selAA), .selAB(selAB), .selAC(selAC), .selAD(selAD),
    .selBA(selBA), .selBB(selBB), .selBC(selBC), .selBD(selBD),
    .selCA(selCA), .selCB(selCB), .selCC(selCC), .selCD(selCD),
    .selDA(selDA), .selDB(selDB), .selDC(selDC), .selDD(selDD),
    .selEA(selEA), .selEB(selEB), .selEC(selEC), .selED(selED),
    .selFA(selFA), .selFB(selFB), .selFC(selFC), .selFD(selFD),
    .selGA(selGA), .selGB(selGB), .selGC(selGC), .selGD(selGD),
    .selHA(selHA), .selHB(selHB), .selHC(selHC), .selHD(selHD)
);

// Clock generation
initial begin
    clk = 0;
    forever #1 clk = ~clk; // 500MHz clock: period = 2ns, toggle every 1ns
end

initial begin
    clk_hs = 1;
    forever #0.25 clk_hs = ~clk_hs; // 2GHz clock: period = 0.5ns, toggle every 0.25ns
end


// SPI test 1 bit write/read + 5bit length + 10bit addr + length*8 bit data
reg [7:0] test_pattern [50:0];
reg [15:0] cmd_test [2:0];

initial begin
    // write registers
    // ADDR 0 : 8bit dphi_slope
    // ADDR 1 : 16bit iacc_slope
    // ADDR 3 : 16bit inv_delta_phi_Preset
    // ADDR 5 : 18bit phiApreset
    // ADDR 8 : 18bit phiBpreset
    // ADDR 11: 18bit phiCpreset
    // ADDR 14: 18bit phiDpreset
    // ADDR 17: 18bit dPhiPresetA
    // ADDR 20: 18bit dPhiPresetB
    // ADDR 23: 18bit dPhiPresetC
    // ADDR 26: 18bit dPhiPresetD
    // ADDR 29: CONTROL_REG :
                //1bit ram_cs + 1bit output_select_mode + 1bit test_mode_enable + 1bit rst_n + 4bit  command
                // output SEL  0 : fifo mode , 1 : test mode
    // ADDR 30: TEST_MODE_RAM_REG :
                //1bit_wr_en + 4bit wr_addr 
    // ADDR 31: frame_len,16bit
    // ADDR 33: idle_len,16bit
    // ADDR 35-79: RAM DATA IN  
    // TOTAL 79 REGISTERS
    
//   iacc_slope = 16'b0000_1000_0000_0000;
//   dphi_slope = 8'b1000_0000;

//   inv_delta_phi_Preset = 16'b1111_1111_1111_0010;

//   phiApreset = 18'b00_0000_0000_0000_0000;
//   phiBpreset = 18'b10_0000_0000_0000_0100;
//   phiCpreset = 18'b00_0000_0000_0001_0000;
//   phiDpreset = 18'b10_0000_0000_0010_0100;

//   dPhiPresetA = 18'b00_0000_0000_0000_0000;
//   dPhiPresetB = 18'b00_0000_0000_0010_0000;
//   dPhiPresetC = 18'b00_0000_0000_0100_0000;
//   dPhiPresetD = 18'b00_0000_0000_0110_0000;

// .command(4'b0010),
// .frame_len(16'h1002),
// .idle_len(16'h0004),

    //command for write 32 regs from addr 0 to addr 31
    cmd_test[0] = 16'b1_11111_0000000000;

    //data for reg0
    test_pattern[0] = 8'b1000_0000;

    test_pattern[1] = 8'b0000_0000; 
    test_pattern[2] = 8'b0000_1000;

    test_pattern[3] = 8'b1111_0010;
    test_pattern[4] = 8'b1111_1111;

    test_pattern[5] = 8'b0000_0000;
    test_pattern[6] = 8'b0000_0000;
    test_pattern[7] = 8'b0000_0000;

    test_pattern[8] = 8'b0000_0100;
    test_pattern[9] = 8'b0000_0000;
    test_pattern[10] = 8'b0000_0010;    

    test_pattern[11] = 8'b0001_0000;
    test_pattern[12] = 8'b0000_0000;
    test_pattern[13] = 8'b0000_0000;

    test_pattern[14] = 8'b0010_0100;
    test_pattern[15] = 8'b0000_0000;
    test_pattern[16] = 8'b0000_0010;

    test_pattern[17] = 8'b0000_0000;
    test_pattern[18] = 8'b0000_0000;
    test_pattern[19] = 8'b0000_0000;

    // DPhiPresetB
    test_pattern[20] = 8'b0010_0000;
    test_pattern[21] = 8'b0000_0000;
    test_pattern[22] = 8'b0000_0000;

    // DPhiPresetC
    test_pattern[23] = 8'b0100_0000;
    test_pattern[24] = 8'b0000_0000;
    test_pattern[25] = 8'b0000_0000;

    // DPhiPresetD
    test_pattern[26] = 8'b0110_0000;
    test_pattern[27] = 8'b0000_0000;
    test_pattern[28] = 8'b0000_0000;

    // CONTROL_REG
    test_pattern[29] = 8'b0000_0010; //ram_cs=0, output_select_mode=0, test_mode_enable=0, rst_n=0, command=4'b0010
    // TEST_MODE_RAM_REG
    test_pattern[30] = 8'b0000_0000; //wr_en=0, wr_addr=4'b0000
    // frame_len
    test_pattern[31] = 8'b0000_0010;    

    //insert cmd2 , length = 3 ,addr = 32
    cmd_test[1] = 16'b1_00010_0000100000;

    test_pattern[32] = 8'b0001_0000; //frame_len=16'h1002
    // idle_len
    test_pattern[33] = 8'b0000_0010;
    test_pattern[34] = 8'b0000_0000; //idle_len=16'h0004

    // release reset
    cmd_test[2] = 16'b1_00000_0000011101; //write 29 reg
    test_pattern[35] = 8'b0001_0010; //ram_cs=0, output_select_mode=0, test_mode_enable=0, rst_n=1, command=4'b0010

end

integer i;
integer j;

// Test stimulus
initial begin
    // Initialize inputs
    spi_csn_pad = 1;
    spi_rstn_pad = 1;
    spi_sck_pad = 0;
    spi_mosi_pad = 0;

    // Reset sequence
    #10 spi_rstn_pad = 0;
    #10 spi_rstn_pad = 1;

    // SPI transaction example
    #20 spi_csn_pad = 0;

    i = 15;
    repeat (16) begin
        #10 spi_sck_pad = 0; 
        #5  spi_mosi_pad = cmd_test[0][i];
        #5  spi_sck_pad = 1;
        i = i - 1;
    end

    j = 0;
    repeat (32) begin
        i=7;
        repeat (8) begin
            #10 spi_sck_pad = 0; 
            #5  spi_mosi_pad = test_pattern[j][i];
            #5  spi_sck_pad = 1;
            i = i - 1;
        end
        j = j + 1;
    end

    i = 15;
    repeat (16) begin
        #10 spi_sck_pad = 0; 
        #5  spi_mosi_pad = cmd_test[1][i];
        #5  spi_sck_pad = 1;
        i = i - 1;
    end

    j =32;
    repeat (3) begin
        i=7;
        repeat (8) begin
            #10 spi_sck_pad = 0; 
            #5  spi_mosi_pad = test_pattern[j][i];
            #5  spi_sck_pad = 1;
            i = i - 1;
        end    
        j = j + 1;
    end

    i = 15;
    repeat (16) begin
        #10 spi_sck_pad = 0; 
        #5  spi_mosi_pad = cmd_test[2][i];
        #5  spi_sck_pad = 1;
        i = i - 1;
    end
    j =35;
    i=7;
    repeat (8) begin
        #10 spi_sck_pad = 0; 
        #5  spi_mosi_pad = test_pattern[j][i];
        #5  spi_sck_pad = 1;
        i = i - 1;
    end    
    #10 spi_csn_pad = 1;

end


endmodule
