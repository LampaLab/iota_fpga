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

module curl_pow (i_clk,
			i_arst_n,
			i_we,
            i_addr,
			i_data,
			i_transform,
            i_pow,
            i_mwm_mask,
			o_transforming,
            o_pow_finish,
            o_pow_hash_finish,
            o_data
			);

parameter CU_NUM = 10;

localparam DATA_WIDTH = 54;
localparam STATE_WORDS = 27;
localparam TRITS_IN_WORD = 27;
localparam NONCE_WORD_OFFSET = 6;
localparam NONCE_WORDS = 3;
localparam TRITS_IN_STATE = STATE_WORDS * TRITS_IN_WORD;
localparam MWM_MASK_WIDTH = 32;

localparam STATE_WORDS_IO = STATE_WORDS / 3;

localparam ADDR_WIDTH = $clog2(STATE_WORDS_IO);    
// we need to read/write from outside only low 1/3 part of state
					
localparam NUMBER_OF_ROUNDS = 81;

localparam IDLE_ST = 0, TRANSFORM_ST = 1, POW_ST = 2, CHECK_POW_ST = 3, LOAD_MIDSTATE_ST = 4;

input 								                        i_clk;
input 								                        i_arst_n;
input								                        i_we;
input       [(ADDR_WIDTH-1):0]                              i_addr;
input 		[(DATA_WIDTH-1):0]	                            i_data;
input 								                        i_transform;
input                                                       i_pow;
input       [(MWM_MASK_WIDTH-1):0]                          i_mwm_mask;

output  reg							                        o_transforming;
output 	reg	[2*NONCE_WORDS*TRITS_IN_WORD-1:0]	            o_data;
output  reg                                                 o_pow_finish;        
output  reg                                                 o_pow_hash_finish;

reg [$clog2(NUMBER_OF_ROUNDS)-1:0]                          round_cnt_ff;

reg [(MWM_MASK_WIDTH-1):0]                                  mwm_mask_ff;

reg [CU_NUM-1:0][STATE_WORDS-1:0][TRITS_IN_WORD-1:0][1:0]   state;
reg [CU_NUM-1:0][TRITS_IN_STATE-1:0][1:0]                   state_trits;

reg [STATE_WORDS-1:0][TRITS_IN_WORD-1:0][1:0]               midstate;
reg [CU_NUM-1:0][NONCE_WORDS-1:0][TRITS_IN_WORD-1:0][1:0]   nonce;
reg [CU_NUM-1:0][2*NONCE_WORDS*TRITS_IN_WORD-1:0]           nonce_bits;
reg [NONCE_WORDS-1:0][TRITS_IN_WORD-1:0][1:0]               selected_nonce;

reg [CU_NUM-1:0][31:0][1:0]                                 trits_for_check;
reg [CU_NUM-1:0][31:0][1:0]                                 masked_trits_for_check;

reg [CU_NUM-1:0][STATE_WORDS-1:0][TRITS_IN_WORD-1:0][1:0]   state_new;
reg [CU_NUM-1:0][TRITS_IN_STATE-1:0][1:0]                   state_new_trits;

reg [STATE_WORDS_IO-1:0]                                    state_word_we;

reg [CU_NUM-1:0][TRITS_IN_STATE-1:0][1:0]                   trit_a_vec;
reg [CU_NUM-1:0][TRITS_IN_STATE-1:0][1:0]                   trit_b_vec;
reg [CU_NUM-1:0][TRITS_IN_STATE-1:0][1:0]                   trit_1_vec;
reg [CU_NUM-1:0][TRITS_IN_STATE-1:0][1:0]                   trit_2_vec;

reg [CU_NUM-1:0][TRITS_IN_STATE-1:0][3:0]                   truth_table_sel_vec;

wire [CU_NUM-1:0][TRITS_IN_STATE-1:0][1:0]                  truth_table_trit_vec;

reg                                                         transform_m_we_ff;
reg                                                         transform_s_we_ff;

reg                                                         midst_preld;

reg                                                         save_midst;

wire [CU_NUM-1:0][DATA_WIDTH - 1:0]                         rnd_trits; 

reg [2:0]                                                   state_ff;

reg                                                         valid_nonce;
reg [CU_NUM-1:0]                                            valid_nonces;
reg                                                         en_new_nonce;
reg [$clog2(CU_NUM)-1:0]                                    nonce_sel;

genvar j, k, i, n;

integer t;

