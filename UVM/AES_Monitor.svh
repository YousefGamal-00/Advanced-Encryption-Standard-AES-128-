//-----------------------------------------------------------------------------
// AES_Monitor.svh
//-----------------------------------------------------------------------------

`ifndef AES_MONITOR_SVH
`define AES_MONITOR_SVH

class AES_Monitor extends uvm_monitor;

    `uvm_component_utils(AES_Monitor)

    AES_VIF_t     Vif ; // Virtual interface handle
    AES_seq_item  seq_item; // Sequence item handle

    uvm_analysis_port #(AES_seq_item) mon_ap ;
    //-----------------------------------------------------------------------------
    // constractor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_Monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //-----------------------------------------------------------------------------
    // Build Phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);
    endfunction

    //-----------------------------------------------------------------------------
    // Run Phase
    //-----------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        @(Vif.cb_mon) ; // Skipp the first clock edge to avoid sampling uninitialized signals

        forever 
            begin
                seq_item = AES_seq_item::type_id::create("seq_item");
                
                @(Vif.cb_mon);

                seq_item.reset       <= Vif.cb_mon.reset;
                seq_item.valid_in    <= Vif.cb_mon.valid_in;
                seq_item.plain_text  <= Vif.cb_mon.plain_text;
                seq_item.cipher_key  <= Vif.cb_mon.cipher_key;
                seq_item.cipher_text <= Vif.cb_mon.cipher_text;
                seq_item.valid_out   <= Vif.cb_mon.valid_out;


                // Wait for the non-blocking assignments above to take effect
                #1step;

                // Print the sequence item information
                `uvm_info(get_type_name(), $sformatf("%s", seq_item.convert2string()), UVM_HIGH)

                // Send the sequence item to the analysis port
                mon_ap.write(seq_item);
            end
    endtask
endclass

`endif // AES_MONITOR_SVH