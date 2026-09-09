
module edge_interp(
    input clk,
    input rst_n,
    input [13:0] edgeA_in,
    input [13:0] edgeB_in,
    input [13:0] edgeC_in,
    input [13:0] edgeD_in,

    input edgeA_in_valid,
    input edgeB_in_valid,
    input edgeC_in_valid,
    input edgeD_in_valid,

    output [12:0] edgeAA_out,
    output [12:0] edgeAB_out,
    output [12:0] edgeAC_out,
    output [12:0] edgeAD_out,
    output [12:0] edgeAE_out,
    output [12:0] edgeAF_out,
    output [12:0] edgeAG_out,
    output [12:0] edgeAH_out,

    output [12:0] edgeBA_out,
    output [12:0] edgeBB_out,
    output [12:0] edgeBC_out,
    output [12:0] edgeBD_out,
    output [12:0] edgeBE_out,
    output [12:0] edgeBF_out,
    output [12:0] edgeBG_out,
    output [12:0] edgeBH_out,

    output [12:0] edgeCA_out,
    output [12:0] edgeCB_out,
    output [12:0] edgeCC_out,
    output [12:0] edgeCD_out,
    output [12:0] edgeCE_out,
    output [12:0] edgeCF_out,
    output [12:0] edgeCG_out,
    output [12:0] edgeCH_out,

    output [12:0] edgeDA_out,
    output [12:0] edgeDB_out,
    output [12:0] edgeDC_out,
    output [12:0] edgeDD_out,
    output [12:0] edgeDE_out,
    output [12:0] edgeDF_out,
    output [12:0] edgeDG_out,
    output [12:0] edgeDH_out,

    output edgeA_out_valid,
    output edgeB_out_valid,
    output edgeC_out_valid,
    output edgeD_out_valid

);

reg [13:0] next_edge; // next clk cycle max edge
reg [1:0] next_edge_id; // next clk cycle max edge id
reg next_edge_valid; // next clk cycle max edge valid ,always valid except first clk cycle

reg [13:0] interpolatorA_inA, interpolatorA_inB, interpolatorB_inA, interpolatorB_inB ,
            interpolatorC_inA, interpolatorC_inB, interpolatorD_inA, interpolatorD_inB;

reg interpolatorA_in_valid , interpolatorB_in_valid , interpolatorC_in_valid , interpolatorD_in_valid;
reg interpolatorA_out_valid, interpolatorB_out_valid, interpolatorC_out_valid, interpolatorD_out_valid;

wire next_edgeA_valid, next_edgeB_valid, next_edgeC_valid, next_edgeD_valid;
wire [13:0] next_edgeA, next_edgeB, next_edgeC, next_edgeD;

assign next_edgeA_valid = edgeA_in_valid;
assign next_edgeB_valid = edgeB_in_valid;
assign next_edgeC_valid = edgeC_in_valid;
assign next_edgeD_valid = edgeD_in_valid;

assign next_edgeA = edgeA_in;
assign next_edgeB = edgeB_in;
assign next_edgeC = edgeC_in;
assign next_edgeD = edgeD_in;

reg [13:0] cur_edgeA, cur_edgeB, cur_edgeC, cur_edgeD; // internal edge registers
reg cur_edgeA_valid, cur_edgeB_valid, cur_edgeC_valid, cur_edgeD_valid; // internal edge valid registers

reg [2:0] late_counterA, late_counterB, late_counterC, late_counterD;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cur_edgeA_valid <= 1'b0;
        cur_edgeB_valid <= 1'b0;
        cur_edgeC_valid <= 1'b0;
        cur_edgeD_valid <= 1'b0;
    end 
    else begin
        cur_edgeA_valid <= next_edgeA_valid;
        cur_edgeB_valid <= next_edgeB_valid;
        cur_edgeC_valid <= next_edgeC_valid;
        cur_edgeD_valid <= next_edgeD_valid;
    end
end


always @(posedge clk) begin
    cur_edgeA <= next_edgeA;
    cur_edgeB <= next_edgeB;
    cur_edgeC <= next_edgeC;
    cur_edgeD <= next_edgeD;
end

// *A *C *E *G is rising edge
// *B *D *F *H is falling edge

// find next edge ,next only not valid in first clk cycle
// next_edge_* is wire
always@(*)begin:find_next_edge
    next_edge_valid = next_edgeA_valid | next_edgeB_valid | next_edgeC_valid | next_edgeD_valid;

    if(next_edgeA_valid) begin
        next_edge = next_edgeA;
        next_edge_id = 2'b00;
    end
    else if(next_edgeB_valid) begin
        next_edge = next_edgeB;
        next_edge_id = 2'b01;
    end
    else if(next_edgeC_valid) begin
        next_edge = next_edgeC;
        next_edge_id = 2'b10;
    end
    else if(next_edgeD_valid) begin
        next_edge = next_edgeD;
        next_edge_id = 2'b11;
    end
