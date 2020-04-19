///////////////////////////////////////////////////
// FA.sv  This design will take in 3 bits       //
// and add them to produce a sum and carry out //
////////////////////////////////////////////////
module FA(
  input 	A,B,Cin,	// three input bits to be added
  output	S,Cout		// Sum and carry out
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic half_sum, a_and_b, Cin_and_half;
	
	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	xor iXOR1(half_sum,A,B);
	and iAND1(a_and_b,A,B);
	and iAND2(Cin_and_half,half_sum,Cin);
	xor iXOR2(S,half_sum,Cin);
	or  iOR1(Cout,a_and_b,Cin_and_half);
	
endmodule