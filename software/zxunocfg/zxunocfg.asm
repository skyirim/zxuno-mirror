;Para ensamblar con PASMO como archivo binario: pasmo --bin zxunocfg.asm zxunocfg

ZXUNOADDR           equ 0fc3bh
ZXUNODATA           equ 0fd3bh

                    org 2000h  ;comienzo de la ejecución de los comandos ESXDOS.

Main                proc
                    ld a,h
                    or l
                    jr z,PrintAndExit
                    call RecogerParam
                    call ParseParam
                    jr nc,NoError
                    cp 255
                    ret z
                    ret c

NoError             ld bc,ZXUNOADDR
                    xor a   ;MASTERCONF
                    out (c),a
                    inc b
                    ld a,(ConfValue)
                    out (c),a
                    dec b
                    ld a,11
                    out (c),a
                    inc b
                    ld a,(ScanDblCtrl)
                    out (c),a

PrintAndExit        call PrintCurrentMode
                    or a
                    ret
                    endp
;------------------------------------------------------

PrintCurrentMode    proc
                    ld a,(QuietMode)
                    or a
                    ret nz
                    call GetCoreID
                    ld bc,ZXUNOADDR
                    ld a,0   ;MASTERCONF
                    out (c),a
                    inc b
                    in a,(c)
                    ld (ConfValue),a  ;Current config value
                    dec b
                    ld a,11
                    out (c),a
                    inc b
                    in a,(c)
                    ld (ScanDblCtrl),a

                    ld hl,CurrConfString1
                    call PrintString
                    ld hl,TimmPenStr
                    ld a,(ConfValue)
                    bit 6,a
                    jr nz,NoChTimm
                    ld hl,Timm128KStr
                    bit 4,a
                    jr nz,NoChTimm
                    ld hl,Timm48KStr
NoChTimm            call PrintString

                    ld hl,CurrConfString2
                    call PrintString
                    ld hl,ContEnabledStr
                    ld a,(ConfValue)
                    bit 5,a
                    jr z,NoChCont
                    ld hl,ContDisabledStr
NoChCont            call PrintString

                    ld hl,CurrConfString3
                    call PrintString
                    ld a,(ConfValue)
                    cpl
                    and 08h  ;
                    sra a    ; A = "2" or "3"
                    sra a    ; depending upon the
                    sra a    ; bit at 3
                    or 32h   ;
                    rst 10h
                    ld a,13
                    rst 10h

                    call InitMouse
                    ld hl,CurrConfString4
                    call PrintString

                    ld hl,CurrConfString5
                    call PrintString
                    ld a,(ScanDblCtrl)
                    and 0c0h
                    ld hl,Speed3d5Str
                    jr z,GoTurboPrint
                    cp 40h
                    ld hl,Speed7Str
                    jr z,GoTurboPrint
                    cp 80h
                    ld hl,Speed14Str
                    jr z,GoTurboPrint
                    ld hl,Speed28Str
GoTurboPrint        call PrintString

                    ld hl,CurrConfString6
                    call PrintString
                    ld a,(ScanDblCtrl)
                    ld hl,CompositeStr
                    bit 0,a
                    jr z,PrintVideo
                    ld hl,VGANoScansStr
                    and 3
                    cp 1
                    jr z,PrintVideo
                    ld hl,VGAScansStr
PrintVideo          call PrintString

                    ld hl,CurrConfString7
                    call PrintString
                    ld a,(ScanDblCtrl)
                    sra a
                    sra a
                    and 7
                    add a,a
                    ld e,a
                    ld d,0
                    ld hl,TablaFreqStr
                    add hl,de
                    ld a,(hl)
                    inc hl
                    ld h,(hl)
                    ld l,a
                    call PrintString

                    ret

                    endp
;------------------------------------------------------

RecogerParam        proc   ;HL apunta a los argumentos
                    ld de,BufferParam
CheckCaracter       ld a,(hl)
                    or a
                    jr z,FinRecoger
                    cp ":"
                    jr z,FinRecoger
                    cp 13
                    jr z,FinRecoger
                    ldi
                    jr CheckCaracter
FinRecoger          ld a," "
                    ld (de),a
                    inc de
                    xor a
                    ld (de),a
                    ret
                    endp
;------------------------------------------------------

ParseParam          proc
                    ld bc,ZXUNOADDR
                    ld a,0   ;MASTERCONF
                    out (c),a
                    inc b
                    in a,(c)
                    ld (ConfValue),a  ;Current config value
                    ld bc,ZXUNOADDR
                    ld a,11   ;SCANDBLCTRL
                    out (c),a
                    inc b
                    in a,(c)
                    ld (ScanDblCtrl),a

                    ld hl,BufferParam
