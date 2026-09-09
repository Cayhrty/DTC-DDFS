
module enable_state_machine(
    input clk,
    input rst_n,
    input [3:0] command,
    input [15:0] frame_len,
    input [15:0] idle_len,
//    output reg [3:0] state,
    output reg enable,
    output reg reset_calc_module
);

reg [15:0] frame_counter;
reg [2:0] pipeline_counter;

// IDLE State 0
// RUN State 1 
// AUTO continue State 2
// Auto continue idle State 3
reg [3:0] state;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state <= 4'b0000;
        enable <= 1'b0;
        frame_counter <= 16'b0;
        reset_calc_module <= 1'b0; // Reset the calculation module on reset , negative reset
    end
    else begin
        case(state)
            4'b0000: begin // IDLE State
                enable <= 1'b0;
                frame_counter <= 16'b0;
                if(command == 4'b0001) begin // RUN command
                    pipeline_counter <= 3'b000; // Reset pipeline counter
                    state <= 4'b0001;
                    enable <= 1'b0;
                    reset_calc_module <= 1'b1; // release the reset of the calculation module
                end
                else if(command == 4'b0010) begin // AUTO command
                    pipeline_counter <= 3'b000; // Reset pipeline counter
                    state <= 4'b0010;
                    enable <= 1'b0;
                    reset_calc_module <= 1'b1; // release the reset of the calculation module
                end
                else begin
                    reset_calc_module <= 1'b0;
                end
            end
            4'b0001: begin // RUN State
                if(frame_counter >= frame_len) begin // AUTO STOP 
                    state <= 4'b0000;
                    enable <= 1'b0;
                    frame_counter <= 16'b0;
                    reset_calc_module <= 1'b0; // Reset the calculation module
                end
                else begin

                    if( pipeline_counter < 3'b011 ) begin // Increment pipeline counter
                        pipeline_counter <= pipeline_counter + 1'b1;
                    end
                    else begin
                        pipeline_counter <= 3'b011; // Hold pipeline counter after reaching max
                    end

                    frame_counter <= frame_counter + 16'b1;

                    if( pipeline_counter == 3'b011 ) begin
                        enable <= 1'b1; // enable output when pipeline counter is maxed
                    end
                    else begin
                        enable <= 1'b0; 
                    end
                    reset_calc_module <= 1'b1;
                end
            end
            4'b0010: begin // AUTO continue State
                if(command == 4'b0000) begin // STOP command
                    state <= 4'b0000;
                    enable <= 1'b0;
                    frame_counter <= 16'b0;
                end
                else if(frame_counter >= frame_len) begin // Frame length reached
                    state <= 4'b0011;
                    enable <= 1'b0;
                    frame_counter <= 16'b0;
                    reset_calc_module <= 1'b0;
                end
                else begin
                    if( pipeline_counter < 3'b011 ) begin // Increment pipeline counter
                        pipeline_counter <= pipeline_counter + 1'b1;
                    end
                    else begin
                        pipeline_counter <= 3'b011; // Hold pipeline counter after reaching max
                    end

                    if( pipeline_counter == 3'b011 ) begin
                        enable <= 1'b1; // enable output when pipeline counter is maxed
                    end
                    else begin
                        enable <= 1'b0; 
                    end
                    reset_calc_module <= 1'b1;
                    frame_counter <= frame_counter + 16'b1;
                end
            end
            4'b0011: begin //Auto continue idle
                if(frame_counter >= idle_len) begin // Idle length reached
                    state <= 4'b0010;
                    enable <= 1'b0;
                    reset_calc_module <= 1'b1;
                    pipeline_counter <= 3'b000; // Reset pipeline counter
                    frame_counter <= 16'b0;
                end
                else begin
                    state <= 4'b0011;
                    enable <= 1'b0;
                    reset_calc_module <= 1'b0;
                    frame_counter <= frame_counter + 16'b1;
                end
            end
            default: begin
                state <= 4'b0000;
                enable <= 1'b0;
                reset_calc_module <= 1'b0;
            end
        endcase
    end
end

endmodule
