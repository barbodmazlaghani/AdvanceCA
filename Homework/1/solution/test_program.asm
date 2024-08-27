.data
array:  .word  10, 20, 15, 25, 30, 5, 7, 50, 2, 33  # An array of 10 integers

.text
.globl main
main:
    la   $t0, array         # Load the address of the array into $t0
    li   $t1, 10            # Set $t1 to the array's length
    li   $t2, 0             # Initialize max value to 0 in $t2
    li   $t3, 0             # Initialize loop counter to 0 in $t3

loop:
    bge  $t3, $t1, endLoop  # If counter >= array length, end loop
    lw   $t4, 0($t0)        # Load current element into $t4
    addi $t0, $t0, 4        # Move to the next array element
    bgt  $t4, $t2, update   # If current element > max, update max
    j    nextIteration
update:
    move $t2, $t4           # Update max value
nextIteration:
    addi $t3, $t3, 1        # Increment loop counter
    j    loop

endLoop:
    move $v0, $t2           # Move the max value to $v0 for output
    # End of program, typically an exit syscall or an infinite loop