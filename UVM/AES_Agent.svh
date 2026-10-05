//-----------------------------------------------------------------------------
// AES_Agent.svh
//-----------------------------------------------------------------------------

`ifndef AES_AGENT_SVH
`define AES_AGENT_SVH

class AES_Agent extends uvm_agent;

    `uvm_component_utils(AES_Agent)

    AES_Driver     drv_h  ; // Driver handle
    AES_Monitor    mon_h  ; // Monitor handle
    AES_sqr        sqr_h  ; // Sequence handle
    AES_CFG        cfg_h  ; // Configuration handle

    uvm_analysis_port #(AES_seq_item) agt_ap ; // Analysis port 
    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_Agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //-----------------------------------------------------------------------------
    // Build Phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt_ap = new("agt_ap", this);

        // Create the configuration object
        cfg_h = AES_CFG::type_id::create("cfg_h");

        if(!uvm_config_db#(AES_CFG)::get(this, "", "AES_Config", cfg_h))
            begin
                `uvm_fatal(get_type_name(), "Virtual interface not found")
            end

        mon_h = AES_Monitor::type_id::create("mon_h", this);
        sqr_h = AES_sqr::type_id::create("sqr_h", this);
        
        if(cfg_h.is_active == UVM_ACTIVE)
            begin
                drv_h = AES_Driver::type_id::create("drv_h", this);
            end 
    endfunction

    //-----------------------------------------------------------------------------
    // Connect Phase
    //-----------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if(cfg_h.is_active == UVM_ACTIVE)
            begin
                drv_h.seq_item_port.connect(sqr_h.seq_item_export);
                drv_h.Vif = cfg_h.AES_VIF;
            end

        mon_h.Vif = cfg_h.AES_VIF;
        mon_h.mon_ap.connect(agt_ap);

    endfunction
endclass

`endif // AES_AGENT_SVH