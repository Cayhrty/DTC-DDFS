`define PACK_ARRAY(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST) \
                generate \
                genvar pk_idx; \
                for (pk_idx=0; pk_idx<(PK_LEN); pk_idx=pk_idx+1) \
                begin \
                        assign PK_DEST[((PK_WIDTH)*pk_idx+((PK_WIDTH)-1)):((PK_WIDTH)*pk_idx)] = PK_SRC[pk_idx][((PK_WIDTH)-1):0]; \
                end \
                endgenerate

localparam STATUS_WAIT = 2'b00;
localparam STATUS_READ = 2'b01;
localparam STATUS_WRITE = 2'b11;
localparam REG_CNT =  79;
module spi_slv_top(
    input csn_pad,
    input rstn_pad,
    input sck_pad,
    input mosi_pad,
    output miso_pad,
    output [REG_CNT*8-1:0] slv_reg_out
);

wire csn, sck, mosi, miso, rstn;
//PAD
  PDIDGZ    pad_sck    (.PAD(sck_pad)  ,.C(sck));
  PDIDGZ    pad_rstn   (.PAD(rstn_pad) ,.C(rstn));
  PDIDGZ    pad_csn    (.PAD(csn_pad)  ,.C(csn));
  PDIDGZ    pad_mosi   (.PAD(mosi_pad) ,.C(mosi));
  PDO12CDG  pad_miso   (.PAD(miso_pad) ,.I(miso));

//power
  wire VDD;
  wire VDDPST;
  wire VSS;
  PVDD1DGZ PAD_vdd_core (.VDD(VDD));//1.2V
  PVSS3DGZ PAD_vss      (.VSS(VSS));
  PVDD2DGZ PAD_vdd_io   (.VDDPST(VDDPST));//3.3V
  PVDD2POC PAD_poc      (.VDDPST());// power on control 
//power end

reg [7:0] slv_reg [REG_CNT-1:0];
`PACK_ARRAY(8,REG_CNT,slv_reg,slv_reg_out)

reg [1:0] status;

reg [4:0] bit_transfer_cnt;
reg [7:0] byte_transfer_cnt;

reg [9:0] address;

wire [15:0] spi_rdata;
reg  [15:0] spi_rdata_r;
reg  [7:0] spi_wdata_r;

assign spi_rdata = {spi_rdata_r[15:1] , mosi};              // msb first
assign miso = spi_wdata_r [7 - bit_transfer_cnt];      // negedge update miso 

always @(posedge sck or posedge csn) begin

    if( csn == 1'b1 )begin
        //reset
        bit_transfer_cnt  <= 0;
        byte_transfer_cnt <= 0;
        status <= 0;
        spi_wdata_r <=0;
        spi_rdata_r <=0;
        address <=0;
    end
    else begin
        spi_rdata_r [15 - bit_transfer_cnt] <= mosi;

        case (status) // synopsys full_case
            STATUS_WAIT: begin:load_cmd
                if(bit_transfer_cnt == 15) begin

                    bit_transfer_cnt <= 0;
                    spi_wdata_r <= slv_reg[spi_rdata[9:0]];
                    byte_transfer_cnt <= spi_rdata[14:10];

                    if(spi_rdata [15] == 1'b0 ) begin
                        status <= STATUS_READ;
                        address <= spi_rdata[9:0] + 1'b1;
                    end
                    else begin
                        status <= STATUS_WRITE;
                        address <= spi_rdata[9:0];
                    end
                    
                end
                else begin
                    bit_transfer_cnt <= bit_transfer_cnt + 1'b1;
                end
            end

            STATUS_READ: begin:read_proc
                if(bit_transfer_cnt == 7) begin
                    bit_transfer_cnt <= 0;
                    if( byte_transfer_cnt == 0 ) begin
                        status <= STATUS_WAIT;
                    end
                    else begin
                        byte_transfer_cnt <= byte_transfer_cnt - 1'b1;
                        address <= address + 1'b1;
                        spi_wdata_r <= slv_reg[address];
                    end
                end
                else begin
                    bit_transfer_cnt <= bit_transfer_cnt + 1'b1;
                end
            end

            STATUS_WRITE: begin:write_proc
                if(bit_transfer_cnt == 7)begin
                    bit_transfer_cnt <= 0;

                    if( byte_transfer_cnt == 0 )begin
                        status <= STATUS_WAIT;
                    end
                    else begin
                        byte_transfer_cnt <= byte_transfer_cnt - 1'b1;
                        address <= address + 1'b1;
                    end
                    //slv_reg[address] <= {spi_rdata[15:9],mosi}; write slv reg seperated
                end
                else begin
                    bit_transfer_cnt <= bit_transfer_cnt + 1'b1;
                end
            end
        endcase
    end
end

always @(posedge sck or negedge rstn) begin
    if( rstn == 1'b0 )begin
        integer i;
        for (i = 0; i<REG_CNT; i=1+i) begin
            slv_reg[i] <= 8'b0;
        end
    end
    else begin
        if( status == STATUS_WRITE && bit_transfer_cnt == 7)begin
            slv_reg[address] <= {spi_rdata[15:9],mosi};
        end
    end
end

endmodule // spi