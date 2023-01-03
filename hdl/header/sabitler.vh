//------Sentez Parametreleri------
`define VCU108
// `define NEXYS
// `define SBOX
// `define OPENLANE
// `define BUS_SIFRELI // Timer vb. bellek disindaki bilesenlerin trafigi sifreli mi?
//-----------Diger----------------
`define HIGH 1'b1
`define LOW  1'b0

`define VERI_BIT  32
`define VERI_BYTE (`VERI_BIT / 8)
`define PS_BIT    32
//-----------Bellek---------------
`define ADRES_BIT           32
`define BELLEK_BASLANGIC    'h4000_0000
`define BELLEK_BOYUT        'h0001_0000

//-----------Mikroislem-----------
`define UIS_BIT 414 //462

//-----------Adres Aralıkları-----------
`define UART_BASE_ADDR  32'h2000_0000
`define UART_MASK_ADDR  32'h0000_000f
`define SPI_BASE_ADDR   32'h2001_0000
`define SPI_MASK_ADDR   32'h0000_00ff
`define RAM_BASE_ADDR   32'h4000_0000
`define RAM_BASE        32'h4000_0000
`define RAM_MASK_ADDR   32'h0007_ffff
//-----------Getir----------------
`define BB_ADRES_BIT 32
`define BUYRUK_BIT 32

// ----------Getir 2--------------

// Getir 2 icin gecerli durumlar
`define GETIR 1
`define YAZMACTAN_GETIR 2
`define YAZMAC_TAMAMLA 4
`define C_FUNCT3_KAYDIRMA 13
`define C_FUNCT4_KAYDIRMA 12

//-----------Coz------------------
`define BUY_ISKODU 0
`define BUY_ISKODU_BIT 7
`define BUY_HY 7
`define BUY_HY_BIT 5
`define BUY_KY1 15
`define BUY_KY1_BIT 5
`define BUY_KY2 20
`define BUY_KY2_BIT 5
`define BUY_F7 25
`define BUY_F7_BIT 7
`define BUY_F3 12
`define BUY_F3_BIT 3

`define I_ANLIK 20
`define I_ANLIK_BIT 12
`define I_ANLIK_ISARET 31

`define U_ANLIK 12
`define U_ANLIK_BIT 20

`define ODD_BIT 5
//Compress
`define C_BUYRUK_BIT 16

`define C_BUY_ISKODU 0
`define C_BUY_ISKODU_BIT 2

//CR
/*
CR type: .insn cr opcode2, func4, rd, rs2
    +---------+--------+-----+---------+
    |   func4 | rd/rs1 | rs2 | opcode2 |
    +---------+--------+-----+---------+
    15        12       7     2        0*/
`define C_BUY_KY2 2
`define C_BUY_KY2_BIT 5

`define C_BUY_HY_KY1 7
`define C_BUY_HY_KY1_BIT 5

`define C_BUY_F4 12
`define C_BUY_F4_BIT 4

//CI
/*     
CI type: .insn ci opcode2, func3, rd, simm6
    +---------+-----+--------+-----+---------+
    |   func3 | imm | rd/rs1 | imm | opcode2 |
    +---------+-----+--------+-----+---------+
    15        13    12       7     2         0 */
`define C_ANLIK_5 2
`define C_ANLIK_5_BIT 5

`define C_BUY_HY_KY1 7
`define C_BUY_HY_KY1_BIT 5

`define C_ANLIK_1 12
`define C_ANLIK_1_BIT 1

`define C_BUY_F3 13
`define C_BUY_F3_BIT 3

//CIW
/*    
CIW type: .insn ciw opcode2, func3, rd, uimm8
    +---------+--------------+-----+---------+
    |   func3 |          imm | rd' | opcode2 |
    +---------+--------------+-----+---------+
    15        13            *7     2         0*/
`define C_BUY_HY 2
`define C_BUY_HY_BIT 3

`define C_ANLIK_8 5
`define C_ANLIK_8_BIT 8

`define C_BUY_F3 13
// `define C_BUY_F3_BIT 3    

//CB Branch
/*     
CB type: .insn cb opcode2, func3, rs1, symbol
    +---------+--------+------+--------+---------+
    |   func3 | offset | rs1' | offset | opcode2 |
    +---------+--------+------+--------+---------+
    15        13       10     7        2         0*/
`define C_BUY_OFS_5 2
`define C_BUY_OFS_5_BIT 5

`define C_BUY_KY1 7
// `define C_BUY_OFS_5_BIT 3

`define C_BUY_OFS_3 10
//`define C_BUY_OFS_5_BIT 3

`define C_BUY_F3 13
// `define C_BUY_F3_BIT 3
    

/*    
CJ type: .insn cj opcode2, symbol
    +---------+--------------------+---------+
    |   func3 |        jump target | opcode2 |
    +---------+--------------------+---------+
    15        13             7     2         0
*/
`define C_BUY_JUMPT 2
`define C_BUY_JUMPT_BIT 11

`define C_BUY_F3 13
`define C_BUY_F3_BIT 3

//---------Yurut------------------
`define DDY_ADRES_BIT 12

//-------------DDY---------------
// Kural disi durum kodlari
`define KDD_HBA   32'd0   // hizasiz buyruk adresi
`define KDD_YB    32'd2   // yanlis buyruk
`define KDD_HYA   32'd4   // hizasiz yukle buyrugu
`define KDD_HKA   32'd6   // hizasiz kaydet buyrugu
`define KDD_MRET  32'd11  // makine modundan ortam cagrisi

//-------Önbellek Denetleyiciler----------
`define L1_BLOK_BIT 64    
`define L1_SATIR    128
`define L1_YOL      4
`define L1_BOYUT    (`L1_BLOK_BIT * `L1_SATIR * `L1_YOL) // Teknofest 2022-2023 icin 4KB olmali

`define ADRES_BYTE_BIT      3 // Veriyi byte adreslemek icin gereken bit
`define ADRES_BYTE_OFFSET   0 // ADRES_BYTE ilk bitine erismek icin gereken kaydirma
`define ADRES_SATIR_BIT     7 // Satirlari indexlemek icin gereken bit
`define ADRES_SATIR_OFFSET  `ADRES_BYTE_BIT // ADRES_SATIR ilk bitine erismek icin gereken kaydirma
`define ADRES_ETIKET_BIT    (32 - `ADRES_SATIR_BIT - `ADRES_BYTE_BIT) // Adresin kalan kismi
`define ADRES_ETIKET_OFFSET (`ADRES_BYTE_BIT + `ADRES_SATIR_BIT) // Adresin kalan kismi

`define L1_BLOK_BYTE (`L1_BLOK_BIT / 8)

//////////////////////////////
// MSTATUS yazmac offsetleri
`define MSTATUS_MIE       3       
`define MSTATUS_MPIE      7 
`define MSTATUS_MPP       11

//////////////////////////////
// CSR
`define DDY_MSTATUS       12'h300
`define DDY_MISA          12'h301
`define DDY_MEDELEG       12'h302
`define DDY_MIDELEG       12'h303
`define DDY_MIE           12'h304
`define DDY_MTVEC         12'h305
`define DDY_MSCRATCH      12'h340
`define DDY_MEPC          12'h341
`define DDY_MCAUSE        12'h342
`define DDY_MTVAL         12'h343
`define DDY_MIP           12'h344
`define DDY_MCYCLE        12'hc00
`define DDY_MTIME         12'hc01
`define DDY_MTIMEH        12'hc81
`define DDY_MHARTID       12'hF14

// ----Yardımcı Tanımlamalar----
`define ALL_ONES_256        256'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF
`define ALL_ONES_128        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF
`define ALL_ONES_64          64'hFFFF_FFFF_FFFF_FFFF
`define ALL_ONES_32          32'hFFFF_FFFF