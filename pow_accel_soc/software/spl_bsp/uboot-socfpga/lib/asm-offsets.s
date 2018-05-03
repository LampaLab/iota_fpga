	.arch armv7-a
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 4
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"asm-offsets.c"
	.text
.Ltext0:
	.cfi_sections	.debug_frame
	.section	.text.startup,"ax",%progbits
	.align	1
	.global	main
	.syntax unified
	.thumb
	.thumb_func
	.fpu softvfp
	.type	main, %function
main:
.LFB110:
	.file 1 "lib/asm-offsets.c"
	.loc 1 23 0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 25 0
	.syntax unified
@ 25 "lib/asm-offsets.c" 1
	
->GENERATED_GBL_DATA_SIZE #128 (sizeof(struct global_data) + 15) & ~15
@ 0 "" 2
	.loc 1 28 0
@ 28 "lib/asm-offsets.c" 1
	
->GENERATED_BD_INFO_SIZE #32 (sizeof(struct bd_info) + 15) & ~15
@ 0 "" 2
	.loc 1 31 0
@ 31 "lib/asm-offsets.c" 1
	
->GD_SIZE #128 sizeof(struct global_data)
@ 0 "" 2
	.loc 1 33 0
@ 33 "lib/asm-offsets.c" 1
	
->GD_BD #0 offsetof(struct global_data, bd)
@ 0 "" 2
	.loc 1 37 0
@ 37 "lib/asm-offsets.c" 1
	
->GD_RELOCADDR #52 offsetof(struct global_data, relocaddr)
@ 0 "" 2
	.loc 1 39 0
@ 39 "lib/asm-offsets.c" 1
	
->GD_RELOC_OFF #72 offsetof(struct global_data, reloc_off)
@ 0 "" 2
	.loc 1 41 0
@ 41 "lib/asm-offsets.c" 1
	
->GD_START_ADDR_SP #68 offsetof(struct global_data, start_addr_sp)
@ 0 "" 2
	.loc 1 46 0
	.thumb
	.syntax unified
	movs	r0, #0
	bx	lr
	.cfi_endproc
.LFE110:
	.size	main, .-main
	.text
.Letext0:
	.file 2 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/common.h"
	.file 3 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/asm/types.h"
	.file 4 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/linux/types.h"
	.file 5 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/asm/arch/clock_manager.h"
	.file 6 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/linux/string.h"
	.file 7 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/ide.h"
	.file 8 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/lmb.h"
	.file 9 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/asm/u-boot.h"
	.file 10 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/image.h"
	.file 11 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/asm/mach-types.h"
	.file 12 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/asm/setup.h"
	.file 13 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/asm/u-boot-arm.h"
	.file 14 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/net.h"
	.file 15 "/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp/uboot-socfpga/include/environment.h"
	.section	.debug_info,"",%progbits
