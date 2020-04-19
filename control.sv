module control(

	input CLK,					// 50MHz clock
	input CLRN,					// active low asynch reset
	input OVER,					// indicates game over (1 player at 12 points)
	input START,				// comes from edge_detect of push button
	input DIR,					// ball dir 1=>right, 0=>left.  Comes from shifter
	input TICK,					// divided version of clock used to slow game
	input ATL,					// At Left.  1=>ball all the way to the left
	input ATR,					// At Right
	input BtnL,					// Left player's button released
	input BtnR,					// Right player's button released 
	output logic [5:0] state,	// state is output for debug purposes
	output logic LD,			// Load shift register with ball at center
	output logic SHL,			// Shift ball to left (qualified with TICK)
	output logic SHR,			// Shift ball to right (qualified with TICK)
	output logic CLRPT,			// Clear the point registers
	output logic PTL,			// increment left players points
	output logic PTR,			// increment right players points
	output logic MAXTIME,		// TICK timer resets to slowest speed
	output logic SETTIME		// TICK timer should update with new faster time
);


	typedef enum reg[5:0] {INIT=6'h01, MOVE_R=6'h02, END_R=6'h04, MOVE_L=6'h08,
                           END_L=6'h10, DONE=6'h20} state_t;
	
	/////////////////////////////
	// declare state register //
	///////////////////////////
	state_t nxt_state;
	
    //////////////////////////////
	// Instantiate state flops //
	////////////////////////////
	state6_reg iST(.CLK(CLK),.CLRN(CLRN),.nxt_state(nxt_state),.state(state));		
	
	//////////////////////////////////////////////
	// State transitions and outputs specified //
	// next as combinational logic with case  //
	///////////////////////////////////////////	
	
	always_comb begin
		/////////////////////////////////////////
		// Default all SM outputs & nxt_state //
		///////////////////////////////////////
		nxt_state = state_t'(state);		// defaulted this one for you...you do the outputs
		LD = 1'b0;			
	 	SHL = 1'b0;			
		SHR = 1'b0;			
		CLRPT = 1'b0;		
	 	PTL = 1'b0;			
	 	PTR = 1'b0;			
	 	MAXTIME = 1'b0;		
	 	SETTIME = 1'b0;	

		case (state)
		  INIT: begin
            
		if(START == 0)begin
			nxt_state = INIT;
			CLRPT = 1'b1;
			MAXTIME = 1'b1;
		end
		else if(~DIR && START == 1)begin
			nxt_state = MOVE_L;
			LD = 1'b1;
			CLRPT = 1'b1;
		end
		else begin
			nxt_state = MOVE_R;
			LD = 1'b1;
			CLRPT = 1'b1;
		end
		  end

		  MOVE_R : begin
             	 
		if(ATR)begin
		nxt_state = END_R;
		end
		else if(OVER)begin
		nxt_state = DONE;
		end
		else if (~ATR && ~OVER && BtnR && TICK)begin
		nxt_state = MOVE_R;
		PTL = 1'b1;
		SHR = 1'b1;
		  end
		else if(~ATR && TICK && ~OVER)begin
		SHR = 1'b1;
		nxt_state = MOVE_R;
		end
		else begin
		nxt_state = MOVE_R;
		
		end
		end

		  MOVE_L : begin
             	
		if(OVER)begin
		nxt_state = DONE;
		end
		else if(ATL)begin
		nxt_state = END_L;
		end
		else if(~ATL && ~OVER && BtnL && TICK)begin
		nxt_state = MOVE_L;
 		SHL = 1'b1;
		PTR = 1'b1;
		end
		else if(~ATR && TICK && ~OVER)begin
		SHL = 1'b1;
		nxt_state = MOVE_L;
		end
		else begin
		nxt_state = MOVE_L;
		
		end
		  end

		  END_R : begin
            	
		if(TICK && ~BtnR)begin
		nxt_state = MOVE_L;
		PTL = 1'b1;
		MAXTIME = 1'b1;
		end
		else if(~TICK && BtnR)begin
		nxt_state = MOVE_L;
		SETTIME = 1'b1;
		end
		else if(TICK && BtnR)begin
		MAXTIME = 1'b1;
		nxt_state = MOVE_L;
		end
		else if(~TICK && ~BtnR)begin
		nxt_state = END_R;
		MAXTIME = 1'b0;
		SETTIME = 1'b0;
		end
		  end

		  END_L : begin
 		
		if(TICK && ~BtnL)begin
		nxt_state = MOVE_R;
		PTR = 1'b1;
		MAXTIME = 1'b1;
		end
		else if(~TICK && BtnL)begin
		nxt_state = MOVE_R;
		SETTIME = 1'b1;
		
		end
		else if(TICK && BtnL)begin
		MAXTIME = 1'b1;
		nxt_state = MOVE_R;
		
		end
		else if(~TICK && ~BtnL)begin
		 MAXTIME = 1'b0;
		SETTIME = 1'b0;
		nxt_state = END_L;
		end
		  end

		  default : begin		// this is same as DONE
              
		if(DIR && START)begin
		nxt_state = MOVE_R;
		 LD = 1'b1;
		 CLRPT = 1'b1;
		
		end
		else if(~DIR && START)begin
		nxt_state = MOVE_L;
		 LD = 1'b1;
		CLRPT = 1'b1;
		
		end
		else begin
		nxt_state = DONE;
		MAXTIME = 1'b1;
		end  
		  end
		endcase
	end
		
endmodule	