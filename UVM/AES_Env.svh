//-----------------------------------------------------------------------------
// AES_Env.svh
//-----------------------------------------------------------------------------

`ifndef AES_ENV_SVH
`define AES_ENV_SVH

class AES_Env extends uvm_env ;

    `uvm_component_utils(AES_Env)

    AES_Agent      agt_h  ; // Agent handle
    AES_Scoreboard sb_h   ; // Scoreboard handle
    AES_CVG        cvg_h  ; // Coverage handle
    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_Env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //-----------------------------------------------------------------------------
    // Build Phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agt_h = AES_Agent::type_id::create("agt_h", this);
        sb_h  = AES_Scoreboard::type_id::create("sb_h", this);
        cvg_h = AES_CVG::type_id::create("cvg_h", this);
    endfunction

    //-----------------------------------------------------------------------------
    // Connect Phase
    //-----------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agt_h.agt_ap.connect(sb_h.sb_imp);
        agt_h.agt_ap.connect(cvg_h.sub_imp);
    endfunction
endclass

`endif // AES_ENV_SVH