.Ldebug_info0:
	.4byte	0x98a
	.2byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	.LASF152
	.byte	0xc
	.4byte	.LASF153
	.4byte	.LASF154
	.4byte	.Ldebug_ranges0+0
	.4byte	0
	.4byte	.Ldebug_line0
	.uleb128 0x2
	.4byte	.LASF9
	.byte	0x2
	.byte	0x20
	.4byte	0x30
	.uleb128 0x3
	.byte	0x1
	.byte	0x8
	.4byte	.LASF0
	.uleb128 0x4
	.4byte	0x30
	.uleb128 0x3
	.byte	0x4
	.byte	0x7
	.4byte	.LASF1
	.uleb128 0x3
	.byte	0x2
	.byte	0x7
	.4byte	.LASF2
	.uleb128 0x3
	.byte	0x4
	.byte	0x7
	.4byte	.LASF3
	.uleb128 0x5
	.byte	0x4
	.byte	0x5
	.ascii	"int\000"
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.4byte	.LASF4
	.uleb128 0x3
	.byte	0x4
	.byte	0x7
	.4byte	.LASF5
	.uleb128 0x6
	.byte	0x4
	.4byte	0x6c
	.uleb128 0x3
	.byte	0x1
	.byte	0x8
	.4byte	.LASF6
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.4byte	.LASF7
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.4byte	.LASF8
	.uleb128 0x2
	.4byte	.LASF10
	.byte	0x3
	.byte	0xc
	.4byte	0x30
	.uleb128 0x3
	.byte	0x2
	.byte	0x5
	.4byte	.LASF11
	.uleb128 0x2
	.4byte	.LASF12
	.byte	0x3
	.byte	0x12
	.4byte	0x5f
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.4byte	.LASF13
	.uleb128 0x7
	.ascii	"u8\000"
	.byte	0x3
	.byte	0x1f
	.4byte	0x30
	.uleb128 0x7
	.ascii	"u32\000"
	.byte	0x3
	.byte	0x25
	.4byte	0x5f
	.uleb128 0x2
	.4byte	.LASF14
	.byte	0x3
	.byte	0x30
	.4byte	0x3c
	.uleb128 0x2
	.4byte	.LASF15
	.byte	0x3
	.byte	0x31
	.4byte	0x3c
	.uleb128 0x2
	.4byte	.LASF16
	.byte	0x4
	.byte	0x5a
	.4byte	0x43
	.uleb128 0x2
	.4byte	.LASF17
	.byte	0x4
	.byte	0x5c
	.4byte	0x3c
	.uleb128 0x2
	.4byte	.LASF18
	.byte	0x4
	.byte	0x6a
	.4byte	0x81
	.uleb128 0x2
	.4byte	.LASF19
	.byte	0x4
	.byte	0x6c
	.4byte	0x93
	.uleb128 0x2
	.4byte	.LASF20
	.byte	0x4
	.byte	0x88
	.4byte	0x93
	.uleb128 0x8
	.4byte	.LASF21
	.byte	0x5
	.2byte	0x103
	.4byte	0x3c
	.uleb128 0x8
	.4byte	.LASF22
	.byte	0x5
	.2byte	0x104
	.4byte	0x3c
	.uleb128 0x8
	.4byte	.LASF23
	.byte	0x5
	.2byte	0x105
	.4byte	0x3c
	.uleb128 0x9
	.4byte	.LASF24
	.byte	0x6
	.byte	0xb
	.4byte	0x66
	.uleb128 0xa
	.byte	0x4
	.uleb128 0xb
	.4byte	0xdb
	.4byte	0x143
	.uleb128 0xc
	.byte	0
	.uleb128 0x9
	.4byte	.LASF25
	.byte	0x7
	.byte	0x1e
	.4byte	0x138
	.uleb128 0x3
	.byte	0x8
	.byte	0x4
	.4byte	.LASF26
	.uleb128 0xd
	.4byte	.LASF29
	.byte	0x8
	.byte	0x8
	.byte	0x14
	.4byte	0x17a
	.uleb128 0xe
	.4byte	.LASF27
	.byte	0x8
	.byte	0x15
	.4byte	0xba
	.byte	0
	.uleb128 0xe
	.4byte	.LASF28
	.byte	0x8
	.byte	0x16
	.4byte	0xc5
	.byte	0x4
	.byte	0
	.uleb128 0xd
	.4byte	.LASF30
	.byte	0x50
	.byte	0x8
	.byte	0x19
	.4byte	0x1ab
	.uleb128 0xf
	.ascii	"cnt\000"
	.byte	0x8
	.byte	0x1a
	.4byte	0x3c
	.byte	0
	.uleb128 0xe
	.4byte	.LASF28
	.byte	0x8
	.byte	0x1b
	.4byte	0xc5
	.byte	0x4
	.uleb128 0xe
	.4byte	.LASF31
	.byte	0x8
	.byte	0x1c
	.4byte	0x1ab
	.byte	0x8
	.byte	0
	.uleb128 0xb
	.4byte	0x155
	.4byte	0x1bb
	.uleb128 0x10
	.4byte	0x4a
	.byte	0x8
	.byte	0
	.uleb128 0x11
	.ascii	"lmb\000"
	.byte	0xa0
	.byte	0x8
	.byte	0x1f
	.4byte	0x1e0
	.uleb128 0xe
	.4byte	.LASF32
	.byte	0x8
	.byte	0x20
	.4byte	0x17a
	.byte	0
	.uleb128 0xe
	.4byte	.LASF33
	.byte	0x8
	.byte	0x21
	.4byte	0x17a
	.byte	0x50
	.byte	0
	.uleb128 0x12
	.ascii	"lmb\000"
	.byte	0x8
	.byte	0x24
	.4byte	0x1bb
	.uleb128 0x13
	.byte	0x8
	.byte	0x9
	.byte	0x2e
	.4byte	0x20c
	.uleb128 0xe
	.4byte	.LASF34
	.byte	0x9
	.byte	0x30
	.4byte	0xdb
	.byte	0
	.uleb128 0xe
	.4byte	.LASF28
	.byte	0x9
	.byte	0x31
	.4byte	0xdb
	.byte	0x4
	.byte	0
	.uleb128 0xd
	.4byte	.LASF35
	.byte	0x20
	.byte	0x9
	.byte	0x27
	.4byte	0x26d
	.uleb128 0xe
	.4byte	.LASF36
	.byte	0x9
	.byte	0x28
	.4byte	0x5f
	.byte	0
	.uleb128 0xe
	.4byte	.LASF37
	.byte	0x9
	.byte	0x29
	.4byte	0xdb
	.byte	0x4
	.uleb128 0xe
	.4byte	.LASF38
	.byte	0x9
	.byte	0x2a
	.4byte	0xdb
	.byte	0x8
	.uleb128 0xe
	.4byte	.LASF39
	.byte	0x9
	.byte	0x2b
	.4byte	0x3c
	.byte	0xc
	.uleb128 0xe
	.4byte	.LASF40
	.byte	0x9
	.byte	0x2c
	.4byte	0x3c
	.byte	0x10
	.uleb128 0xe
	.4byte	.LASF41
	.byte	0x9
	.byte	0x2d
	.4byte	0x3c
	.byte	0x14
	.uleb128 0xe
	.4byte	.LASF42
	.byte	0x9
	.byte	0x32
	.4byte	0x26d
	.byte	0x18
	.byte	0
	.uleb128 0xb
	.4byte	0x1eb
	.4byte	0x27d
	.uleb128 0x10
	.4byte	0x4a
	.byte	0
	.byte	0
	.uleb128 0x2
	.4byte	.LASF43
	.byte	0x9
	.byte	0x33
	.4byte	0x20c
	.uleb128 0xd
	.4byte	.LASF44
	.byte	0x40
	.byte	0xa
	.byte	0xbd
	.4byte	0x325
	.uleb128 0xe
	.4byte	.LASF45
	.byte	0xa
	.byte	0xbe
	.4byte	0xfc
	.byte	0
	.uleb128 0xe
	.4byte	.LASF46
	.byte	0xa
	.byte	0xbf
	.4byte	0xfc
	.byte	0x4
	.uleb128 0xe
	.4byte	.LASF47
	.byte	0xa
	.byte	0xc0
	.4byte	0xfc
	.byte	0x8
	.uleb128 0xe
	.4byte	.LASF48
	.byte	0xa
	.byte	0xc1
	.4byte	0xfc
	.byte	0xc
	.uleb128 0xe
	.4byte	.LASF49
	.byte	0xa
	.byte	0xc2
	.4byte	0xfc
	.byte	0x10
	.uleb128 0xe
	.4byte	.LASF50
	.byte	0xa
	.byte	0xc3
	.4byte	0xfc
	.byte	0x14
	.uleb128 0xe
	.4byte	.LASF51
	.byte	0xa
	.byte	0xc4
	.4byte	0xfc
	.byte	0x18
	.uleb128 0xe
	.4byte	.LASF52
	.byte	0xa
	.byte	0xc5
	.4byte	0xe6
	.byte	0x1c
	.uleb128 0xe
	.4byte	.LASF53
	.byte	0xa
	.byte	0xc6
	.4byte	0xe6
	.byte	0x1d
	.uleb128 0xe
	.4byte	.LASF54
	.byte	0xa
	.byte	0xc7
	.4byte	0xe6
	.byte	0x1e
	.uleb128 0xe
	.4byte	.LASF55
	.byte	0xa
	.byte	0xc8
	.4byte	0xe6
	.byte	0x1f
	.uleb128 0xe
	.4byte	.LASF56
	.byte	0xa
	.byte	0xc9
	.4byte	0x325
	.byte	0x20
	.byte	0
	.uleb128 0xb
	.4byte	0xe6
	.4byte	0x335
	.uleb128 0x10
	.4byte	0x4a
	.byte	0x1f
	.byte	0
	.uleb128 0x2
	.4byte	.LASF57
	.byte	0xa
	.byte	0xca
	.4byte	0x288
	.uleb128 0xd
	.4byte	.LASF58
	.byte	0x18
	.byte	0xa
	.byte	0xcc
	.4byte	0x3ac
	.uleb128 0xe
	.4byte	.LASF34
	.byte	0xa
	.byte	0xcd
	.4byte	0xdb
	.byte	0
	.uleb128 0xf
	.ascii	"end\000"
	.byte	0xa
	.byte	0xcd
	.4byte	0xdb
	.byte	0x4
	.uleb128 0xe
	.4byte	.LASF59
	.byte	0xa
	.byte	0xce
	.4byte	0xdb
	.byte	0x8
	.uleb128 0xe
	.4byte	.LASF60
	.byte	0xa
	.byte	0xce
	.4byte	0xdb
	.byte	0xc
	.uleb128 0xe
	.4byte	.LASF61
	.byte	0xa
	.byte	0xcf
	.4byte	0xdb
	.byte	0x10
	.uleb128 0xe
	.4byte	.LASF62
	.byte	0xa
	.byte	0xd0
	.4byte	0xe6
	.byte	0x14
	.uleb128 0xe
	.4byte	.LASF63
	.byte	0xa
	.byte	0xd0
	.4byte	0xe6
	.byte	0x15
	.uleb128 0xf
	.ascii	"os\000"
	.byte	0xa
	.byte	0xd0
	.4byte	0xe6
	.byte	0x16
	.byte	0
	.uleb128 0x2
	.4byte	.LASF64
	.byte	0xa
	.byte	0xd1
	.4byte	0x340
	.uleb128 0x14
	.4byte	.LASF65
	.2byte	0x130
	.byte	0xa
	.byte	0xd7
	.4byte	0x493
	.uleb128 0xe
	.4byte	.LASF66
	.byte	0xa
	.byte	0xdd
	.4byte	0x493
	.byte	0
	.uleb128 0xe
	.4byte	.LASF67
	.byte	0xa
	.byte	0xde
	.4byte	0x335
	.byte	0x4
	.uleb128 0xe
	.4byte	.LASF68
	.byte	0xa
	.byte	0xdf
	.4byte	0xdb
	.byte	0x44
	.uleb128 0xf
	.ascii	"os\000"
	.byte	0xa
	.byte	0xf2
	.4byte	0x3ac
	.byte	0x48
	.uleb128 0xf
	.ascii	"ep\000"
	.byte	0xa
	.byte	0xf3
	.4byte	0xdb
	.byte	0x60
	.uleb128 0xe
	.4byte	.LASF69
	.byte	0xa
	.byte	0xf5
	.4byte	0xdb
	.byte	0x64
	.uleb128 0xe
	.4byte	.LASF70
	.byte	0xa
	.byte	0xf5
	.4byte	0xdb
	.byte	0x68
	.uleb128 0xe
	.4byte	.LASF71
	.byte	0xa
	.byte	0xf8
	.4byte	0x66
	.byte	0x6c
	.uleb128 0xe
	.4byte	.LASF72
	.byte	0xa
	.byte	0xfa
	.4byte	0xdb
	.byte	0x70
	.uleb128 0xe
	.4byte	.LASF73
	.byte	0xa
	.byte	0xfc
	.4byte	0xdb
	.byte	0x74
	.uleb128 0xe
	.4byte	.LASF74
	.byte	0xa
	.byte	0xfd
	.4byte	0xdb
	.byte	0x78
	.uleb128 0xe
	.4byte	.LASF75
	.byte	0xa
	.byte	0xfe
	.4byte	0xdb
	.byte	0x7c
	.uleb128 0xe
	.4byte	.LASF76
	.byte	0xa
	.byte	0xff
	.4byte	0xdb
	.byte	0x80
	.uleb128 0x15
	.ascii	"kbd\000"
	.byte	0xa
	.2byte	0x100
	.4byte	0x499
	.byte	0x84
	.uleb128 0x16
	.4byte	.LASF77
	.byte	0xa
	.2byte	0x103
	.4byte	0x51
	.byte	0x88
	.uleb128 0x16
	.4byte	.LASF78
	.byte	0xa
	.2byte	0x10d
	.4byte	0x51
	.byte	0x8c
	.uleb128 0x15
	.ascii	"lmb\000"
	.byte	0xa
	.2byte	0x110
	.4byte	0x1bb
	.byte	0x90
	.byte	0
	.uleb128 0x6
	.byte	0x4
	.4byte	0x335
	.uleb128 0x6
	.byte	0x4
	.4byte	0x27d
	.uleb128 0x17
	.4byte	.LASF79
	.byte	0xa
	.2byte	0x112
	.4byte	0x3b7
	.uleb128 0x8
	.4byte	.LASF80
	.byte	0xa
	.2byte	0x114
	.4byte	0x49f
	.uleb128 0xb
	.4byte	0x6c
	.4byte	0x4c7
	.uleb128 0x10
	.4byte	0x4a
	.byte	0x1f
	.byte	0
	.uleb128 0xb
	.4byte	0x6c
	.4byte	0x4d2
	.uleb128 0xc
	.byte	0
	.uleb128 0x8
	.4byte	.LASF81
	.byte	0x2
	.2byte	0x12c
	.4byte	0x4c7
	.uleb128 0x8
	.4byte	.LASF82
	.byte	0x2
	.2byte	0x135
	.4byte	0xdb
	.uleb128 0xb
	.4byte	0xa5
	.4byte	0x4f5
	.uleb128 0xc
	.byte	0
	.uleb128 0x8
	.4byte	.LASF83
	.byte	0x2
	.2byte	0x137
	.4byte	0x4ea
	.uleb128 0x8
	.4byte	.LASF84
	.byte	0x2
	.2byte	0x149
	.4byte	0xdb
	.uleb128 0x8
	.4byte	.LASF85
	.byte	0x2
	.2byte	0x14a
	.4byte	0xdb
	.uleb128 0x8
	.4byte	.LASF86
	.byte	0x2
	.2byte	0x14b
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF87
	.byte	0xb
	.byte	0xb
	.4byte	0x5f
	.uleb128 0x18
	.byte	0xc
	.byte	0xc
	.2byte	0x104
	.4byte	0x561
	.uleb128 0x16
	.4byte	.LASF34
	.byte	0xc
	.2byte	0x105
	.4byte	0x3c
	.byte	0
	.uleb128 0x16
	.4byte	.LASF28
	.byte	0xc
	.2byte	0x106
	.4byte	0x3c
	.byte	0x4
	.uleb128 0x16
	.4byte	.LASF88
	.byte	0xc
	.2byte	0x107
	.4byte	0x51
	.byte	0x8
	.byte	0
	.uleb128 0x19
	.4byte	.LASF89
	.byte	0x68
	.byte	0xc
	.2byte	0x101
	.4byte	0x596
	.uleb128 0x16
	.4byte	.LASF90
	.byte	0xc
	.2byte	0x102
	.4byte	0x51
	.byte	0
	.uleb128 0x15
	.ascii	"end\000"
	.byte	0xc
	.2byte	0x103
	.4byte	0x3c
	.byte	0x4
	.uleb128 0x16
	.4byte	.LASF91
	.byte	0xc
	.2byte	0x108
	.4byte	0x596
	.byte	0x8
	.byte	0
	.uleb128 0xb
	.4byte	0x530
	.4byte	0x5a6
	.uleb128 0x10
	.4byte	0x4a
	.byte	0x7
	.byte	0
	.uleb128 0x8
	.4byte	.LASF89
	.byte	0xc
	.2byte	0x10b
	.4byte	0x561
	.uleb128 0x9
	.4byte	.LASF92
	.byte	0xd
	.byte	0x21
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF93
	.byte	0xd
	.byte	0x22
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF94
	.byte	0xd
	.byte	0x23
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF95
	.byte	0xd
	.byte	0x24
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF96
	.byte	0xd
	.byte	0x25
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF97
	.byte	0xd
	.byte	0x26
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF98
	.byte	0xd
	.byte	0x27
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF99
	.byte	0xd
	.byte	0x28
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF100
	.byte	0xd
	.byte	0x29
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF101
	.byte	0xd
	.byte	0x2a
	.4byte	0xdb
	.uleb128 0x9
	.4byte	.LASF102
	.byte	0xd
	.byte	0x2b
	.4byte	0xdb
	.uleb128 0x2
	.4byte	.LASF103
	.byte	0xe
	.byte	0x2a
	.4byte	0xaf
	.uleb128 0x6
	.byte	0x4
	.4byte	0x25
	.uleb128 0xd
	.4byte	.LASF104
	.byte	0x40
	.byte	0xe
	.byte	0x51
	.4byte	0x6d9
	.uleb128 0xe
	.4byte	.LASF105
	.byte	0xe
	.byte	0x52
	.4byte	0x6d9
	.byte	0
	.uleb128 0xe
	.4byte	.LASF106
	.byte	0xe
	.byte	0x53
	.4byte	0x6e9
	.byte	0x10
	.uleb128 0xe
	.4byte	.LASF107
	.byte	0xe
	.byte	0x54
	.4byte	0x51
	.byte	0x18
	.uleb128 0xe
	.4byte	.LASF78
	.byte	0xe
	.byte	0x55
	.4byte	0x51
	.byte	0x1c
	.uleb128 0xe
	.4byte	.LASF108
	.byte	0xe
	.byte	0x57
	.4byte	0x713
	.byte	0x20
	.uleb128 0xe
	.4byte	.LASF109
	.byte	0xe
	.byte	0x58
	.4byte	0x732
	.byte	0x24
	.uleb128 0xe
	.4byte	.LASF110
	.byte	0xe
	.byte	0x59
	.4byte	0x747
	.byte	0x28
	.uleb128 0xe
	.4byte	.LASF111
	.byte	0xe
	.byte	0x5a
	.4byte	0x758
	.byte	0x2c
	.uleb128 0xe
	.4byte	.LASF112
	.byte	0xe
	.byte	0x5e
	.4byte	0x747
	.byte	0x30
	.uleb128 0xe
	.4byte	.LASF113
	.byte	0xe
	.byte	0x5f
	.4byte	0x70d
	.byte	0x34
	.uleb128 0xe
	.4byte	.LASF114
	.byte	0xe
	.byte	0x60
	.4byte	0x51
	.byte	0x38
	.uleb128 0xe
	.4byte	.LASF115
	.byte	0xe
	.byte	0x61
	.4byte	0x136
	.byte	0x3c
	.byte	0
	.uleb128 0xb
	.4byte	0x6c
	.4byte	0x6e9
	.uleb128 0x10
	.4byte	0x4a
	.byte	0xf
	.byte	0
	.uleb128 0xb
	.4byte	0x30
	.4byte	0x6f9
	.uleb128 0x10
	.4byte	0x4a
	.byte	0x5
	.byte	0
	.uleb128 0x1a
	.4byte	0x51
	.4byte	0x70d
	.uleb128 0x1b
	.4byte	0x70d
	.uleb128 0x1b
	.4byte	0x499
	.byte	0
	.uleb128 0x6
	.byte	0x4
	.4byte	0x63c
	.uleb128 0x6
	.byte	0x4
	.4byte	0x6f9
	.uleb128 0x1a
	.4byte	0x51
	.4byte	0x732
	.uleb128 0x1b
	.4byte	0x70d
	.uleb128 0x1b
	.4byte	0x136
	.uleb128 0x1b
	.4byte	0x51
	.byte	0
	.uleb128 0x6
	.byte	0x4
	.4byte	0x719
	.uleb128 0x1a
	.4byte	0x51
	.4byte	0x747
	.uleb128 0x1b
	.4byte	0x70d
	.byte	0
	.uleb128 0x6
	.byte	0x4
	.4byte	0x738
	.uleb128 0x1c
	.4byte	0x758
	.uleb128 0x1b
	.4byte	0x70d
	.byte	0
	.uleb128 0x6
	.byte	0x4
	.4byte	0x74d
	.uleb128 0x9
	.4byte	.LASF116
	.byte	0xe
	.byte	0x6b
	.4byte	0x70d
	.uleb128 0xb
	.4byte	0x25
	.4byte	0x779
	.uleb128 0x10
	.4byte	0x4a
	.byte	0x5
	.byte	0
	.uleb128 0x8
	.4byte	.LASF117
	.byte	0xe
	.2byte	0x197
	.4byte	0x62b
	.uleb128 0x8
	.4byte	.LASF118
	.byte	0xe
	.2byte	0x198
	.4byte	0x62b
	.uleb128 0x8
	.4byte	.LASF119
	.byte	0xe
	.2byte	0x199
	.4byte	0x62b
	.uleb128 0x8
	.4byte	.LASF120
	.byte	0xe
	.2byte	0x19d
	.4byte	0x4b7
	.uleb128 0x8
	.4byte	.LASF121
	.byte	0xe
	.2byte	0x19e
	.4byte	0x4b7
	.uleb128 0xb
	.4byte	0x6c
	.4byte	0x7c5
	.uleb128 0x10
	.4byte	0x4a
	.byte	0x3f
	.byte	0
	.uleb128 0x8
	.4byte	.LASF122
	.byte	0xe
	.2byte	0x19f
	.4byte	0x7b5
	.uleb128 0x8
	.4byte	.LASF123
	.byte	0xe
	.2byte	0x1a0
	.4byte	0xd0
	.uleb128 0x8
	.4byte	.LASF124
	.byte	0xe
	.2byte	0x1a2
	.4byte	0xdb
	.uleb128 0x8
	.4byte	.LASF125
	.byte	0xe
	.2byte	0x1a3
	.4byte	0x769
	.uleb128 0x8
	.4byte	.LASF126
	.byte	0xe
	.2byte	0x1a4
	.4byte	0x769
	.uleb128 0x8
	.4byte	.LASF127
	.byte	0xe
	.2byte	0x1a5
	.4byte	0x62b
	.uleb128 0x8
	.4byte	.LASF128
	.byte	0xe
	.2byte	0x1a6
	.4byte	0x62b
	.uleb128 0x8
	.4byte	.LASF129
	.byte	0xe
	.2byte	0x1a7
	.4byte	0x636
	.uleb128 0xb
	.4byte	0x636
	.4byte	0x835
	.uleb128 0x10
	.4byte	0x4a
	.byte	0x3
	.byte	0
	.uleb128 0x8
	.4byte	.LASF130
	.byte	0xe
	.2byte	0x1a8
	.4byte	0x825
	.uleb128 0x8
	.4byte	.LASF131
	.byte	0xe
	.2byte	0x1a9
	.4byte	0x636
	.uleb128 0x8
	.4byte	.LASF132
	.byte	0xe
	.2byte	0x1aa
	.4byte	0x51
	.uleb128 0x8
	.4byte	.LASF133
	.byte	0xe
	.2byte	0x1ab
	.4byte	0x5f
	.uleb128 0x8
	.4byte	.LASF134
	.byte	0xe
	.2byte	0x1ac
	.4byte	0x769
	.uleb128 0x8
	.4byte	.LASF135
	.byte	0xe
	.2byte	0x1ad
	.4byte	0x769
	.uleb128 0x8
	.4byte	.LASF136
	.byte	0xe
	.2byte	0x1b1
	.4byte	0xd0
	.uleb128 0x8
	.4byte	.LASF137
	.byte	0xe
	.2byte	0x1b2
	.4byte	0xd0
	.uleb128 0x8
	.4byte	.LASF138
	.byte	0xe
	.2byte	0x1b4
	.4byte	0x51
	.uleb128 0xb
	.4byte	0x6c
	.4byte	0x8b1
	.uleb128 0x10
	.4byte	0x4a
	.byte	0x7f
	.byte	0
	.uleb128 0x8
	.4byte	.LASF139
	.byte	0xe
	.2byte	0x1bc
	.4byte	0x8a1
	.uleb128 0x8
	.4byte	.LASF140
	.byte	0xe
	.2byte	0x1c4
	.4byte	0x62b
	.uleb128 0x1d
	.4byte	.LASF155
	.byte	0x4
	.4byte	0x5f
	.byte	0xe
	.2byte	0x203
	.4byte	0x8f3
	.uleb128 0x1e
	.4byte	.LASF141
	.byte	0
	.uleb128 0x1e
	.4byte	.LASF142
	.byte	0x1
	.uleb128 0x1e
	.4byte	.LASF143
	.byte	0x2
	.uleb128 0x1e
	.4byte	.LASF144
	.byte	0x3
	.byte	0
	.uleb128 0x8
	.4byte	.LASF145
	.byte	0xe
	.2byte	0x209
	.4byte	0x8c9
	.uleb128 0x9
	.4byte	.LASF146
	.byte	0xf
	.byte	0x8a
	.4byte	0x66
	.uleb128 0x14
	.4byte	.LASF147
	.2byte	0x1000
	.byte	0xf
	.byte	0x8f
	.4byte	0x930
	.uleb128 0xf
	.ascii	"crc\000"
	.byte	0xf
	.byte	0x90
	.4byte	0xf1
	.byte	0
	.uleb128 0xe
	.4byte	.LASF148
	.byte	0xf
	.byte	0x94
	.4byte	0x930
	.byte	0x4
	.byte	0
	.uleb128 0xb
	.4byte	0x30
	.4byte	0x941
	.uleb128 0x1f
	.4byte	0x4a
	.2byte	0xffb
	.byte	0
	.uleb128 0x2
	.4byte	.LASF149
	.byte	0xf
	.byte	0x95
	.4byte	0x90a
	.uleb128 0xb
	.4byte	0x37
	.4byte	0x957
	.uleb128 0xc
	.byte	0
	.uleb128 0x4
	.4byte	0x94c
	.uleb128 0x9
	.4byte	.LASF150
	.byte	0xf
	.byte	0x9b
	.4byte	0x957
	.uleb128 0x9
	.4byte	.LASF151
	.byte	0xf
	.byte	0x9c
	.4byte	0x972
	.uleb128 0x6
	.byte	0x4
	.4byte	0x941
	.uleb128 0x20
	.4byte	.LASF156
	.byte	0x1
	.byte	0x16
	.4byte	0x51
	.4byte	.LFB110
	.4byte	.LFE110-.LFB110
	.uleb128 0x1
	.byte	0x9c
	.byte	0
	.section	.debug_abbrev,"",%progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x55
	.uleb128 0x17
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x21
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0x13
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0x5
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x16
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x17
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x18
	.uleb128 0x13
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x19
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1a
	.uleb128 0x15
	.byte	0x1
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1b
	.uleb128 0x5
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1c
	.uleb128 0x15
	.byte	0x1
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1d
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1e
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x1f
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0x5
	.byte	0
	.byte	0
	.uleb128 0x20
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",%progbits
	.4byte	0x1c
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.LFB110
	.4byte	.LFE110-.LFB110
	.4byte	0
	.4byte	0
	.section	.debug_ranges,"",%progbits
