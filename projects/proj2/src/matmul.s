.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    addi t0 x0 1
    blt a1 t0 err_handler # check a1 > 1
    blt a2 t0 err_handler
    blt a4 t0 err_handler
    blt a5 t0 err_handler
    bne a2 a4 err_handler

    # Prologue
    addi sp sp -4
    sw ra 0(sp)

    add t0 x0 x0 # initialise i (row number)    

outer_loop_start:
    mul t2 t0 a5 # index
    add t1 x0 x0 # initialise j (col number)

inner_loop_start:
    add t3 t2 t1 # index from a6
    slli t3 t3 2 # offset from a6
    add t3 a6 t3 # addr

    # save regs on stack: a0-6, t0-3
    addi sp sp -44
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    sw a3 12(sp)
    sw a4 16(sp)
    sw a5 20(sp)
    sw a6 24(sp)
    sw t0 28(sp)
    sw t1 32(sp)
    sw t2 36(sp)
    sw t3 40(sp)

    # set up args for function dot
    mul t3 t0 a2 
    slli t3 t3 2
    add a0 a0 t3 

    slli t3 t1 2
    add a1 a3 t3

    addi a3 x0 1
    add a4 x0 a5

    jal ra dot  
    lw t3 40(sp)    
    sw a0 0(t3) # write results to C[i, j]

    # restore regs from stack
    lw a0 0(sp)
    lw a1 4(sp)
    lw a2 8(sp)
    lw a3 12(sp)
    lw a4 16(sp)
    lw a5 20(sp)
    lw a6 24(sp)
    lw t0 28(sp)
    lw t1 32(sp)  
    lw t2 36(sp) 
    addi sp sp 44

inner_loop_end:
    addi t1 t1 1
    blt t1 a5 inner_loop_start 

outer_loop_end:
    addi t0 t0 1
    blt t0 a1 outer_loop_start 

    # Epilogue
    lw ra 0(sp)
    addi sp sp 4
    jr ra

err_handler:
    li a0 38
    j exit
