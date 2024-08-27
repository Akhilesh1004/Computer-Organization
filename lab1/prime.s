.data
	input_msg:	.asciiz "Please input a number: "
	output_msg1:	.asciiz "It's a prime"
	output_msg2:	.asciiz "It's not a prime"
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

# jump to procedure prime
	jal 	prime
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 
	beq		$t0, 1, L1
	beq		$t0, 0, L2
L1:
# print output_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg1		# load address of string into $a0
	syscall                 	# run the syscall
	j finish

L2:
# print output_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg2		# load address of string into $a0
	syscall 
	j finish

finish:
# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure prime -----------------------------
# load argument n in $a0, return value in $v0. 
.text
prime:	
	addi 	$sp, $sp, -8		# adiust stack for 2 items
	sw 		$ra, 4($sp)			# save the return address
	sw 		$a0, 0($sp)			# save the argument n
	beq		$a0, $zero, P0		# if n == 0, return 0
	beq		$a0, 1, P0			# if n == 1, return 0
	slti 	$t0, $a0, 3			# test for n < 3
	beq 	$t0, 1, P1			# if n <= 2 return 1
	addi  	$t0, $zero, 2    	# initialize i = 2
Loop:		
	mul   	$t1, $t0, $t0    	# t1 = i * i
	bgt   	$t1, $a0, P1	 	# if i*i > n, return 1
	div   	$a0, $t0         	# divide n by i
    mfhi  	$t2              	# get remainder
	beq   	$t2, $zero, P0 		# if remainder == 0, return 0
	addi  	$t0, $t0, 1      	# increment i
	j	Loop					# repeat loop
P0:
	add		$v0, $zero, $zero
	j	end_prime
P1:
	addi 	$v0, $zero, 1
	j	end_prime
end_prime:
	lw 		$ra, 4($sp)			# restore the return address
	addi 	$sp, $sp, 8			# adjust stack pointer to pop 2 items
	jr 		$ra					# return to caller