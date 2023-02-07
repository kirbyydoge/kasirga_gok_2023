// Buyruk Bilgisi
`define UOP_VALID_BIT       1
`define UOP_VALID_PTR       0
`define UOP_VALID           0

`define UOP_PC_BIT          32
`define UOP_PC_PTR          `UOP_VALID_PTR + `UOP_VALID_BIT
`define UOP_PC              `UOP_PC_PTR +: `UOP_PC_BIT

`define UOP_TAG_BIT         4
`define UOP_TAG_PTR         `UOP_PC_PTR + `UOP_PC_BIT
`define UOP_TAG             `UOP_TAG_PTR +: `UOP_TAG_BIT

// RD yazmac adresi
`define UOP_RD_ADDR_BIT     5
`define UOP_RD_ADDR_PTR     `UOP_TAG_PTR + `UOP_TAG_BIT
`define UOP_RD_ADDR         `UOP_RD_ADDR_PTR +: `UOP_RD_ADDR_BIT

// RD'ye yazma yapilacagini belirten flag
`define UOP_RD_ALLOC_BIT    1
`define UOP_RD_ALLOC_PTR    `UOP_RD_ADDR_PTR + `UOP_RD_ADDR_BIT
`define UOP_RD_ALLOC        `UOP_RD_ALLOC_PTR +: `UOP_RD_ALLOC_BIT

// RS2'den okuma yapilacagini belirten flag
`define UOP_RS2_EN_BIT      1
`define UOP_RS2_EN_PTR      (`UOP_RD_ALLOC_PTR + `UOP_RD_ALLOC_BIT)
`define UOP_RS2_EN          `UOP_RS2_EN_PTR +: `UOP_RS2_EN_BIT

// RS1'den okuma yapilacagini belirten flag
`define UOP_RS1_EN_BIT      1
`define UOP_RS1_EN_PTR      (`UOP_RS2_EN_PTR + `UOP_RS2_EN_BIT)
`define UOP_RS1_EN          `UOP_RS1_EN_PTR +: `UOP_RS1_EN_BIT

// Islecler (Simdilik 4 tane lazim sanirim? Islec iletmek gerekirse genisletilebilir)
`define UOP_RD_BIT          32
`define UOP_RD_PTR          (`UOP_RS1_EN_PTR + `UOP_RS1_EN_BIT)
`define UOP_RD              `UOP_RD_PTR +: `UOP_RD_BIT

`define UOP_IMM_BIT         32
`define UOP_IMM_PTR         (`UOP_RD_PTR + `UOP_RD_BIT)
`define UOP_IMM             `UOP_IMM_PTR +: `UOP_IMM_BIT

`define UOP_RS2_BIT         32
`define UOP_RS2_PTR         (`UOP_IMM_PTR + `UOP_IMM_BIT)
`define UOP_RS2             `UOP_RS2_PTR +: `UOP_RS2_BIT

`define UOP_RS1_BIT         32
`define UOP_RS1_PTR         (`UOP_RS2_PTR + `UOP_RS2_BIT)
`define UOP_RS1             `UOP_RS1_PTR +: `UOP_RS1_BIT 

`define UOP_CSR_BIT         32
`define UOP_CSR_PTR         (`UOP_RS1_PTR + `UOP_RS1_BIT)
`define UOP_CSR             `UOP_CSR_PTR +: `UOP_CSR_BIT

`define UOP_CSR_ADDR_BIT    12
`define UOP_CSR_ADDR_PTR    (`UOP_CSR_PTR + `UOP_CSR_BIT)
`define UOP_CSR_ADDR        `UOP_CSR_ADDR_PTR +: `UOP_CSR_ADDR_BIT

`define UOP_CSR_ALLOC_BIT   1
`define UOP_CSR_ALLOC_PTR   (`UOP_CSR_ADDR_PTR + `UOP_CSR_ADDR_BIT)
`define UOP_CSR_ALLOC       `UOP_CSR_ALLOC_PTR +: `UOP_CSR_ALLOC_BIT

`define UOP_CSR_EN_BIT      1
`define UOP_CSR_EN_PTR      (`UOP_CSR_ALLOC_PTR + `UOP_CSR_ALLOC_BIT)
`define UOP_CSR_EN          `UOP_CSR_EN_PTR +: `UOP_CSR_EN_BIT

// Aritmetik Mantik Birimi
`define UOP_AMB_NOP         0
`define UOP_AMB_ADD         1
`define UOP_AMB_SUB         2
`define UOP_AMB_DIV         3
`define UOP_AMB_MUL         4
`define UOP_AMB_AND         5
`define UOP_AMB_OR          6
`define UOP_AMB_XOR         7
`define UOP_AMB_SLL         8
`define UOP_AMB_SRL         9
`define UOP_AMB_SRA         10
`define UOP_AMB_SLT         11
`define UOP_AMB_SLTU        12
`define UOP_AMB_HMDST       13
`define UOP_AMB_PKG         14
`define UOP_AMB_RVRS        15
`define UOP_AMB_SLADD       16
`define UOP_AMB_CNTZ        17
`define UOP_AMB_CNTP        18
`define UOP_AMB_MULH        19
`define UOP_AMB_MULHSU      20
`define UOP_AMB_MULHU       21
`define UOP_AMB_DIVU        22
`define UOP_AMB_REM         23
`define UOP_AMB_REMU        24

`define UOP_AMB_OP_NOP      0
`define UOP_AMB_OP_RS1      1
`define UOP_AMB_OP_RS2      2
`define UOP_AMB_OP_IMM      3
`define UOP_AMB_OP_CSR      4
`define UOP_AMB_OP_PC       5