end
// find A interpolator input
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        interpolatorA_in_valid <= 1'b0;
    end else begin
        // Interpolator A: A input is edgeA, B input is the first valid edge in this clk cycle or next clk cycle
        if(cur_edgeA_valid)begin
            interpolatorA_inA <= cur_edgeA;
            if (cur_edgeB_valid) begin
                interpolatorA_inB <= cur_edgeB;
                late_counterA <= 3'd1;
            end else if (cur_edgeC_valid) begin
                interpolatorA_inB <= cur_edgeC;
                late_counterA <= 3'd2;
            end else if (cur_edgeD_valid) begin
                interpolatorA_inB <= cur_edgeD;
                late_counterA <= 3'd3;
            end else begin
                interpolatorA_inB <= next_edge; // next edge is always valid
                late_counterA <= 3'd4 + next_edge_id; // next edge id is 0,1,2,3
            end
        end
        interpolatorA_in_valid <= (cur_edgeA_valid);
    end
end

// find B interpolator input
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        interpolatorB_in_valid <= 1'b0;
    end else begin
        // Interpolator B: A input is edgeB, B input is the first valid among C, D, next
        
        if(cur_edgeB_valid)begin
            if (cur_edgeC_valid) begin
                interpolatorB_inA <= cur_edgeB;
                interpolatorB_inB <= cur_edgeC;
                late_counterB <= 3'd1;
            end else if (cur_edgeD_valid) begin
                interpolatorB_inA <= cur_edgeB;
                interpolatorB_inB <= cur_edgeD;
                late_counterB <= 3'd2;
            end else begin
                interpolatorB_inA <= cur_edgeB;
                interpolatorB_inB <= next_edge; // next edge is always valid
                late_counterB <= 3'd3 + next_edge_id; // next_edge_id is 0,1,2,3
            end
        end
        interpolatorB_in_valid <= (cur_edgeB_valid);
    end
end

// find C interpolator input
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        interpolatorC_in_valid <= 1'b0;
    end else begin
        // Interpolator C: A input is edgeC, B input is the first valid among D,next
        if(cur_edgeC_valid)begin
            if (cur_edgeD_valid) begin
                interpolatorC_inA <= cur_edgeC;
                interpolatorC_inB <= cur_edgeD;
                late_counterC <= 3'd1;
            end else begin
                interpolatorC_inA <= cur_edgeC;
                interpolatorC_inB <= next_edge; // next edge is always valid
                late_counterC <= 3'd2 + next_edge_id; // next_edge_id is 0,1,2,3
            end
        end
        interpolatorC_in_valid <= (cur_edgeC_valid);
    end
end

// find D interpolator input
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        interpolatorD_in_valid <= 1'b0;
    end else begin
        // Interpolator D: A input is edgeD, B input is next edge
        if(cur_edgeD_valid)begin
            interpolatorD_inA <= cur_edgeD;
            interpolatorD_inB <= next_edge;
            late_counterD <= 1'b1 + next_edge_id; // next_edge_id is 0,1,2,3
        end
        interpolatorD_in_valid <= (cur_edgeD_valid);
    end
end

interpolation_calc interpolatorA (
    .clk(clk),
    .rst_n(rst_n),
    .edge_in_A(interpolatorA_inA),
    .edge_in_I(interpolatorA_inB),
    .late_counter(late_counterA),
    .input_valid(interpolatorA_in_valid),
    .edge_outA(edgeAA_out),
    .edge_outB(edgeAB_out),
    .edge_outC(edgeAC_out),
    .edge_outD(edgeAD_out),
    .edge_outE(edgeAE_out),
    .edge_outF(edgeAF_out),
    .edge_outG(edgeAG_out),
    .edge_outH(edgeAH_out),
    .output_valid(edgeA_out_valid)
);

interpolation_calc interpolatorB (
    .clk(clk),
    .rst_n(rst_n),
    .edge_in_A(interpolatorB_inA),
    .edge_in_I(interpolatorB_inB),
    .late_counter(late_counterB),
    .input_valid(interpolatorB_in_valid),
    .edge_outA(edgeBA_out),
    .edge_outB(edgeBB_out),
    .edge_outC(edgeBC_out),
    .edge_outD(edgeBD_out),
    .edge_outE(edgeBE_out),
    .edge_outF(edgeBF_out),
    .edge_outG(edgeBG_out),
    .edge_outH(edgeBH_out),
    .output_valid(edgeB_out_valid)
);

interpolation_calc interpolatorC (
    .clk(clk),
    .rst_n(rst_n),
    .edge_in_A(interpolatorC_inA),
    .edge_in_I(interpolatorC_inB),
    .late_counter(late_counterC),
    .input_valid(interpolatorC_in_valid),
    .edge_outA(edgeCA_out),
    .edge_outB(edgeCB_out),
    .edge_outC(edgeCC_out),
    .edge_outD(edgeCD_out),
    .edge_outE(edgeCE_out),
    .edge_outF(edgeCF_out),
    .edge_outG(edgeCG_out),
    .edge_outH(edgeCH_out),
    .output_valid(edgeC_out_valid)
);