.Ldebug_ranges0:
	.4byte	.LFB110
	.4byte	.LFE110
	.4byte	0
	.4byte	0
	.section	.debug_line,"",%progbits
.Ldebug_line0:
	.section	.debug_str,"MS",%progbits,1
.LASF153:
	.ascii	"lib/asm-offsets.c\000"
.LASF107:
	.ascii	"iobase\000"
.LASF130:
	.ascii	"NetRxPackets\000"
.LASF100:
	.ascii	"_datarellocal_start_ofs\000"
.LASF69:
	.ascii	"rd_start\000"
.LASF146:
	.ascii	"env_name_spec\000"
.LASF93:
	.ascii	"_bss_end_ofs\000"
.LASF23:
	.ascii	"cm_qspi_clock\000"
.LASF5:
	.ascii	"unsigned int\000"
.LASF117:
	.ascii	"NetOurGatewayIP\000"
.LASF113:
	.ascii	"next\000"
.LASF67:
	.ascii	"legacy_hdr_os_copy\000"
.LASF56:
	.ascii	"ih_name\000"
.LASF123:
	.ascii	"NetBootFileSize\000"
.LASF90:
	.ascii	"nr_banks\000"
.LASF136:
	.ascii	"NetOurVLAN\000"
.LASF24:
	.ascii	"___strtok\000"
