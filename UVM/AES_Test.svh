//-----------------------------------------------------------------------------
// AES_Test.svh
//-----------------------------------------------------------------------------

`ifndef AES_TEST_SVH
`define AES_TEST_SVH

class AES_Test extends uvm_test;

    `uvm_component_utils(AES_Test)

    AES_seq    seq_h ; // Sequence handle
    AES_Env    env_h ; // Environment handle
    AES_CFG    cfg_h ; // Configuration handle
    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_Test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //-----------------------------------------------------------------------------
    // Build Phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg_h = AES_CFG::type_id::create("cfg_h", this);

        // Set the virtual interface and agent type in the configuration object
        if(!uvm_config_db#(AES_VIF_t)::get(this, "", "AES_VIF", cfg_h.AES_VIF))
            begin
                `uvm_fatal(get_type_name(), "Virtual interface not found")
            end

        cfg_h.is_active = UVM_ACTIVE; // Set the agent type to active
        uvm_config_db#(AES_CFG)::set(this, "env_h.agt_h", "AES_Config", cfg_h);

        seq_h = AES_seq::type_id::create("seq_h");
        env_h = AES_Env::type_id::create("env_h", this);
    endfunction

    //-----------------------------------------------------------------------------
    // Run Phase
    //-----------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
            seq_h.start(env_h.agt_h.sqr_h);
        phase.drop_objection(this);
    
    endtask
endclass
`endif // AES_TEST_SVH