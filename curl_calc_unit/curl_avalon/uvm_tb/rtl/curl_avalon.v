/*MIT License

Copyright (c) 2018 Ievgen Korokyi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/

module curl_avalon ( i_clk,
                    i_arst,
                    // slave IF
                    i_slave_writedata,
                    i_slave_byteenable,
                    i_slave_write,
                    i_slave_read,
                    i_slave_address,
                    o_slave_readdata,
                    o_slave_waitrequest,
                    o_slave_readdatavalid,
                    // master IF
                    o_master_address,
                    o_master_write,
                    o_master_read,
                    o_master_byteenable,
                    o_master_writedata,
                    i_master_waitrequest,
                    i_master_readdatavalid,
                    i_master_readdata
);

localparam  MASTER_DATA_WIDTH   = 128;
localparam  MASTER_BE_WIDTH     = MASTER_DATA_WIDTH/8;
localparam  MASTER_ADDR_WIDTH   = 28;
localparam  CURL_RESULT_LEN     = 16; // 16 128bit words

localparam  SLAVE_DATA_WIDTH    = 32;
localparam  SLAVE_BE_WIDTH      = SLAVE_DATA_WIDTH/8;
localparam  SLAVE_ADDR_WIDTH    = 2;

localparam  OP_REG              = 2'd0;
localparam  SRC_ADDR_REG        = 2'd1;
localparam  DST_ADDR_REG        = 2'd2;
// Slave Addr Space
// 0: main ctrl reg (bit0:finish, bit1:start, bit8-23:src_buf_len in trits)
// 1: src buf word addr
// 2: dst buf word addr

localparam IDLE_S = 0, LOAD_S = 1, TRANSFORM_S = 2, STORE_S = 3;

input                                   i_clk;
input                                   i_arst;

// slave IF
input       [SLAVE_DATA_WIDTH-1:0]      i_slave_writedata;
input       [SLAVE_BE_WIDTH-1:0]        i_slave_byteenable;
input                                   i_slave_write;
input                                   i_slave_read;
input       [SLAVE_ADDR_WIDTH-1:0]      i_slave_address;

output reg  [SLAVE_DATA_WIDTH-1:0]      o_slave_readdata;
output                                  o_slave_waitrequest;
output                                  o_slave_readdatavalid;

// master IF

input       [MASTER_DATA_WIDTH-1:0]     i_master_readdata;
input                                   i_master_waitrequest;
input                                   i_master_readdatavalid;

output      [MASTER_DATA_WIDTH-1:0]     o_master_writedata;
output reg  [MASTER_BE_WIDTH-1:0]       o_master_byteenable;
output                                  o_master_write;
output                                  o_master_read;
output reg  [MASTER_ADDR_WIDTH-1:0]     o_master_address;

reg         [31:0]                      src_addr_ff;
reg         [31:0]                      dst_addr_ff;

reg         [15:0]                      src_buf_len; // in trits
reg         [15:0]                      trits_to_process;  
reg                                     start_ff;
reg                                     finish_ff;

reg                                     curl_rst_n;
reg                                     curl_we_ff;
reg         [3:0]                       curl_addr_ff;
reg                                     curl_transform_ff;
reg         [53:0]                      curl_idata_ff;
wire        [53:0]                      curl_odata;
wire                                    curl_otransforming;

reg         [MASTER_DATA_WIDTH-1:0]     awm_user_buffer_data;
wire        [MASTER_ADDR_WIDTH-1:0]     awm_master_address;
wire        [MASTER_BE_WIDTH-1:0]       awm_master_byteenable;
reg                                     awm_control_go;
reg                                     awm_rst;
reg                                     awm_user_write_buffer;
wire                                    awm_control_done;
wire                                    awm_user_buffer_full;

wire        [MASTER_DATA_WIDTH-1:0]     arm_user_buffer_data;
wire        [MASTER_ADDR_WIDTH-1:0]     arm_master_address;
wire        [MASTER_BE_WIDTH-1:0]       arm_master_byteenable;
wire        [11:0]                      arm_control_read_length; // should be > 15
reg                                     arm_control_go;
reg                                     arm_rst;
reg                                     arm_user_read_buffer;
reg                                     arm_user_data_available;
//wire                                    arm_control_done;

reg         [1:0]                       state_ff;

reg         [3:0]                       mem_trit_cnt_ff;
reg         [4:0]                       curl_trit_cnt_ff;

reg                                     rw_master_ctrl; 

integer i;

curl_transform transform_inst (.i_clk ( i_clk ),
                                .i_arst_n ( curl_rst_n),
                                .i_we ( curl_we_ff ),
                                .i_addr ( curl_addr_ff ),
                                .i_data ( curl_idata_ff ),
                                .i_transform ( curl_transform_ff ),
                                .o_transforming ( curl_otransforming ),
                                .o_data ( curl_odata )
					            );

write_master #( .DATAWIDTH ( MASTER_DATA_WIDTH ),
                .BYTEENABLEWIDTH ( MASTER_BE_WIDTH ),
                .ADDRESSWIDTH ( MASTER_ADDR_WIDTH ),
                .FIFODEPTH ( 8 ),
                .FIFODEPTH_LOG2 ( 3 ),
                .FIFOUSEMEMORY ( 1 ) 

            ) awm ( .clk ( i_clk ),     // awm means address write master
	                .reset ( awm_rst ),
	
	                // control inputs and outputs
	                .control_fixed_location ( 1'b0 ),
	                .control_write_base ( dst_addr_ff ),
	                .control_write_length ( CURL_RESULT_LEN ),
	                .control_go ( awm_control_go ),
	                .control_done ( awm_control_done ),
	
	                // user logic inputs and outputs
	                .user_write_buffer ( awm_user_write_buffer ),
	                .user_buffer_data ( awm_user_buffer_data ),
	                .user_buffer_full ( awm_user_buffer_full ),
	
	                // master inputs and outputs
	                .master_address ( awm_master_address ),
	                .master_write ( o_master_write ),
	                .master_byteenable ( awm_master_byteenable ),
	                .master_writedata ( o_master_writedata ),
	                .master_waitrequest ( i_master_waitrequest )
                );

latency_aware_read_master #( .DATAWIDTH ( MASTER_DATA_WIDTH ),
                            .BYTEENABLEWIDTH ( MASTER_BE_WIDTH ),
                            .ADDRESSWIDTH ( MASTER_ADDR_WIDTH ),
                            .FIFODEPTH ( 16 ),
                            .FIFODEPTH_LOG2 ( 4 ),
                            .FIFOUSEMEMORY ( 1 ) 

                        ) arm ( .clk ( i_clk ),     // arm means address read master
	                            .reset ( arm_rst ),

	                            // control inputs and outputs
	                            .control_fixed_location ( 1'b0 ),
	                            .control_read_base ( src_addr_ff ),
	                            .control_read_length ({16'b0, arm_control_read_length}),
	                            .control_go ( arm_control_go ),
	                            .control_done ( ),
	                            .control_early_done ( ),
	
	                            // user logic inputs and outputs
	                            .user_read_buffer ( arm_user_read_buffer ),
	                            .user_buffer_data ( arm_user_buffer_data ),
	                            .user_data_available ( arm_user_data_available ),
	
	                            // master inputs and outputs
	                            .master_address ( arm_master_address ),
	                            .master_read ( o_master_read ),
	                            .master_byteenable ( arm_master_byteenable ),
	                            .master_readdata ( i_master_readdata ),
	                            .master_readdatavalid ( i_master_readdatavalid ),
	                            .master_waitrequest ( i_master_waitrequest )
                            );

assign o_slave_waitrequest      = 1'b0;
assign o_slave_readdatavalid    = i_slave_read;

// Avalon Slave Read implementation

always @* begin

	o_slave_readdata = 'x;

    case (i_slave_address)

    OP_REG:       o_slave_readdata = {src_buf_len, 6'd0, start_ff, finish_ff};

    SRC_ADDR_REG: o_slave_readdata = src_addr_ff;

    DST_ADDR_REG: o_slave_readdata = dst_addr_ff;

    endcase

end

// Avalon Slave Write implementation 
always @(posedge i_clk, posedge i_arst) begin

    if (i_arst) begin

        src_addr_ff     <= '0;  
        dst_addr_ff     <= '0; 
        src_buf_len     <= '0;
        start_ff        <= 1'b0;

    end else begin

        start_ff        <= 1'b0;
        
        if (i_slave_write) begin

            case (i_slave_address)

            OP_REG: begin
                
                if (i_slave_byteenable[0]) begin
                    start_ff            <= i_slave_writedata[1];
                end

                if(i_slave_byteenable[1]) begin
                    src_buf_len[7:0]    <= i_slave_writedata[15:8];
                end

                if(i_slave_byteenable[2]) begin
                    src_buf_len[15:8]   <= i_slave_writedata[23:16];
                end

            end

            SRC_ADDR_REG: begin
    
                for (i=0; i < 4; i=i+1)
                    if (i_slave_byteenable[i])
                        src_addr_ff[8*i +: 8] <= i_slave_writedata[8*i +: 8];

            end

            DST_ADDR_REG: begin

                for (i=0; i < 4; i=i+1)
                    if (i_slave_byteenable[i])
                        dst_addr_ff[8*i +: 8] <= i_slave_writedata[8*i +: 8];

            end

            endcase
        
        end
        
    end

end

assign arm_control_read_length = (src_buf_len >> 4) + 1'b1; 

always @* begin

    if (rw_master_ctrl) begin

        o_master_address        = arm_master_address;
        o_master_byteenable     = arm_master_byteenable;

    end else begin

        o_master_address        = awm_master_address;
        o_master_byteenable     = awm_master_byteenable;

    end

end

always @(posedge i_clk, posedge i_arst) begin

    if (i_arst) begin

        state_ff                <= IDLE_S;
        curl_we_ff              <= 1'b0;
        curl_transform_ff       <= 1'b0;
        awm_control_go          <= 1'b0;
        arm_control_go          <= 1'b0;
        curl_rst_n              <= 1'b0;
        awm_user_write_buffer   <= 1'b0;
        arm_rst                 <= 1'b1;
        awm_rst                 <= 1'b1;     
        finish_ff               <= 1'b0;

    end else begin

        arm_control_go          <= 1'b0;
        curl_rst_n              <= 1'b1;
        curl_we_ff              <= 1'b0;
        curl_transform_ff       <= 1'b0;
        awm_control_go          <= 1'b0;
        awm_user_write_buffer   <= 1'b0;

        case (state_ff)

        IDLE_S: begin

            arm_rst                 <= 1'b1;
            awm_rst                 <= 1'b1; 

            if (start_ff) begin
            
                state_ff            <= LOAD_S;
                arm_control_go      <= 1'b1;
                mem_trit_cnt_ff     <= '0;
                curl_trit_cnt_ff    <= '0;
                curl_rst_n          <= 1'b0;
                curl_addr_ff        <= '0;
                trits_to_process    <= src_buf_len;
                arm_rst             <= 1'b0;
                awm_rst             <= 1'b0;
                finish_ff           <= 1'b0;
                rw_master_ctrl      <= 1'b1;

            end

        end

        LOAD_S: begin

            if (arm_user_data_available) begin

                if (trits_to_process) begin

                    curl_idata_ff[2*curl_trit_cnt_ff +: 2] <= arm_user_buffer_data[8*mem_trit_cnt_ff +: 2];  
                    trits_to_process    <= trits_to_process - 1'b1;

                end else begin

                    curl_idata_ff[2*curl_trit_cnt_ff +: 2] <= '0;

                end

                curl_trit_cnt_ff    <= curl_trit_cnt_ff + 1'b1;
                mem_trit_cnt_ff     <= mem_trit_cnt_ff + 1'b1;

                if (5'd26 == curl_trit_cnt_ff) begin
                    curl_trit_cnt_ff <= '0;
                    curl_we_ff      <= 1'b1;
                end

                if (4'd15 == mem_trit_cnt_ff) begin
                    mem_trit_cnt_ff <= '0;
                end

            end

            if (curl_we_ff) begin

                curl_addr_ff <= curl_addr_ff + 1'b1;

                if (4'd8 == curl_addr_ff) begin

                    state_ff            <= TRANSFORM_S;
                    curl_transform_ff   <= 1'b1;
                    curl_addr_ff        <= '0;

                end

            end

        end

        TRANSFORM_S: begin

            if (!curl_transform_ff && !curl_otransforming) begin

                if (trits_to_process) begin                

                    state_ff <= LOAD_S;

                end else begin

                    state_ff            <= STORE_S;
                    awm_control_go      <= 1'b1;
                    curl_addr_ff        <= '0;
                    curl_trit_cnt_ff    <= '0;
                    mem_trit_cnt_ff     <= '0;
                    trits_to_process    <= 16'd243;
                    rw_master_ctrl      <= 1'b0;

                end

            end

        end

        STORE_S: begin

            if (!awm_user_buffer_full) begin
        
                if (trits_to_process) begin

                    awm_user_buffer_data[8*mem_trit_cnt_ff +: 8] <= $signed(curl_odata[2*curl_trit_cnt_ff +: 2]);
                    trits_to_process    <= trits_to_process - 1'b1;

                end else begin

                    awm_user_buffer_data[8*mem_trit_cnt_ff +: 8] <= '0;

                end

                curl_trit_cnt_ff        <= curl_trit_cnt_ff + 1'b1;
                mem_trit_cnt_ff         <= mem_trit_cnt_ff + 1'b1;

          
                if (5'd26 == curl_trit_cnt_ff) begin
            
                    curl_trit_cnt_ff    <= '0;
                    curl_addr_ff        <= curl_addr_ff + 1'b1;

                end

                if (4'd15 == mem_trit_cnt_ff) begin

                    awm_user_write_buffer   <= 1'b1;
                    mem_trit_cnt_ff         <= '0;

                end

                if (awm_control_done & !awm_control_go) begin

                    state_ff    <= IDLE_S;
                    finish_ff   <= 1'b1;

                end

            end

        end

        endcase

    end

end


always @* begin

    arm_user_read_buffer    = 1'b0;

    case (state_ff)
    
        IDLE_S: begin
    
        end
    
        LOAD_S: begin

            if ( arm_user_data_available && (4'd15 == mem_trit_cnt_ff) ) 
                arm_user_read_buffer = 1'b1;   
    
        end
    
        TRANSFORM_S: begin
    
        end
    
        STORE_S: begin
    
        end
    
    endcase

end

endmodule 

