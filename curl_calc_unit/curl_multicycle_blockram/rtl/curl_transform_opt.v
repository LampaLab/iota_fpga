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

module curl_transform (i_clk,
						i_arst_n,
				        i_we,
                        i_addr,
						i_data,
						i_transform,
						o_transforming,
						o_data
					);

localparam DATA_WIDTH = 54;
localparam CURL_STATE_WORD_NUM = 27;
localparam TRITS_IN_STATE_WORD = 27;
localparam ADDR_WIDTH = $clog2(CURL_STATE_WORD_NUM);
					
localparam NUMBER_OF_ROUNDS = 81;
localparam NUMBER_OF_STEPS = CURL_STATE_WORD_NUM * 27;

input 								i_clk;
input 								i_arst_n;
input								i_we;
input       [(ADDR_WIDTH - 1) : 0]  i_addr;
input 		[(DATA_WIDTH - 1) : 0]	i_data;
input 								i_transform;
output  reg							o_transforming;
output 	reg	[(DATA_WIDTH - 1) : 0]	o_data;

reg     [(ADDR_WIDTH - 1) : 0]      rd_addr_a_ff;
reg     [(ADDR_WIDTH - 1) : 0]      rd_addr_b_ff;

reg     [(ADDR_WIDTH - 1) : 0]      wr_addr_ff;

reg     [(DATA_WIDTH - 1) : 0]	    w_data;
					
reg                                 tictac_a_ff;
reg                                 tictac_b_ff;
reg                                 tictac_a_st2_ff;
reg                                 tictac_b_st2_ff;
wire                                tictac;

reg                                 st2_en_ff;
reg                                 st3_en_ff;

reg     sel_state_ff;

reg     we_b_0;
reg     we_b_1;

reg     [1:0]   trit_a_0_prev;
reg     [1:0]   trit_a_1_prev;

reg     [1:0]   trit_b_0_prev;
reg     [1:0]   trit_b_1_prev;

reg     [1:0]   trit_id0_s0;
reg     [1:0]   trit_id0_s1;

reg     [1:0]   trit_a_vec[TRITS_IN_STATE_WORD - 1 : 0];
reg     [1:0]   trit_b_vec[TRITS_IN_STATE_WORD - 1 : 0];

reg     [1:0]   trit_a_vec_ff[TRITS_IN_STATE_WORD - 1 : 0];
reg     [1:0]   trit_b_vec_ff[TRITS_IN_STATE_WORD - 1 : 0];

reg     [1:0]   trit_1_vec[TRITS_IN_STATE_WORD - 1 : 0];
reg     [1:0]   trit_2_vec[TRITS_IN_STATE_WORD - 1 : 0];

reg     [3:0]   truth_table_sel_vec[TRITS_IN_STATE_WORD - 1 : 0];

wire    [1:0]   truth_table_trit_vec[TRITS_IN_STATE_WORD - 1 : 0];

reg     [$clog2(NUMBER_OF_ROUNDS) - 1:0]        round_cnt_ff;

reg     transform_ff;

reg     [(ADDR_WIDTH - 1):0]        addr_a_0;
reg     [(ADDR_WIDTH) - 1:0]        addr_b_0;
reg     [(ADDR_WIDTH - 1):0]        addr_a_1;
reg     [(ADDR_WIDTH) - 1:0]        addr_b_1;

reg     we_a_0;
reg     we_a_1;

wire    [(DATA_WIDTH - 1) : 0]	    q_a_0;
wire    [(DATA_WIDTH - 1) : 0]	    q_b_0;
wire    [(DATA_WIDTH - 1) : 0]	    q_a_1;
wire    [(DATA_WIDTH - 1) : 0]	    q_b_1;					

reg     [(DATA_WIDTH + 2 - 1) : 0]	q_a;
reg     [(DATA_WIDTH + 2 - 1) : 0]	q_b;

genvar i;

assign tictac = tictac_b_st2_ff;

true_dual_port_ram #( 	.DATA_WIDTH(DATA_WIDTH),
						.WORD_NUM(CURL_STATE_WORD_NUM)
					) state0 (.i_clk(i_clk),
						        .i_data_a( i_data ), 
						        .i_data_b( w_data ),
						        .i_addr_a( addr_a_0 ), 
						        .i_addr_b( addr_b_0 ),
						        .i_we_a( we_a_0 ), 
						        .i_we_b( we_b_0 ), 
						        .o_data_a( q_a_0 ), 
						        .o_data_b( q_b_0 )
						        );
	
