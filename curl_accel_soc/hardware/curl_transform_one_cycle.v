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
localparam STATE_WORDS = 27;
localparam TRITS_IN_WORD = 27;
localparam TRITS_IN_STATE = STATE_WORDS * TRITS_IN_WORD;

localparam STATE_WORDS_IO = STATE_WORDS / 3;

localparam ADDR_WIDTH = $clog2(STATE_WORDS_IO);    
// we need to read/write from outside only low 1/3 part of state
					
localparam NUMBER_OF_ROUNDS = 81;

input 								                    i_clk;
input 								                    i_arst_n;
input								                    i_we;
input       [(ADDR_WIDTH - 1) : 0]                      i_addr;
input 		[(DATA_WIDTH - 1) : 0]	                    i_data;
input 								                    i_transform;
output  reg							                    o_transforming;
output 	reg	[(DATA_WIDTH - 1) : 0]	                    o_data;

reg [$clog2(NUMBER_OF_ROUNDS) - 1:0]                    round_cnt_ff;

(* preserve *) reg [STATE_WORDS - 1:0][TRITS_IN_WORD - 1:0][1:0]       state;
reg [TRITS_IN_STATE - 1:0][1:0]                         state_trits;

reg [STATE_WORDS - 1:0][TRITS_IN_WORD - 1:0][1:0]       state_new;
reg [TRITS_IN_STATE - 1:0][1:0]                         state_new_trits;

reg [STATE_WORDS_IO - 1:0][TRITS_IN_WORD - 1:0][1:0]    state_out_subset;

reg [STATE_WORDS_IO - 1:0]                              state_word_we;

reg [TRITS_IN_STATE - 1:0][1:0]                         trit_a_vec;
reg [TRITS_IN_STATE - 1:0][1:0]                         trit_b_vec;
reg [TRITS_IN_STATE - 1:0][1:0]                         trit_1_vec;
reg [TRITS_IN_STATE - 1:0][1:0]                         trit_2_vec;

reg [TRITS_IN_STATE - 1:0][3:0]                         truth_table_sel_vec;

wire [TRITS_IN_STATE - 1:0][1:0]                        truth_table_trit_vec;

reg                                                     transform_ff;

genvar j, k, i;

generate

    for (j = 0; j < STATE_WORDS; j++) begin: state_words_ff
        for (k = 0; k < TRITS_IN_WORD; k++) begin: state_word_trits_ff

            if (j < STATE_WORDS_IO) begin: write_mux_state
            // we need to write from outside only low 1/3 part of state
                always @(posedge i_clk, negedge i_arst_n)
                    if (!i_arst_n)
                        state[j][k]   <= 2'b0;
                    else if (transform_ff | state_word_we[j]) 
                        state[j][k]   <= transform_ff ? state_new[j][k] : i_data[2*k +: 2];

            end else begin: no_write_mux_state

                always @(posedge i_clk, negedge i_arst_n)
                    if (!i_arst_n)
                        state[j][k]   <= 2'b0;
                    else if (transform_ff) 
                        state[j][k]   <= state_new[j][k];

            end

        end
    end

endgenerate

always @* begin
    state_word_we           = '0;
    state_word_we[i_addr]   = i_we;    
end

always @* begin
    state_out_subset = state[8:0];
    o_data = state_out_subset[i_addr];
end

        
always @(posedge i_clk, negedge i_arst_n) begin

    if(!i_arst_n) begin    
        transform_ff        <= 1'b0;    
        o_transforming      <= 1'b0;

    end else begin
        
        if( !transform_ff && i_transform ) begin
            transform_ff    <= 1'b1;
            o_transforming  <= 1'b1;  
            round_cnt_ff    <= '0;
        end 

        if (transform_ff) begin
		
            round_cnt_ff    <= round_cnt_ff + 1'b1;  
    
            if ((NUMBER_OF_ROUNDS - 1) == round_cnt_ff) begin
                o_transforming  <= 1'b0;
                transform_ff    <= 1'b0;
            end
        
        end
    
    end

end	

generate
    
    for (i = 0; i < TRITS_IN_STATE; i++) begin: trits_ab_extract   

        localparam base_a = 364;
        localparam base_b = 728;
        localparam p = i/2;
        localparam q = (i % 2) ? p : p - 1;
     
        if (0 == i) begin: zero_id_trit

            always @* begin
                state_trits  = state;
                trit_a_vec[i]   = state_trits[base_a - p];
                trit_b_vec[i]   = state_trits[0];
            end

        end else begin: other_nonzero_id_trits

            always @* begin
                state_trits  = state;
                trit_a_vec[i]   = state_trits[base_a - p];
                trit_b_vec[i]   = state_trits[base_b - q];
            end

        end

    end

    for (i = 0; i < TRITS_IN_STATE; i++) begin: trits_reorder

        if (0 == (i % 2)) begin: even_trits

            always @* begin
                trit_1_vec[i] = trit_b_vec[i];
                trit_2_vec[i] = trit_a_vec[i];
            end

        end else begin: odd_trits

            always @* begin
                trit_1_vec[i] = trit_a_vec[i];
                trit_2_vec[i] = trit_b_vec[i];
            end

        end

    end

    for (i = 0; i < TRITS_IN_STATE; i++) begin: gen_new_trits

        always @* begin
            truth_table_sel_vec[i] = $signed(trit_1_vec[i]) + $signed(trit_2_vec[i]) * 4'sd3 + 4'sd4;
        end

        truth_table tt_inst(.truth_table_sel(truth_table_sel_vec[i]), 
                            .truth_table_trit(truth_table_trit_vec[i])
                            );

        always @* begin
            state_new_trits[i] = truth_table_trit_vec[i];
        end

    end

endgenerate

always @* 
    state_new = state_new_trits;

endmodule
					
