.data
	input_msg1:	.asciiz "Please enter option (1: triangle, 2: inverted triangle): "
	input_msg2:	.asciiz "Please input a triangle size: "
	output_msg1:	.asciiz " "
	output_msg2:	.asciiz "*"
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
	move    $t0, $v0      		# store input in $t0 (set arugument of procedure factorial)

# print input_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t1, $v0      		# store input in $t1 (set arugument of procedure factorial)
	add		$t2, $zero, $zero	# initial i to 0
Loop:
	bgt   	$t2, $t1, finish	 # if i > n, go to finish
	beq		$t2, $t1, finish	# if i = n, go to finish
	beq		$t0, 1, L1			# if op = 1, go to L1
	beq		$t0, 2, L2			# if op = 2, go to L2
	j	Loop					# repeat loop

L4:
# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall
	addi  	$t2, $t2, 1      	# increment i
	j Loop

L1:
	sub		$t3, $t1, $t2		# set $t3 to n - i
	addi	$t4, $zero, 1		# initial j to 1
L11:
	beq		$t4, $t3, L12
	bgt   	$t4, $t3, L12
# print output_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg1	# load address of string into $a0
	syscall                 	# run the syscall
	addi  	$t4, $t4, 1      	# increment j
	j L11
L12:
	add		$t3, $t1, $t2		# set $t3 to n + i
	sub		$t4, $t1, $t2		# initial j to n - i
	j L13

L13:
	bgt   	$t4, $t3, L4
# print output_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg2	# load address of string into $a0
	syscall                 	# run the syscall
	addi  	$t4, $t4, 1      	# increment j
	j L13

L2:
	addi	$t3, $t2, 1			# set $t3 to i + 1
	addi	$t4, $zero, 1		# initial j to 1
L21:
	beq		$t4, $t3, L22
	bgt   	$t4, $t3, L22
# print output_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg1	# load address of string into $a0
	syscall                 	# run the syscall
	addi  	$t4, $t4, 1      	# increment j
	j L21
L22:
	add		$t3, $t1, $t1		# set $t3 to 2n
	sub		$t3, $t3, $t2		# set $t3 to 2n - i
	addi	$t3, $t3, -1		# set $t3 to 2n - i - 1
	addi	$t4, $t2, 1			# initial j to i + 1
	j L23

L23:
	bgt   	$t4, $t3, L4
# print output_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg2	# load address of string into $a0
	syscall                 	# run the syscall
	addi  	$t4, $t4, 1      	# increment j
	j L23

finish:
# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall
