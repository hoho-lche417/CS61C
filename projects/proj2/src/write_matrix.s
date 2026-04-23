.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # Prologue  
    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)

    #
    add s0 a0 x0
    add s1 a1 x0
    add s2 a2 x0
    add s3 a3 x0

    # 1. open the file with write permissions
    addi a1 x0 1
    jal ra fopen
    li t0 -1
    beq a0 t0 fopen_err
    add s4 a0 x0 # s4 file descriptor

    # 2. write the number of rows and columns to the file
    add a0 s4 x0 
    addi sp sp -8
    sw s2 0(sp)
    sw s3 4(sp)
    add a1 sp x0
    addi a2 x0 2
    addi a3 x0 4
    jal ra fwrite 
    li t0 2
    bne a0 t0 fwrite_err
    addi sp sp 8

    # 3. write the data to the file
    add a0 s4 x0 
    add a1 s1 x0
    mul a2 s2 s3
    addi a3 x0 4
    jal ra fwrite 
    mul t0 s2 s3
    bne a0 t0 fwrite_err

    # 4. close the file 
    add a0 s4 x0 
    jal ra fclose
    li t0 -1
    beq a0 t0 fclose_err

    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    addi sp sp 28
    jr ra

fopen_err:
    li a0 27
    j exit

fclose_err:
    li a0 28
    j exit

fwrite_err:
    li a0 30
    j exit
