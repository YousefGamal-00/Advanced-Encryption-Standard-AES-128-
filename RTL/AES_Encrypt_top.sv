module AES_Encrypt_top #(parameter KEY_WIDTH = 128)
(
	input  logic                   clk       , // System clock
	input  logic                   reset     , // Active-low asynchronous reset
	input  logic                   valid_in  , // Asserted to launch a new encryption
	input  logic [127:0]           plain_text, // 128-bit plaintext input block
	input  logic [KEY_WIDTH-1:0]   cipher_key, // Encryption key (width = KEY_WIDTH)

	output logic                   valid_out , // High 1 cycle per transaction (stays high if back-to-back)
	output logic [127:0]           cipher_text // 128-bit ciphertext output block (live in DONE, held otherwise)
);

	//-----------------------------------------------------------------------------
	// Derived parameters (AES-128 / AES-192 / AES-256)
	//-----------------------------------------------------------------------------
	localparam int NK = KEY_WIDTH / 32;
	localparam int NR = (KEY_WIDTH == 128) ? 10 :
	                    (KEY_WIDTH == 192) ? 12 :
	                    (KEY_WIDTH == 256) ? 14 : 0;

	initial
		begin
			if (NR == 0)
				begin
					$fatal(1, "AES_Encrypt_top: unsupported KEY_WIDTH=%0d (must be 128, 192, or 256)", KEY_WIDTH);
				end
		end

	//-----------------------------------------------------------------------------
	// internal signals
	//-----------------------------------------------------------------------------
	typedef enum logic {S_IDLE, S_DONE} state_e;

	state_e              state_reg , state_next;
	logic  [127:0]       cipher_text_reg;
	logic  [127:0]       core_cipher_text;

	//--------------------------------------------------------------------------
	// AES Combinational Core
	//--------------------------------------------------------------------------
	AES_Encrypt #(.N(KEY_WIDTH), .Nr(NR), .Nk(NK)) u_aes_core 
	(
		.in  (plain_text       ),
		.key (cipher_key       ),
		.out (core_cipher_text )
	);

	//--------------------------------------------------------------------------
	// Handshake FSM - State Register
	//--------------------------------------------------------------------------
	always_ff @(posedge clk or negedge reset)
		begin
			if (!reset)
				begin
					state_reg       <= S_IDLE;
					cipher_text_reg <= '0;
				end
			else
				begin
					state_reg <= state_next;

					if (valid_in)
						begin
							cipher_text_reg <= core_cipher_text; /* latch result on every accepted transaction so the value holds once DONE is left */
						end
				end
		end

	//--------------------------------------------------------------------------
	// Handshake FSM - Next-State Logic
	//--------------------------------------------------------------------------
	always_comb
		begin
			case (state_reg)
				S_IDLE :
					begin
						if (valid_in)
							state_next = S_DONE; /* accept new transaction */
						else
							state_next = S_IDLE;
					end
				S_DONE :
					begin
						if (valid_in)
							state_next = S_DONE; /* back-to-back transaction: stay in DONE, no idle bubble */
						else
							state_next = S_IDLE;
					end
				default: state_next = S_IDLE;
			endcase
		end

	//--------------------------------------------------------------------------
	// Output Assignments
	//--------------------------------------------------------------------------
	assign valid_out   = (state_reg == S_DONE);
	assign cipher_text = (state_reg == S_DONE) ? core_cipher_text : cipher_text_reg; /* DONE: follow new data combinationally, else hold last result */

endmodule