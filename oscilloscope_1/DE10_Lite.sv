
module DE10_Lite(

      ///////// Clocks /////////
      input              ADC_CLK_10,
      input              MAX10_CLK1_50,
      input              MAX10_CLK2_50,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,

      ///////// Clock Generator I2C /////////
      output             CLK_I2C_SCL,
      inout              CLK_I2C_SDA,

      ///////// GSENSOR /////////
      output             GSENSOR_SCLK,
      inout              GSENSOR_SDO,
      inout              GSENSOR_SDI,
      input    [ 2: 1]   GSENSOR_INT,
      output             GSENSOR_CS_N,

      ///////// GPIO /////////
      inout    [35: 0]   GPIO,

      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 
		
);

   wire rst = SW [8];
	
	localparam w_x = 10, w_y = 10, h = 480, w = 640;
    //------------------------------------------------------------------------

    wire display_on;

    wire [w_x - 1:0] x;
    wire [w_y - 1:0] y;

    vga
    # (
        .HPOS_WIDTH ( w_x     ),
        .VPOS_WIDTH ( w_y     ),

        .CLK_MHZ    ( 50 )
    )
    i_vga
    (
        .clk        ( MAX10_CLK1_50       ),
        .rst        ( rst        ),
        .hsync      ( VGA_HS      ),
        .vsync      ( VGA_VS      ),
        .display_on ( display_on ),
        .hpos       ( x          ),
        .vpos       ( y          )
    );
		
//=======================================================
//  REG/WIRE declarations
//=======================================================

wire reset_n;
wire sys_clk;


//=======================================================
//  Structural coding
//=======================================================

assign reset_n = 1'b1;



    adc_qsys u0 (
        .clk_clk                              (ADC_CLK_10),                              //                    clk.clk
        .reset_reset_n                        (reset_n),                        //                  reset.reset_n
        .modular_adc_0_command_valid          (command_valid),          //  modular_adc_0_command.valid
        .modular_adc_0_command_channel        (command_channel),        //                       .channel
        .modular_adc_0_command_startofpacket  (command_startofpacket),  //                       .startofpacket
        .modular_adc_0_command_endofpacket    (command_endofpacket),    //                       .endofpacket
        .modular_adc_0_command_ready          (command_ready),          //                       .ready
        .modular_adc_0_response_valid         (response_valid),         // modular_adc_0_response.valid
        .modular_adc_0_response_channel       (response_channel),       //                       .channel
        .modular_adc_0_response_data          (response_data),          //                       .data
        .modular_adc_0_response_startofpacket (response_startofpacket), //                       .startofpacket
        .modular_adc_0_response_endofpacket   (response_endofpacket),    //                       .endofpacket
        .clock_bridge_sys_out_clk_clk         (sys_clk)          // clock_bridge_sys_out_clk.clk
    );

	 
////////////////////////////////////////////
// command
wire  command_valid;
wire  [4:0] command_channel;
wire  command_startofpacket;
wire  command_endofpacket;
wire command_ready;

// continused send command
assign command_startofpacket = 1'b1; // // ignore in altera_adc_control core
assign command_endofpacket = 1'b1; // ignore in altera_adc_control core
assign command_valid = 1'b1; // 
assign command_channel = 1; // SW2/SW1/SW0 down: map to arduino ADC_IN0

////////////////////////////////////////////
// response
wire response_valid/* synthesis keep */;
wire [4:0] response_channel;
wire [11:0] response_data;
wire response_startofpacket;
wire response_endofpacket;
reg [4:0]  cur_adc_ch /* synthesis noprune */;
reg [11:0] adc_sample_data /* synthesis noprune */;
reg [12:0] vol /* synthesis noprune */;
localparam depth = w, width = 10;
logic [width - 1:0] data [0:depth - 1];
logic [width - 1:0] data_1 [0:depth - 1];
wire clk = MAX10_CLK1_50;
logic [15:0] count;
logic reg_number;

logic [25:0] tacts_count;
logic [11:0] v_min, v_max;
logic ready;

wire [8:0] delay_multiplier;
assign delay_multiplier = SW[8:0];

