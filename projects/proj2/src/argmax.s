.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    addi t0 x0 1
    blt a1 t0 err_handler # check a1 > 1

    add t0 x0 x0 # index
    li t3 0x80000000 # store the current largest number
    add t4 x0 x0 # initialise the argmax
loop_start:
    slli t1 t0 2 # offset
    add t1 a0 t1 # address to current element
    lw t2 0(t1) # current element
    bge t3 t2 loop_continue
    add t3 t2 x0 # update max
    add t4 t0 x0 # update argmax

loop_continue:
    addi t0 t0 1
    blt t0 a1 loop_start

loop_end:
    add a0 t4 x0
    jr ra

err_handler:
    li a0 36
    j exit