true_dual_port_ram #( 	.DATA_WIDTH(DATA_WIDTH),
						.WORD_NUM(CURL_STATE_WORD_NUM)
					) state1 (.i_clk(i_clk),
						        .i_data_a( i_data ),             
						        .i_data_b( w_data ),
						        .i_addr_a( addr_a_1 ), 
						        .i_addr_b( addr_b_1 ),
						        .i_we_a( we_a_1 ),               
						        .i_we_b( we_b_1 ), 
						        .o_data_a( q_a_1 ), 
						        .o_data_b( q_b_1 )
						        );

always @(posedge i_clk) begin
    if (we_a_0 && (0 == addr_a_0)) 
        trit_id0_s0 <= i_data[1:0];
    else if (we_b_0 && (0 == addr_b_0))
        trit_id0_s0 <= w_data[1:0];
end
	
always @(posedge i_clk) begin
    if (we_a_1 && (0 == addr_a_1))
        trit_id0_s1 <= i_data[1:0];
    else if (we_b_1 && (0 == addr_b_1))
        trit_id0_s1 <= w_data[1:0];
end

always @(posedge i_clk, negedge i_arst_n) begin

    if(!i_arst_n) begin    
        transform_ff        <= 1'b0;    
        o_transforming      <= 1'b0;
        st2_en_ff           <= 1'b0;
        st3_en_ff           <= 1'b0;
        sel_state_ff        <= 1'b0;
    end else begin
        
        if( !transform_ff && i_transform ) begin
            transform_ff        <= 1'b1;
            o_transforming      <= 1'b1;  
            round_cnt_ff        <= '0;

            rd_addr_a_ff        <= 5'd13;       // 351/27 = 13
            rd_addr_b_ff        <= 5'd26;       // 702/27 = 26

            tictac_a_ff         <= 1'b1;
            tictac_b_ff         <= 1'b0;            

            wr_addr_ff          <= '0;
            st2_en_ff           <= 1'b0;
            st3_en_ff           <= 1'b0;
        end 

        if (transform_ff) begin

            tictac_a_ff         <= ~tictac_a_ff;
            tictac_b_ff         <= ~tictac_b_ff;

            tictac_a_st2_ff     <= tictac_a_ff;
            tictac_b_st2_ff     <= tictac_b_ff;

            if (tictac_a_ff)
                rd_addr_a_ff    <= rd_addr_a_ff - 5'd1;

            trit_a_0_prev       <= q_a_0[1:0];
            trit_a_1_prev       <= q_a_1[1:0];
            
            trit_b_0_prev       <= q_b_0[1:0];
            trit_b_1_prev       <= q_b_1[1:0];

            if (tictac_b_ff)
                rd_addr_b_ff    <= rd_addr_b_ff - 5'd1;

            st2_en_ff           <= 1'b1;
            st3_en_ff           <= st2_en_ff;
        
            if (st3_en_ff)
                wr_addr_ff <= wr_addr_ff + 1'b1;

            if ((CURL_STATE_WORD_NUM - 1) == wr_addr_ff) begin
                round_cnt_ff        <= round_cnt_ff + 1'b1;
                sel_state_ff        <= ~sel_state_ff;
                st2_en_ff           <= 1'b0;
                st3_en_ff           <= 1'b0;
                wr_addr_ff          <= '0;
                rd_addr_a_ff        <= 5'd13;       // 351/27 = 13
                rd_addr_b_ff        <= 5'd26;       // 702/27 = 26
                tictac_a_ff         <= 1'b1;
                tictac_b_ff         <= 1'b0; 
            end
    
            if (NUMBER_OF_ROUNDS == round_cnt_ff) begin
                o_transforming      <= 1'b0;
                transform_ff        <= 1'b0;
            end
        
        end
    
    end

end	
		
always @(posedge i_clk) begin
    trit_a_vec_ff <= trit_a_vec;
    trit_b_vec_ff <= trit_b_vec;
end

