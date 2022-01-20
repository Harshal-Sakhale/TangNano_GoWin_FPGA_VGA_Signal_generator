// https://www.youtube.com/watch?v=cVxSYm8aHRo
module top;

	wire clk;
	(* BEL="R5C20_IOBA", keep *)
	GENERIC_IOB #(.INPUT_USED(1), .OUTPUT_USED(0)) clk_ibuf (.O(clk));
	
// VGA signals 640 x 480 (60 Hz)
		
	wire red;
	(* BEL="R11C11_IOBA", keep *) // pin 19 RED
	GENERIC_IOB #(.INPUT_USED(0), .OUTPUT_USED(1)) red_obuf (.I(red));

	wire green;
	(* BEL="R11C11_IOBB", keep *) // pin 20 GREEN
	GENERIC_IOB #(.INPUT_USED(0), .OUTPUT_USED(1)) green_obuf (.I(green));

	wire blue;
	(* BEL="R11C14_IOBA", keep *) // pin 21 BLUE
	GENERIC_IOB #(.INPUT_USED(0), .OUTPUT_USED(1)) blue_obuf (.I(blue));

	
	wire hsync;
	(* BEL="R11C14_IOBB", keep *) // pin 22 HS
	GENERIC_IOB #(.INPUT_USED(0), .OUTPUT_USED(1)) hsync_obuf (.I(hsync));

	wire vsync;
	(* BEL="R11C16_IOBA", keep *) // pin 23 VS
	GENERIC_IOB #(.INPUT_USED(0), .OUTPUT_USED(1)) vsync_obuf (.I(vsync));

reg [9:0] ctr = 0 ; 		// 10 bit counter
reg [9:0] hscounter = 0; 	// 10-bit modulo 768 (0-767)

reg DisplayEnable = 0;

reg red_out = 0;
reg green_out = 0;
reg blue_out = 0;
reg hsync_out = 1;
reg vsync_out = 1;

// VS Section
always @(posedge clk)
begin
	hscounter = hscounter + 1;

	// --------------------------------------------------	
	case (hscounter)
	
		1 :
		begin
			hsync_out = 0;
		end	
			
		123 :
		begin
			hsync_out = 1;
		end
		
		138 :
		begin
			if (DisplayEnable)
			begin		
				red_out = 1;
				green_out = 0;
				blue_out = 0;
			end
			else
			begin
				red_out = 0;
				green_out = 0;
				blue_out = 0;
			end
		end		
		// 138 - 753

		//753 : // 753 =  Full gray
		// 700 : // 700 = 80 % gray, 20 % black
		//445 : //  445 = Half gray and half black
		
		// 138, 343, 548 Tricolor 
		343 :
		begin
			red_out = 0;
			green_out = 1;
			blue_out = 0;
		end

		548 :
		begin
			red_out = 0;
			green_out = 0;
			blue_out = 1;
		end

			
		768 :
		begin
			hscounter = 0;	
		end
	
	endcase

end

always @(posedge ~hsync_out) begin
	ctr = ctr + 1; // HSYNC pulses counter

	case (ctr)
		1 : 
		begin
			vsync_out = 0;
		end
		
		3 :
		begin
			vsync_out = 1;
		end
		
		32 :
		begin
			DisplayEnable = 1;
		end
		
		// 32 + 480  = 512
		// 512 + 4 
		// 4 additional hsync pulses are needed else the 
		// red vertical stripe is clipped at the bottom 
		516 :
		begin
			DisplayEnable = 0;
		end	

		522 :
		begin
			ctr = 0;
		end
	endcase
end

assign red = red_out;
assign green = green_out;
assign blue = blue_out;
assign hsync = hsync_out;
assign vsync = vsync_out;

endmodule

