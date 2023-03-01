// ADDR is 20-bit, 4K address
// Flag includes: Strong Order, Cacheable, Bufferable, Reserved, Reserved
`define SYSMAP_BASE_ADDR0  20'hffff
`define SYSMAP_FLG0        5'b01100

`define SYSMAP_BASE_ADDR1  20'h2ffff
`define SYSMAP_FLG1        5'b00000

`define SYSMAP_BASE_ADDR2  20'h3ffff
`define SYSMAP_FLG2        5'b01100

`define SYSMAP_BASE_ADDR3  20'h6ffff
`define SYSMAP_FLG3        5'b00000

`define SYSMAP_BASE_ADDR4  20'haffff
`define SYSMAP_FLG4        5'b01100

`define SYSMAP_BASE_ADDR5  20'heffff
`define SYSMAP_FLG5        5'b10000

`define SYSMAP_BASE_ADDR6  20'hfff5f 
`define SYSMAP_FLG6        5'b01100

`define SYSMAP_BASE_ADDR7  20'hfffff 
`define SYSMAP_FLG7        5'b10000
