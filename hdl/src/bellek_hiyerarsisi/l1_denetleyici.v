`timescale 1ns / 1ps

`include "sabitler.vh"

module l1_denetleyici (
    input                                           clk_i,
    input                                           rstn_i,

    // okuyan birim <> l1 denetleyici istek
    input   [`ADRES_BIT-1:0]                        port_istek_adres_i,
    input                                           port_istek_gecerli_i,
    input                                           port_istek_yaz_i,
    input   [`VERI_BIT-1:0]                         port_istek_veri_i,
    output                                          port_istek_hazir_o,

    // l1 denetleyici veri <> okuyan birim 
    output  [`VERI_BIT-1:0]                         port_veri_o,
    output                                          port_veri_gecerli_o,
    input                                           port_veri_hazir_i,

    // l1 denetleyici <> l1 SRAM (BRAM)
    output                                          l1_istek_gecersiz_o,
    output  [`ADRES_SATIR_BIT-1:0]                  l1_istek_satir_o,
    output  [`L1_YOL-1:0]                           l1_istek_yaz_o,
    output  [(`ADRES_ETIKET_BIT * `L1_YOL)-1:0]     l1_istek_etiket_o,
    output  [(`L1_BLOK_BIT * `L1_YOL)-1:0]          l1_istek_blok_o,

    input   [(`ADRES_ETIKET_BIT * `L1_YOL)-1:0]     l1_veri_etiket_i,
    input   [(`L1_BLOK_BIT * `L1_YOL)-1:0]          l1_veri_blok_i,
    input                                           l1_veri_gecerli_i,

    // veri yolu denetleyici <> l1 denetleyici oku
    output  [`ADRES_BIT-1:0]                        vy_istek_adres_o,
    output                                          vy_istek_gecerli_o,
    input                                           vy_istek_hazir_i,
    output                                          vy_istek_yaz_o,
    output  [`L1_BLOK_BIT-1:0]                      vy_istek_veri_o,

    input   [`L1_BLOK_BIT-1:0]                      vy_veri_i,
    input                                           vy_veri_gecerli_i,
    output                                          vy_veri_hazir_o
);

localparam  L1_DURUM_BIT    = 'd4;

localparam  L1_BOSTA        = 'd0;
localparam  L1_OKU          = 'd1;
localparam  L1_BEKLE        = 'd2;
localparam  L1_SORGU        = 'd3;
localparam  L1_YANIT        = 'd4;
localparam  L1_SATIR_ACIK   = 'd5;
localparam  VY_OKU_ISTEK    = 'd6;
localparam  VY_OKU_BEKLE    = 'd7;
localparam  VY_YAZ_ISTEK    = 'd8;

reg [L1_DURUM_BIT-1:0] l1_durum_r; 
reg [L1_DURUM_BIT-1:0] l1_durum_ns;

reg [`ADRES_BIT-1:0] son_adres_r;
reg [`ADRES_BIT-1:0] son_adres_ns;

reg [`ADRES_BIT-1:0] port_istek_adres_r;
reg [`ADRES_BIT-1:0] port_istek_adres_ns;

reg [`VERI_BIT-1:0] port_istek_veri_r;
reg [`VERI_BIT-1:0] port_istek_veri_ns;

reg port_istek_hazir_r; 
reg port_istek_hazir_ns;
assign port_istek_hazir_o = port_istek_hazir_r;

reg port_yazma_istegi_r;
reg port_yazma_istegi_ns;

reg [`VERI_BIT-1:0] port_veri_r;
reg [`VERI_BIT-1:0] port_veri_ns;
assign port_veri_o = port_veri_r;

reg port_veri_gecerli_r;
reg port_veri_gecerli_ns;
assign port_veri_gecerli_o = port_veri_gecerli_r;

reg l1_istek_gecerli_r;
reg l1_istek_gecerli_ns;
assign l1_istek_gecersiz_o = ~l1_istek_gecerli_r;       

reg  [`ADRES_SATIR_BIT-1:0]     l1_istek_satir_r;
reg  [`ADRES_SATIR_BIT-1:0]     l1_istek_satir_ns;
assign l1_istek_satir_o = l1_istek_satir_r;

reg  [`L1_YOL-1:0]              l1_istek_yaz_r;
reg  [`L1_YOL-1:0]              l1_istek_yaz_ns;
assign l1_istek_yaz_o = l1_istek_yaz_r;

