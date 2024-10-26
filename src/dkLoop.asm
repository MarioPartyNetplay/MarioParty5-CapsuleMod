.set spaceData, 0x8024d5f8

lis r29, spaceData@h
ori r29, r29, spaceData@l
lis r3, 1
ori r3, r3, 0x25
lha r5, -0x7458 (r13)
    
dk_change_loop:
    cmpwi r5, 0
    ble- dk_change_end
    
    lwz r4, 0x2c (r29)
    cmpw r3, r4
    bne+ 0x10
    
    #Change DK capsule to proper DK space.
    lis r4, 8
    ori r4, r4, 0xffff
    stw r4, 0x2c (r29)
    
    subi r5, r5, 1
    addi r29, r29, 0x70
    b dk_change_loop
    
dk_change_end: