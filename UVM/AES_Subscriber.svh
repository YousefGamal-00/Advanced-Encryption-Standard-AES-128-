//-----------------------------------------------------------------------
// AES_Subscriber.svh
//-----------------------------------------------------------------------

`ifndef AES_SUBSCRIBER_SVH
`define AES_SUBSCRIBER_SVH

class AES_CVG extends uvm_component;

    `uvm_component_utils(AES_CVG)

    AES_seq_item                              item    ; // Sequence item handle
    uvm_analysis_imp #(AES_seq_item, AES_CVG) sub_imp ; // Analysis implementation
    

    //-----------------------------------------------------------------------------
    // covergroup 
    //-----------------------------------------------------------------------------
    covergroup cg ;
    
        Reset_cp : coverpoint item.reset 
        {
            bins reset_0 = {0} ;
            bins reset_1 = {1} ;
        }

        valid_in_cp : coverpoint item.valid_in 
        {
            bins valid_in_0 = {0} ;
            bins valid_in_1 = {1} ;
        }

        valid_out_cp : coverpoint item.valid_out 
        {
            bins valid_out_0 = {0} ;
            bins valid_out_1 = {1} ;
        }   

        cipher_text_cp : coverpoint item.cipher_text
        {
            bins cipher_data_0 = {[(128'd1 << 0)   : (128'd1 << 21)  - 1]};
            bins cipher_data_1 = {[(128'd1 << 21)  : (128'd1 << 43)  - 1]};
            bins cipher_data_2 = {[(128'd1 << 43)  : (128'd1 << 64)  - 1]};
            bins cipher_data_3 = {[(128'd1 << 64)  : (128'd1 << 85)  - 1]};
            bins cipher_data_4 = {[(128'd1 << 85)  : (128'd1 << 107) - 1]};
            bins cipher_data_5 = {[(128'd1 << 107) : 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF]};
        }

        cross_Reset_valid_in_cp : cross Reset_cp, valid_in_cp 
        {
            ignore_bins reset_0_valid_in_1 = binsof(Reset_cp) intersect {0} && binsof(valid_in_cp) intersect {1} ;
        }

        cross_Valid_out_cipher_text_cp : cross valid_out_cp, cipher_text_cp 
        {
            ignore_bins valid_out_0_cipher_data = binsof(valid_out_cp) intersect {0} && binsof(cipher_text_cp) ;
        }
    endgroup
    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_CVG", uvm_component parent = null);
        super.new(name, parent);
        cg = new() ;
    endfunction

    //-----------------------------------------------------------------------------
    // Build Phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sub_imp = new("sub_imp", this);
    endfunction
    //-----------------------------------------------------------------------------
    // Write method for analysis imp
    //-----------------------------------------------------------------------------
    function void write(AES_seq_item item);
        $cast(this.item, item.clone()) ; // Clone the item to avoid any side effects
        cg.sample() ;
    endfunction

endclass

`endif // AES_SUBSCRIBER_SVH