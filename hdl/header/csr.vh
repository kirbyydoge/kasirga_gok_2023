`define CSR_SPEC_BIT        12
`define CSR_ARCH_BIT        5
`define CSR_ARCH_N_REGS     18

//--------------------- SPEC ADRESLERI ---------------------
// Machine Information Registers
`define CSR_SPEC_MVENDORID  12'hF11
`define CSR_SPEC_MARCHID    12'hF12
`define CSR_SPEC_MIMPID     12'hF13
`define CSR_SPEC_MHARTID    12'hF14

// Machine Trap Setup
`define CSR_SPEC_MSTATUS    12'h300
`define CSR_SPEC_MISA       12'h301
`define CSR_SPEC_MIE        12'h304
`define CSR_SPEC_MTVEC      12'h305
`define CSR_SPEC_MSTATUSH   12'h310

// Machine Trap Handling
`define CSR_SPEC_MEPC       12'h341
`define CSR_SPEC_MCAUSE     12'h342
`define CSR_SPEC_MTVAL      12'h343
`define CSR_SPEC_MTIP       12'h345
`define CSR_SPEC_MTINST     12'h34A

// Machine Counter/Timers
`define CSR_SPEC_MCYCLE     12'hB00
`define CSR_SPEC_MINSTRET   12'hB02
`define CSR_SPEC_MCYCLEH    12'hB80
`define CSR_SPEC_MINSTRETH  12'hB82
//--------------------- SPEC ADRESLERI ---------------------

//--------------------- MIMARI ADRESLER ---------------------
// Machine Information Registers
`define CSR_MVENDORID  5'd1
`define CSR_MARCHID    5'd2
`define CSR_MIMPID     5'd3
`define CSR_MHARTID    5'd4

// Machine Trap Setup
`define CSR_MSTATUS    5'd5
`define CSR_MISA       5'd6
`define CSR_MIE        5'd7
`define CSR_MTVEC      5'd8
`define CSR_MSTATUSH   5'd9

// Machine Trap Handling
`define CSR_MEPC       5'd10
`define CSR_MCAUSE     5'd11
`define CSR_MTVAL      5'd12
`define CSR_MTIP       5'd13
`define CSR_MTINST     5'd14

// Machine Counter/Timers
`define CSR_MCYCLE     5'd15
`define CSR_MINSTRET   5'd16
`define CSR_MCYCLEH    5'd17
`define CSR_MINSTRETH  5'd18

//--------------------- MIMARI ADRESLER ---------------------
`define CSR_UNIMPLEMENTED {`CSR_ARCH_BIT{1'b0}}

//---- MISA ----
`define MISA_A          0
`define MISA_B          1
`define MISA_C          2
`define MISA_D          3
`define MISA_E          4
`define MISA_F          5
`define MISA_G          6
`define MISA_H          7
`define MISA_I          8
`define MISA_J          9
`define MISA_K          10
`define MISA_L          11
`define MISA_M          12
`define MISA_N          13
`define MISA_O          14
`define MISA_P          15
`define MISA_Q          16
`define MISA_R          17
`define MISA_S          18
`define MISA_T          19
`define MISA_U          20
`define MISA_V          21
`define MISA_W          22
`define MISA_X          23
`define MISA_Y          24
`define MISA_Z          25

`define MISA_MXL        `MXLEN-2 +: 2
`define MXL_32          2'd1
`define MXL_64          2'd2
`define MXL_128         2'd3
//---- MISA ----

//---- MSTATUS ----
`define MSTATUS_MIE     3
`define MSTATUS_MPIE    7
`define MSTATUS_MPP     12:11

`define PRIV_USER       2'd0
`define PRIV_SUPER      2'd1
`define PRIV_MACHINE    2'd3
//---- MSTATUS ----