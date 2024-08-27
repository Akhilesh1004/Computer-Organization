.data
	input_msg1:	.asciiz "Please enter option (1: add, 2: sub, 3: mul): "
	input_msg2:	.asciiz "Please enter the first number: "
	input_msg3:	.asciiz "Please enter the second number: "
	output_msg:	.asciiz "The calculation result is: "
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg1		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t0, $v0      		# store input in $a0 (set arugument of procedure factorial)

# print input_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t1, $v0

# print input_msg3 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg3		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t2, $v0

# check the option
	bne		$t0,	1,	L1
	add		$t1,	$t1,	$t2
	j L3
	
L1:
	bne		$t0,	2,	L2
	sub		$t1,	$t1,	$t2
	j L3
L2:
	mul     $t1,	$t1,	$t2
	j L3
L3:
# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure calculator on the console interface
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t1			# move value of integer into $a0
	syscall 					# run the syscall

# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall
