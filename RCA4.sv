///////////////////////////////////////////////////////
// RCA4.sv  This design will add two 4-bit vectors  //
// plus a carry in to produce a sum and a carry out//
////////////////////////////////////////////////////
module RCA4(
  input 	[3:0]	A,B,	// two 4-bit vectors to be added
  input 			Cin,	// An optional carry in bit
  output 	[3:0]	S,		// 4-bit Sum
  output 			Cout  	// and carry out
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic C1,C2,C3;
	
	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	FA iFA0(.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(C1));
	FA iFA1(.A(A[1]), .B(B[1]), .Cin(C1), .S(S[1]), .Cout(C2));
	FA iFA2(.A(A[2]), .B(B[2]), .Cin(C2), .S(S[2]), .Cout(C3));
	FA iFA3(.A(A[3]), .B(B[3]), .Cin(C3), .S(S[3]), .Cout(Cout));
	
endmodule