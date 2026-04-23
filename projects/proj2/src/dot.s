.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    addi t0 x0 1
    blt a2 t0 arr_len_err # check a2 > 1

    blt a3 t0 stride_err # check a3 > 1
    blt a4 t0 stride_err # check a4 > 1

    add t0 x0 x0 # number of elements processed
    add t4 x0 x0 # initialise total sum

loop_start:
    mul t1 t0 a3 # index for arr0
    slli t1 t1 2 # offset 
    add t1 t1 a0 # addr
    lw t2 0(t1) # load elem from arr0

    mul t1 t0 a4 # index for arr1
    slli t1 t1 2 # offset 
    add t1 t1 a1 # addr
    lw t3 0(t1) # load elem from arr1

    mul t2 t2 t3
    add t4 t4 t2

    addi t0 t0 1 # update iterator
    blt t0 a2 loop_start

loop_end:
    add a0 t4 x0
    jr ra

arr_len_err:
    li a0 36
    j exit
stride_err:
    li a0 37
    j exit
