#-----------------------------------------------------------------
#Benjamin Scown
#62071873
#COSC 211
#Computer Science
#Lab 5_6, Excercise 1
#-----------------------------------------------------------------
#code section
      .text  		# directive for code section
      .globl main  	# directive: main is visible to other files 
main: 
	# $s0 -> num1
	# $s1 -> num2
	# $s2 -> product bottom
	# #s3 -> product top
	
	li $v0, 4
	la $a0, msg1
	syscall
	
	li $v0, 5
	syscall
	
	or $s0, $v0, $v0
	
	li $v0, 4
	la $a0, msg2
	syscall
	
	li $v0, 5
	syscall
	
	or $s1, $v0, $v0
	
	# move num1 and num2 to $a regs for method
	or $a0, $s0, $s0
	or $a1, $s1, $s1
	
	jal multiply
	# move results into $s3-4
	or $s3, $v0, $v0
	or $s4, $v1, $v1
	
	li $v0, 4
	la $a0, msg3
	syscall
	
	li $v0, 4
	la $a0, msg4
	syscall
	
	or $a0, $s3, $s3
	jal print_hex
	
	li $v0, 11
	li $a0, 10
	syscall
	
	li $v0, 4
	la $a0, msg5
	syscall
	
	or $a0, $s4, $s4
	jal print_hex
	
	j exit
	
multiply:
	# $a0 -> multiplier
	# $a1 -> multiplicand
	# $v0 -> product left
	# $v1 -> product right
	
	# clear $v0-1
	or $v0, $zero, $zero
	or $v1, $zero, $zero
	
	# store $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# $t0 -> mask for last bit
	li $t0, 1
	
	# $t3 -> loop counter
	# $t4 -> loop max
	and $t3, $zero, $zero
	li $t4, 32
	
mult_loop:
	# $t1 -> multiplier[0]
	and $t1, $a0, $t0

	beq $t1, $zero, mult_shift   #if multiplier[0] == 0, skip adding multiplicand to left-half of product
	
	add $v0, $v0, $a1
mult_shift:
	srl $a0, $a0, 1
	
	# move last bit of product left to first bit of product right
	# $t2 -> last bit of product left (also used when checking for overflow)

	# CHECK FOR OVERFLOW (not needed since product registers are 64-bit, but will check anyways)
	and $t2, $v1, $t0
	bne $t2, $zero, mult_overflow
	
of_return:

	srl $v1, $v1, 1
	and $t2, $v0, $t0
	sll $t2, $t2, 31
	addu $v1, $v1, $t2
	srl $v0, $v0, 1
	
	addi $t3, $t3, 1
	bne $t3, $t4, mult_loop
	
mult_exit:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
mult_overflow:
	jal overflow_handler
	beq $zero, $zero, of_return
	
overflow_handler:
	addi $sp, $sp, -8
	sw $v0, 4($sp)
	sw $a0, 0($sp)
	
	li $v0, 4
	la $a0, overflow
	syscall
	
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra
	
print_hex:
	# prints hex value in $a0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# save $a0 in $t1
	# $t1 -> number to print
	or $t1, $zero, $a0
	
	la $a0, hex_sym
	li $v0, 4
	syscall
	
	# prepare $v0 for syscall
	li $v0, 11
	
	# $t7 -> mask for first 4 bits
	addi $t7, $zero, 15
	sll $t7, $t7, 28
	
	# $t6 -> max count
	# $t5 -> counter
	addi $t6, $zero, 8
	add $t5, $zero, $zero
	
hex_loop:
	# apply mask
	# $t0 -> 4-bit val
	and $t0, $t1, $t7
	# return 4 bits to bottom
	srl $t0, $t0, 28
	
	# $t4 -> max value that can be printed in hex with a number
	addi $t4, $zero, 10
	blt $t0, $t4, is_num
	
is_char:
	addi $t0, $t0, 39
is_num:
	addi $t0, $t0, 48

	or $a0, $zero, $t0
	syscall
	
	sll $t1, $t1, 4
	addi $t5, $t5, 1
	bne $t5, $t6, hex_loop
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra	
	
exit:
	li $v0, 10
	syscall

#-------------------------------------------------------------------
#data section

     .data   #directive for
msg1:
	.asciiz "Please enter the first number: "

msg2:
	.asciiz "Please enter the second number: "
	
msg3:
	.asciiz "The product is: \n"

msg4:
	.asciiz "Upper half: "
	
msg5:
	.asciiz "Lower half: "
	
hex_sym:
	.asciiz "0x"

overflow:
	.asciiz "ERROR: Arithmetic overflow occurred during operation"