interpolation_calc interpolatorD (
    .clk(clk),
    .rst_n(rst_n),
    .edge_in_A(interpolatorD_inA),
    .edge_in_I(interpolatorD_inB),
    .late_counter(late_counterD),
    .input_valid(interpolatorD_in_valid),
    .edge_outA(edgeDA_out),
    .edge_outB(edgeDB_out),
    .edge_outC(edgeDC_out),
    .edge_outD(edgeDD_out),
    .edge_outE(edgeDE_out),
    .edge_outF(edgeDF_out),
    .edge_outG(edgeDG_out),
    .edge_outH(edgeDH_out),
    .output_valid(edgeD_out_valid)
);

endmodule

module interpolation_calc(
    input clk,
    input rst_n,
    input [13:0] edge_in_A,
    input [13:0] edge_in_I,
    input [2:0] late_counter, // 3bit for late counter , indicate how many clk cycles I from A
    input input_valid,
    output reg [12:0] edge_outA,
    output reg [12:0] edge_outB,
    output reg [12:0] edge_outC,
    output reg [12:0] edge_outD,
    output reg [12:0] edge_outE,
    output reg [12:0] edge_outF,
    output reg [12:0] edge_outG,
    output reg [12:0] edge_outH,
    output reg output_valid
);

wire [16:0] edge_in_A_ext;
wire [16:0] edge_in_I_ext;

assign edge_in_A_ext = {3'b000, edge_in_A};
assign edge_in_I_ext = {late_counter, edge_in_I};

reg [16:0] edge_in_A_delay;
reg [16:0] edge_in_I_delay;
reg [16:0] edge_in_A_delay2;
reg [16:0] edge_in_I_delay2;

reg [16:0] edge_E_delay;
reg [16:0] edge_E_delay2;

reg [16:0] edge_C_delay2;
reg [16:0] edge_G_delay2;


reg valid_delay;
reg valid_delay2;


always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        valid_delay <= 1'b0;
        valid_delay2 <= 1'b0;

        edge_outA <= 13'b0;
        edge_outB <= 13'b0;
        edge_outC <= 13'b0;
        edge_outD <= 13'b0;
        edge_outE <= 13'b0;
        edge_outF <= 13'b0;
        edge_outG <= 13'b0;
        edge_outH <= 13'b0;

        output_valid <= 1'b0;
    end
    else begin
        // pipe stage 1
        if(input_valid)begin
            edge_in_A_delay <= edge_in_A_ext;
            edge_in_I_delay <= edge_in_I_ext;
            edge_E_delay <= ({1'b0,edge_in_A_ext} + {1'b0,edge_in_I_ext})>>1; // average of A and I
        end
        valid_delay <= input_valid;
        // pipe stage 2
        if(valid_delay) begin
            edge_in_A_delay2 <= edge_in_A_delay;
            edge_in_I_delay2 <= edge_in_I_delay;
            edge_E_delay2 <= ({1'b0, edge_in_A_delay} + {1'b0, edge_in_I_delay}) >> 1; // average of A and I, 1 bit extension
            edge_C_delay2 <= ({1'b0, edge_in_A_delay} + {1'b0, edge_E_delay}) >> 1;    // average of A and E, 1 bit extension
            edge_G_delay2 <= ({1'b0, edge_in_I_delay} + {1'b0, edge_E_delay}) >> 1;    // average of I and E, 1 bit extension
        end
        valid_delay2 <= valid_delay;
        // output edges pipe stage 3
        if(valid_delay2) begin
            edge_outA <= edge_in_A_delay2[16:4]; // MSB 10bit + 3bit late counter
            edge_outB <= ({1'b0, edge_in_A_delay2} + {1'b0, edge_C_delay2}) >> 1 >> 4; // average of A and C, 1 bit extension, then shift
            edge_outC <= edge_C_delay2[16:4];
            edge_outD <= ({1'b0, edge_C_delay2} + {1'b0, edge_E_delay2}) >> 1 >> 4;    // average of C and E, 1 bit extension, then shift
            edge_outE <= edge_E_delay2[16:4];
            edge_outF <= ({1'b0, edge_E_delay2} + {1'b0, edge_G_delay2}) >> 1 >> 4;    // average of E and G, 1 bit extension, then shift
            edge_outG <= edge_G_delay2[16:4];
            edge_outH <= ({1'b0, edge_G_delay2} + {1'b0, edge_in_I_delay2}) >> 1 >> 4; // average of G and I, 1 bit extension, then shift
        end
        output_valid <= valid_delay2;
    end
end


endmodule