always_ff @ (posedge sys_clk)
begin
	if (rst) begin
		count <= 0;
		reg_number <= 0;
		v_min <= 4095;
		v_max <= 0;
		ready <= 0;
		 
		for (int i = 0; i < w; i ++) begin
			 data [i] <= 0;
			 data_1 [i] <= 0;
		 end
   end else if (response_valid) begin
		adc_sample_data <= response_data;
		cur_adc_ch <= response_channel;
		vol <= response_data * 2 * 2500 / 4095;
		
		if (count >= w * delay_multiplier) begin
			reg_number <= ~reg_number;
			count <= 0;
			ready <= 1;
		end else begin
			count <= count + 1;
		end

		if (reg_number) begin
			data [0] <= 470 - (response_data * 460 / 4095);
			for (int i = 1; i < 640; i ++)
				 data [i] <= data [i - 1];
		end else begin
			data_1 [0] <= 470 - (response_data * 460 / 4095);
			for (int i = 1; i < 640; i ++)
				 data_1 [i] <= data_1 [i - 1];
		end
		
		if (response_data > v_max) v_max <= response_data;
		if (response_data < v_min) v_min <= response_data;
	end
end

logic started_from_high;
logic [1:0] measure_phase;
logic [25:0] calculated_freq;

localparam delta = 25;

always_ff @ (posedge clk)
begin
	if (rst) begin
		 measure_phase <= 0;
	end else if (measure_phase == 0 && ready) begin
		if (adc_sample_data >= (v_max - delta)) begin
			started_from_high <= 1;
		end else begin
			started_from_high <= 0;
		end
		measure_phase <= 1;
		tacts_count <= 0;
	end else begin
		if (measure_phase > 1) tacts_count <= tacts_count + 1;
		if (measure_phase == 1) begin
			if (started_from_high && adc_sample_data <= (v_min + delta)) begin
				measure_phase <= 2;
			end else if (~started_from_high && adc_sample_data >= (v_max - delta)) begin
				measure_phase <= 2;
			end
		end else if (measure_phase == 2) begin
			if (started_from_high && adc_sample_data  >= (v_max - delta)) begin
				measure_phase <= 3;
			end else if (~started_from_high && adc_sample_data  <= (v_min + delta)) begin
				measure_phase <= 3;
			end
		end else if (measure_phase == 3) begin
			if (started_from_high && adc_sample_data  <= (v_min + delta)) begin
				measure_phase <= 0;
				calculated_freq <= 50000000 / tacts_count;
			end else if (~started_from_high && adc_sample_data >= (v_max - delta)) begin
				measure_phase <= 0;
				calculated_freq <= 50000000 / tacts_count;
			end
		end
	end
end 

always_ff @ (posedge clk)
begin
	  VGA_R <= '0;
	  VGA_G <= '0;
	  VGA_B <= '0;
	  if (~ display_on)
	  begin
	  end
	  else if (x == 320) begin
		  VGA_R <= '1;
		  VGA_G <= '1;
		  VGA_B <= '1;
	  end else if (y == 240) begin
		  VGA_R <= '1;
		  VGA_G <= '1;
		  VGA_B <= '1;
	  end else if (~reg_number && data[x] == y ) begin
		  VGA_R <= '1;
		  VGA_G <= '1;
		  VGA_B <= '1;
	  end else if (reg_number && data_1[x] == y ) begin
		  VGA_R <= '1;
		  VGA_G <= '1;
		  VGA_B <= '1;
	  end		  
end
	
// adc_sample_data: hold 12-bit adc sample value
// Vout = Vin (12-bit x2 x 2500 / 4095)	

//assign LEDR[9:0] = vol[12:3];  // led is high active
assign LEDR[9:0] = calculated_freq[9:0];  // led is high active

assign HEX5[7] = 1'b1; // low active
assign HEX4[7] = 1'b1; // low active
assign HEX3[7] = 1'b0; // low active
assign HEX2[7] = 1'b1; // low active
assign HEX1[7] = 1'b1; // low active
assign HEX0[7] = 1'b1; // low active

SEG7_LUT	SEG7_LUT_ch (
	.oSEG(HEX5),
	.iDIG(SW[2:0])
);

assign HEX4 = 8'b10111111;

SEG7_LUT	SEG7_LUT_v (
	.oSEG(HEX3),
	.iDIG(vol/1000)
);
 
SEG7_LUT	SEG7_LUT_v_1 (
	.oSEG(HEX2),
	.iDIG(vol/100 - (vol/1000)*10)
);

SEG7_LUT	SEG7_LUT_v_2 (
	.oSEG(HEX1),
	.iDIG(vol/10 - (vol/100)*10)
);

SEG7_LUT	SEG7_LUT_v_3 (
	.oSEG(HEX0),
	.iDIG(vol - (vol/10)*10)
);

endmodule