.LASF58:
	.ascii	"image_info\000"
.LASF79:
	.ascii	"bootm_headers_t\000"
.LASF43:
	.ascii	"bd_t\000"
.LASF122:
	.ascii	"NetOurRootPath\000"
.LASF101:
	.ascii	"_datarelro_start_ofs\000"
.LASF68:
	.ascii	"legacy_hdr_valid\000"
.LASF97:
	.ascii	"_TEXT_BASE\000"
.LASF84:
	.ascii	"load_addr\000"
.LASF109:
	.ascii	"send\000"
.LASF8:
	.ascii	"signed char\000"
.LASF131:
	.ascii	"NetRxPacket\000"
.LASF72:
	.ascii	"ft_len\000"
.LASF19:
	.ascii	"uint32_t\000"
.LASF86:
	.ascii	"save_size\000"
.LASF137:
	.ascii	"NetOurNativeVLAN\000"
.LASF95:
	.ascii	"IRQ_STACK_START\000"
.LASF82:
	.ascii	"monitor_flash_len\000"
.LASF27:
	.ascii	"base\000"
.LASF114:
	.ascii	"index\000"
.LASF128:
	.ascii	"NetServerIP\000"
.LASF111:
	.ascii	"halt\000"
.LASF13:
	.ascii	"long long unsigned int\000"
