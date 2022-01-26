module TRY_BEEP(clk, life_change, beep);
input  clk;  //50m hz
input  life_change;
output beep;  //output
reg  beep_r; //register
reg[1:0]count;

assign beep = beep_r;

divfreq_bp dd0 (clk, clk_div);

always @(posedge clk_div or negedge life_change)
	if (!life_change) begin
		count <= count + 1'b1;
	end
	else begin
		count <= count + 1'b1;
		beep_r <= 1'b1;
		if(count == 2'b11) begin
		  count <= 2'b0;
		  beep_r <= !beep_r;
		end
	end

endmodule

//-------------------------------------------------------

module divfreq_bp(input CLK, output reg CLK_time);
  reg [25:0] Count;
  initial
    begin
      CLK_time = 0;
	 end	
		
  always @(posedge CLK)
    begin
      if(Count > 2500000)
        begin
          Count <= 25'b0;
          CLK_time <= ~CLK_time;
        end
      else
        Count <= Count + 1'b1;
    end
endmodule 