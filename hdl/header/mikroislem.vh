///////////////////////////
// Mikroislem sinyalleri//
`define PS_BIT 32
`define PS 0

`define SIRADAKI_PS_BIT 32
`define SIRADAKI_PS 32

`define SIRADAKI_PS_GECERLI 64

`define HY_BIT 5
`define HY 65

`define HY_DEGER_BIT 64
`define HY_DEGER 70

`define HY_YAZ 134

`define BELLEK_ISARETLI 135

`define BELLEK_TURU_BIT 4
`define BELLEK_TURU 136

`define BELLEK_BUYRUGU_BIT 3
`define BELLEK_BUYRUGU 140

`define KY2_BIT 5
`define KY2 143

`define KY2_DEGER_BIT 64
`define KY2_DEGER 148

`define KY1_BIT 5
`define KY1 212

`define KY1_DEGER_BIT 64
`define KY1_DEGER 217

`define ANLIK_DEGER_BIT 64
`define ANLIK_DEGER 281

`define IS2_SEC_BIT 5
`define IS2_SEC 345

`define IS1_SEC_BIT 3
`define IS1_SEC 350

`define ISLEV_KODU_BIT 12
`define ISLEV_KODU 353

`define YURUT_KODU_BIT 9
`define YURUT_KODU 365

`define GECERLI 374

`define W_BUYRUGU 375

`define YO_TAG_BIT 5
`define YO_TAG 376

`define C_MI 381

`define BUYRUK 382
`define BUY_BIT 32

// 414 bit mikroislem

////////////////////////
 // BELLEK_TURU kodları//
// `define BELLEK_TURU_W 'h1
// `define BELLEK_TURU_HW 'h2
// `define BELLEK_TURU_B 'h4
// `define BELLEK_TURU_DW 'h8
////////////////////////
 // IS1_SEC kodları//
`define IS2_SEC_KY2 'h1
`define IS2_SEC_AD 'h2
`define IS2_SEC_4 'h4
`define IS2_SEC_0 'h8
`define IS2_SEC_CSR_AD 'h10
////////////////////////
 // IS2_SEC kodları//
`define IS1_SEC_KY1 'h1
`define IS1_SEC_PS 'h2
`define IS1_SEC_0 'h4
////////////////////////
 // Yurut kodlari//
`define YURUT_KODU_AMB 'h1
`define YURUT_KODU_DB 'h2
`define YURUT_KODU_BIB 'h4
`define YURUT_KODU_TCB 'h8
`define YURUT_KODU_TBB 'h10
`define YURUT_KODU_CSR 'h20
`define YURUT_KODU_SISTEM 'h40
`define YURUT_KODU_AMBP 'h80
`define YURUT_KODU_XB 'h100
////////////////////////
 // AMBP islev kodlari//
 `define ADD 'h1
 `define SUB 'h2
////////////////////////
 // AMB islev kodlari//
 `define AND 'h1
 `define OR 'h2
 `define XOR 'h4
 `define SLT 'h8
 `define SLTU 'h10
 `define SLL 'h20
 `define SRL 'h40
 `define SRA 'h80
 `define LUI 'h100
 `define AUIPC 'h200
/////////////////////////
 // TCB islev kodlari //
 `define MUL 'h1
 `define MULH 'h2
 `define MULHU 'h4
 `define MULHSU 'h8
/////////////////////////
 // TBB islev kodlari //
 `define DIV 'h1
 `define DIVU 'h2
 `define REM 'h4
 `define REMU 'h8
/////////////////////////
 // X islev kodlari //
 `define HMDST  'h01
 `define PKG    'h02
 `define RVRS   'h04
 `define SLADD  'h08
 `define CNTZ   'h10
 `define CNTP   'h20
////////////////////////
 // DB islev kodlari //
 `define JAL  'h1
 `define JALR 'h2
 `define BEQ  'h4
 `define BNE  'h8
 `define BLT  'h10
 `define BLTU 'h20
 `define BGE  'h40
 `define BGEU 'h80
////////////////////////
 // DB compressed islev kodlari //
 `define CJAL   'h1 //CJ CJAL
 `define CJALR  'h2 // CJALR CJR
 `define CBEQZ  'h4 // CBEQZ
 `define CBNEZ  'h8 //CBNEZ
 //`define CJR    'h10 
 //`define CJALR  'h20
/////////////////////////
 // BIB islev kodlari //
 `define LW    'h1 
 `define LH    'h2 
 `define LHU   'h4 
 `define LB    'h8 
 `define LBU   'h10
 `define SW    'h20
 `define SH    'h40
 `define SB    'h80
 `define FENCE 'h100
 `define LWU   'h200 //rv64i
 `define LD    'h400 //rv64i
 `define SD    'h800 //rv64i
 /////////////////////////////
 // Bellk Buyrugu tanimlamalari//
 `define FENCE_b 'h1
 `define KAYDET_b 'h2
 `define YUKLE_b 'h4
 //////////////////////////////
 // CSR islev kodlari //
 `define ECALL  'h1
 `define EBREAK 'h2
 `define URET   'h4
 `define MRET   'h8
 `define CSRRW  'h10
 `define CSRRS  'h20
 `define CSRRC  'h40 
 `define CSRRWI  'h80
 `define CSRRSI  'h100
 `define CSRRCI  'h200
