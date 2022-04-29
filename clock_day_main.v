`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    7:37:13 03/20/2022 
// Design Name: 
// Module Name:    main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module day_time(Out, clk_1s, clk_5ms, up, down, clk, control, change, reset);

input  clk;
input up, down, change, reset;
output reg [5:0]control;
output reg[6:0]Out;

output reg clk_1s;
output reg clk_5ms;

reg [27:0] counter;
reg [6:0] counter1;

reg [7:0]sec; // gio phut giay
reg [7:0]min;
reg [7:0]hour;

reg [7:0]day; // ngay thang nam
reg [7:0]month;
reg [7:0]year;

reg [3:0]c_sec; // dv, c
reg [3:0]dv_sec;

reg [3:0]c_min;
reg [3:0]dv_min;

reg [3:0]c_hour;
reg [3:0]dv_hour;

////////////////////////////////////////day
reg [3:0]c_day; // day
reg [3:0]dv_day;

reg [3:0]c_month; // month
reg [3:0]dv_month;

reg [3:0]c_year; //year
reg [3:0]dv_year;

reg [2:0]count;  // bien dem quet led
initial begin
	counter = 28'b0;// counter 1s
	clk_1s = 1'b0;
	sec = 8'd0;
	counter1 = 28'b0; // counter
	clk_5ms = 1'b0;
	
	count = 3'b000;
	sec = 8'd0;
	min = 8'd50;
	hour = 8'd7;
	
	min_alarm = 8'd0;  // set alarm
	hour_alarm = 8'd0;
	
	day = 8'd19;
	month = 8'd04;	
	year = 8'd22;

end

always @(posedge clk) // chia xung 1hz
begin
	counter <= counter + 1;
	if (counter == 28'd50_000) // tao xung 1Hz
		begin
			counter <= 28'b0;
			clk_1s <= ~clk_1s;
		end
end


always @(posedge clk) // chia xung 200hz
begin
	counter1 <= counter1 + 1;
	if (counter1 == 7'd100) // tao xung 
		begin
			counter1 <= 7'b0;
			clk_5ms <= ~clk_5ms;
		end
end

function [3:0]mod_10; // so/10
	input [5:0]number;
	begin
		mod_10 = (number >= 50) ? 5:((number>=40)?4:((number>=30)?3:((number>=20)?2:((number>=10)?1:0))));
	end
endfunction

function [6:0]number_led7seg; 
	input [3:0]num;
	begin
		number_led7seg = (num == 4'd0) ? 7'b1000000:((num == 4'd1)?7'b1111001:((num == 4'd2)?7'b0100100:((num==4'd3)?7'b0110000:((num==4'd4)?7'b0011001:((num == 4'd5)?7'b0010010:((num == 4'd6)?7'b0000010:((num == 4'd7)?7'b1111000:((num == 4'd8)?7'b0000000:7'b0010000))))))));
	end
endfunction


always @(posedge clk_1s)
begin
	sec = sec + 1; 
	if (down && !change) //up hour
		begin
			hour = hour + 1;
			if(hour == 24)
				hour = 0;	
		end
	if (up && !change) // up min
		begin
			min = min +1;
			if(min == 60)
				min = 0;	
		end
		
	if (down && change) //up hour
		begin
			day = day + 1;
			if(day == 30)
				day = 0;	
		end
	if (up && change) // up day
		begin
			month = month +1;
			if(month > 12)
				month = 0;	
		end
		
	
	/////////////////////
	if	(reset)begin
		day = 0;
		month = 0;
		min = 0;
		hour = 0;
		sec = 0;
	end
		
	/////////////////////////////////// time up
	if(sec == 60)
		begin
			 sec = 0;  //reset seconds
			 min = min + 1;
			 if(min == 60)
				begin
					 min = 0;  //reset seconds
					 hour = hour + 1;
				end
				if(hour == 24)
				begin
					hour = 0;
					day = day + 1;
				end	
		end	
	if(month == 1 || month == 3 || month == 5 || month == 7|| month == 8||month == 10||month == 12)begin
		if(day == 31)  // thang 31 ngay
			begin
			 day = 0;  //reset days
			 month = month + 1;
			 if(month == 12)
				begin
					 month = 0;  //reset months
				end
			end
	end
	else if (month == 4 || month == 6 || month == 9 || month == 11)begin
		if(day == 30)  // thang 30 ngay
			begin
			 day = 0;  //reset days
			 month = month + 1;
			 if(month == 12)
				begin
					 month = 0;  //reset months
				end
			end
	end
	else begin
		if(day == 28) // nam khong nhuan
			begin
			 day = 0;  //reset days
			 month = month + 1;
			 if(month == 12)
				begin
					 month = 0;  //reset months
				end
			end
	end
	
	
	/////////////////////////////	
	c_sec = mod_10(sec); 
	dv_sec = sec - c_sec*10;	
	
	c_min = mod_10(min); 
	dv_min = min - c_min*10;
	
	c_hour = mod_10(hour); 
	dv_hour = hour - c_hour*10;

	c_day = mod_10(day);  /// day
	dv_day = day - c_day*10;
	
	c_month = mod_10(month); 
	dv_month = month - c_month*10;
	
	c_year = mod_10(year); 
	dv_year = year - c_year*10;
	////////////////////////////////////// alarm
	
end


always @ (posedge clk_5ms)
begin
	if (!change)begin   // if change
		if(count == 3'b101)
			begin
				case (c_hour)
					4'd0: Out = 7'b1000000;
					4'd1: Out = 7'b1111001;
					4'd2: Out = 7'b0100100;
				endcase
				control = 6'b000001;
			end
		else if (count == 3'b100)
			begin
				Out = number_led7seg(dv_hour);	
				control = 6'b000010;
			end
		else if (count == 3'b011)
			begin
				Out = number_led7seg(c_min);	
				control = 6'b000100;
			end
		else if (count == 3'b010)
			begin
				Out = number_led7seg(dv_min);		
				control = 6'b001000;
			end
		else if (count == 3'b001)
			begin
				Out = number_led7seg(c_sec);	
				control = 6'b010000;
			end
		else if (count == 3'b000)
			begin
				Out = number_led7seg(dv_sec);	
				control = 6'b100000;
			end
	end 
	else if (change)
	begin   // if change
		if(count == 3'b101)
			begin
				case (c_day)
					4'd0: Out = 7'b1000000;
					4'd1: Out = 7'b1111001;
					4'd2: Out = 7'b0100100;
					4'd3: Out = 7'b0110000;
				endcase
				control = 6'b000001;
			end
		else if (count == 3'b100)
			begin
				Out = number_led7seg(dv_day);	
				control = 6'b000010;
			end
		else if (count == 3'b011)
			begin
				Out = number_led7seg(c_month);	
				control = 6'b000100;
			end
		else if (count == 3'b010)
			begin
				Out = number_led7seg(dv_month);		
				control = 6'b001000;
			end
		else if (count == 3'b001)
			begin
				Out = 7'b0100100;	 // 2
				control = 6'b010000;
			end
		else if (count == 3'b000)
			begin
				Out = 7'b0100100;	 // 2 
				control = 6'b100000;
			end
	end 
	
	
	count = count + 3'b001;
	if(count == 3'b110)
	begin
		count = 3'b000;
	end		
end

endmodule
