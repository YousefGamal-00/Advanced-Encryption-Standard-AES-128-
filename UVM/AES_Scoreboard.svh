//-----------------------------------------------------------------------------
// AES_Scoreboard.svh
//-----------------------------------------------------------------------------

`ifndef AES_SCOREBOARD_SVH
`define AES_SCOREBOARD_SVH

class AES_Scoreboard extends uvm_scoreboard;

    `uvm_component_utils(AES_Scoreboard)

    uvm_analysis_imp #(AES_seq_item, AES_Scoreboard) sb_imp ; // Analysis implementation

    bit end_sim ; // Flag to indicate the end of simulation

    int match_count    ; // Count of matching outputs
    int mismatch_count ; // Count of mismatching outputs
    //-----------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------
    function new(string name = "AES_Scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //-----------------------------------------------------------------------------
    // Build Phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_imp = new("sb_imp", this);
    endfunction

    //-----------------------------------------------------------------------------
    // Write method for the analysis implementation
    //-----------------------------------------------------------------------------
    function void write (AES_seq_item item);
        if(!item.reset)
            begin                
                if (item.cipher_text == 0 && item.valid_out == 0)
                    begin
                        match_count++ ;
                        `uvm_info(get_type_name(), $sformatf("Reset is asserted, cipher_text=%h, valid_out=%0b", item.cipher_text, item.valid_out), UVM_HIGH)
                    end                              
                else
                    begin
                        mismatch_count++ ;
                        `uvm_error(get_type_name(), $sformatf("Error in reset"))
                    end    
            end
        else if (item.valid_out)
            begin
                compare(item);        
            end
        else
            begin
                match_count++ ;
                `uvm_info(get_type_name(), $sformatf("No valid output, cipher_text=%h, valid_out=%0b", item.cipher_text, item.valid_out), UVM_HIGH)
            end

    endfunction

    //-----------------------------------------------------------------------------
    // comapre method to compare the expected and actual outputs
    //-----------------------------------------------------------------------------
    function void compare(AES_seq_item item);
    
        bit [127:0]  exp_out  ; // Expected output from the Python reference model
        AES_seq_item exp_item ; // Expected item to compare with the actual item
        int          fd       ; // File descriptor for I/O operations
        int          rc       ; // Exit code of the Python reference model
        string       cmd      ; // Shell command used to launch the reference model

        exp_item = new() ; // Create a new expected item

        fd = $fopen("../Py_Model/key.txt", "w");                        // Open file "key.txt" for writing
        if (fd == 0)
            begin
                `uvm_fatal(get_type_name(), "Cannot open ../Py_Model/key.txt for writing")
            end

        $fdisplay(fd, "%h \n%h", item.plain_text, item.cipher_key);    // Write data on first line and key on second line
        $fclose(fd);                                                    // Close "key.txt"

        // Run Python code and interact with scoreboard through I/O files
        // cmd = "python ../Py_Model/REF_MODEL.py";
        cmd = {"cd ../Py_Model && python REF_MODEL.py"};
        rc  = $system(cmd);

        // A failed run leaves the input in key.txt, which would be misread as the expected output
        if (rc != 0)
            begin
                `uvm_fatal(get_type_name(), $sformatf("Reference model failed (exit code %0d): %s", rc, cmd))
            end

        fd = $fopen("../Py_Model/Ref_Data.txt", "r");               // Open file "Ref_Data.txt" for reading
        if (fd == 0)
            begin
                `uvm_fatal(get_type_name(), "Cannot open ../Py_Model/Ref_Data.txt for reading")
            end

        $fscanf(fd, "%h", exp_out);                            // Read Python's expected output from "output.txt"
        $fclose(fd);                                           // Close "output.txt"

        exp_item.cipher_text = exp_out ; // Assign the expected output to the expected item

        if (exp_item.compare(item)) // Compare the expected item with the actual item
            begin
                `uvm_info(get_type_name(), $sformatf("SUCCESS, RTL.Cipher_Text IS %h and Py.Cipher_Text IS %h", item.cipher_text, exp_out), UVM_HIGH)
                match_count++ ;
            end                              
        else
            begin
                `uvm_error(get_type_name(), $sformatf("FAILURE, RTL.Cipher_Text IS %h and Py.Cipher_Text IS %h", item.cipher_text, exp_out))
                mismatch_count++ ;
                // $stop;
            end    
    endfunction

    //-----------------------------------------------------------------------------
    // Phase ready to end
    //-----------------------------------------------------------------------------
    function void phase_ready_to_end(uvm_phase phase);
        super.phase_ready_to_end(phase);

        if(phase.is(uvm_run_phase::get))
            if (!end_sim)
            begin
                phase.raise_objection(this);
                fork
                    begin
                        wait_for_end_sim();
                        phase.drop_objection(this);
                    end
                join_none 
            end
    endfunction

    //-----------------------------------------------------------------------------
    // wait_for_end_sim method to wait for the end of simulation
    //-----------------------------------------------------------------------------
    task wait_for_end_sim();
        wait (match_count + mismatch_count == NUM_TESTS); 
        end_sim = 1;
    endtask
    //-----------------------------------------------------------------------------
    // Report Phase
    //-----------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Total Matches: %0d || Total Mismatches: %0d", match_count, mismatch_count), UVM_LOW)
    endfunction
endclass

`endif // AES_SCOREBOARD_SVH