// state
generate

    for (n = 0; n < CU_NUM; n++) begin: pow_calc_unit

        if (0 == n) begin: master_pow_calc_unit

            for (j = 0; j < STATE_WORDS; j++) begin: state_words_ff
                for (k = 0; k < TRITS_IN_WORD; k++) begin: state_word_trits_ff

                    if (j < NONCE_WORD_OFFSET) begin: state_data_io
                    // we need to write from outside only low 1/3 part of state
                        always @(posedge i_clk, negedge i_arst_n)
                            if (!i_arst_n)
                                state[0][j][k]   <= 2'b0;
                            else if (transform_m_we_ff | midst_preld | state_word_we[j]) 
                                state[0][j][k]   <= transform_m_we_ff ? state_new[0][j][k] : (midst_preld ? midstate[j][k] : i_data[2*k +: 2]); 

                    end else if (j >= NONCE_WORD_OFFSET && j < STATE_WORDS_IO) begin: state_data_io_nonce_part
                    // we need to write from outside only low 1/3 part of state
                        always @(posedge i_clk, negedge i_arst_n)
                            if (!i_arst_n)
                                state[0][j][k]   <= 2'b0;
                            else if (midst_preld | transform_m_we_ff | state_word_we[j]) 
                                state[0][j][k]   <= transform_m_we_ff ? state_new[0][j][k] : (midst_preld ? nonce[0][j - NONCE_WORD_OFFSET][k] : i_data[2*k +: 2]); 

                    end else begin: state_no_data_io

                        always @(posedge i_clk, negedge i_arst_n)
                            if (!i_arst_n)
                                state[0][j][k]   <= 2'b0;
                            else if (transform_m_we_ff | midst_preld) 
                                state[0][j][k]   <= transform_m_we_ff ? state_new[0][j][k] : midstate[j][k];

                    end

                end
            end

        end else begin: slave_pow_calc_units

            for (j = 0; j < STATE_WORDS; j++) begin: state_words_ff
                for (k = 0; k < TRITS_IN_WORD; k++) begin: state_word_trits_ff

                    if (j >= NONCE_WORD_OFFSET && j < STATE_WORDS_IO) begin: state_nonce_part
                    
                        always @(posedge i_clk, negedge i_arst_n)
                            if (!i_arst_n)
                                state[n][j][k]   <= 2'b11;
                            else if (midst_preld | transform_s_we_ff) 
                                state[n][j][k]   <= transform_s_we_ff ? state_new[n][j][k] : nonce[n][j - NONCE_WORD_OFFSET][k]; 

                    end else begin: state_not_nonce_part

                        always @(posedge i_clk, negedge i_arst_n)
                            if (!i_arst_n)
                                state[n][j][k]   <= 2'b11;
                            else if (transform_s_we_ff | midst_preld) 
                                state[n][j][k]   <= transform_s_we_ff ? state_new[n][j][k] : midstate[j][k];

                    end
                end
            end

        end

    end

endgenerate

// midstate 
generate

    for (j = 0; j < NONCE_WORD_OFFSET; j++) begin: midstate_words_low
        for (k = 0; k < TRITS_IN_WORD; k++) begin: midstate_low_trits

            always @(posedge i_clk, negedge i_arst_n)
                if (!i_arst_n)
                    midstate[j][k]   <= 2'b0;
                else if (save_midst) 
                    midstate[j][k]   <= state[0][j][k];
        end
    end

    for (j = STATE_WORDS_IO; j < STATE_WORDS; j++) begin: midstate_words_hi
        for (k = 0; k < TRITS_IN_WORD; k++) begin: midstate_hi_trits

            always @(posedge i_clk, negedge i_arst_n)
                if (!i_arst_n)
                    midstate[j][k]   <= 2'b0;
                else if (save_midst) 
                    midstate[j][k]   <= state[0][j][k];
        end
    end

endgenerate


generate

for (n = 0; n < CU_NUM; n++) begin: nonce_generator

    LFSR27trit #(.UNIT_NUMBER(n)) LFSR27trit_inst(.i_clk (i_clk), 
                                                    .i_arst_n (i_arst_n),
                                                    .o_rnd_trits (rnd_trits[n])
                                                  );

    //nonce ff part
    always @(posedge i_clk, negedge i_arst_n)
        if (!i_arst_n)
            nonce_bits[n]   <= '0;
        else if (en_new_nonce) 
            nonce_bits[n]   <= {nonce_bits[n][107:0], rnd_trits[n]}; 

    //nonce comb part
    always @* begin
        nonce[n] = nonce_bits[n];
    end

end

endgenerate

//check nonce
generate

    for (n = 0; n < CU_NUM; n++) begin: check_nonce

        always @* begin

            state_trits[n]  = state[n];

            trits_for_check[n] = state_trits[n][242:211];

            for(t = 0; t < 32; t = t + 1) begin
                masked_trits_for_check[n][t] = trits_for_check[n][t] & {2{mwm_mask_ff[31 - t]}};
            end

            valid_nonces[n] = ~|masked_trits_for_check[n];

        end

    end

endgenerate

always @* begin
    valid_nonce = |valid_nonces;
end

always @* begin
    state_word_we           = '0;
    state_word_we[i_addr]   = i_we;    
end

always @* begin

    nonce_sel = '0;

    for(t = 0; t < CU_NUM; t = t + 1)
        if (valid_nonces[t])
            nonce_sel = t;

    selected_nonce = nonce[nonce_sel];
end

always @(posedge i_clk) begin
    o_data <= selected_nonce;
end

