.data
	input_msg:	.asciiz "Please input a number: "
	output_msg:	.asciiz "The result of fibonacci(n) is "
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a0 (set arugument of procedure factorial)

# jump to procedure fibonacci
	jal 	fibonacci
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 

# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure fibonacci on the console interface
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t0			# move value of integer into $a0
	syscall 					# run the syscall

# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure fibonacci -----------------------------
# load argument n in $a0, return value in $v0.
.text
fibonacci:
    addi    $sp, $sp, -12      # adjust stack for 3 items
    sw      $ra, 0($sp)        # save the return address
    sw      $s0, 4($sp)        # save the argument n
	sw      $s1, 8($sp)        # save the argument fibonacci(n-1)
	add		$s0, $a0, $zero	   # store n in $s0
    beq     $s0, $zero, L1     # if n = 0 go to L1
	beq     $s0, 1, L1     	   # if n = 1 go to L1
	addi    $a0, $s0, -1       # n >= 2, argument gets (n-1)
    jal     fibonacci          # call fibonacci with (n-1)
    move    $s1, $v0           # store fibonacci(n-1) in $s0
    addi    $a0, $s0, -2       # n >= 2, argument gets (n-2)
    jal     fibonacci          # call fibonacci with (n-2)
    add     $v0, $s1, $v0      # return fibonacci(n-1) + fibonacci(n-2)
	j L3
L1:
    add 	$v0, $zero, $a0		# return 1 or 0
	j L3
L3:
	lw      $ra, 0($sp)        # restore the return address
	lw      $s0, 4($sp)        # restore argument n
	lw      $s1, 8($sp)        # restore argument n
	addi    $sp, $sp, 12        # adjust stack pointer to pop 2 items
    jr      $ra                # return to the caller