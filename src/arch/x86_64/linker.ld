ENTRY(start)

SECTIONS {
    . = 1M;

    .boot :
    {
        /* Place multiboot header */
        *(.multiboot_header)
    }

    .text :
    {
        *(.text)
    }
}
