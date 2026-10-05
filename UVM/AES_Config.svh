//-----------------------------------------------------------------------------
// AES_config.svh
//-----------------------------------------------------------------------------
`ifndef AES_CONFIG
`define AES_CONFIG

class AES_CFG extends uvm_object ;

    `uvm_object_utils(AES_CFG)

    AES_VIF_t               AES_VIF   ; // Virtual interface handle
    uvm_active_passive_enum is_active ; // Active or Passive agent

    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_CFG");
        super.new(name);
    endfunction

endclass

`endif //AES_CONFIG