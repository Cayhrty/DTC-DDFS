module reset_sync(
    input clk,
    input rst_n,
    output reset_out
);

reg reset_out_sync1, reset_out_sync2;


reg [1:0] sync_rst_n_reg;
always@(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin // press
       sync_rst_n_reg <= 2'b00; 
    end
    else begin  //Release
       sync_rst_n_reg <= {sync_rst_n_reg[0],1'b1};  //shift out,decrease fanout
    end
end
assign reset_out = sync_rst_n_reg[1];//Data after stabilization

endmodule