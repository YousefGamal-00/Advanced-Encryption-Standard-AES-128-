`timescale 1ns/1ps

//-----------------------------------------------------------------------------
// Top-level TB for AES encryption
//-----------------------------------------------------------------------------

module top; 

    import AES_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    //-----------------------------------------------------------------------------
    // Clock Generation
    //-----------------------------------------------------------------------------
    bit clk;
    initial 
        begin
            forever #1 clk = ~clk;       
        end

    //-----------------------------------------------------------------------------
    // DUT & interface instantiation    
    //-----------------------------------------------------------------------------

    AES_IF #(.KEY_WIDTH(KEY_WIDTH)) AES_if (clk);

    AES_Encrypt_top #(.KEY_WIDTH(KEY_WIDTH)) DUT
    (
        .clk         (AES_if.clk        ),
        .reset       (AES_if.reset      ),
        .valid_in    (AES_if.valid_in   ),
        .plain_text  (AES_if.plain_text ),
        .cipher_key  (AES_if.cipher_key ),
        .valid_out   (AES_if.valid_out  ),
        .cipher_text (AES_if.cipher_text)
    );

    //-----------------------------------------------------------------------------
    // Run the UVM test
    //-----------------------------------------------------------------------------
    initial
        begin
            uvm_config_db#(AES_VIF_t)::set(null, "uvm_test_top", "AES_VIF", AES_if);
            run_test("");
        end
endmodule