.LASF83:
	.ascii	"_binary_dt_dtb_start\000"
.LASF54:
	.ascii	"ih_type\000"
.LASF110:
	.ascii	"recv\000"
.LASF29:
	.ascii	"lmb_property\000"
.LASF154:
	.ascii	"/home/lampa/Desktop/curl/curl_fpga/software/spl_bsp"
	.ascii	"/uboot-socfpga\000"
.LASF144:
	.ascii	"NETLOOP_FAIL\000"
.LASF25:
	.ascii	"ide_bus_offset\000"
.LASF120:
	.ascii	"NetOurNISDomain\000"
.LASF55:
	.ascii	"ih_comp\000"
.LASF15:
	.ascii	"phys_size_t\000"
.LASF147:
	.ascii	"environment_s\000"
.LASF121:
	.ascii	"NetOurHostName\000"
.LASF155:
	.ascii	"net_loop_state\000"
.LASF139:
	.ascii	"BootFile\000"
.LASF133:
	.ascii	"NetIPID\000"
.LASF60:
	.ascii	"image_len\000"
.LASF118:
	.ascii	"NetOurSubnetMask\000"
.LASF45:
	.ascii	"ih_magic\000"
.LASF149:
	.ascii	"env_t\000"
.LASF61:
	.ascii	"load\000"
