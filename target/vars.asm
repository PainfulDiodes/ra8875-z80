; Fulfils EXTERN labels required by the asm library modules.
;
; GPIO port assignments for the BeanBoard GPIO transport.
; Other targets must provide their own definitions of these labels.

    PUBLIC GPIO_OUT
    PUBLIC GPIO_IN

GPIO_OUT equ 6
GPIO_IN  equ 7