always @* begin

    if (transform_ff) begin
        we_a_0 = 1'b0;
        we_a_1 = 1'b0;
    end else if (sel_state_ff) begin
        we_a_0 = 1'b0;
        we_a_1 = i_we;
    end else begin
        we_a_0 = i_we;
        we_a_1 = 1'b0;
    end

    if (sel_state_ff) begin                
        we_b_0 = st3_en_ff;
        we_b_1 = 1'b0;
    end else begin
        we_b_1 = st3_en_ff;
        we_b_0 = 1'b0;
    end

    if (sel_state_ff)
        o_data = q_a_1;    
    else
        o_data = q_a_0;

    if (transform_ff)
        addr_a_0 = rd_addr_a_ff;    
    else
        addr_a_0 = i_addr;

    if (sel_state_ff)
        addr_b_0 = wr_addr_ff;
    else
        addr_b_0 = rd_addr_b_ff;

    if (transform_ff)
        addr_a_1 = rd_addr_a_ff;    
    else
        addr_a_1 = i_addr;

    if (sel_state_ff)
        addr_b_1 = rd_addr_b_ff;
    else
        addr_b_1 = wr_addr_ff;

    if (sel_state_ff) begin
        q_a[53:0]   = q_a_1;
        q_a[55:54]  = trit_a_1_prev;
        q_b[53:0]   = q_b_1;
        if ((0 == wr_addr_ff) && (1'b0 == tictac_b_st2_ff))
            q_b[55:54]  = trit_id0_s1;
        else
            q_b[55:54]  = trit_b_1_prev;
    end else begin
        q_a[53:0]   = q_a_0;
        q_a[55:54]  = trit_a_0_prev;
        q_b[53:0]   = q_b_0;
        if ((0 == wr_addr_ff) && (1'b0 == tictac_b_st2_ff))
            q_b[55:54]  = trit_id0_s0;
        else
            q_b[55:54]  = trit_b_0_prev;
    end

end	

generate

    for (i = 0; i < TRITS_IN_STATE_WORD; i++) begin: trit_a_extract

        localparam j = (i / 2);

        if (0 == (i % 2)) begin: even_trits

            always @* begin
                if (tictac_a_st2_ff)
                    trit_a_vec[i] = q_a[2*(TRITS_IN_STATE_WORD - 14 - j) +: 2];
                else
                    trit_a_vec[i] = q_a[2*(TRITS_IN_STATE_WORD - j) +: 2];
            end

        end else begin: odd_trits

            always @* begin
                if (tictac_a_st2_ff)
                    trit_a_vec[i] = q_a[2*(TRITS_IN_STATE_WORD - 14 - j) +: 2];
                else
                    trit_a_vec[i] = q_a[2*(TRITS_IN_STATE_WORD - (j + 1)) +: 2]; 
            end

        end

    end

    for (i = 0; i < TRITS_IN_STATE_WORD; i++) begin: trit_b_extract

        localparam k = (i / 2);
        
        if (0 == (i % 2)) begin: even_trits

            always @* begin
                if (tictac_b_st2_ff)
                    trit_b_vec[i] = q_b[2*(TRITS_IN_STATE_WORD - 1 - 13 - k) +: 2];
                else
                    trit_b_vec[i] = q_b[2*(TRITS_IN_STATE_WORD - k) +: 2];
            end

        end else begin: odd_trits

            always @* begin
                if (tictac_b_st2_ff)
                    trit_b_vec[i] = q_b[2*(TRITS_IN_STATE_WORD - 1 - 13 - k) +: 2];
                else
                    trit_b_vec[i] = q_b[2*(TRITS_IN_STATE_WORD - 1 - k) +: 2];
            end

        end

    end

    for (i = 0; i < TRITS_IN_STATE_WORD; i++) begin: gen_new_trits
        
        always @* begin
            truth_table_sel_vec[i] = $signed(trit_1_vec[i]) + $signed(trit_2_vec[i]) * 4'sd3 + 4'sd4;
        end

        truth_table tt_inst(.truth_table_sel(truth_table_sel_vec[i]), 
                            .truth_table_trit(truth_table_trit_vec[i])
                            );

        always @* begin
            w_data[2*i +: 2] = truth_table_trit_vec[i];
        end

    end

    for (i = 0; i < TRITS_IN_STATE_WORD; i++) begin: reorder_trits

        if (0 == (i % 2)) begin: even_trits

            always @* begin
                if (tictac) begin
                    trit_1_vec[i] = trit_b_vec_ff[i];
                    trit_2_vec[i] = trit_a_vec_ff[i];
                end else begin
                    trit_1_vec[i] = trit_a_vec_ff[i];
                    trit_2_vec[i] = trit_b_vec_ff[i];
                end
            end

        end else begin: odd_trits

            always @* begin
                if (tictac) begin
                    trit_1_vec[i] = trit_a_vec_ff[i];
                    trit_2_vec[i] = trit_b_vec_ff[i];
                end else begin
                    trit_1_vec[i] = trit_b_vec_ff[i];
                    trit_2_vec[i] = trit_a_vec_ff[i];
                end
            end

        end

    end

endgenerate

					
endmodule
					
