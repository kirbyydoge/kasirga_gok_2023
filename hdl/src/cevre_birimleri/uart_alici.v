`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module uart_alici (
    input                   clk_i,
    input                   rstn_i,

    input                   rx_en_i,
    output [7:0]            alinan_veri_o,
    output                  alinan_gecerli_o,
    input [15:0]            baud_div_i,
    
    input                   rx_i
    
);
  reg     al_gecerli_o;
  assign alinan_gecerli_o = al_gecerli_o;
  localparam BOSTA          = 0;
  localparam START_BITI_AL  = 1;
  localparam VERI_AL        = 2;
  localparam DUR            = 3;

  reg [7:0] veri_ns, veri_r;    
  reg [1:0] durum_ns, durum_r;
  reg [31:0] baud_sayac_ns, baud_sayac_r;
  reg [2:0] RX_ek_ns, RX_ek_r; 
  
  wire      saat_ac     = baud_sayac_r == baud_div_i;
  wire      ornekle1    = baud_sayac_r == (baud_div_i/20 * 9);
  wire      ornekle2    = baud_sayac_r == (baud_div_i/20 * 10);
  wire      ornekle3    = baud_sayac_r == (baud_div_i/20 * 11);
  
  reg       RX_r1, RX_r2;
  
  reg       RX_ornek1_r, RX_ornek1_ns;
  reg       RX_ornek2_r, RX_ornek2_ns;
  reg       RX_ornek3_r, RX_ornek3_ns;
  
  wire      RX_ornek_cogunluk = (RX_ornek1_r & RX_ornek2_r) | 
                                (RX_ornek2_r & RX_ornek3_r) | 
                                (RX_ornek1_r & RX_ornek3_r);
  
  // yari kararli durumdan kurtulmak icin RX'i
  // iki kez yazmaca yaz
  always @(posedge clk_i) begin
    RX_r1                      <=                   rx_i;
    RX_r2                      <=                   RX_r1;
  end
  
  assign alinan_veri_o                =                   veri_r;
  
  always @* begin
     durum_ns                    =                   durum_r;
     veri_ns                     =                   veri_r ;
     baud_sayac_ns               =                   baud_sayac_r;
     RX_ek_ns                    =                   RX_ek_r;
     RX_ornek1_ns                =                   RX_ornek1_r;
     RX_ornek2_ns                =                   RX_ornek2_r;
     RX_ornek3_ns                =                   RX_ornek3_r;
    
     al_gecerli_o                =                   1'b0;
    
     if (ornekle1) begin
       RX_ornek1_ns              =                   RX_r2;
     end
     if (ornekle2) begin
       RX_ornek2_ns              =                   RX_r2;
     end
     if (ornekle3) begin
       RX_ornek3_ns              =                   RX_r2;
     end        

     if (durum_r != BOSTA)
       baud_sayac_ns             =                   baud_sayac_r + 1;
 
     case (durum_r)
      BOSTA: begin
        if (RX_r2 == 1'b0)
          durum_ns              =                   START_BITI_AL;
          baud_sayac_ns         =                   32'd0; 
      end
      START_BITI_AL: begin
        if (saat_ac) begin
          if (RX_ornek_cogunluk == 1'b0)
            durum_ns            =                   VERI_AL;
          else
            durum_ns            =                   BOSTA;          
        end      
      end
      VERI_AL: begin
        if (saat_ac) begin
          veri_ns[RX_ek_r]      =                   RX_ornek_cogunluk;        
          if (RX_ek_r == 3'b111) begin 
            RX_ek_ns            =                   3'b000;
            durum_ns            =                   DUR;
          end
          else begin
            RX_ek_ns            =                   RX_ek_r + 1;
          end
        end
      end
      DUR: begin
        if (baud_sayac_r > (baud_div_i/20 * 11)) begin
          durum_ns              =                   BOSTA;
          baud_sayac_ns         =                   32'd0;
          al_gecerli_o          =                   1'b1;    
        end
      end
    endcase
  
    if (saat_ac) begin  
      baud_sayac_ns             =                   32'd0;
    end          
  end
  
  always @(posedge clk_i) begin
    if (!rstn_i) begin
      veri_r                      <=                  0;
      durum_r                     <=                  BOSTA;
      baud_sayac_r                <=                  0;
      RX_ek_r                     <=                  0;    
      RX_ornek1_r                 <=                  0;
      RX_ornek2_r                 <=                  0;
      RX_ornek3_r                 <=                  0;
    end
    else begin
      veri_r                      <=                  veri_ns;
      durum_r                     <=                  durum_ns;
      baud_sayac_r                <=                  baud_sayac_ns;
      RX_ek_r                     <=                  RX_ek_ns;
      RX_ornek1_r                 <=                  RX_ornek1_ns;
      RX_ornek2_r                 <=                  RX_ornek2_ns;
      RX_ornek3_r                 <=                  RX_ornek3_ns;
    end
  end   
  
endmodule