.LASF142:
	.ascii	"NETLOOP_RESTART\000"
.LASF85:
	.ascii	"save_addr\000"
.LASF152:
	.ascii	"GNU C11 6.2.0 -mfloat-abi=soft -mthumb -mthumb-inte"
	.ascii	"rwork -mabi=aapcs-linux -march=armv7-a -mno-unalign"
	.ascii	"ed-access -g -Os -fno-common -ffixed-r8 -fno-builti"
	.ascii	"n -ffreestanding -fno-stack-protector -fstack-usage"
	.ascii	"\000"
.LASF125:
	.ascii	"NetOurEther\000"
.LASF6:
	.ascii	"char\000"
.LASF124:
	.ascii	"NetBootFileXferSize\000"
.LASF59:
	.ascii	"image_start\000"
.LASF52:
	.ascii	"ih_os\000"
.LASF51:
	.ascii	"ih_dcrc\000"
.LASF148:
	.ascii	"data\000"
.LASF127:
	.ascii	"NetOurIP\000"
.LASF18:
	.ascii	"uint8_t\000"
.LASF12:
	.ascii	"__u32\000"
.LASF135:
	.ascii	"NetEtherNullAddr\000"
.LASF89:
	.ascii	"meminfo\000"
.LASF65:
	.ascii	"bootm_headers\000"
