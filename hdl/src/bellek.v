`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module bellek (
    input                       clk_i,
    input                       rstn_i,

    // l1v istek <> bellek
    output  [`ADRES_BIT-1:0]    l1v_istek_adres_o,
    output                      l1v_istek_gecerli_o,
    output                      l1v_istek_onbellekleme_o,
    output                      l1v_istek_yaz_o,
    output  [`VERI_BIT-1:0]     l1v_istek_veri_o,
    output  [`VERI_BYTE-1:0]    l1v_istek_maske_o,
    input                       l1v_istek_hazir_i,

    // Yazmc oku sonuna veri yonlendirmesi
    output  [`VERI_BIT-1:0]     yo_veri_o,
    output  [`YAZMAC_BIT-1:0]   yo_adres_o,
    output  [`UOP_TAG_BIT-1:0]  yo_etiket_o,
    output                      yo_gecerli_o,

    // l1v yanit <> bellek
    input   [`VERI_BIT-1:0]     l1v_veri_i,
    input                       l1v_veri_gecerli_i,
    output                      l1v_veri_hazir_o,
    //Yazma
    input                       l1v_istek_hazir_i,
    output  [`PS_BIT-1:0]       l1v_istek_adres_o,
    output                      l1v_istek_gecerli_o,

    //duraklat
    output                      duraklat_o,

    input   [`UOP_BIT-1:0]      bellek_uop_i,
    output  [`UOP_BIT-1:0]      geri_yaz_uop_o
);

reg [`UOP_BIT-1:0]              uop_r;
reg [`UOP_BIT-1:0]              uop_ns;

wire [`UOP_PC_BIT-1:0]          uop_ps_w;
wire [`UOP_TAG_BIT-1:0]         uop_tag_w;
wire                            uop_taken_w;

wire                            uop_gecerli_w;
wire [`UOP_BEL_BIT-1:0]         uop_buyruk_secim_w;
wire [`UOP_RS1_BIT-1:0]         uop_rs1_w;
wire [`UOP_RS2_BIT-1:0]         uop_rs2_w;
wire [`UOP_IMM_BIT-1:0]         uop_imm_w;
wire [`UOP_RD_BIT-1:0]          uop_rd_w;

wire                            vyb_hazir_w;
wire [`VERI_BYTE-1:0]           maske_w;


// veri yolu birimine gidecek olanlar

wire bib_istek_gecerli_w;
wire bib_istek_yaz_w;
wire [`VERI_BIT-1:0] bib_veri_w;
wire bib_istek_oku_w;
wire [`ADRES_BIT-1:0] bib_istek_adres_w;
wire [`VERI_BYTE-1:0] bib_istek_maske_w;
wire [`VERI_BIT-1:0] bellek_veri_w;
wire bellek_gecerli_w;

wire [1:0] uop_bayt_indis_w;

reg bib_istek_gecerli_cmb;
reg [`VERI_BIT-1:0] bib_veri_cmb;

reg bellek_veri_r;
reg bellek_veri_ns;

reg yo_gecerli_cmb;

reg duraklat_cmb;

reg[1:0] durum_r;
reg[1:0] durum_ns;

localparam OKU = 0;
localparam HAZIR = 1;

