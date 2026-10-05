package AES_pkg ; 
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //-----------------------------------------------------------------------------
    // AES Parameters
    //-----------------------------------------------------------------------------
    localparam NUM_TESTS = 500;
    localparam KEY_WIDTH = 128;

    //-----------------------------------------------------------------------------
    // AES Interface type 
    //-----------------------------------------------------------------------------
    typedef virtual AES_IF #(.KEY_WIDTH(KEY_WIDTH)) AES_VIF_t;

    //------------------------------------------------------------------------------
	// Include all UVM class files
	//------------------------------------------------------------------------------

    `include"AES_Seq_item.svh"
    `include"AES_Config.svh"
    `include"AES_Driver.svh"
    `include"AES_Monitor.svh"
    `include"AES_Sequencer.svh"
    `include"AES_Agent.svh"
    `include"AES_Scoreboard.svh"
    `include"AES_Sequence.svh"
    `include"AES_Subscriber.svh"
    `include"AES_Env.svh"
    `include"AES_Test.svh"

endpackage