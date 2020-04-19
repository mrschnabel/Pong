module control_tb();

  reg clk,CLRN;			// system clock and asynch active low reset
  reg OVER;				// game over
  reg START,BtnL,BtnR;	// push button inputs
  reg DIR;				// direction of shift reg
  reg ATL,ATR;			// when at end of shift reg
  reg TICK;				// indicates next step of game
  reg error;
  
  wire LD,SHL,SHR;		// shift reg controls
  wire CLRPT,PTL,PTR;	// score controls
  wire MAXTIME,SETTIME;	// timer controls
  wire [5:0] state;

  typedef enum reg[5:0] {INIT=6'h01, MOVE_R=6'h02, END_R=6'h04, MOVE_L=6'h08,
                         END_L=6'h10, DONE=6'h20} state_t;
					 
  state_t state_chk;

  assign state_chk = state_t'(state);  
						   
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  control iDUT(.CLK(clk), .CLRN(CLRN), .OVER(OVER), .START(START), .DIR(DIR),
               .TICK(TICK), .ATL(ATL), .ATR(ATR), .BtnL(BtnL), .BtnR(BtnR),
			   .state(state), .LD(LD), .SHL(SHL), .SHR(SHR), .CLRPT(CLRPT),
			   .PTL(PTL), .PTR(PTR), .MAXTIME(MAXTIME), .SETTIME(SETTIME));
			   
  initial begin
    error = 0;		// innocent till proven guilty
    clk = 0;
	CLRN = 0;
	OVER = 0;
	START = 0;
	BtnL = 0;
	BtnR = 0;
	DIR = 0;
	ATL = 0;
	ATR = 0;
	TICK = 0;
	
	@(posedge clk);
	@(negedge clk);
	CLRN = 1;		// deassert reset
	if (state_chk!==INIT) begin
	  $display("ERR: state should be INIT when out of reset");
	  error = 1;
	end
	
	////////////////////////////////////////////////////
	// At first we will just check state transitions //
	//////////////////////////////////////////////////
	@(negedge clk);
	if (state_chk!==INIT) begin
	  $display("ERR: at time %t state should still be INIT",$time);
	  error = 1;
	end	else $display("Check 1 passed");
	
	START = 1;
	@(negedge clk);
	if (state_chk!==MOVE_L) begin
	  $display("ERR: at time %t state should be MOVE_L",$time);
	  error = 1;
	end	else $display("Check 2 passed");
	@(negedge clk);
	if (state_chk!==MOVE_L) begin
	  $display("ERR: at time %t state should still be MOVE_L",$time);
	  error = 1;
	end	else $display("Check 3 passed");	
	
	ATL = 1;
	START = 0;
	@(negedge clk);
	if (state_chk!==END_L) begin
	  $display("ERR: at time %t state should be END_L",$time);
	  error = 1;
	end	else $display("Check 4 passed");
	
	ATL = 0;
	@(negedge clk);
	if (state_chk!==END_L) begin
	  $display("ERR: at time %t state should still be END_L",$time);
	  error = 1;
	end	else $display("Check 5 passed");
	
	BtnL = 1;
	@(negedge clk);
	if (state_chk!==MOVE_R) begin
	  $display("ERR: at time %t state should be MOVE_R",$time);
	  error = 1;
	end	else $display("Check 6 passed");
	
	BtnL = 0;
	@(negedge clk);
	if (state_chk!==MOVE_R) begin
	  $display("ERR: at time %t state should still be MOVE_R",$time);
	  error = 1;
	end	else $display("Check 7 passed");
	
	ATR = 1;
	@(negedge clk);
	if (state_chk!==END_R) begin
	  $display("ERR: at time %t state should be END_R",$time);
	  error = 1;
	end	else $display("Check 8 passed");
	
	ATR = 0;
	@(negedge clk);
	if (state_chk!==END_R) begin
	  $display("ERR: at time %t state should still be END_R",$time);
	  error = 1;
	end	else $display("Check 9 passed");
	
	TICK = 1;
	@(negedge clk);
	if (state_chk!==MOVE_L) begin
	  $display("ERR: at time %t state should be MOVE_L",$time);
	  error = 1;
	end	else $display("Check 10 passed");
	
	TICK = 0;
	OVER = 1;
	@(negedge clk);
	if (state_chk!==DONE) begin
	  $display("ERR: at time %t state should be DONE",$time);
	  error = 1;
	end	else $display("Check 11 passed");
	
	OVER = 0;
	@(negedge clk);
	if (state_chk!==DONE) begin
	  $display("ERR: at time %t state should still be DONE",$time);
	  error = 1;
	end	else $display("Check 12 passed");
	
	START = 1;
	DIR = 1;
	@(negedge clk);
	if (state_chk!==MOVE_R) begin
	  $display("ERR: at time %t state should be MOVE_R",$time);
	  error = 1;
	end	else $display("Check 13 passed");
	
	OVER = 1;
	START = 0;
	@(negedge clk);
	if (state_chk!==DONE) begin
	  $display("ERR: at time %t state should be DONE",$time);
	  error = 1;
	end	else $display("Check 14 passed");

    OVER = 0;
	START = 1;
	DIR = 0;
	@(negedge clk);
	if (state_chk!==MOVE_L) begin
	  $display("ERR: at time %t state should be MOVE_L",$time);
	  error = 1;
	end	else $display("Check 15 passed");
	
	START = 0;
	ATL = 1;
	@(negedge clk);
	if (state_chk!==END_L) begin
	  $display("ERR: at time %t state should be END_L",$time);
	  error = 1;
	end	else $display("Check 16 passed");
	
	TICK = 1;
	ATL = 0;
	@(negedge clk);
	if (state_chk!==MOVE_R) begin
	  $display("ERR: at time %t state should be MOVE_R",$time);
	  error = 1;
	end	else $display("Check 17 passed");
	
	TICK = 0;
	
	if (!error) begin
	  $display("EXCELLENT!!! you are passing state transitions test!!!");
	  $display("Will test SM outputs next...");
	end else begin
	  $display("Bummer!!! you are failing state transitions test.");
	  $display("Fix state transitions before continuing");
	  $stop();
	end
	
	CLRN = 0;
	@(negedge clk);
	if (state_chk!==INIT) begin
	  $display("ERR: state should be INIT when out of reset");
	  error = 1;
	end
	
	CLRN = 1;
	DIR = 1;
	#1;
	if ((MAXTIME!==1) || (CLRPT!==1)) begin
	  $display("ERR: at time %t MAXTIME & CLRPT should be asserted",$time);
	  error = 1;
	end
	#1;
	START = 1;
	#1;
	if (LD!==1) begin
	  $display("ERR: at time %t LD should be asserted",$time);
	  error = 1;
	end
	if (!error) $display("GOOD: outputs for INIT seem OK");
	
	@(negedge clk);
	START = 0;
	DIR = 0;
	#1;
	if (PTL | SHR) begin
	  $display("ERR: at time %t neither PTL or SHR should be asserted",$time);
	  error = 1;
	end
	#1;
	TICK = 1;
	#1;
	if (!SHR) begin
	  $display("ERR: at time %t SHR should be asserted",$time);
	  error = 1;
	end
	BtnR = 1;
	#1;
	if (!PTL) begin
	  $display("ERR: at time %t PTL should be asserted",$time);
	  error = 1;
	end
	if (!error) $display("GOOD: outputs for MOVE_R seem OK");
	OVER = 1;
	
	@(negedge clk);
	TICK = 0;
	BtnR = 0;
	OVER = 0;
	#1;
	if (!MAXTIME) begin
	  $display("ERR: at time %t MAXTIME should be asserted",$time);
	  error = 1;
	end
	if (LD | CLRPT) begin
	  $display("ERR: at time %t neither LD or CLRPT should be asserted",$time);
	  error = 1;
	end
	#1;
	START = 1;
	#1;
	if ((LD==0) || (CLRPT==0)) begin
	  $display("ERR: at time %t both LD and CLRPT should be asserted",$time);
	  error = 1;
	end
	if (!error) $display("GOOD: outputs for DONE seem OK");

	@(negedge clk);
	START = 0;
	#1;
	if (PTR | SHL) begin
	  $display("ERR: at time %t neither PTR or SHL should be asserted",$time);
	  error = 1;
	end
	#1;
	TICK = 1;
	#1;
	if (!SHL) begin
	  $display("ERR: at time %t SHL should be asserted",$time);
	  error = 1;
	end
	BtnL = 1;
	#1;
	if (!PTR) begin
	  $display("ERR: at time %t PTR should be asserted",$time);
	  error = 1;
	end
	if (!error) $display("GOOD: outputs for MOVE_L seem OK");
	ATL = 1;	
	
	@(negedge clk);
	BtnL = 0;
    TICK = 0;
    ATL = 0;
    #1;	
	if (MAXTIME | SETTIME |PTR) begin
	  $display("ERR: at time %t no outputs should be asserted",$time);
	  error = 1;
	end
	#1;
	BtnL = 1;
	#1;
	if (!SETTIME) begin
	  $display("ERR: at time %t SETTIME should be asserted",$time);
	  error = 1;
	end
	#1;
	BtnL = 0;
	TICK = 1;
	#1;
	if ((MAXTIME==0) || (PTR==0)) begin
	  $display("ERR: at time %t MAXTIME and PTR should be asserted",$time);
	  error = 1;
	end
	if (!error) begin
	  $display("GOOD: outputs for END_L seem OK");
	  $display("      only END_R remains unchecked, is it symmetric but opposite of END_L?");
	end
    TICK = 0;	
	
	
	if (!error) begin
	  $display("EXCELLENT!!! state outputs look good too");
	  $display("YAHOO!! test of control passed!");
	end
	$stop();
	
  end
  
  always
    #10 clk = ~clk;
	
endmodule