.LASF92:
	.ascii	"_bss_start_ofs\000"
.LASF96:
	.ascii	"FIQ_STACK_START\000"
.LASF106:
	.ascii	"enetaddr\000"
.LASF7:
	.ascii	"long long int\000"
.LASF44:
	.ascii	"image_header\000"
.LASF37:
	.ascii	"bi_arch_number\000"
.LASF132:
	.ascii	"NetRxPacketLen\000"
.LASF134:
	.ascii	"NetBcastAddr\000"
.LASF99:
	.ascii	"_datarelrolocal_start_ofs\000"
.LASF39:
	.ascii	"bi_arm_freq\000"
.LASF57:
	.ascii	"image_header_t\000"
.LASF28:
	.ascii	"size\000"
.LASF38:
	.ascii	"bi_boot_params\000"
.LASF22:
	.ascii	"cm_sdmmc_clock\000"
.LASF145:
	.ascii	"net_state\000"
.LASF81:
	.ascii	"console_buffer\000"
.LASF76:
	.ascii	"cmdline_end\000"
.LASF116:
	.ascii	"eth_current\000"
.LASF36:
	.ascii	"bi_baudrate\000"
.LASF35:
	.ascii	"bd_info\000"
.LASF75:
	.ascii	"cmdline_start\000"