wire [`ADRES_ETIKET_BIT-1:0]    l1_okunan_etiketler_w [0:`L1_YOL-1];
wire [`L1_BLOK_BIT-1:0]         l1_okunan_bloklar_w [0:`L1_YOL-1];

reg [`L1_YOL-1:0] l1_yol_guncellendi_r;
reg [`L1_YOL-1:0] l1_yol_guncellendi_ns;

reg [`L1_BLOK_BIT-1:0] l1_buffer_bloklar_r [0:`L1_YOL-1];
reg [`L1_BLOK_BIT-1:0] l1_buffer_bloklar_ns [0:`L1_YOL-1];

reg [`ADRES_ETIKET_BIT-1:0] l1_buffer_etiketler_r [0:`L1_YOL-1];
reg [`ADRES_ETIKET_BIT-1:0] l1_buffer_etiketler_ns [0:`L1_YOL-1];

reg [$clog2(`L1_YOL)-1:0] cikarma_sayaci_r;
reg [$clog2(`L1_YOL)-1:0] cikarma_sayaci_ns;

reg [`L1_YOL-1:0] satir_gecerli_r [0:`L1_SATIR-1];
reg [`L1_YOL-1:0] satir_gecerli_ns [0:`L1_SATIR-1];

reg [`L1_YOL-1:0] satir_kirli_r [0:`L1_SATIR-1];
reg [`L1_YOL-1:0] satir_kirli_ns [0:`L1_SATIR-1];

wire [`L1_YOL-1:0] acik_satir_gecerli_durumu_w;
wire [`L1_YOL-1:0] acik_satir_kirli_durumu_w;

