`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module bellek (
    input                       clk_i,
    input                       rstn_i,

    //veri yolu birimi + l1 denetleyici 
    //Okuma girdileri
    input   [`VERI_BIT-1:0]     l1v_veri_i,
    input                       l1v_veri_gecerli_i,
    output                      l1v_veri_hazir_o,
    //Yazma
    input                       l1v_istek_hazir_i,
    output  [`PS_BIT-1:0]       l1v_istek_adres_o,
    output                      l1v_istek_gecerli_o,

    //duraklat
    output                      duraklat_o,

    //mikroişlem giriş çıkışları
    input   [`UOP_BIT-1:0]          bellek_uop_i,
    output  [`UOP_BIT-1:0]          geri_yaz_uop_o

);

reg [`UOP_BIT-1:0]              uop_r;
reg [`UOP_BIT-1:0]              uop_ns;
wire [`UOP_TAG_BIT-1:0]         uop_tag_w;
wire                            uop_taken_w;

wire                            uop_gecerli_w;
wire [`UOP_BEL_BIT-1:0]         uop_buyruk_secim_w;
wire [`UOP_RS1_BIT-1:0]         uop_rs1_w;
wire [`UOP_RS2_BIT-1:0]         uop_rs2_w;
wire [`UOP_IMM_BIT-1:0]         uop_imm_w;
wire [`UOP_RD_BIT-1:0]          uop_rd_w;


wire [`VERI_BIT-1:0]            maske_w;
wire [`ADRES_BIT-1:0]           erisilecek_adres_w;



always @* begin
    uop_ns = bellek_uop_i;
    uop_ns[`UOP_VALID] = uop_gecerli_w; 
<<<<<<< HEAD
=======

    bib_istek_gecerli_ns = bib_istek_gecerli_r;
    bib_veri_ns = bib_veri_r;
    bellek_veri_ns = bellek_veri_r;
   

    if (yaz_w || oku_w) begin // ikisinden biri birse bibden sonuç gelmiş demektir
        bib_istek_gecerli_ns = 1'b1; // veri yolu birimi başlayabilir 
        if (yaz_w) begin
            bib_veri_ns = uop_rs2_w;  // store buyrukları için    
            // SONRA 0 YAPALI MIYIM YAZI?
        end 
        else if (oku_w && bellek_gecerli_w) begin
           // Uop'a bellek_veri_w yi yaz ilet 
        end
    end
>>>>>>> c84c9ab (Yazmac obegi hatasini cozer ve bellegi gunceller.)
   
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        uop_r <= {`UOP_BIT{`LOW}};
    end
    else begin
        uop_r <= bellek_uop_i;
    end
end

<<<<<<< HEAD
bellek_islem_birimi bib(
.clk_i                    ( clk_i               ),
.rstn_i                   ( rstn_i              ),  
.uop_buyruk_secim_i       ( uop_buyruk_secim_w  ),          
.uop_rd_i                 ( uop_rd_w            ),  
.maske_o                  ( maske_w             ) 
);

=======
bellek_islem_birimi bib (
    .clk_i                            ( clk_i               ),
    .rstn_i                           ( rstn_i              ),  
    .uop_buyruk_secim_i               ( uop_buyruk_secim_w  ),          
    .uop_rd_i                         ( uop_rd_w            ),  
    .maske_o                          ( maske_w             ),
    .oku_o                            ( oku_w               ),
    .yaz_o                            ( yaz_w               )    
);

veri_yolu_birimi vyb (
    .clk_i                            (clk_i                ),
    .rstn_i                           (rstn_i               ),
    .port_istek_adres_o               (l1v_istek_adres_o    ),
    .port_istek_gecerli_o             (l1v_istek_gecerli_o  ),
    .port_istek_yaz_o                 (l1v_istek_yaz_o      ),
    .port_istek_veri_o                (l1v_istek_veri_o     ),
    .port_istek_hazir_i               (l1v_istek_hazir_i    ),
    .port_veri_i                      (l1v_veri_i           ),
    .port_veri_gecerli_i              (l1v_veri_gecerli_i   ),
    .port_veri_hazir_o                (l1v_veri_hazir_o     ),
    .bib_istek_gecerli_i              (bib_istek_gecerli_w  ),
    .bib_istek_yaz_i                  (bib_istek_yaz_w      ),
    .bib_veri_i                       (bib_veri_w           ),  // yazılacak veri
    .bib_istek_oku_i                  (bib_istek_oku_w      ),
    .bib_istek_adres_i                (bib_istek_adres_w    ),
    .bib_istek_maske_i                (bib_istek_maske_w    ),
    .bellek_veri_o                    (bellek_veri_w        ),
    .bellek_gecerli_o                 (bellek_gecerli_w     ) // hazır sinyali
);

>>>>>>> c84c9ab (Yazmac obegi hatasini cozer ve bellegi gunceller.)
assign duraklat_o = `LOW;
assign geri_yaz_uop_o = uop_r;

assign uop_gecerli_w = bellek_uop_i[`UOP_VALID];
assign uop_tag_w = bellek_uop_i[`UOP_TAG];

assign uop_rs1_w = bellek_uop_i[`UOP_RS1];
assign uop_rs2_w = bellek_uop_i[`UOP_RS2];
assign uop_rd_w = bellek_uop_i[`UOP_RD];
assign uop_imm_w = bellek_uop_i[`UOP_IMM];
assign uop_taken_w = bellek_uop_i[`UOP_TAKEN];
assign uop_buyruk_secim_w = bellek_uop_i[`UOP_BEL];


endmodule