`define UOP_AMB_OP_BIT      3

// Islecler hangi veriler olmali?
`define UOP_AMB_OP2_BIT     `UOP_AMB_OP_BIT
`define UOP_AMB_OP2_PTR     (`UOP_CSR_EN_PTR + `UOP_CSR_EN_BIT)
`define UOP_AMB_OP2         `UOP_AMB_OP2_PTR +: `UOP_AMB_OP2_BIT

`define UOP_AMB_OP1_BIT     `UOP_AMB_OP_BIT
`define UOP_AMB_OP1_PTR     (`UOP_AMB_OP2_PTR + `UOP_AMB_OP2_BIT)
`define UOP_AMB_OP1         `UOP_AMB_OP1_PTR +: `UOP_AMB_OP1_BIT

`define UOP_AMB_BIT         5
`define UOP_AMB_PTR         (`UOP_AMB_OP1_PTR + `UOP_AMB_OP1_BIT)
`define UOP_AMB             `UOP_AMB_PTR +: `UOP_AMB_BIT

// Yazilacak veri secimi
`define UOP_YAZ_NOP         0
`define UOP_YAZ_AMB         1
`define UOP_YAZ_IS1         2
`define UOP_YAZ_DAL         3
`define UOP_YAZ_CSR         4
`define UOP_YAZ_BEL         5
`define UOP_YAZ_YZB         6

`define UOP_YAZ_BIT         3
`define UOP_YAZ_PTR         (`UOP_AMB_PTR + `UOP_AMB_BIT)
`define UOP_YAZ             `UOP_YAZ_PTR +: `UOP_YAZ_BIT

// Dallanma Birimi
`define UOP_DAL_NOP             0
`define UOP_DAL_BEQ             1
`define UOP_DAL_BNE             2
`define UOP_DAL_BLT             3
`define UOP_DAL_JAL             4
`define UOP_DAL_JALR            5
`define UOP_DAL_BGE             6
`define UOP_DAL_BLTU            7
`define UOP_DAL_BGEU            8
`define UOP_DAL_CJAL            9
`define UOP_DAL_CJALR           10

`define UOP_DAL_BIT             4
`define UOP_DAL_PTR             (`UOP_YAZ_PTR + `UOP_YAZ_BIT)
`define UOP_DAL                 `UOP_DAL_PTR +: `UOP_DAL_BIT

`define UOP_TAKEN_BIT           1
`define UOP_TAKEN_PTR           (`UOP_DAL_PTR + `UOP_DAL_BIT)
`define UOP_TAKEN               `UOP_TAKEN_PTR +: `UOP_TAKEN_BIT

// Bellek Islemleri
`define UOP_BEL_NOP             0
`define UOP_BEL_LW              1
`define UOP_BEL_LH              2
`define UOP_BEL_LHU             3
`define UOP_BEL_LB              4
`define UOP_BEL_LBU             5
`define UOP_BEL_SW              6
`define UOP_BEL_SH              7
`define UOP_BEL_SB              8

`define UOP_BEL_BIT             4   //seçim için kullanılacak
`define UOP_BEL_PTR             (`UOP_TAKEN_PTR + `UOP_TAKEN_BIT)
`define UOP_BEL                 `UOP_BEL_PTR +: `UOP_BEL_BIT

`define EXC_CODE_IAM            0   // Instruction Address Misaligned
`define EXC_CODE_IS             1   // Illegal Instruction
`define EXC_CODE_LAM            4   // Load Address Misaligned
`define EXC_CODE_SAM            6   // Store Address Misaligned
`define EXC_CODE_MRET           11  // Environment call from M-mode

`define EXC_CODE_BIT            5

// CSR Islemleri
`define UOP_CSR_NOP             0
`define UOP_CSR_RW              1
`define UOP_CSR_RS              2
`define UOP_CSR_RC              3
`define UOP_CSR_MRET            4

`define UOP_CSR_OP_BIT          4 // CSR_OP berbat bir isim, AMB_OP1'deki OPerand ile buradaki CSR_OPeration kisaltmasi ayristirilmali
`define UOP_CSR_OP_PTR          (`UOP_BEL_PTR + `UOP_BEL_BIT)
`define UOP_CSR_OP              `UOP_CSR_OP_PTR +: `UOP_CSR_OP_BIT

// Yapaz Zeka Birimi
`define UOP_YZB_NOP             0
`define UOP_YZB_LDX_OP1         1
`define UOP_YZB_LDX_OP2         2
`define UOP_YZB_LDX_ALL         3
`define UOP_YZB_LDW_OP1         4
`define UOP_YZB_LDW_OP2         5
`define UOP_YZB_LDW_ALL         6
`define UOP_YZB_CLRX            7
`define UOP_YZB_CLRW            8
`define UOP_YZB_RUN             9

`define UOP_YZB_BIT             4
`define UOP_YZB_PTR             (`UOP_CSR_OP_PTR + `UOP_CSR_OP_BIT)
`define UOP_YZB                 `UOP_YZB_PTR +: `UOP_YZB_BIT

`define UOP_BIT                 (`UOP_YZB_PTR + `UOP_YZB_BIT)

//!!! TODO: HER ASAMA ICIN MIKROISLEM TANIMLARI (COZ_UOP, YURUT_UOP...) YAPILMALI, BU SAYEDE UOP YAZMACLARI KUCULTULEBILIR !!!