always @* begin
    uop_ns = bellek_uop_i;
    yo_gecerli_cmb = `LOW;

    bib_istek_gecerli_cmb = `LOW;
    duraklat_cmb = `LOW;
    durum_ns = durum_r;
    
    case(durum_r)
        HAZIR: begin
            if (yaz_w && uop_gecerli_w) begin
                bib_istek_gecerli_cmb = `HIGH;
                duraklat_cmb = !vyb_hazir_w;
            end
            if (oku_w && uop_gecerli_w) begin
                bib_istek_gecerli_cmb = `HIGH;
                duraklat_cmb = `HIGH;
                durum_ns = vyb_hazir_w ? OKU : HAZIR;
            end
        end
        OKU: begin
            duraklat_cmb = `HIGH;
            if (bellek_gecerli_w) begin // bana veri gelmiş demektir 
                yo_gecerli_cmb = `HIGH;
                case (uop_buyruk_secim_w)
                    `UOP_BEL_LW: begin // 32 Bit Okur
                        uop_ns[`UOP_RD] = bellek_veri_w;   
                    end
                    `UOP_BEL_LH: begin // 16 Bit Okur, sign-extend edip rd'ye yazar
                        uop_ns[`UOP_RD] = $signed(bellek_veri_w[uop_bayt_indis_w * 8 +: 16]);
                    end
                    `UOP_BEL_LHU: begin // 16 Bit Okur, zero-extend edip rd'ye yazar
                        uop_ns[`UOP_RD] = {16'b0, bellek_veri_w[uop_bayt_indis_w * 8 +: 16]};       
                    end
                    `UOP_BEL_LB: begin // 8 Bit Okur, sign-extend edip rd'ye yazar
                        uop_ns[`UOP_RD] = $signed(bellek_veri_w[uop_bayt_indis_w * 8 +: 8]);         
                    end
                    `UOP_BEL_LBU: begin // 8 Bit Okur, zero-extend edip rd'ye yazar
                        uop_ns[`UOP_RD] = {24'b0, bellek_veri_w[uop_bayt_indis_w * 8 +: 8]};      
                    end
                endcase
                duraklat_cmb = `LOW;
                durum_ns = HAZIR;
            end
        end
    endcase

    uop_ns[`UOP_VALID] = !duraklat_cmb && uop_gecerli_w;
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        uop_r <= {`UOP_BIT{`LOW}};
        bib_istek_gecerli_r <= 1'b0;
        bib_veri_r <= {`VERI_BIT{1'b0}};
        bellek_veri_r <= 1'b0;
        durum_r <= HAZIR;
    end
    else begin
        uop_r <= uop_ns;
        bellek_veri_r <= bellek_veri_ns;
        durum_r <= durum_ns;  
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
    .uop_rs2_i                        ( uop_rs2_w           ),  
    .veri_o                           ( bib_veri_w          ),
    .maske_o                          ( maske_w             ),
    .oku_o                            ( oku_w               ),
    .yaz_o                            ( yaz_w               )    
);

veri_yolu_birimi vyb ( 
    .clk_i                            ( clk_i                ),
    .rstn_i                           ( rstn_i               ),
    .port_istek_adres_o               ( l1v_istek_adres_o    ),
    .port_istek_gecerli_o             ( l1v_istek_gecerli_o  ),
    .port_istek_onbellekleme_o        ( l1v_istek_onbellekleme_o ),
    .port_istek_yaz_o                 ( l1v_istek_yaz_o      ),
    .port_istek_veri_o                ( l1v_istek_veri_o     ),
    .port_istek_maske_o               ( l1v_istek_maske_o    ),
    .port_istek_hazir_i               ( l1v_istek_hazir_i    ),
    .port_veri_i                      ( l1v_veri_i           ),
    .port_veri_gecerli_i              ( l1v_veri_gecerli_i   ),
    .port_veri_hazir_o                ( l1v_veri_hazir_o     ),
    .bib_istek_gecerli_i              ( bib_istek_gecerli_w  ),
    .bib_istek_yaz_i                  ( bib_istek_yaz_w      ),
    .bib_veri_i                       ( bib_veri_w           ),  // yazılacak veri
    .bib_istek_oku_i                  ( bib_istek_oku_w      ),
    .bib_istek_adres_i                ( bib_istek_adres_w    ),
    .bib_istek_maske_i                ( bib_istek_maske_w    ),
    .bellek_hazir_o                   ( vyb_hazir_w          ),
    .bellek_veri_o                    ( bellek_veri_w        ),
    .bellek_gecerli_o                 ( bellek_gecerli_w     )   // islem bitti sinyali
);

assign geri_yaz_uop_o = uop_r;

assign uop_ps_w = bellek_uop_i[`UOP_PC];
assign uop_gecerli_w = bellek_uop_i[`UOP_VALID];
assign uop_tag_w = bellek_uop_i[`UOP_TAG];

assign uop_rs1_w = bellek_uop_i[`UOP_RS1];
assign uop_rs2_w = bellek_uop_i[`UOP_RS2];
assign uop_rd_w = bellek_uop_i[`UOP_RD];
assign uop_imm_w = bellek_uop_i[`UOP_IMM];
assign uop_taken_w = bellek_uop_i[`UOP_TAKEN];
assign uop_buyruk_secim_w = bellek_uop_i[`UOP_BEL];
assign uop_bayt_indis_w = uop_rd_w[1:0];

assign bib_istek_maske_w = maske_w;
assign bib_istek_yaz_w = yaz_w;
assign bib_istek_oku_w = oku_w;
assign bib_istek_adres_w = uop_rd_w;
assign bib_istek_gecerli_w = bib_istek_gecerli_cmb;

assign yo_veri_o = uop_ns[`UOP_RD];
assign yo_adres_o = bellek_uop_i[`UOP_RD_ADDR];
assign yo_gecerli_o = yo_gecerli_cmb && uop_gecerli_w;
assign yo_etiket_o = uop_tag_w;

assign duraklat_o = duraklat_cmb;




endmodule
