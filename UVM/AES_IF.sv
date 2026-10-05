interface AES_IF #(parameter KEY_WIDTH = 128)
(
	input logic clk         // System clock
);
    
    logic                   reset      ; // Active-low asynchronous reset
	logic                   valid_in   ; // Asserted to launch a new encryption
	logic [127:0]           plain_text ; // 128-bit plaintext input block
	logic [KEY_WIDTH-1:0]   cipher_key ; // Encryption key (width = KEY_WIDTH)
	
    logic                   valid_out   ; // Pulses high for 1 cycle when done
	logic [127:0]           cipher_text ; // 128-bit ciphertext output block


    //-----------------------------------------------------------------------------
    // Driver Clocking Block
    //-----------------------------------------------------------------------------
    clocking cb_drv @(posedge clk);
        default output #1step;
        output reset, valid_in, plain_text, cipher_key;
    endclocking 
    
    //-----------------------------------------------------------------------------
    // Monitor Clocking Block
    //-----------------------------------------------------------------------------
    clocking cb_mon @(posedge clk);
        default input #0 ;
        input reset, valid_in, plain_text, cipher_key, valid_out, cipher_text;
    endclocking 

endinterface

