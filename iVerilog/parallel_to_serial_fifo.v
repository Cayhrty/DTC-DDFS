module parallel_to_serial_fifo(
    input clk_slow, // 0.625 GHz
    input clk_fast, // 2.5 GHz
    input rst_n,
    // input from edge_interp
    input [12:0] edgeA_in, // 3bit for late counter
    input [12:0] edgeB_in, // 3bit for late counter
    input [12:0] edgeC_in, // 3bit for late counter
    input [12:0] edgeD_in, // 3bit for late counter
    input edgeA_valid,
    input edgeB_valid,
    input edgeC_valid,
    input edgeD_valid,

    // output to DTC Analog controller 
    output reg [9:0] dac_edge_out,
    output reg dac_edge_out_valid
);

//Fifo depth 8
reg [12:0] fifo_data [1:0];
reg [1:0] fifo_data_valid ; // 1bit valid for each fifo data

reg fifo_write_ptr;
reg fifo_read_ptr;

reg [9:0] edgeA, edgeB, edgeC, edgeD; // 8bit output edges for Analog controller
reg [2:0] edgeA_late_counter, edgeB_late_counter, edgeC_late_counter, edgeD_late_counter; // 3bit late counter for edges

reg [1:0] fast_counter; // 2bit counter for fast clock ,for selecting ABCD

reg edgeA_valid_delay, edgeB_valid_delay, edgeC_valid_delay, edgeD_valid_delay;

always@(posedge clk_slow or negedge rst_n)begin:read_logic

    if(~rst_n) begin
        edgeA_valid_delay <= 1'b0;
        edgeB_valid_delay <= 1'b0;
        edgeC_valid_delay <= 1'b0;
        edgeD_valid_delay <= 1'b0;
    end
    else begin
        edgeA_valid_delay <= edgeA_valid;
        edgeB_valid_delay <= edgeB_valid;
        edgeC_valid_delay <= edgeC_valid;
        edgeD_valid_delay <= edgeD_valid;
    end
end

always@(posedge clk_slow)begin
    // read from slow clock domain
    if(edgeA_valid) begin
        edgeA <= edgeA_in[9:0];
        edgeA_late_counter <= edgeA_in[12:10];
    end
    if(edgeB_valid) begin
        edgeB <= edgeB_in[9:0];
        edgeB_late_counter <= edgeB_in[12:10];
    end
    if(edgeC_valid) begin
        edgeC <= edgeC_in[9:0];
        edgeC_late_counter <= edgeC_in[12:10];
    end
    if(edgeD_valid) begin
        edgeD <= edgeD_in[9:0];
        edgeD_late_counter <= edgeD_in[12:10];
    end
end

always@(posedge clk_fast or negedge rst_n)begin
    if(~rst_n) begin
        fast_counter <= 2'b00;
        dac_edge_out <= 10'b0;

        fifo_write_ptr <= 1'b0;
        fifo_read_ptr <= 1'b0;

        fifo_data_valid <= 2'b0;
        dac_edge_out_valid <= 1'b0;
    end
    else begin
        fast_counter <= fast_counter + 1'b1; // Increment fast counter

        fifo_data[0][12:10] <= fifo_data[0][12:10] -1'b1; // Decrement late counter by default
        fifo_data[1][12:10] <= fifo_data[1][12:10] -1'b1;

        dac_edge_out_valid <= 1'b0; // No valid data, output zero
        dac_edge_out <= dac_edge_out ;
        if(fifo_data[fifo_read_ptr][12:10] == 3'b000 && fifo_data_valid[fifo_read_ptr]) begin
            dac_edge_out <= fifo_data[fifo_read_ptr][9:0]; // Output edge to DAC
            dac_edge_out_valid <= 1'b1; // Indicate valid output
            fifo_data_valid[fifo_read_ptr] <= 1'b0; // Clear valid bit
            fifo_read_ptr <= ~fifo_read_ptr; // Increment read pointer
        end
        
        // IF input data is valid, write to FIFO
        case(fast_counter)
            2'b00: begin // Select edgeA
                if(edgeA_valid_delay ) begin
                    fifo_data[fifo_write_ptr] <= {edgeA_late_counter, edgeA}; // Store late counter and edge
                    fifo_data_valid [fifo_write_ptr] <= 1'b1; // Set valid bit
                    fifo_write_ptr <= ~ fifo_write_ptr;
                end
            end
            2'b01: begin // Select edgeB
                if(edgeB_valid_delay ) begin
                    fifo_data[fifo_write_ptr] <= {edgeB_late_counter, edgeB}; // Store late counter and edge
                    fifo_data_valid [fifo_write_ptr] <= 1'b1;
                    fifo_write_ptr <= ~ fifo_write_ptr;
                end
            end
            2'b10: begin // Select edgeC
                if(edgeC_valid_delay ) begin
                    fifo_data[fifo_write_ptr] <= {edgeC_late_counter, edgeC}; // Store late counter and edge
                    fifo_data_valid [fifo_write_ptr] <= 1'b1;
                    fifo_write_ptr <= ~ fifo_write_ptr;
                end
            end
            2'b11: begin // Select edgeD
                if(edgeD_valid_delay ) begin
                    fifo_data[fifo_write_ptr] <= {edgeD_late_counter, edgeD}; // Store late counter and edge
                    fifo_data_valid [fifo_write_ptr] <= 1'b1;
                    fifo_write_ptr <= ~ fifo_write_ptr;
                end
            end
        endcase
    end
end

endmodule