.LASF80:
	.ascii	"images\000"
.LASF26:
	.ascii	"long double\000"
.LASF115:
	.ascii	"priv\000"
.LASF66:
	.ascii	"legacy_hdr_os\000"
.LASF119:
	.ascii	"NetOurDNSIP\000"
.LASF87:
	.ascii	"__machine_arch_type\000"
.LASF14:
	.ascii	"phys_addr_t\000"
.LASF73:
	.ascii	"initrd_start\000"
.LASF11:
	.ascii	"short int\000"
.LASF53:
	.ascii	"ih_arch\000"
.LASF103:
	.ascii	"IPaddr_t\000"
.LASF151:
	.ascii	"env_ptr\000"
.LASF4:
	.ascii	"long int\000"
.LASF49:
	.ascii	"ih_load\000"
.LASF143:
	.ascii	"NETLOOP_SUCCESS\000"
.LASF88:
	.ascii	"node\000"
.LASF17:
	.ascii	"ulong\000"
.LASF47:
	.ascii	"ih_time\000"
.LASF48:
	.ascii	"ih_size\000"
.LASF141:
	.ascii	"NETLOOP_CONTINUE\000"
.LASF46:
	.ascii	"ih_hcrc\000"
.LASF31:
	.ascii	"region\000"
.LASF71:
	.ascii	"ft_addr\000"
.LASF150:
	.ascii	"default_environment\000"
.LASF105:
	.ascii	"name\000"
.LASF34:
	.ascii	"start\000"
.LASF94:
	.ascii	"_end_ofs\000"
.LASF50:
	.ascii	"ih_ep\000"
.LASF112:
	.ascii	"write_hwaddr\000"
.LASF140:
	.ascii	"NetPingIP\000"
.LASF108:
	.ascii	"init\000"
.LASF156:
	.ascii	"main\000"
.LASF3:
	.ascii	"sizetype\000"
.LASF1:
	.ascii	"long unsigned int\000"
.LASF10:
	.ascii	"__u8\000"
.LASF98:
	.ascii	"_datarel_start_ofs\000"
.LASF21:
	.ascii	"cm_l4_sp_clock\000"
.LASF64:
	.ascii	"image_info_t\000"
.LASF32:
	.ascii	"memory\000"
.LASF70:
	.ascii	"rd_end\000"
.LASF102:
	.ascii	"IRQ_STACK_START_IN\000"
.LASF74:
	.ascii	"initrd_end\000"
.LASF63:
	.ascii	"type\000"
.LASF0:
	.ascii	"unsigned char\000"
.LASF16:
	.ascii	"ushort\000"
.LASF41:
	.ascii	"bi_ddr_freq\000"
.LASF78:
	.ascii	"state\000"
.LASF20:
	.ascii	"__be32\000"
.LASF104:
	.ascii	"eth_device\000"
.LASF91:
	.ascii	"bank\000"
.LASF9:
	.ascii	"uchar\000"
.LASF2:
	.ascii	"short unsigned int\000"
.LASF40:
	.ascii	"bi_dsp_freq\000"
.LASF126:
	.ascii	"NetServerEther\000"
.LASF138:
	.ascii	"NetRestartWrap\000"
.LASF33:
	.ascii	"reserved\000"
.LASF129:
	.ascii	"NetTxPacket\000"
.LASF77:
	.ascii	"verify\000"
.LASF42:
	.ascii	"bi_dram\000"
.LASF62:
	.ascii	"comp\000"
.LASF30:
	.ascii	"lmb_region\000"
	.ident	"GCC: (Sourcery CodeBench Lite 2016.11-59) 6.2.0"