OtroChar            ld a,(hl)
                    inc hl
                    or a
                    ret z
                    cp " "
                    jp z,OtroChar
                    cp "-"
                    jp nz,ErrorInvalidArg

                    ld a,(hl)
                    inc hl
                    cp "t"
                    jp z,ParseTimming
                    cp "c"
                    jp z,ParseContention
                    cp "k"
                    jp z,ParseKeyboard
                    cp "h"
                    jp z,ParseHelp
                    cp "q"
                    jp z,ParseQuiet
                    cp "s"
                    jp z,ParseSpeed
                    cp "v"
                    jp z,ParseVideo
                    cp "f"
                    jp z,ParseFreq
                    jp ErrorInvalidArg

ParseTimming        ld a,(hl)
                    inc hl
                    cp "4"
                    jp z,Parse48K
                    cp "1"
                    jp z,Parse128K
                    cp "p"
                    jp z,ParsePentagon
                    jp ErrorInvalidArg
Parse48K            ld a,(hl)
                    inc hl
                    cp "8"
                    jp nz,ErrorInvalidArg
                    ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ConfValue)
                    and 0afh  ;clear bit 4 and 6
                    ld (ConfValue),a
                    jp OtroChar
Parse128K           ld a,(hl)
                    inc hl
                    cp "2"
                    jp nz,ErrorInvalidArg
                    ld a,(hl)
                    inc hl
                    cp "8"
                    jp nz,ErrorInvalidArg
                    ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ConfValue)
                    and 0afh  ;clear bit 4 and 6
                    or 10h  ;set bit 4
                    ld (ConfValue),a
                    jp OtroChar

ParsePentagon       ld a,(hl)
                    inc hl
                    cp "e"
                    jp nz,ErrorInvalidArg
                    ld a,(hl)
                    inc hl
                    cp "n"
                    jp nz,ErrorInvalidArg
                    ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ConfValue)
                    and 0afh  ;clear bit 4 and 6
                    or 40h  ;set bit 6
                    ld (ConfValue),a
                    jp OtroChar

ParseContention     ld a,(hl)
                    inc hl
                    cp "y"
                    jp nz,PutDisableCont
                    ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ConfValue)
                    and 0dfh
                    ld (ConfValue),a
                    jp OtroChar
PutDisableCont      cp "n"
                    jp nz,ErrorInvalidArg
                    ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ConfValue)
                    or 20h
                    ld (ConfValue),a
                    jp OtroChar

ParseKeyboard       ld a,(hl)
                    inc hl
                    cp "3"
                    jp nz,PutIssue2
                    ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ConfValue)
                    and 0f7h
                    ld (ConfValue),a
                    jp OtroChar
PutIssue2           cp "2"
                    jp nz,ErrorInvalidArg
                    ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ConfValue)
                    or 08h
                    ld (ConfValue),a
                    jp OtroChar

ParseSpeed          ld a,(hl)
                    inc hl
                    cp "0"
                    jp c,ErrorInvalidArg
                    cp "4"
                    jp nc,ErrorInvalidArg
                    ld b,a
                    ld a,(hl)
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,b
                    and 3
                    add a,a
                    add a,a
                    add a,a
                    add a,a
                    add a,a
                    add a,a
                    ld b,a
                    ld a,(ScanDblCtrl)
                    and 3fh
                    or b
                    ld (ScanDblCtrl),a
                    jp OtroChar

ParseVideo          ld a,(hl)
                    inc hl
                    cp "0"
                    jp z,Modo15khz
                    cp "1"
                    jp z,ModoVGANoScans
                    cp "2"
                    jp nz,ErrorInvalidArg
                    ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ScanDblCtrl)
                    and 0fch
                    or 3
                    ld (ScanDblCtrl),a
                    jp OtroChar
Modo15khz           ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ScanDblCtrl)
                    and 0fch
                    ld (ScanDblCtrl),a
                    jp OtroChar
ModoVGANoScans      ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,(ScanDblCtrl)
                    and 0fch
                    or 1
                    ld (ScanDblCtrl),a
                    jp OtroChar

ParseFreq           ld a,(hl)
                    inc hl
                    cp "0"
                    jp c,ErrorInvalidArg
                    cp "8"
                    jp nc,ErrorInvalidArg
                    sub "0"
                    ld b,a
                    ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,b
                    add a,a
                    add a,a
                    ld b,a
                    ld a,(ScanDblCtrl)
                    and 0e3h
                    or b
                    ld (ScanDblCtrl),a
                    jp OtroChar

ParseHelp           ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld hl,Uso
                    call PrintString
                    ld a,255
                    scf
                    ret

ParseQuiet          ld a,(hl)
                    inc hl
                    cp " "
                    jp nz,ErrorInvalidArg
                    ld a,1
                    ld (QuietMode),a
                    jp OtroChar