always @(posedge i_clk, negedge i_arst_n) begin

    if(!i_arst_n) begin    
        state_ff            <= IDLE_ST;    
        o_transforming      <= 1'b0;
        transform_m_we_ff   <= 1'b0;
        transform_s_we_ff   <= 1'b0;
        o_pow_finish        <= 1'b0;
        o_pow_hash_finish   <= 1'b0;
    end else begin
        
        o_pow_finish        <= 1'b0;
        o_pow_hash_finish   <= 1'b0;
    
        case (state_ff)

        IDLE_ST: begin

            if ( i_transform ) begin
                state_ff            <= TRANSFORM_ST;
                o_transforming      <= 1'b1;  
                round_cnt_ff        <= '0;
                transform_m_we_ff   <= 1'b1;
            end 

            if ( i_pow ) begin
                state_ff            <= POW_ST;
                round_cnt_ff        <= '0;
                transform_m_we_ff   <= 1'b1;
                mwm_mask_ff         <= i_mwm_mask;
            end

        end

        TRANSFORM_ST: begin

            round_cnt_ff    <= round_cnt_ff + 1'b1;  
    
            if ((NUMBER_OF_ROUNDS - 1) == round_cnt_ff) begin
                o_transforming      <= 1'b0;
                state_ff            <= IDLE_ST;
                transform_m_we_ff   <= 1'b0;
            end

        end

        POW_ST: begin

            round_cnt_ff    <= round_cnt_ff + 1'b1;

            if ((NUMBER_OF_ROUNDS - 1) == round_cnt_ff) begin
                state_ff            <= CHECK_POW_ST;  
                transform_m_we_ff   <= 1'b0;
                transform_s_we_ff   <= 1'b0;
                o_pow_hash_finish   <= 1'b1;           
            end

        end

        CHECK_POW_ST: begin
    
            if (valid_nonce) begin
                state_ff        <= IDLE_ST;
                o_pow_finish    <= 1'b1;
            end else begin
                state_ff        <= LOAD_MIDSTATE_ST;    
            end

        end

        LOAD_MIDSTATE_ST: begin

            state_ff            <= POW_ST;
            round_cnt_ff        <= '0;
            transform_m_we_ff   <= 1'b1;
            transform_s_we_ff   <= 1'b1;

        end

        default: begin

            state_ff            <= IDLE_ST;    
            o_transforming      <= 1'b0;
            transform_m_we_ff   <= 1'b0;
            transform_s_we_ff   <= 1'b0;
            o_pow_finish        <= 1'b0;
            o_pow_hash_finish   <= 1'b0;

        end

        endcase

    end

end

always @* begin

    save_midst      = 1'b0;
    en_new_nonce    = 1'b0;
    midst_preld     = 1'b0;

    case (state_ff)
    
    IDLE_ST: begin

        if ( i_pow ) begin
            save_midst = 1'b1;
        end

    end

    TRANSFORM_ST: begin

    end

    POW_ST: begin

    end

    CHECK_POW_ST: begin

        if (~valid_nonce) begin        
            en_new_nonce = 1'b1;
        end

    end    

    LOAD_MIDSTATE_ST: begin
        midst_preld = 1'b1;
    end
    
    endcase

end

generate

    for (n = 0; n < CU_NUM; n++) begin: gen_new_state
    
        for (i = 0; i < TRITS_IN_STATE; i++) begin: trits_ab_extract   

            localparam base_a = 364;
            localparam base_b = 728;
            localparam p = i/2;
            localparam q = (i % 2) ? p : p - 1;
         
            if (0 == i) begin: zero_id_trit

                always @* begin
                    state_trits[n]      = state[n];
                    trit_a_vec[n][i]    = state_trits[n][base_a - p];
                    trit_b_vec[n][i]    = state_trits[n][0];
                end

            end else begin: other_nonzero_id_trits

                always @* begin
                    state_trits[n]      = state[n];
                    trit_a_vec[n][i]    = state_trits[n][base_a - p];
                    trit_b_vec[n][i]    = state_trits[n][base_b - q];
                end

            end

        end

        for (i = 0; i < TRITS_IN_STATE; i++) begin: trits_reorder

            if (0 == (i % 2)) begin: even_trits

                always @* begin
                    trit_1_vec[n][i] = trit_b_vec[n][i];
                    trit_2_vec[n][i] = trit_a_vec[n][i];
                end

            end else begin: odd_trits

                always @* begin
                    trit_1_vec[n][i] = trit_a_vec[n][i];
                    trit_2_vec[n][i] = trit_b_vec[n][i];
                end

            end

        end

        for (i = 0; i < TRITS_IN_STATE; i++) begin: gen_new_trits

            always @* begin
                truth_table_sel_vec[n][i] = $signed(trit_1_vec[n][i]) + $signed(trit_2_vec[n][i]) * 4'sd3 + 4'sd4;
            end

            truth_table tt_inst(.truth_table_sel(truth_table_sel_vec[n][i]), 
                                .truth_table_trit(truth_table_trit_vec[n][i])
                                );

            always @* begin
                state_new_trits[n][i] = truth_table_trit_vec[n][i];
            end

        end

    always @* 
        state_new[n] = state_new_trits[n];

    end

endgenerate


endmodule
					