reg [$clog2(`L1_YOL)-1:0] idx_gecersiz_yol_cmb;
reg gecersiz_yol_var_cmb;

reg [$clog2(`L1_YOL)-1:0] vy_hedef_yol_r;
reg [$clog2(`L1_YOL)-1:0] vy_hedef_yol_ns;

reg [`ADRES_BIT-1:0] vy_istek_adres_r;
reg [`ADRES_BIT-1:0] vy_istek_adres_ns;
assign vy_istek_adres_o = vy_istek_adres_r;

reg [`L1_BLOK_BIT-1:0] vy_istek_veri_r;
reg [`L1_BLOK_BIT-1:0] vy_istek_veri_ns;
assign vy_istek_veri_o = vy_istek_veri_r;

reg vy_istek_gecerli_r;
reg vy_istek_gecerli_ns;
assign vy_istek_gecerli_o = vy_istek_gecerli_r;

reg vy_istek_yaz_r;
reg vy_istek_yaz_ns;
assign vy_istek_yaz_o = vy_istek_yaz_r;

reg vy_veri_hazir_r;
reg vy_veri_hazir_ns;
assign vy_veri_hazir_o = vy_veri_hazir_r;

integer i;
integer j;

// Duz girisleri yeniden isimlendir ve isimlendirilmis flip floplari cikislar icin geri duzlestir
// degisken[yol_idx * <veri_bit> +: <veri_bit>] yerine degisken[yol_idx] erisim okunakligi sagliyor
// Sentez programi zaten bu isimlendirmeleri kaldirarak orijinal tanimlari birakiyor. Maaliyeti yok
genvar idx_yol;
generate
    for (idx_yol = 0; idx_yol < `L1_YOL; idx_yol = idx_yol + 1) begin : l1b_kablo_yeniden_isimlendir
        assign l1_okunan_etiketler_w[idx_yol] = l1_veri_etiket_i[(idx_yol * `ADRES_ETIKET_BIT) +: `ADRES_ETIKET_BIT];
        assign l1_okunan_bloklar_w[idx_yol] = l1_veri_blok_i[(idx_yol * `L1_BLOK_BIT) +: `L1_BLOK_BIT];
        assign l1_istek_etiket_o[(idx_yol * `ADRES_ETIKET_BIT) +: `ADRES_ETIKET_BIT] = l1_buffer_etiketler_r[idx_yol];
        assign l1_istek_blok_o[(idx_yol * `L1_BLOK_BIT) +: `L1_BLOK_BIT] = l1_buffer_bloklar_r[idx_yol];
    end
endgenerate

// Acik satirdaki kirli ve gecerli durumlarini yeniden isimlendir
genvar arama_yol;
generate
    for (arama_yol = 0; arama_yol < `L1_YOL; arama_yol = arama_yol + 1) begin : l1b_kirli_gecerli
        assign acik_satir_gecerli_durumu_w[arama_yol] = satir_gecerli_r[get_satir(son_adres_r)][arama_yol];
    end
endgenerate

function [`ADRES_ETIKET_BIT-1:0] get_etiket;
    input [`ADRES_BIT-1:0] adres;
    begin
        get_etiket = adres[`ADRES_ETIKET_OFFSET +: `ADRES_ETIKET_BIT];
    end
endfunction

function [`ADRES_SATIR_BIT-1:0] get_satir;
    input [`ADRES_BIT-1:0] adres;
    begin
        get_satir = adres[`ADRES_SATIR_OFFSET +: `ADRES_SATIR_BIT];
    end
endfunction

function [`ADRES_BYTE_BIT-1:0] get_bytes;
    input [`ADRES_BIT-1:0] adres;
    begin
        get_bytes = adres[`ADRES_BYTE_OFFSET +: `ADRES_BYTE_BIT];
    end
endfunction

function [`VERI_BIT-1:0] get_veri;
    input [`L1_BLOK_BIT-1:0] blok;
    input [`ADRES_BIT-1:0] adres;
    begin
        get_veri = blok[get_bytes(adres) * 8 +: `VERI_BIT];
    end
endfunction

task set_veri;
    input [$clog2(`L1_YOL)-1:0] yol_idx;
    input [`ADRES_BIT-1:0] adres;
    input [`VERI_BIT-1:0] veri;
    begin
        l1_buffer_bloklar_ns[yol_idx][get_bytes(adres) * 8 +: `VERI_BIT] = veri;
        l1_buffer_etiketler_ns[yol_idx] = get_etiket(adres);
        l1_yol_guncellendi_ns[yol_idx] = `HIGH;
        satir_kirli_ns[get_satir(adres)][yol_idx] = `HIGH;
    end
endtask

// Verilogda (maalesef) structlarimiz yok. O nedenle bu tip cozumlere gitmemiz gerekiyor.
`define FN_L1_SORGU_YOL     $clog2(`L1_YOL)-1:0
`define FN_L1_SORGU_SONUC   $clog2(`L1_YOL)
reg [$clog2(`L1_YOL):0] fn_l1_ara_sonuc_cmb;
function [$clog2(`L1_YOL):0] l1_ara;
    input [`ADRES_BIT-1:0] adres;
    begin
        l1_ara[`FN_L1_SORGU_YOL] = 0;
        l1_ara[`FN_L1_SORGU_SONUC] = `LOW;
        for (i = 0; i < `L1_YOL; i = i + 1) begin
            if (acik_satir_gecerli_durumu_w[i]
            && l1_buffer_etiketler_r[i] == get_etiket(adres)
            && get_satir(son_adres_r) == get_satir(adres)) begin
                l1_ara[`FN_L1_SORGU_YOL] = i;
                l1_ara[`FN_L1_SORGU_SONUC] = `HIGH;
            end
        end
    end
endfunction

// Gelen adresi yerlestirmek icin bir yolu secer.
// Gecersiz yol varsa ustune yaz, secilen yol kirliyse once ana bellege git.
// TODO (Oguzhan): 
//  - Kirli satiri bir buffera koy ve ana bellekten okuma yap.
//  - Bu sayede istegi erken yanitlayip bos kalan vakitte yazabiliriz.
//  - Simdilik donanim karmasikligini artirmak istemiyoruz. Son islerden olacak.
task l1_cikar (input [`ADRES_BIT-1:0] istek_adres);
    begin
        if (get_satir(son_adres_r) != get_satir(istek_adres)) begin
            if (l1_yol_guncellendi_r != {`L1_YOL{`LOW}}) begin // Arabelleklerde SRAM'e yazilmamis veri var
                l1_istek_gecerli_ns = `HIGH;
                l1_istek_satir_ns = get_satir(son_adres_r);
                l1_istek_yaz_ns = l1_yol_guncellendi_r;
                l1_yol_guncellendi_ns = {`L1_YOL{`LOW}};
            end
            if (satir_gecerli_r[get_satir(istek_adres)] != {`L1_YOL{`LOW}}) begin // Tum satir gecersiz degil
                l1_durum_ns = L1_OKU;
            end
            else begin
                vy_hedef_yol_ns = 0;
                vy_istek_adres_ns = istek_adres;
                vy_istek_gecerli_ns = `HIGH;
                vy_istek_yaz_ns = `LOW;
                vy_veri_hazir_ns = `LOW;
                l1_durum_ns = VY_OKU_ISTEK;
            end
        end
        else if (gecersiz_yol_var_cmb) begin
            vy_hedef_yol_ns = idx_gecersiz_yol_cmb;
            vy_istek_adres_ns = istek_adres;
            vy_istek_gecerli_ns = `HIGH;
            vy_istek_yaz_ns = `LOW;
            vy_veri_hazir_ns = `LOW;
            l1_durum_ns = VY_OKU_ISTEK;
        end
        else if (satir_kirli_r[get_satir(istek_adres)][cikarma_sayaci_r]) begin
            vy_hedef_yol_ns = cikarma_sayaci_r;
            vy_istek_veri_ns = l1_buffer_bloklar_r[cikarma_sayaci_r];
            vy_istek_adres_ns = {l1_buffer_etiketler_r[cikarma_sayaci_r], get_satir(istek_adres)} << `ADRES_BYTE_BIT;
            vy_istek_gecerli_ns = `HIGH;
            vy_istek_yaz_ns = `HIGH; 
            vy_veri_hazir_ns = `LOW;
            l1_durum_ns = VY_YAZ_ISTEK;
        end
        else begin
            vy_hedef_yol_ns = cikarma_sayaci_r;
            vy_istek_adres_ns = istek_adres;
            vy_istek_gecerli_ns = `HIGH;
            vy_istek_yaz_ns = `LOW;
            vy_veri_hazir_ns = `LOW;
            l1_durum_ns = VY_OKU_ISTEK;
        end
    end
endtask

// Acik satirdaki kirli ve gecerli yollari bul ve yeniden isimlendir
always @* begin
    idx_gecersiz_yol_cmb = 0;
    gecersiz_yol_var_cmb = `LOW;
    for (i = `L1_YOL - 1; i >= 0; i = i - 1) begin
        if (!acik_satir_gecerli_durumu_w[i]) begin
            idx_gecersiz_yol_cmb = i;
            gecersiz_yol_var_cmb = `HIGH;
        end
    end
end

// L1 Denetleyici Durum Makinesi
always @* begin
    for (i = 0; i < `L1_SATIR; i = i + 1) begin
        satir_gecerli_ns[i] = satir_gecerli_r[i];
        satir_kirli_ns[i] = satir_kirli_r[i];
    end
    for (i = 0; i < `L1_YOL; i = i + 1) begin
        l1_buffer_etiketler_ns[i] = l1_buffer_etiketler_r[i];
        l1_buffer_bloklar_ns[i] = l1_buffer_bloklar_r[i]; 
    end
    son_adres_ns = son_adres_r;
    port_istek_adres_ns = port_istek_adres_r;
    cikarma_sayaci_ns = cikarma_sayaci_r + 1;
    l1_istek_satir_ns = l1_istek_satir_r;
    port_istek_hazir_ns = l1_durum_ns == L1_BOSTA || l1_durum_ns == L1_SATIR_ACIK;
    port_veri_gecerli_ns = port_veri_gecerli_r;
    port_veri_ns = port_veri_r;
    l1_istek_gecerli_ns = `LOW;        // Tek cevrim 1 olmali
    l1_istek_yaz_ns = {`L1_YOL{`LOW}}; // Tek cevrim 1 olmali
    l1_durum_ns = l1_durum_r;
    vy_istek_gecerli_ns = vy_istek_gecerli_r;
    vy_istek_yaz_ns = vy_istek_yaz_r;
    vy_veri_hazir_ns = vy_veri_hazir_r;
    vy_istek_veri_ns = vy_istek_veri_r;
    vy_hedef_yol_ns = vy_hedef_yol_r;
    port_yazma_istegi_ns = port_yazma_istegi_r;
    l1_yol_guncellendi_ns = l1_yol_guncellendi_r;

    case(l1_durum_r)
    L1_BOSTA: begin
        port_istek_hazir_ns = `HIGH;
        if (port_istek_gecerli_i && port_istek_hazir_o) begin
            port_istek_hazir_ns = `LOW;
            port_istek_adres_ns = port_istek_adres_i;
            port_istek_veri_ns = port_istek_veri_i;
            port_yazma_istegi_ns = port_istek_yaz_i;
            l1_cikar(port_istek_adres_i);
        end
    end
    L1_SATIR_ACIK: begin
    // Yine bostayiz ama elimizde acik bir satir var. Istek burayi vurursa l1 okumaya gerek yok.
        port_istek_hazir_ns = `HIGH;
        fn_l1_ara_sonuc_cmb = l1_ara(port_istek_adres_i);
        if (port_istek_gecerli_i && port_istek_hazir_o) begin
            port_istek_hazir_ns = `LOW;
            port_istek_adres_ns = port_istek_adres_i;
            port_istek_veri_ns = port_istek_veri_i;
            port_yazma_istegi_ns = port_istek_yaz_i;
            if (fn_l1_ara_sonuc_cmb[`FN_L1_SORGU_SONUC]) begin
                if (port_istek_yaz_i) begin
                    set_veri(fn_l1_ara_sonuc_cmb[`FN_L1_SORGU_YOL], port_istek_adres_i, port_istek_veri_i);
                    port_yazma_istegi_ns = `LOW;
                end
                else begin
                    port_veri_ns = get_veri(l1_buffer_bloklar_r[fn_l1_ara_sonuc_cmb[`FN_L1_SORGU_YOL]], port_istek_adres_i);
                    port_veri_gecerli_ns = `HIGH;
                    l1_durum_ns = L1_YANIT;
                end
            end
            else begin
                l1_cikar(port_istek_adres_i);
            end
        end
    end
    L1_OKU: begin
    // BRAM/SRAM'lerden 1 satirin etiketlerini ve veri bloklarini getir
        l1_istek_satir_ns = get_satir(port_istek_adres_r);
        l1_istek_gecerli_ns = `HIGH;
        l1_istek_yaz_ns = {`L1_YOL{`LOW}};
        son_adres_ns = port_istek_adres_r;
        l1_durum_ns = L1_BEKLE; 
    end
    L1_BEKLE: begin
    // Cevabi bekle
        l1_istek_gecerli_ns = `LOW; // L1 hep hazir degilse kabul edilene kadar yuksek tutulabilir
        if (l1_veri_gecerli_i) begin
            for (i = 0; i < `L1_YOL; i = i + 1) begin
                l1_buffer_etiketler_ns[i] = l1_okunan_etiketler_w[i];
                l1_buffer_bloklar_ns[i] = l1_okunan_bloklar_w[i];
            end
            l1_durum_ns = L1_SORGU;
        end
    end
    L1_SORGU: begin
        fn_l1_ara_sonuc_cmb = l1_ara(port_istek_adres_r);
        if (fn_l1_ara_sonuc_cmb[`FN_L1_SORGU_SONUC]) begin
            if (port_yazma_istegi_r) begin
                set_veri(fn_l1_ara_sonuc_cmb[`FN_L1_SORGU_YOL], port_istek_adres_r, port_istek_veri_r);
                port_yazma_istegi_ns = `LOW;
                l1_durum_ns = L1_SATIR_ACIK;
            end
            else begin
                port_veri_ns =  get_veri(l1_buffer_bloklar_r[fn_l1_ara_sonuc_cmb[`FN_L1_SORGU_YOL]], port_istek_adres_r);
                port_veri_gecerli_ns = `HIGH;
                l1_durum_ns = L1_YANIT;
            end
        end
        else begin
            l1_cikar(port_istek_adres_r);
        end
    end
    L1_YANIT: begin
        port_veri_gecerli_ns = `HIGH;
        if (port_veri_hazir_i && port_veri_gecerli_o) begin
            port_veri_gecerli_ns = `LOW;
            l1_durum_ns = L1_SATIR_ACIK;
        end
    end
    VY_OKU_ISTEK: begin
        if (vy_istek_hazir_i && vy_istek_gecerli_o) begin
            vy_istek_gecerli_ns = `LOW;
            vy_veri_hazir_ns = `HIGH;
            son_adres_ns = vy_istek_adres_r;
            l1_durum_ns = VY_OKU_BEKLE;
        end
    end
    VY_OKU_BEKLE: begin
        vy_veri_hazir_ns = `HIGH;
        if (vy_veri_hazir_o && vy_veri_gecerli_i) begin
            l1_buffer_etiketler_ns[vy_hedef_yol_r] = get_etiket(son_adres_r);
            l1_buffer_bloklar_ns[vy_hedef_yol_r] = vy_veri_i;
            satir_gecerli_ns[get_satir(son_adres_r)][vy_hedef_yol_r] = `HIGH;
            satir_kirli_ns[get_satir(son_adres_r)][vy_hedef_yol_r] = `LOW;
            
            vy_veri_hazir_ns = `LOW;
            vy_istek_gecerli_ns = `LOW;
            vy_istek_yaz_ns = `LOW; 
            l1_durum_ns = L1_SORGU;
        end
    end
    VY_YAZ_ISTEK: begin
        vy_istek_gecerli_ns = `HIGH;
        vy_istek_yaz_ns = `HIGH; 
        if (vy_istek_hazir_i && vy_istek_gecerli_o) begin 
            satir_gecerli_ns[get_satir(son_adres_r)][vy_hedef_yol_r] = `HIGH;
            satir_kirli_ns[get_satir(son_adres_r)][vy_hedef_yol_r] = `LOW;

            vy_hedef_yol_ns = vy_hedef_yol_r;
            vy_istek_adres_ns = son_adres_r;
            vy_istek_gecerli_ns = `HIGH;
            vy_istek_yaz_ns = `LOW; 
            l1_durum_ns = VY_OKU_ISTEK;
        end
    end
    endcase
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        for (i = 0; i < `L1_SATIR; i = i + 1) begin
            satir_gecerli_r[i] <= 0;
            satir_kirli_r[i] <= 0;
        end
        for (i = 0; i < `L1_YOL; i = i + 1) begin
            l1_buffer_etiketler_r[i] <= 0;
            l1_buffer_bloklar_r[i] <= 0; 
        end
        port_istek_adres_r <= 0;
        son_adres_r <= 0;
        cikarma_sayaci_r <= 0;
        l1_istek_satir_r <= 0;
        vy_istek_adres_r <= 0;
        vy_istek_gecerli_r <= `LOW;
        vy_istek_yaz_r <= `LOW;
        vy_istek_veri_r <= 0;
        vy_veri_hazir_r <= `LOW;
        vy_hedef_yol_r <= 0;
        l1_istek_gecerli_r <= `LOW;
        l1_istek_yaz_r <= {`L1_YOL{`LOW}};
        port_istek_hazir_r <= `HIGH;
        port_veri_gecerli_r <= `LOW;
        port_yazma_istegi_r <= `LOW;
        port_istek_veri_r <= 0;
        port_veri_r <= 0;
        l1_yol_guncellendi_r <= 0;
        l1_durum_r <= L1_BOSTA;
    end
    else begin
        for (i = 0; i < `L1_SATIR; i = i + 1) begin
            satir_gecerli_r[i] <= satir_gecerli_ns[i];
            satir_kirli_r[i] <= satir_kirli_ns[i];
        end
        for (i = 0; i < `L1_YOL; i = i + 1) begin
            l1_buffer_etiketler_r[i] <= l1_buffer_etiketler_ns[i];
            l1_buffer_bloklar_r[i] <= l1_buffer_bloklar_ns[i]; 
        end
        port_istek_adres_r <= port_istek_adres_ns;
        son_adres_r <= son_adres_ns;
        cikarma_sayaci_r <= cikarma_sayaci_ns;
        l1_istek_satir_r <= l1_istek_satir_ns;
        l1_istek_gecerli_r <= l1_istek_gecerli_ns;
        l1_istek_yaz_r <= l1_istek_yaz_ns;
        vy_istek_adres_r <= vy_istek_adres_ns;
        vy_istek_gecerli_r <= vy_istek_gecerli_ns;
        vy_istek_yaz_r <= vy_istek_yaz_ns;
        vy_istek_veri_r <= vy_istek_veri_ns;
        vy_veri_hazir_r <= vy_veri_hazir_ns;
        vy_hedef_yol_r <= vy_hedef_yol_ns;
        port_istek_hazir_r <= port_istek_hazir_ns;
        port_veri_gecerli_r <= port_veri_gecerli_ns;
        port_istek_veri_r <= port_istek_veri_ns;
        port_veri_r <= port_veri_ns;
        port_yazma_istegi_r <= port_yazma_istegi_ns;
        l1_yol_guncellendi_r <= l1_yol_guncellendi_ns;
        l1_durum_r <= l1_durum_ns;
    end
end

endmodule