ErrorInvalidArg     ld a,0
                    ld hl,ErrorMsg
                    scf
                    ret
                    endp
;------------------------------------------------------

PrintString         proc
BucPrintMsg         ld a,(hl)
                    or a
                    ret z
                    rst 10h
                    inc hl
                    jr BucPrintMsg
                    endp
;------------------------------------------------------

GetCoreID           proc
                    ld bc,ZXUNOADDR
                    ld a,255
                    out (c),a
                    inc b
                    in a,(c)
                    ld hl,StringCoreID + 13
                    ld d,32
gettext             or a
                    jr z,finget
                    cp 128
                    jr nc,finget
                    ld (hl),a
                    inc hl
                    dec d
                    jr z,finget
                    in a,(c)
                    jr gettext
finget              ld a,(hl)
                    cp 13
                    jr z,finrell
                    ld (hl),32
                    inc hl
                    jr finget
finrell             ret
                    endp

;------------------------------------------------------

InitMouse           proc
                    ld bc,ZXUNOADDR
                    ld a,9
                    out (c),a
                    inc b
                    ld a,0F4h
                    out (c),a
NoMouse             ret
                    endp

;------------------------------------------------------

                    ;   01234567890123456789012345678901
Uso                 db "ZXUNOCFG v1.0",13
                    db "Configure/print ZX-UNO options",13,13
                    db "Usage: zxunocfg [switches]",13
                    db " No switches: print config",13
                    db " -h : shows this help and exits",13
                    db " -q : silent operation",13

                    db " -tN: choose ULA timings",13
                    db "      N=48:   48K timings",13
                    db "      N=128: 128K timings",13
                    db "      N=pen: Pentagon timings",13

                    db " -cS: en/dis contention",13
                    db "      S=y: enable contention",13
                    db "      S=n: disable contention",13

                    db " -kN: choose keyboard mode",13
                    db "      N=2: issue 2 keyboard",13
                    db "      N=3: issue 3 keyboard",13

                    db " -sN: choose CPU speed",13
                    db "      N=0: std. speed (3.5 Mhz)",13
                    db "      N=1, 2 or 3: turbo speed",13
                    db "             (7, 14 or 28 MHz)",13

                    db " -vN: choose video output",13
                    db "      N=0: composite/RGB 15kHz",13
                    db "      N=1: VGA no scanlines",13
                    db "      N=2: VGA with scanlines",13

                    db " -fN: choose master frequency",13
                    db "      N=0-7: master freq option",13,13

                    db "Example: zxunocfg -tpen -cn -k3",13
                    db "  (provides Pentagon 128 compati",13
                    db "   ble mode)",13
                    db 0

                    ;   01234567890123456789012345678901
CurrConfString1     db "ZX-Uno current configuration:",13
StringCoreID        db "       Core: NOT AVAILABLE   ",13    ;+13
                    db "     Timing: ",0
Timm48KStr          db "48K",13,0
Timm128KStr         db "128K",13,0
TimmPenStr          db "Pentagon",13,0
CurrConfString2     db " Contention: ",0
ContEnabledStr      db "ENABLED",13,0
ContDisabledStr     db "DISABLED",13,0
CurrConfString3     db "   Keyboard: ISSUE ",0
CurrConfString4     db "      Mouse: INITIALIZED",13,0
CurrConfString5     db "      Speed: ",0
Speed3d5Str         db "3.5 MHz",13,0
Speed7Str           db "7 MHz",13,0
Speed14Str          db "14 MHz",13,0
Speed28Str          db "28 MHz",13,0
CurrConfString6     db "      Video: ",0
CompositeStr        db "CVBS/RGB 15 kHz",13,0
VGANoScansStr       db "VGA",13,0
VGAScansStr         db "VGA w/scanlines",13,0
CurrConfString7     db "  VFreq opt: ",0

Freq0Str            db "50 Hz (0)",13,0
Freq1Str            db "51 Hz (1)",13,0
Freq2Str            db "53.50 Hz (2)",13,0
Freq3Str            db "55.80 Hz (3)", 13,0
Freq4Str            db "57.39 Hz (4)",13,0
Freq5Str            db "59.52 Hz (5)",13,0
Freq6Str            db "61.80 Hz (6)",13,0
Freq7Str            db "63.77 Hz (7)",13,0

TablaFreqStr        dw Freq0Str,Freq1Str,Freq2Str,Freq3Str,Freq4Str,Freq5Str,Freq6Str,Freq7Str;

ErrorMsg            db "Invalid option. Use zxunocfg -","h"+80h

ConfValue           db 0
ScanDblCtrl         db 0
QuietMode           db 0

BufferParam         equ $   ;resto de la RAM para el nombre del fichero