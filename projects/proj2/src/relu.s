.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int*) is the pointer to the array
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    addi t0 x0 1
    blt a1 t0 err_handler # check a1 > 1

    addi t0 x0 0 # t0 = 0

loop_start:

    slli t1 t0 2 # t1 = t0*4
    add t1 t1 a0 
    lw t2 0(t1)
    
    bge t2 x0 loop_continue
    sw x0 0(t1)

loop_continue:
    addi t0 t0 1
    blt t0 a1 loop_start


loop_end:
    jr ra

err_handler:
    li a0 36
    j exit
