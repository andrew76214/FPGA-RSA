module LCD1602(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
	 input start,
	 output [7:0] data, 
	 output reg RS, RW, E
	 );

wire rst = ~rst_n; // make reset active high

// these signals should be high-z when not used

localparam [1:0] idle      = 2'b00,
					  lcd_init  = 2'b01,
					  lcd_print = 2'b10;
					  
reg [1:0] state_reg, state_next;
reg [4:0] addr_reg, addr_next;
reg [21:0] cnt_reg, cnt_next;
reg [1:0] s1, s2;

//State Registers
always@(posedge clk, posedge rst)
begin
	if(rst)
		state_reg <= idle;
	else
		state_reg <= state_next;
end


//Next State Logic
always @*
begin
	case(state_reg)
		idle:
			if(start)
				state_next = lcd_init;
			else
				state_next = idle;
				
		lcd_init:
			if(addr_reg == 5'h03 && cnt_reg == 3550000)
				state_next = lcd_print;
			else 
				state_next = lcd_init;
				
		lcd_print:
			if(addr_reg == 5'h19 && cnt_reg == 3550000)
				state_next = idle;
			else 
				state_next = lcd_print;
				
		 default:
				state_next = idle;
		endcase
end

//Output Logic	
always @*
begin
		case(state_reg)
			idle:
				begin
				s1 = 2'b10;
				s2 = 2'b10;
				RW = 0;
				RS = 0;
				E = 0;
				end
				
			lcd_init:
				begin
				s1 = 2'b00;
				s2 = 2'b01;
				RS = 0;
				RW = 0;
				E = 0;
				if (cnt_reg >= 500000)
					E = 1;
				if (cnt_reg >= 3400000)
					E = 0;
				if (cnt_reg == 3550000)
				begin
					s1 = 2'b01;
					s2 = 2'b10;
				end
				end
				
			lcd_print:
				begin
				s1 = 2'b00;
				s2 = 2'b01;
				RS = 1;
				RW = 0;
				E = 0;
				if (cnt_reg >= 500000)
					E = 1;
				if (cnt_reg >= 3400000)
					E = 0;
				if (cnt_reg == 3550000)
				begin
					s1 = 2'b01;
					s2 = 2'b10;
				end
				end
			default:
				begin
				s1 = 2'b10;
				s2 = 2'b10;
				RW = 0;
				RS = 0;
				E = 0;
				end
				
		endcase
end

//Path 1: ROM
wire [7:0] rom_data [23:0];
 
  assign rom_data[0] = 8'h38;
  assign rom_data[1] = 8'h06;
  assign rom_data[2] = 8'h0C;
  assign rom_data[3] = 8'h01;
  
  assign rom_data[4] = " ";
  assign rom_data[5] = " ";
  assign rom_data[6] = " ";
  assign rom_data[7] = " ";
  assign rom_data[8] = "T";
  assign rom_data[9] = "H";
  assign rom_data[10] = "I";
  assign rom_data[11] = "S";
  assign rom_data[12] = " ";
  assign rom_data[13] = "I";
  assign rom_data[14] = "S";
  assign rom_data[15] = " ";
  assign rom_data[16] = "P";
  assign rom_data[17] = "P";
  assign rom_data[18] = "A";
  assign rom_data[19] = "P";
  assign rom_data[20] = " ";
  assign rom_data[21] = " ";
  assign rom_data[22] = " ";
  assign rom_data[23] = " ";
 
  assign data = rom_data[addr_reg];

//Path 1: Registers
always@(posedge clk, posedge rst)
begin
	if(rst)
		addr_reg <= 5'b0;
	else
		addr_reg <= addr_next;
end

//Path 1: Mux
always @* 
	case(s1)
		2'b00:
			addr_next = addr_reg;
			
		2'b01:
			addr_next = addr_reg + 1'b1;
			
		2'b10:
			addr_next = 5'b0;
			
		default:
			addr_next = addr_reg;
	endcase
	

//Path 2: Registers
always@(posedge clk, posedge rst)
begin
	if(rst)
		cnt_reg <= 21'h0;
	else
		cnt_reg <= cnt_next;
end

//Path 2: Mux
always @* 
	case(s2)
		2'b00:
			cnt_next = cnt_reg;
			
		2'b01:
			cnt_next = cnt_reg + 1'b1;
			
		2'b10:
			cnt_next = 21'h0;
			
		default:
			cnt_next = cnt_reg;
	endcase

endmodule