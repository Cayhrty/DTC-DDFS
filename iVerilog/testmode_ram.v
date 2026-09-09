module testmode_ram(
    input clk,
    input clk_hs,
    input cs_n,
    input test_mode_enable,
    input [3:0] ram_wr_addr,
    input ram_wr_en,
    input [351:0] ram_data_in,
    output reg [9:0] edgeA_out,
    output reg [9:0] edgeB_out,
    output reg [9:0] edgeC_out,
    output reg [9:0] edgeD_out,
    output reg [9:0] edgeE_out,
    output reg [9:0] edgeF_out,
    output reg [9:0] edgeG_out,
    output reg [9:0] edgeH_out,
    output reg [7:0] edge_out_valid
);

reg [3:0] rd_addr;

always@(posedge clk) begin
    if(test_mode_enable)
        rd_addr <= rd_addr + 1'b1;
    else 
        rd_addr <= 4'b0;
end

localparam NUM_BLOCKS = 8;
localparam DEPTH = 16;
localparam DATA_WIDTH = 40;
localparam BLOCK_WIDTH = 44;

reg  [351:0] ram_data_out;
wire [351:0] ram_data_out_latch;

// Generate block RAMs using a generate loop
// per RAM 44bit width, 16 depth , 4 11bit data one cycle , in 11bit ,highest 1bit is valid bit
genvar i;
generate
    for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : test_ram_blocks
        DW_ram_r_w_a_lat #(BLOCK_WIDTH, DEPTH, 1) ram_inst (
            .rst_n(1'b1),
            .cs_n(cs_n),
            .wr_n(ram_wr_en),
            .rd_addr(rd_addr),
            .wr_addr(ram_wr_addr),
            .data_in(ram_data_in[(i+1)*BLOCK_WIDTH-1:i*BLOCK_WIDTH]),
            .data_out(ram_data_out_latch[(i+1)*BLOCK_WIDTH-1:i*BLOCK_WIDTH])
        );
    end
endgenerate

reg [1:0] cnt_hs;

always @(posedge clk) begin
    if(test_mode_enable)
        ram_data_out <= ram_data_out_latch;
    else
        ram_data_out <= ram_data_out;
end

always @(posedge clk_hs) begin
        if(test_mode_enable) begin
           case(cnt_hs)
                2'b00: begin
                    edgeA_out <= ram_data_out[9:0];
                    edgeB_out <= ram_data_out[53:44];
                    edgeC_out <= ram_data_out[97:88];
                    edgeD_out <= ram_data_out[141:132];
                    edgeE_out <= ram_data_out[185:176];
                    edgeF_out <= ram_data_out[229:220];
                    edgeG_out <= ram_data_out[273:264];
                    edgeH_out <= ram_data_out[317:308];
                    edge_out_valid <= {ram_data_out[318], ram_data_out[274], ram_data_out[230], ram_data_out[186], ram_data_out[142], ram_data_out[98], ram_data_out[54], ram_data_out[10]};
                end
                2'b01: begin
                    edgeA_out <= ram_data_out[20:11];
                    edgeB_out <= ram_data_out[64:55];
                    edgeC_out <= ram_data_out[108:99];
                    edgeD_out <= ram_data_out[152:143];
                    edgeE_out <= ram_data_out[196:187];
                    edgeF_out <= ram_data_out[240:231];
                    edgeG_out <= ram_data_out[284:275];
                    edgeH_out <= ram_data_out[328:319];
                    edge_out_valid <= {ram_data_out[329], ram_data_out[285], ram_data_out[241], ram_data_out[197], ram_data_out[153], ram_data_out[109], ram_data_out[65], ram_data_out[21]};
                end
                2'b10: begin
                    edgeA_out <= ram_data_out[31:22];
                    edgeB_out <= ram_data_out[75:66];
                    edgeC_out <= ram_data_out[119:110];
                    edgeD_out <= ram_data_out[163:154];
                    edgeE_out <= ram_data_out[207:198];
                    edgeF_out <= ram_data_out[251:242];
                    edgeG_out <= ram_data_out[295:286];
                    edgeH_out <= ram_data_out[339:330];
                    edge_out_valid <= {ram_data_out[340], ram_data_out[296], ram_data_out[252], ram_data_out[208], ram_data_out[164], ram_data_out[120], ram_data_out[76], ram_data_out[32]};
                end
                2'b11: begin
                    edgeA_out <= ram_data_out[42:33];
                    edgeB_out <= ram_data_out[86:77];
                    edgeC_out <= ram_data_out[130:121];
                    edgeD_out <= ram_data_out[174:165];
                    edgeE_out <= ram_data_out[218:209];
                    edgeF_out <= ram_data_out[262:253];
                    edgeG_out <= ram_data_out[306:297];
                    edgeH_out <= ram_data_out[350:341];
                    edge_out_valid <= {ram_data_out[351], ram_data_out[307], ram_data_out[263], ram_data_out[219], ram_data_out[175], ram_data_out[131], ram_data_out[87], ram_data_out[43]};
                end
            endcase
        end
end

always @(posedge clk_hs) begin
    if(test_mode_enable)
        cnt_hs <= cnt_hs + 1'b1;
    else 
        cnt_hs <= cnt_hs;
end

endmodule



