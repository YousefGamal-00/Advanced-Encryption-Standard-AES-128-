//-----------------------------------------------------------------------------
// AES_Driver.svh
//-----------------------------------------------------------------------------
`ifndef AES_DRIVER_SVH
`define AES_DRIVER_SVH

class AES_Driver extends uvm_driver #(AES_seq_item);

    `uvm_component_utils(AES_Driver)

    AES_VIF_t    Vif  ;     // Virtual interface handle
    AES_seq_item seq_item ; // Sequence item handle

    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_Driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //-----------------------------------------------------------------------------
    // Build Phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq_item = AES_seq_item::type_id::create("seq_item");
    endfunction

    //-----------------------------------------------------------------------------
    // Run Phase
    //-----------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever 
            begin
                // Get the next sequence item
                seq_item_port.get_next_item(seq_item);

                // Drive the interface signals based on the sequence item
                @(Vif.cb_drv); 
                Vif.cb_drv.reset      <= seq_item.reset;
                Vif.cb_drv.valid_in   <= seq_item.valid_in;
                Vif.cb_drv.plain_text <= seq_item.plain_text;
                Vif.cb_drv.cipher_key <= seq_item.cipher_key;

                // Indicate that the sequence item has been processed
                seq_item_port.item_done();
            end
    endtask
endclass
`endif // AES_DRIVER_SVH
