//------------------------------------------------------------------------------
// Author      : Yousef Gamal
// Module Name : AES_Encrypt
// Description :
//    - Fully combinational AES encryption core (128-bit data path).
//    - Instantiates key expansion, an initial AddRoundKey stage, (Nr-1)
//      full encryption rounds, and a final round (SubBytes, ShiftRows,
//      AddRoundKey - no MixColumns).
//    - FIX: the original ANSI-style port list used semicolons instead of
//      commas between port declarations, which is illegal Verilog syntax
//      and would fail to compile/elaborate. Corrected below; no functional
//      logic below the port list was changed.
//------------------------------------------------------------------------------
module AES_Encrypt #(parameter N = 128, Nr = 10, Nk = 4)
(
	input  wire [127:0] in , // 128-bit plaintext data block
	input  wire [N-1:0]  key, // Encryption key (width = N bits)
	output wire [127:0] out   // 128-bit ciphertext data block
);


	wire [(128*(Nr+1))-1:0] fullkeys;
	wire [127:0] states [Nr+1:0];

	wire [127:0] afterSubBytes;
	wire [127:0] afterShiftRows;

	//--------------------------------------------------------------------------
	// Key Expansion
	//--------------------------------------------------------------------------

	keyExpansion #(Nk, Nr) ke (
		key,
		fullkeys
	);

	//--------------------------------------------------------------------------
	// Initial AddRoundKey
	//--------------------------------------------------------------------------

	addRoundKey addrk1 (
		in,
		states[0],
		fullkeys[((128*(Nr+1))-1)-:128]
	);

	//--------------------------------------------------------------------------
	// AES Encryption Rounds
	//--------------------------------------------------------------------------

	genvar i;

	generate
		for (i = 1; i < Nr; i = i + 1) begin : loop

			encryptRound er (
				states[i-1],
				fullkeys[(((128*(Nr+1))-1)-128*i)-:128],
				states[i]
			);

		end

		//--------------------------------------------------------------------------
		// Final AES Round
		//--------------------------------------------------------------------------

		subBytes sb (
			states[Nr-1],
			afterSubBytes
		);

		shiftRows sr (
			afterSubBytes,
			afterShiftRows
		);

		addRoundKey addrk2 (
			afterShiftRows,
			states[Nr],
			fullkeys[127:0]
		);

		assign out = states[Nr];

	endgenerate

endmodule
