//-----------------------------------------------------------------------------
// AES_seq_item.svh
//-----------------------------------------------------------------------------
`ifndef AES_SEQ_ITEM
`define AES_SEQ_ITEM

class AES_seq_item extends uvm_sequence_item;

    `uvm_object_utils(AES_seq_item)

    //-----------------------------------------------------------------------------
    // AES Sequence Item Data Members
    //-----------------------------------------------------------------------------
    rand  logic                   reset      ; // Active-low asynchronous reset
	rand  logic                   valid_in   ; // Asserted to launch a new encryption
	rand  logic [127:0]           plain_text ; // 128-bit plaintext input block
	rand  logic [KEY_WIDTH-1:0]   cipher_key ; // Encryption key (width = KEY_WIDTH)
	
    logic                   valid_out   ; // Pulses high for 1 cycle when done
	logic [127:0]           cipher_text ; // 128-bit ciphertext output block

    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_seq_item");
        super.new(name);
    endfunction

    //-----------------------------------------------------------------------------
    // Randomization Constraints
    //-----------------------------------------------------------------------------
    constraint c_rst 
    {
        reset dist {0:=5, 1:=95};
    }

    constraint c_valid_in
    {
        valid_in dist {0:=20, 1:=80};
    }

    //-----------------------------------------------------------------------------
    // do copy method to copy the data members from another AES_seq_item
    //-----------------------------------------------------------------------------
    function void do_copy(uvm_object rhs);
        
        AES_seq_item rhs_;

        if (!$cast(rhs_, rhs))
            begin
                `uvm_fatal(get_type_name(), "Object passed to do_copy is not of type AES_seq_item");
            end
        
        super.do_copy(rhs);

        this.reset       = rhs_.reset;
        this.valid_in    = rhs_.valid_in;
        this.plain_text  = rhs_.plain_text;
        this.cipher_key  = rhs_.cipher_key;
        this.cipher_text = rhs_.cipher_text;
        this.valid_out   = rhs_.valid_out;

    endfunction

    //-----------------------------------------------------------------------------
    // do compare method to compare the expected and actual outputs
    //-----------------------------------------------------------------------------
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);

        AES_seq_item rhs_;
        
        if (!$cast(rhs_, rhs))
            begin
                return 0; 
            end
        return
        (
            (super.do_compare(rhs, comparer)) &&
            (this.cipher_text == rhs_.cipher_text)
        ); 
    endfunction

    //-----------------------------------------------------------------------------
    // convert2string method
    //-----------------------------------------------------------------------------
    function string convert2string();
    
    string s ; 

    s = super.convert2string();

    $sformatf(s, "%s \n reset=%0b | valid_in=%0b | plain_text=%h | cipher_key=%h | valid_out=%0b | cipher_text=%h", 
                    s, 
                    reset, 
                    valid_in, 
                    plain_text, 
                    cipher_key, 
                    valid_out, 
                    cipher_text);

        return s;
    endfunction
endclass

`endif //AES_SEQ_ITEM