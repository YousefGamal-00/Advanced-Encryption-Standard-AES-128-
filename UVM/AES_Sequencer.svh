//-----------------------------------------------------------------------------
// AES_sequencer.svh
//-----------------------------------------------------------------------------

`ifndef AES_SEQUENCER_SVH
`define AES_SEQUENCER_SVH

class AES_sqr extends uvm_sequencer #(AES_seq_item);

    `uvm_component_utils(AES_sqr)

    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_sqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

`endif // AES_SEQUENCER_SVH