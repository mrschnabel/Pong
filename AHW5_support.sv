module shift_reg(input LOAD, SHL, SHR, CLK, CLRN, output reg [17:0] Q, output reg DIR);
	reg [17:0] Qnext;
	reg	[2:0] counter;
	logic [17:0] ShiftInit;
	
	always @(posedge CLK or negedge CLRN) begin
		if(!CLRN) Q <= 18'h3FFFF;
		else Q <= Qnext;
	end
	
	always @(*) begin
		if(LOAD) Qnext = ShiftInit;
		else if(SHR) Qnext = {1'd0, Q[17:1]};
		else if(SHL) Qnext = {Q[16:0], 1'h0};
		else Qnext = Q;
	end
	
	/// randomization counter //
	always @(posedge CLK) begin
		counter <= counter + 3'b1;
	end
	
	always_comb begin
		DIR = counter[0];
		case(counter[2:1])
		2'b00: ShiftInit = {7'b0, 4'b0001, 7'b0};
		2'b01: ShiftInit = {7'b0, 4'b0010, 7'b0};
		2'b10: ShiftInit = {7'b0, 4'b0100, 7'b0};
		2'b11: ShiftInit = {7'b0, 4'b1000, 7'b0};
		endcase
	end
	
endmodule

module var_timer(input SET, MAX, output TC, input clk, reset);
	reg [23:0] Q, target_count;
	// largest number of cycles between terminal counts
	localparam MAX_TIMEOUT = 24'd12000000;
	// smallest number of cycles between terminal counts
	localparam MIN_TIMEOUT = 24'd0539998;
	
	assign TC = (Q == target_count)?1'b1:1'b0;
	
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			// active-high asynchronous reset
			Q <= 24'd0;
			target_count <= MAX_TIMEOUT;
		end else begin
			// not a reset, so it's the active clock edge
			if (SET) begin
				// set the timeout to the current count or the min
				// timeout, whichever is larger (i.e., make it faster)
				if (Q >= MIN_TIMEOUT) target_count <= Q;
				else target_count <= MIN_TIMEOUT;
			end else if (MAX) begin
				// return the timeout to the maximum value
				target_count <= MAX_TIMEOUT;
			end else if (Q < target_count) begin
				// not modifying timeout value, just running the timer,
				// and we're not yet at the target count
				Q <= Q + 24'd1;
			end else begin
				// not modifying timeout value, just running the timer,
				// but we've reached the target count (so need to wrap to 0)
				Q <= 24'd0;
			end
		end
	end
endmodule

module win_det(input [7:0] SCORE1, SCORE0, output GAMEOVER, WINNER);
	wire P1WIN = (SCORE1 >= 8'h12);
	wire P0WIN = (SCORE0 >= 8'h12);
	assign GAMEOVER = P1WIN || P0WIN;
endmodule


