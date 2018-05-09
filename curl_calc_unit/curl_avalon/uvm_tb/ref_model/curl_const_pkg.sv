`ifndef CURL_CONST_PKG_SV
`define CURL_CONST_PKG_SV

package curl_const_pkg;

    parameter int HASH_LENGTH = 243;
    parameter int STATE_LENGTH = 3 * HASH_LENGTH;
    parameter int NUMBER_OF_ROUNDS = 81;

endpackage: curl_const_pkg

`endif // CURL_CONST_PKG_SV




