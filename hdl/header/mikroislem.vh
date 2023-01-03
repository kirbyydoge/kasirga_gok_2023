// Buyruk Bilgisi
`define UOP_VALID_BIT       1
`define UOP_VALID_PTR       0
`define UOP_VALID           0

`define UOP_PC_BIT          32
`define UOP_PC_PTR          (`UOP_VALID_PTR + `UOP_VALID_BIT)
`define UOP_PC              `UOP_PC_PTR +: `UOP_PC_BIT

`define UOP_TAG_BIT         4
`define UOP_TAG_PTR         (`UOP_PC_PTR + `UOP_PC_BIT)
`define UOP_TAG             `UOP_TAG_PTR +: `UOP_TAG_BIT

// Islecler (Simdilik 4 tane lazim sanirim? Islec iletmek gerekirse genisletilebilir)
`define UOP_RD_BIT          32
`define UOP_RD_PTR          (`UOP_TAG_PTR + `UOP_TAG_BIT)
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

// Aritmetik Mantik Birimi
`define UOP_AMB_NOP         0
`define UOP_AMB_ADD         1
`define UOP_AMB_SUB         2
`define UOP_AMB_DIV         3
`define UOP_AMB_MUL         4
`define UOP_AMB_AND         5
`define UOP_AMB_OR          6
`define UOP_AMB_XOR         7

`define UOP_AMB_BIT         3
`define UOP_AMB_PTR         (`UOP_RS1_PTR + `UOP_RS1_BIT)
`define UOP_AMB             `UOP_AMB_PTR +: `UOP_AMB_BIT

// Yazilacak veri secimi
`define UOP_YAZ_NOP         0
`define UOP_YAZ_AMB         1
`define UOP_YAZ_IS1         2
`define UOP_YAZ_DAL         3

`define UOP_YAZ_BIT         2
`define UOP_YAZ_PTR         (`UOP_AMB_PTR + `UOP_AMB_BIT)
`define UOP_YAZ             `UOP_YAZ_PTR +: `UOP_YAZ_BIT

// Dallanma Birimi
`define UOP_DAL_NOP             0
`define UOP_DAL_BEQ             1
`define UOP_DAL_BNE             2
`define UOP_DAL_BLT             3
`define UOP_DAL_JAL             4
`define UOP_DAL_JALR            5

`define UOP_DAL_BIT         2
`define UOP_DAL_PTR         (`UOP_YAZ_PTR + `UOP_YAZ_BIT)
`define UOP_DAL             `UOP_DAL_PTR +: `UOP_DAL_BIT

// Bellek Islemleri
`define UOP_BEL_NOP             0
`define UOP_BEL_LW              1
`define UOP_BEL_SW              2

`define UOP_BEL_BIT         2
`define UOP_BEL_PTR         (`UOP_DAL_PTR + `UOP_DAL_BIT)
`define UOP_BEL             `UOP_BEL_PTR +: `UOP_BEL_BIT

// TODO: CSR
// TODO: Compressed
// TODO: Yapaz Zeka Birimi
// TODO: Kriptografi Birimi

`define UOP_BIT (`UOP_BEL_PTR + `UOP_BEL_BIT) //!!! HER ZAMAN EN ANLAMLI YERLESTIRILEN MIKROSILEME GORE SECILMELI !!!

//!!! TODO: HER ASAMA ICIN MIKROISLEM TANIMLARI (COZ_UOP, YURUT_UOP...) YAPILMALI, BU SAYEDE UOP YAZMACLARI KUCULTULEBILIR !!!