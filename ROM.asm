; Control Register Locations.

const mmu_drq   0x0201
const mmu_sr    0x0202
const mmu_i2cin 0x0203
const mmu_dack  0x0211
const mmu_sacc  0x0212
const mmu_cmp   0x0214
const mmu_saddr 0x0218
const mmu_shift 0x0221
const mmu_xch   0x0222
const mmu_rfc   0x0224
const mmu_fck   0x0228
const mmu_dfr   0x0241
const mmu_rst   0x0242
const mmu_acfg  0x0244
const mmu_led   0x0248
const mmu_i2c00 0x0280
const mmu_i2c01 0x0281
const mmu_i2cA0 0x0282
const mmu_i2cA1 0x0283
const mmu_i2cZ0 0x0284
const mmu_i2cZ1 0x0285

; Working Regiser Locations.

const reg_B     0x0100 
const reg_C     0x0101
const reg_D     0x0102
const reg_E     0x0103
const reg_H     0x0104
const reg_L     0x0105

; Boot and Interrupt Vectors.

jp main
jp main

; Include Files.

include "I2C.asm"

; Main Program.

main:

; Acknowledge the boot request.

ld A,(0x04)
ld (mmu_dack),A

; Main Loop.

main_loop:

; Check the Telemetry Dispatch Request.

check_dispatch:
ld A,(mmu_drq)
and A,(0x01)
jp z,check_srd

; Select sample memory location zero for X1, 
; set the channel number, and start the 
; transmission.

ld A,(0x00)
ld (mmu_saddr),A
ld A,(1)
ld (mmu_xch),A
ld A,(0x20)
ld (mmu_dack),A

; Wait for transmission to complete.

tx_wait:
ld A,(mmu_drq)
and A,(0x20)
jp nz,tx_wait

; Reset sample accumulator and write zero to the
; sample memory. Acknowledge the dispatch request.

ld A,(0x01)
ld (mmu_sacc),A
ld A,(0x02)
ld (mmu_sacc),A
ld A,(0x01)
ld (mmu_dack),A

; Check for Sensor Read Request.

check_srd:
ld A,(mmu_drq)
and A,(0x08)
jp z,check_cmd

; Set sample address to zero for X1, set the 
; shift count, initiate conversion.

ld A,(0)
ld (mmu_saddr),A
ld A,(4)
ld (mmu_shift),A
ld A,(0x10)
ld (mmu_dack),A

; Wait for conversion and storage to complete.

srd_wait:
ld A,(mmu_drq)
and A,(0x10)
jp nz,srd_wait

; Acknowledge the sensor read request.

ld A,(0x08)
ld (mmu_dack),A

check_cmd:

jp main


