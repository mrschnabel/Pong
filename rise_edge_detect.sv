module rise_edge_detect(
  input clk,			// hook to CLK of flops
  input rst_n,			// hook to PRN
  input sig,			// signal we are detecting a rising edge on
  output sig_rise		// high for 1 clock cycle on rise of sig
);

	//////////////////////////////////////////
	// Declare any needed internal signals //
	////////////////////////////////////////

	logic sig_rise1;
	logic sig_rise2;
	logic sig_rise3;
	logic not_sig_rise3;
	
	
	///////////////////////////////////////////////////////
	// Instantiate flops to synchronize and edge detect //
	/////////////////////////////////////////////////////
	
	d_ff idff1(.CLK(clk),.D(sig),.CLRN(1'b1),.PRN(rst_n),.Q(sig_rise1));
	d_ff idff2(.CLK(clk),.D(sig_rise1),.CLRN(1'b1),.PRN(rst_n),.Q(sig_rise2));
	d_ff idff3(.CLK(clk),.D(sig_rise2),.CLRN(1'b1),.PRN(rst_n),.Q(sig_rise3));
	
  
	//////////////////////////////////////////////////////////
	// Infer any needed logic (data flow) to form sig_rise //
	////////////////////////////////////////////////////////
	
	not not1(not_sig_rise3,sig_rise3);
	and and1(sig_rise,not_sig_rise3,sig_rise2);
endmodule