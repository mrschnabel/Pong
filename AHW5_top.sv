module AHW5_top(clk,SW,KEY,LEDR,LEDG,HEX7,HEX6,HEX5,HEX4,HEX3,HEX2,HEX1,HEX0);

  input clk;				// 50MHz clock
  input [17:0] SW;			// slide switches
  input [3:0] KEY;			// push buttons
  output [7:0] LEDG;		// Green LEDs
  output [17:0] LEDR;		// Red LEDs
  output [6:0] HEX7,HEX6;	// used to display 2-digit BCD num
  output [6:0] HEX5,HEX4;	// have to drive off
  output [6:0] HEX3,HEX2;	// Po of Pong
  output [6:0] HEX1,HEX0;	// ng of Pong
  
  reg [25:0] CNT;			// counter to drive DUTY (upper 10-bits)
  
  //////////////////////////////////////////
  // Declare any needed internal signals //
  ////////////////////////////////////////
  wire dis;					// disable to bcd7seg driving "Pong"
  wire CLRPT;				// from control SM, clears player's points
  wire PTL,PTR;				// increment player's points (from control SM)
  wire [7:0] PTS_L,PTS_R;	// player's scores
  wire LD,SHL,SHR;			// shift register controls
  wire DIR;					// direction ball is traveling (1=>right)
  wire SETTIME,MAXTIME;		// timer controls
  wire TICK;				// timer expired
  wire OVER;				// from win detector
  wire START;				// from push button rise edge detector
  wire BtnL,BtnR;			// player buttons
  
  
  assign CLRN = SW[0];
  assign LEDG[7:6] = 2'b00;
				 
  /////////////////////////////////////////////////////////////
  // Instantiate rise edge detect as push button interfaces //
  ///////////////////////////////////////////////////////////
  rise_edge_detect iSTRT(.clk(clk), .rst_n(CLRN), .sig(KEY[1]), .sig_rise(START));
  rise_edge_detect iRGHT(.clk(clk), .rst_n(CLRN), .sig(KEY[0]), .sig_rise(BtnR));
  rise_edge_detect iLEFT(.clk(clk), .rst_n(CLRN), .sig(KEY[3]), .sig_rise(BtnL));
  
  //////////////////////////////////////////////////////////////////////
  // instantiate 2 copies of BCDcnt to keep track of player's scores //
  ////////////////////////////////////////////////////////////////////
  BCDcnt iPLY_L(.CLK(clk), .CLRN(CLRN), .CLR_CNT(CLRPT), .INC(PTL), .CNT(PTS_L));
  BCDcnt iPLY_R(.CLK(clk), .CLRN(CLRN), .CLR_CNT(CLRPT), .INC(PTR), .CNT(PTS_R));				  
					  
  ///////////////////////////////////////////////////////////////////
  // instantiate 4 copies of bcd7seg to drive left player's score //
  /////////////////////////////////////////////////////////////////
  bcd7seg iBCD7(.num(PTS_L[7:4]),.dis(1'b0),.seg(HEX7));	// left's upper digit
  bcd7seg iBCD6(.num(PTS_L[3:0]),.dis(1'b0),.seg(HEX6));
  bcd7seg iBCD5(.num(PTS_R[7:4]),.dis(1'b0),.seg(HEX5));	// right's upper digit
  bcd7seg iBCD4(.num(PTS_R[3:0]),.dis(1'b0),.seg(HEX4));
  
  ///////////////////////////////////////////////////////
  // Instantiate shift_reg that keeps track of "ball" //
  /////////////////////////////////////////////////////
  shift_reg iSHF(.CLK(clk), .CLRN(CLRN), .LOAD(LD), .SHL(SHL), .SHR(SHR),
                 .DIR(DIR), .Q(LEDR));
				  
  //////////////////////////////////////////////////////////////
  // Instantiate the variable TICK timer that paces the game //
  ////////////////////////////////////////////////////////////
  var_timer iTMR(.clk(clk), .reset(~CLRN), .SET(SETTIME), .MAX(MAXTIME), .TC(TICK));
  
  ///////////////////////////////////////////////////////////
  // Instantiate the win detector (monitors for score>12) //
  /////////////////////////////////////////////////////////
  win_det iSCR(.SCORE0(PTS_L), .SCORE1(PTS_R), .GAMEOVER(OVER));

  /////////////////////////////////
  // Instantiate the control SM //
  ///////////////////////////////
  control iSM(.CLK(clk), .CLRN(CLRN), .OVER(OVER), .START(START), .DIR(DIR),
              .TICK(TICK), .ATL(LEDR[17]), .ATR(LEDR[0]), .BtnL(BtnL), .BtnR(BtnR),
			  .state(LEDG[5:0]), .LD(LD), .SHL(SHL), .SHR(SHR), .CLRPT(CLRPT),
			  .PTL(PTL), .PTR(PTR), .MAXTIME(MAXTIME), .SETTIME(SETTIME));

  //////////////////////
  // Instantiate PWM //                     
  ////////////////////
  PWM iDUT(.CLK(clk),.CLRN(CLRN),.DUTY({CNT[25:16],6'h00}),.PWM(dis));
  
  ////////////////////////////////////////////////
  // infer 26-bit counter to drive DUTY of PWM //
  //////////////////////////////////////////////
  always_ff @(posedge clk, negedge CLRN)
    if (!CLRN)
	  CNT <= 26'h0000000;
	else
	  CNT <= CNT + 1;
  
  /////////////////////////////////////////////////
  // Instantiate four bcd7seg to display "Pong" //
  ///////////////////////////////////////////////
  bcd7seg iBCD3(.num(4'b1010),.dis(dis),.seg(HEX3));
  bcd7seg iBCD2(.num(4'b1011),.dis(dis),.seg(HEX2));
  bcd7seg iBCD1(.num(4'b1100),.dis(dis),.seg(HEX1));
  bcd7seg iBCD0(.num(4'b1101),.dis(dis),.seg(HEX0));
  
endmodule
  
  