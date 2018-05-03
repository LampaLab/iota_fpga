MEMORY { .sram : ORIGIN = 0xFFFF0000, LENGTH = (64 * 1024) }
MEMORY { .sdram : ORIGIN = (0x02000000 - 0x100000 + 0x00000000), LENGTH = 0x100000 }
OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)
SECTIONS
{
 .text :
 {
  arch/arm/cpu/armv7/start.o (.text)
  *(.text*)
 } >.sram
 . = ALIGN(4);
 .rodata : { *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.rodata*))) } >.sram
 . = ALIGN(4);
 .data : { *(SORT_BY_ALIGNMENT(.data*)) } >.sram
 __ecc_padding_start = .;
 . = ALIGN(4);
 __image_copy_end = .;
 _end = .;
 .bss_fat : {
  __bss_fat_start = .;
  fs/fat/libfat.o (.bss*)
  __bss_fat_end = .;
 } >.sdram
 .bss : {
  . = ALIGN(4);
  __bss_start = .;
  *(.bss*)
  . = ALIGN(4);
  __bss_end__ = .;
 } >.sram
 __malloc_start = .;
 __malloc_end = .;
 .malloc :
 {
  __malloc_fat_start = .;
  . = . + (5 * 1024);
  __malloc_fat_end = .;
 } >.sdram
 .stack :
 {
  . = . + (5 * 1024);
  . = ALIGN(8);
  __stack_start = .;
 } >.sram
 .spl_irq_stack :
 {
  . = . + (1 << 10);
  . = ALIGN(8);
  __irq_stack_start = .;
  . = . + 0x8;
  __ecc_padding_end = .;
 } >.sram
 .sdram_stack :
 {
  __sdram_stack_end = .;
  . = . + (128 * 1024);
  __sdram_stack_start = .;
 } >.sdram
}
