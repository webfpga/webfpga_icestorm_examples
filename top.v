module fpga_top (
    output reg  WF_NEO
);

 
// define registers
//
// 1 pixel
// these are register, they can be moved to a RAM for larger pixel
// arrays. Also since they are 8 bits each, likely more compact
// storage could be used by reducing the color from 8 bits to
// 6 or 5 bits, without much loss of colors.

   reg  [23:0] pixel0;

   reg  [4:0]  pixel_bit_cnt;
   reg  [1:0]  pixel_cnt;
   reg  [23:0] shift_pixels;

   wire        phase;
   reg         phase_d;
   reg         phase_tmp;

   reg         np_eof;
   wire        np_sof;

   reg [2:0] reset_cnt;
   reg [3:0] np_clk_cnt;
   reg       pixel_bit_end;
   reg       tog_bit0;
   reg       tog_bit1;

//////////////////////////////////////////////////////////////////////
//
//  create clock from SB_HFOCS hard macro
  wire clk_en;
  assign clk_en = 1'b1;

  SB_HFOSC OSC_i (                  // 48 MHz clock
        .CLKHFEN(clk_en),
        .CLKHFPU(clk_en),
        .CLKHF(clk));

    // set to 12MHz (ie divide by 4)
   defparam OSC_i.CLKHF_DIV = "0b10";

///////////////////////////////////////////////////////////////////////
//  send data stream continuously {50 us gap, then pixel0}.

   always @(posedge clk)
//     begin
//     if (rst)
//       begin
//       end
//     else
         begin 
           if (phase==0) // neopixel reset
             begin
            if (np_sof)
           begin
                   WF_NEO      <= 1'b1;  // every bit starts at logic 1
              end
               else
                 begin
                   WF_NEO         <= 1'b0;
                   shift_pixels <= pixel0;
                   pixel_bit_cnt<= 5'b0;  // 24 bits per pixel
                   np_eof       <= 1'b0;  // clr singal to create pulse
                 end
             end
           else
             begin
               if (( shift_pixels[0] && tog_bit1) ||
                   (~shift_pixels[0] && tog_bit0) )
                  WF_NEO <= 1'b0;

