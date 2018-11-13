# Compute N numbers and put in array, then print array and sum
.data
nums:.word   0 : 12         # array of words to contain computed values
size: .word  12             # size of array to set N when input disabled
prompt: .asciiz "Enter the size of the array: "
.text
      la   $s0, nums        # load address of array
      la   $s5, size        # load address of size variable
      lw   $s5, 0($s5)      # load array size

entry:la   $a0, prompt      # load address of prompt for syscall
      li   $v0, 4           # specify Print String service
      syscall               # print the prompt string
      li   $v0, 5           # specify Read Integer service
      syscall               # Read the number entered
      
      bgt  $v0, $s5, entry  # Check valid input - N=13 or greater causes overflow
      blez $v0, entry       # Check valid input - N=0 or less is not possible      
      add  $s5, $v0, $zero  # transfer the entry to register
      
      li   $s2, 1           # 1 is the initial value
      sw   $s2, 0($s0)      # A[0] = 1
      addi $s0, $s0, 4      # increment address to the next index
      li   $s1, 1           # set i to 1
      li   $s4, 2           # set the value for 2^i 
      blt  $v0, $s4, final  # print if no calculations necessary
      
# Loop to compute each number using the given function
loop: lw   $s3, -4($s0)     # Get value from array A[i-1]
      mult $s3, $s1         # i*A[i-1]
      mflo $s3              # pull the value from the $LO register
      add  $s2, $s3, $s4    # A[i] = i*A[i-1]+2^i
      sw   $s2, 0($s0)      # Store newly computed A[i] in array
      sll  $s4, $s4, 1      # update 2^i to the next value
      addi $s0, $s0, 4      # increment address to the next index
      addi $s1, $s1, 1      # increment loop counter
      bne $s1, $s5, loop    # loop until the end of the array
        
final:la   $a0, nums       # first argument for print - array
      add  $a1, $zero, $s5  # second argument for print - size
      jal  print            # call print routine

      li   $v0, 10          # system call for exit
      syscall               # Exit
		
# Subroutine to print
      .data
newline: .asciiz  "\n"      # newline for next string
is: .asciiz  " is "         # "is" string part
sumstart: .asciiz  "Sum of the values is "
linestart: .asciiz  "Value at array index "
      .text
print:add  $t0, $zero, $a0  # starting address of array
      li   $t1, 0           # index counter
      li   $t2, 0           # sum value
      
out:  la   $a0, linestart   # load address of the linestart
      li   $v0, 4           # specify Print String service
      syscall               # print the linestart
      
      la   $a0, ($t1)       # load the index
      li   $v0, 1           # specify Print Integer service
      syscall               # print index
      
      la   $a0, is          # load "is" string part
      li   $v0, 4           # specify Print String service
      syscall               # print "is" string part
      
      lw   $a0, 0($t0)      # load the integer to be printed
      add $t2, $t2, $a0     # add to sum
      li   $v0, 1           # specify Print Integer service
      syscall               # print integer
      
      la   $a0, newline     # load the newline
      li   $v0, 4           # specify Print String service
      syscall               # print the newline
      
      addi $t0, $t0, 4      # increment the next index
      addi $t1, $t1, 1      # increment loop counter
      bne $t1, $a1, out
      
      la   $a0, sumstart    # load address of the sumstart
      li   $v0, 4           # specify Print String service
      syscall               # print the sumstart
      
      la   $a0, ($t2)       # load the sum
      li   $v0, 1           # specify Print Integer service
      syscall               # print sum
      
      jr   $ra              # return from subroutine
