`ifndef AES_SEQUENCE_SVH
`define AES_SEQUENCE_SVH

class AES_seq extends uvm_sequence ;

    `uvm_object_utils(AES_seq)
    
    AES_seq_item seq_item ; // Sequence item handle

    //-----------------------------------------------------------------------------
    // constractor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_seq");
        super.new(name);
    endfunction

    //-----------------------------------------------------------------------------
    // Body
    //-----------------------------------------------------------------------------
    task body ();

        seq_item = AES_seq_item::type_id::create("seq_item");  // Create a sequence item object
 
        start_item(seq_item);             // start the sequence item
            seq_item.reset      = 1'b0 ; 
            seq_item.valid_in   = 1'b0 ; 
            seq_item.plain_text = 'b0  ; 
            seq_item.cipher_key = 'b0  ; 
        finish_item(seq_item);            // finish the sequence item 

            repeat(NUM_TESTS - 1) 
                begin
                    start_item(seq_item);
                    
                    assert (seq_item.randomize())
                    else 
                        begin
                            `uvm_fatal(get_type_name(), "Randomization failed")
                        end
                    
                    finish_item(seq_item);
                end
    endtask

endclass

`endif // AES_SEQUENCE_SVH