//       at end of bit time, shift the pixels or load new 24 bits
               if (pixel_bit_end)
                 if (pixel_bit_cnt != 23)
                   begin
                     WF_NEO          <= 1'b1;
                     shift_pixels  <= {1'b0,shift_pixels[23:1]};
                     pixel_bit_cnt <= pixel_bit_cnt + 1'b1;
                   end
           else
             begin     // start reset cycle
                     np_eof <= 1'b1;
                     WF_NEO   <= 1'b0; 
             end
             end
         end


/////////////////////////////////////////////////////////////////////////
// create pulses for bit0 and bit1 switching to low state.
// sync on np_sof signal.
//
// one bit stream is:
//  
//    |                             |
//    |-------------                -----------
//    |             |               |
//    |<- hi time ->|< lo time    ->|
//    |             |               |
//    |              ----------------
//    |                             |
//    |<-         bit time        ->|
//
//    first bit out is the msb for color intentsity.
//    GREEN followed by RED followed by BLUE.
//
//  table values are in ns and +/- tolerances
//
//            period   |   1 hi  |   0 hi  |   1 lo  |   0 lo  |  reset 
//=========================================================================
// WS2812B  1250/600   | 800/150 | 400/150 | 450/150 | 850/150 | >50 us


// this device has 12 MHz, so 83.333ns period. Table for clocks and time

//            period   |   1 hi  |   0 hi  |   1 lo  |   0 lo  |  reset 
//=========================================================================
// WS2812B  15/1250    | 10/833  |  5/417  |  5/417  | 10/833  | >600 clks
//
//
parameter [3:0] BIT1_HI = 10;
parameter [3:0] BIT1_LO =  5;
parameter [3:0] BIT0_HI =  5;
parameter [3:0] BIT0_LO = 10;

parameter [3:0] NEO_PERIOD = 15;


// create bit waveform
   always @(posedge clk)
     begin
       if (np_sof)
         begin
           np_clk_cnt <= 4'b1;  // advance 1 cnt due to dout starting early
                         // for first transfer.
         end
       else if (phase == 1'b1)
         begin
           if (np_clk_cnt == NEO_PERIOD- 4'h1)
             begin
               np_clk_cnt     <= 4'b0;
               pixel_bit_end  <= 1'b1;
             end
           else
             np_clk_cnt <= np_clk_cnt + 4'b1;

           if (np_clk_cnt == BIT0_HI -4'h1)
             tog_bit0 <= 1'b1;     // pulse to change dout for bit being 0
           else
             tog_bit0 <= 1'b0;

           if (np_clk_cnt == BIT1_HI -4'h1)   // pulse to change dout for bit being 1
             tog_bit1 <= 1'b1;
           else
             tog_bit1 <= 1'b0;

           if (pixel_bit_end) pixel_bit_end <= 1'b0; // create pulse
         end
     end

/////////////////////////////////////////////////////////////////////////
// setup approx timers
//
     wire ten_us;
     wire two_ms;

     // include time base
     ten_usec  ten_usec ( 
           .clk(clk),
           .ten_us(ten_us));

     // include time base
     two_msec two_msec( 
           .clk(clk),
           .ten_us(ten_us),
           .two_ms(two_ms));

/////////////////////////////////////////////////////////////////////////
// 50us reset counter  -pause after complete data stream of string of LEDs

   always @(posedge clk)
     begin
       if (phase_tmp == 0)
      begin
           if (ten_us)
             begin
               if (reset_cnt == 'h6)
                 begin
                   phase_tmp <= 1'b1;  // start data frame
                   reset_cnt <= 'd0; // clr rst cnt readying it for nxt use
                 end
               else
                 reset_cnt <= reset_cnt + 3'd1;
             end  
         end

       if (np_eof)           // once last data is sent start reset again
         phase_tmp <= 1'b0;

// create delays for SOF
       phase_d <= phase_tmp;

     end

    assign np_sof =  ~phase_d && phase_tmp; 
    assign phase = phase_d;
// 
//////////////////////////////////////////////////////////////////
//  Create colors to DEMO above bit logic.
//  Loading register or memory from SPI or of means is possible
//////////////////////////////////////////////////////////////////
// create colors in pxiel registers.

  reg [1:0] cnt;
  reg [6:0] cnt2;
  reg       updn;
  reg [2:0] ph;

  wire [6:0]  cnt2_G;
  wire [6:0]  cnt2_R;
  wire [6:0]  cnt2_B;

// bit reverse for WS2812B
  wire [6:0] cnt2_w={cnt2[0],cnt2[1],cnt2[2],cnt2[3],cnt2[4],cnt2[5],cnt2[6]};

  assign cnt2_G = cnt2_w;
  assign cnt2_R = cnt2_w;
  assign cnt2_B = cnt2_w;


  // up-down counters for fading
   always @(posedge clk)
     begin
       if (two_ms)
      begin
           cnt <= cnt + 2'h01;   // every XXms change the color
           if (cnt == 0)
             begin
               if (cnt2 ==  127)
              begin
                   cnt2 <= 126;
                   updn = ~updn;
                ph <= ph + 3'b1;
              end
            else if (cnt2 == 1 && updn ==1)  // down counting
                begin
                     cnt2 <= 1;
                     updn = ~updn;
                  ph <= ph + 3'b1;
                end
            else if (updn==0)
                     cnt2 <= cnt2 + 7'b1;
            else
                     cnt2 <= cnt2 - 7'b1;
        end   // cnt == 0
     end      // 10 ms
    end
        


   always @(*)
    case (ph)   // set up neopixel color cycling (all are half brightness)
      3'h0: pixel0[23:0] <= {8'h00,8'hfe,8'h00};    // red
      3'h1: pixel0[23:0] <= {8'h00,8'h00,8'hfe};    // green
      3'h2: pixel0[23:0] <= {8'hfe,8'h00,8'h00};    // blue
      3'h3: pixel0[23:0] <= {8'h00,{cnt2_R,1'b0},8'h00};  // fade red
      3'h4: pixel0[23:0] <= {8'h00,8'h00,{cnt2_G,1'b0}};  // fade green
      3'h5: pixel0[23:0] <= {{cnt2_B,1'b0},8'h00,8'h00};  // fade blue
      3'h6: pixel0[23:0] <= {8'h00,{cnt2_R,1'b0},{~cnt2_G,1'b0}}; // mix RG
      3'h7: pixel0[23:0] <= {{cnt2_B,1'b0},8'h00,{~cnt2_G,1'b0}}; // mix BG
    endcase


endmodule

//////////////////////////////////////////////////////////////////////
//
// 10us timer pulse
//
//
   module ten_usec (
       input  wire clk,
       output reg  ten_us
   );

    reg [6:0] counter;

    always @ (posedge clk)
        if (counter == 119)
          begin
            ten_us   <= 1'b1;
            counter  <= 'b0;
          end
        else
          begin
            counter  <= counter + 7'b1;
            ten_us   <= 1'b0;
          end

   endmodule

//////////////////////////////////////////////////////////////////////
//
// 2ms timer pulse
//
//
   module two_msec (
       input  wire clk,
       input  wire ten_us,
       output reg  two_ms
   );

    reg [9:0] counter;

    always @ (posedge clk)
        if (ten_us)
       begin
            if (counter == 199)
              begin
                two_ms   <= 1'b1;
                counter  <=   'b0;
              end
           else
            counter  <= counter + 10'b1;
          end
        else
            two_ms   <= 1'b0;

   endmodule
