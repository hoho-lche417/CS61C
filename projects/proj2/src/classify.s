.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:

    # Prologue  
    addi sp sp -36
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    sw s7 32(sp)

    # save the args
    add s0 a0 x0
    add s1 a1 x0
    add s2 a2 x0 

    # check args number
    addi t0 x0 5
    bne a0 t0 args_err

    # Read pretrained m0
    lw a0 4(s1)
    addi sp sp -8
    add a1 sp x0
    addi a2 sp 4
    jal ra read_matrix
    add s3 a0 x0 # m0

    # Read pretrained m1
    lw a0 8(s1)
    addi sp sp -8
    add a1 sp x0
    addi a2 sp 4
    jal ra read_matrix
    add s4 a0 x0 # m1

    # Read input matrix
    lw a0 12(s1)
    addi sp sp -8
    add a1 sp x0
    addi a2 sp 4
    jal ra read_matrix
    add s5 a0 x0 # input matrix

    # Compute h = matmul(m0, input)
    lw t1 16(sp) 
    lw t5 4(sp) 
    mul a0 t1 t5
    slli a0 a0 2
    jal ra malloc
    add s6 a0 x0 # matmul result, to be freed

    lw t1 16(sp) 
    lw t2 20(sp)     
    lw t4 0(sp) 
    lw t5 4(sp) 

    add a6 a0 x0
    add a0 s3 x0
    add a1 t1 x0
    add a2 t2 x0
    add a3 s5 x0
    add a4 t4 x0
    add a5 t5 x0

    jal ra matmul

    # Compute h = relu(h)
    add a0 s6 x0
    lw a1 16(sp) 
    jal ra relu
    # add s6 a0 x0

    # Compute o = matmul(m1, h)
    lw t1 8(sp) 
    addi t5 x0 1
    mul a0 t1 t5
    slli a0 a0 2
    jal ra malloc
    add s7 a0 x0 # to be freed

    lw t1 8(sp) 
    lw t2 12(sp)     
    lw t4 16(sp) 
    addi t5 x0 1

    add a6 a0 x0
    add a0 s4 x0
    add a1 t1 x0
    add a2 t2 x0
    add a3 s6 x0
    add a4 t4 x0
    add a5 t5 x0

    jal ra matmul

    # Write output matrix o
    lw a0 16(s1)
    add a1 s7 x0 
    lw a2 8(sp) 
    addi a3 x0 1
    jal ra write_matrix

    # Compute and return argmax(o)
    add a0 s7 x0 
    lw a1 8(sp) 
    jal ra argmax # a0 is the classification now
    add s0 a0 x0

    # If enabled, print argmax(o) and newline
    bne s2 x0 finish
    jal ra print_int
    li a0 '\n'
    jal ra print_char

    # free any data allocated with malloc
    add a0 s6 x0
    jal ra free
    add a0 s7 x0
    jal ra free    

finish:
    add a0 s0 x0
    addi sp sp 24

    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    lw s7 32(sp)
    addi sp sp 36
    jr ra

malloc_err:
    li a0 26
    j exit

args_err:
    li a0 31
    j exit
