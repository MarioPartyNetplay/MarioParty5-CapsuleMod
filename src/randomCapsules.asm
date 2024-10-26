.set getRandByte, 0x80005ac0
.set spaceData, 0x8024d5f8
.set permSpaceData, 0x8022a4ca

stwu r1, -0x20 (r1)
stw r26, 0x08 (r1)
stw r27, 0x0c (r1)
stw r28, 0x10 (r1)
stw r29, 0x14 (r1)
stw r30, 0x18 (r1)
stw r31, 0x1c (r1)
    
bl data_end

data_start:
replace_space_types:
    #types of spaces that are safe to assign capsules to.
    .byte 0x01, 0x02
capsule_types:
    #types of capsules that can be placed
    .byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x0a, 0x0b
    .byte 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x14, 0x15
    .byte 0x16, 0x17, 0x18, 0x19, 0x1e, 0x1f, 0x20, 0x23
    #special capsules (Bowser = space 3, DK = space 8)
    .byte 0x22, 0x25
capsule_types_end:
    
    .balign 4
data_end:
    mflr r31
    
    lis r27, permSpaceData@h
    ori r27, r27, permSpaceData@l
    lis r28, spaceData@h
    ori r28, r28, spaceData@l
    lha r29, -0x7458 (r13)  #number of spaces on the board
    lis r30, getRandByte@h
    ori r30, r30, getRandByte@l
    
    #Loop over all spaces on the board.
space_loop_start:
    cmpwi r29, 0
    ble- space_loop_exit
    
check_space_type:
    lha r3, 0x2c (r28)
    addi r5, r31, 0
    li r6, 2
check_space_type_loop:
    cmpwi r6, 0
    #If not any of the replaceable types, jump to end.
    ble- space_loop_end

    lbz r4, 0 (r5)
    cmpw r3, r4
    #Space is a replaceable type#jump to set space type.
    beq- assign_capsule
    
    addi r5, r5, 1
    subi r6, r6, 1
    b check_space_type_loop

assign_capsule:
    mr r26, r3
    #Get a random byte (in r3).
    mtlr r30
    blrl
    #Mod by number of capsule options.
    li r4, capsule_types_end - capsule_types
    divw r4, r3, r4
    mulli r4, r4, capsule_types_end - capsule_types
    sub r3, r3, r4
    addi r5, r31, capsule_types - data_start
    lbzx r3, r3, r5
    #Set the capsule type in permanent data + in current space data.
    sth r3, 0 (r27)
    sth r3, 0x2e (r28)
    
    #Check for special capsule types (Bowser + DK).
    li r4, -1
    
    #Bowser capsule?
    cmpwi r3, 0x22
    bne+ 0x10
    #Change to Bowser space.
    li r3, 3
    sth r3, 0x2c (r28)
    sth r4, 0x2e (r28)
    
    #DK capsule?
    cmpwi r3, 0x25
    bne+ space_loop_end
    #If on red space, change to coin block capsule.
    cmpwi r26, 2
    bne+ change_to_dk
    li r3, 0xb
    sth r3, 0x2e (r28)
    b space_loop_end
    #Otherwise, change to DK space

change_to_dk:
    li r3, 8
    sth r3, 0x2c (r28)
    sth r4, 0x2e (r28)
    
space_loop_end:
    addi r27, r27, 2
    addi r28, r28, 0x70
    subi r29, r29, 1
    b space_loop_start
    
space_loop_exit:

    #Restore original opcode at end.
    lis r3, 1

    lwz r26, 0x08 (r1)
    lwz r27, 0x0c (r1)
    lwz r28, 0x10 (r1)
    lwz r29, 0x14 (r1)
    lwz r30, 0x18 (r1)
    lwz r31, 0x1c (r1)
    addi r1, r1, 0x10
