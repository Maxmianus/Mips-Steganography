	.data
	userOptions: .asciiz "Enter 'e' to encode an image or Enter 'd' to decode an image: "
	returnLine: .ascii "\n"
	fileName: .asciiz "C:\\Users\\WHF17\\Desktop\\HiddenImage.pgm"
	fileEncode: .asciiz "C:\\Users\\WHF17\\Downloads\\baboon3.pgm"
	fileWriteName: .asciiz "C:\\Users\\WHF17\\Desktop\\HiddenImage.pgm"
	fileWrite: .space 300000 #string image is stored to
	fileWrite2: .space 300000
	array: .space 300000
	
	.align 2
	NumberArray: .space 300000
	.align 2
	NumberArray2: .space 300000
	
	.text
	.globl main

	main:
	
# To change files, if using Windows, you will need to do the double lashses as seen above
# fileName is the file that is being encoded  into (first image for everything)--> fileEncode is the file that is being encoded (only used for encoding) --> fileWriteName is the output file for each encode/decode
# fileWriteName only gets the hidden image not both images 


########################### USER OPTIONS #####################################################
	# $v1 contains read character, need through entirety of program

		li $v0, 4
		la $a0, userOptions
		syscall
		
		li $v0, 12
		syscall
		move $v1, $v0

		
		
########################HOW TO READ INTO A FILE ##########################################################
		
		li $v0,13           	# open_file syscall code = 13
    		la $a0,fileName     	# get the file name
    		li $a1,0           	# file flag = read (0)
    		syscall
    		move $s0,$v0        	# save the file descriptor. $s0 = file
	
		#read the file
		li $v0, 14		# read_file syscall code = 14
		move $a0,$s0		# file descriptor
		la $a1, array 		# The buffer that holds the string of the WHOLE file	#replaced fileWords with array
		la $a2,300000		# hardcoded buffer length
		syscall
	
		# print whats in the file
		#li $v0, 4		# read_string syscall code = 4
		#la $a0, array		#replaced fileWords with array
		#syscall
	
		#Close the file
    		li $v0, 16         	# close_file syscall code
    		move $a0,$s0      	# file descriptor to close
    		syscall
	
	
	
######################## PARSE IMAGE INTO ARRAY	#####################################################################	
	
	#Variables $s6 = length of array , $s5 = amount of arrays , $t4 = D where the strings are parsed into numbers , $t6 = pointer counter for array 
		#$t2 = address where array is located , $t7 = address where NumberArray is located,  $s7 = address of string to write to file
		
		#Different from ProjectMips, checks for carriage return instead of new line in some areas
	
			add $s6, $zero, $zero	#length of array
			add $s5, $zero, $zero	#amount of arrays
			add $t4, $zero, $zero	#Set D to 0
			add $t6, $zero, $zero	#set s0 to 0
			la $t2, array	#load array
			la $t7, NumberArray	#address where the parsed numbers will be stored
			la $s7, fileWrite	#address where the parsed image will be written to
	
	#find every number in .asiiz and each number increments counter
	ParseFirstTwoLinesLoop:	
			lb $t3, ($t2) #load pointer to array to $t3
			addi $t2, $t2, 1 #increment S to point at next byte
			
			sb $t3, ($s7)	#store byte to string
			addi $s7, $s7, 1 #increment pointer to s7 by 1
			
			#check for first two new line characters
			beq $t3, 10, IncrementCounter	#check if loaded byte equal to \n
			bne $t6, 2, ParseFirstTwoLinesLoop	#t6 = counter
			
			subi $t2, $t2, 1	#go back once for pointer otherwise skips first byte of number
			subi $s7, $s7, 1
			
		GetLengthLoop:	#Get array size
			lb $t3, ($t2)	#load pointer
			sb $t3, ($s7)
			beq $t3, 32, SkipSpace	#check for space
			addi $t2, $t2, 1	#increment pointer
			addi $s7, $s7, 1
			mul $t4, $t4, 10	#multiply D by 10
			subi $t6, $t3, 48	#subtract the ascii number by ascii 0, store in s0
			add $t4, $t4, $t6	#Add D with S
			j GetLengthLoop
		
		SkipSpace:	
			addi $t2, $t2, 1	#skips space after first number
			add $s6, $t4, $zero	#store length of array
			add $t4, $zero, $zero #set D to 0
			
			#copy space to write string
			addi $t5, $zero, 32
			sb $t5, ($s7)
			addi $s7, $s7, 1
			li $t5, 0
			
		#changed compared to ProjectMips
		GetAmountLoop:	#Get amount of arrays/ width
			lb $t3, ($t2)	#load pointer
			sb $t3, ($s7)	#store to write string
			beq $t3, 13, Reset	#check for carriage return
			addi $t2, $t2, 1	#increment pointer
			addi $s7, $s7, 1
			mul $t4, $t4, 10	#multiply D by 10
			subi $t6, $t3, 48	#subtract the ascii number by ascii 0, store in s0
			add $t4, $t4, $t6	#Add D with S
			j GetAmountLoop
			
		#changed compared to ProjectMips
		Reset:	
			#S is currently pointing at carriage return 
			add $s5, $t4, $zero	#store amount into $s5
			add $t4, $zero, $zero	#set D to 0
			add $t6, $zero, $zero	#set s0 to 0
			addi $t2, $t2, 2	#increment S by 2 so not on newline character and carriage return
			
						#copy \n to write string
			la $t4, returnLine
			lb $t6, ($t4)
			addi $s7, $s7, 1
			sb $t6, ($s7)
			addi $s7, $s7, 1
			add $t4, $zero, $zero
		
		#Skips to start of numbers to be parsed		
		QuickSkip:
			lb $t3, ($t2)	#load byte
			sb $t3, ($s7)
			addi $t2, $t2, 1	#increment pointer by 1
			addi $s7, $s7, 1
			beq $t3, 10, ParseNumbers	#check for newline
			j QuickSkip
		
		#Reset for variables for new number, skips over spaces and newline characters until a number is found
		ParseReset: 
			addi $t2, $t2, 1#skips space after first number
			lb $t3, ($t2)
			beq $t3, 13, ParseReset
			beq $t3, 10, ParseReset	
			beq $t3, 32, ParseReset
			beq $t3, 0, ExitParse	#if null exit
			j StoreNumber	#new number so need to store old number before returning to ParseNumbers
			
		#changed compared to ProjectMips
		ParseNumbers:	#where the pixel values are stored
		
			lb $t3, ($t2)
			beq $t3, 13, ParseReset	#checks for carriage return
			beq $t3, 32, ParseReset
			beq $t3, 0, ExitParse	#if null exit
			mul $t4, $t4, 10	#multiply D by 10
			subi $t6, $t3, 48	#subtract the ascii number by ascii 0, store in s0
			addi $t2, $t2, 1	#increment pointer
			add $t4, $t4, $t6	#Add D with S
			j ParseNumbers
			
		StoreNumber:
			#prints out each number
			#li $v0, 1       
			#add $a0, $t4, $zero
			#syscall
		
			sw $t4, ($t7)	#store into data array
			addi $t7, $t7, 4	#increment by 4 for word
			add $t4, $zero, $zero #set D to 0
			j ParseNumbers
			
			j ExitParse
			
			
	#increments counter if newline character is found		
	IncrementCounter:
			addi $t6, $t6, 1
			j ParseFirstTwoLinesLoop
	
	
	ExitParse:	 
	
		#For decode, checks for uppercase D (68) or lowercase d (100)
		li $t4, 100	
		beq $v1, $t4, DecodeStart
		
		li $t4, 68
		beq $v1, $t4, DecodeStart
#################################	Second Image Into NEW Array	##########################################################
	
				#HOW TO READ INTO A FILE
		
		li $v0,13           	# open_file syscall code = 13
    		la $a0,fileEncode     	# get the file name
    		li $a1,0           	# file flag = read (0)
    		syscall
    		move $s0,$v0        	# save the file descriptor. $s0 = file
	
	
		#read the file
		li $v0, 14		# read_file syscall code = 14
		move $a0,$s0		# file descriptor
		la $a1, array 		# The buffer that holds the string of the WHOLE file	#replaced fileWords with array
		la $a2,300000		# hardcoded buffer length
		syscall
	
		# print whats in the file
		#li $v0, 4		# read_string syscall code = 4
		#la $a0, array		#replaced fileWords with array
		#syscall
	
		#Close the file
    		li $v0, 16         	# close_file syscall code
    		move $a0,$s0      	# file descriptor to close
    		syscall
	
############################### SECOND PARSE INTO ARRAY FOR SECOND IAMAGE #####################################################################

			#Variables $s6 = length of array , $s5 = amount of arrays , $t4 = D where the strings are parsed into numbers , $t6 = pointer counter for array 
		#$t2 = address where array is located , $t7 = address where NumberArray is located,  $s7 = address of string to write to file
		
		#Different from ProjectMips, checks for carriage return instead of new line in some areas
	
			add $s6, $zero, $zero	#length of array
			add $s5, $zero, $zero	#amount of arrays
			add $t4, $zero, $zero	#Set D to 0
			add $t6, $zero, $zero	#set s0 to 0
			la $t2, array	#load array
			la $t7, NumberArray2	#address where the parsed numbers will be stored
			la $s7, fileWrite2	#address where the parsed image will be written to
	
	#find every number in .asiiz and each number increments counter
	ParseFirstTwoLinesLoop2:	
			lb $t3, ($t2) #load pointer to array to $t3
			addi $t2, $t2, 1 #increment S to point at next byte
			
			sb $t3, ($s7)	#store byte to string
			addi $s7, $s7, 1 #increment pointer to s7 by 1
			
			#check for first two new line characters
			beq $t3, 10, IncrementCounter2	#check if loaded byte equal to \n
			bne $t6, 2, ParseFirstTwoLinesLoop2	#t6 = counter
			
			subi $t2, $t2, 1	#go back once for pointer otherwise skips first byte of number
			subi $s7, $s7, 1
			
		GetLengthLoop2:	#Get array size
			lb $t3, ($t2)	#load pointer
			sb $t3, ($s7)
			beq $t3, 32, SkipSpace2	#check for space
			addi $t2, $t2, 1	#increment pointer
			addi $s7, $s7, 1
			mul $t4, $t4, 10	#multiply D by 10
			subi $t6, $t3, 48	#subtract the ascii number by ascii 0, store in s0
			add $t4, $t4, $t6	#Add D with S
			j GetLengthLoop2
		
		SkipSpace2:	
			addi $t2, $t2, 1	#skips space after first number
			add $s6, $t4, $zero	#store length of array
			add $t4, $zero, $zero #set D to 0
			
			#copy space to write string
			addi $t5, $zero, 32
			sb $t5, ($s7)
			addi $s7, $s7, 1
			li $t5, 0
			
		#changed compared to ProjectMips
		GetAmountLoop2:	#Get amount of arrays/ width
			lb $t3, ($t2)	#load pointer
			sb $t3, ($s7)	#store to write string
			beq $t3, 13, Reset2	#check for carriage return
			addi $t2, $t2, 1	#increment pointer
			addi $s7, $s7, 1
			mul $t4, $t4, 10	#multiply D by 10
			subi $t6, $t3, 48	#subtract the ascii number by ascii 0, store in s0
			add $t4, $t4, $t6	#Add D with S
			j GetAmountLoop2
			
		#changed compared to ProjectMips
		Reset2:	
			#S is currently pointing at carriage return 
			add $s5, $t4, $zero	#store amount into $s5
			add $t4, $zero, $zero	#set D to 0
			add $t6, $zero, $zero	#set s0 to 0
			addi $t2, $t2, 2	#increment S by 2 so not on newline character and carriage return
			
						#copy \n to write string
			la $t4, returnLine
			lb $t6, ($t4)
			addi $s7, $s7, 1
			sb $t6, ($s7)
			addi $s7, $s7, 1
			add $t4, $zero, $zero
		
		#Skips to start of numbers to be parsed		
		QuickSkip2:
			lb $t3, ($t2)	#load byte
			sb $t3, ($s7)
			addi $t2, $t2, 1	#increment pointer by 1
			addi $s7, $s7, 1
			beq $t3, 10, ParseNumbers2	#check for newline
			j QuickSkip2
		
		#Reset for variables for new number, skips over spaces and newline characters until a number is found
		ParseReset2: 
			addi $t2, $t2, 1#skips space after first number
			lb $t3, ($t2)
			beq $t3, 13, ParseReset2
			beq $t3, 10, ParseReset2	
			beq $t3, 32, ParseReset2
			beq $t3, 0, ExitParse2	#if null exit
			j StoreNumber2	#new number so need to store old number before returning to ParseNumbers
			
		#changed compared to ProjectMips
		ParseNumbers2:	#where the pixel values are stored
		
			lb $t3, ($t2)
			beq $t3, 13, ParseReset2	#checks for carriage return
			beq $t3, 32, ParseReset2
			beq $t3, 0, ExitParse2	#if null exit
			mul $t4, $t4, 10	#multiply D by 10
			subi $t6, $t3, 48	#subtract the ascii number by ascii 0, store in s0
			addi $t2, $t2, 1	#increment pointer
			add $t4, $t4, $t6	#Add D with S
			j ParseNumbers2
			
		StoreNumber2:
			#prints out each number
			#li $v0, 1       
			#add $a0, $t4, $zero
			#syscall
		
			sw $t4, ($t7)	#store into data array
			addi $t7, $t7, 4	#increment by 4 for word
			add $t4, $zero, $zero #set D to 0
			j ParseNumbers2
			#addi $s2, $s2, 1
			j ExitParse2
			
			
	#increments counter if newline character is found		
	IncrementCounter2:
			addi $t6, $t6, 1
			j ParseFirstTwoLinesLoop2
	
	
	ExitParse2:  j EncodeStart
		
#####################	Decoding Image	##########################################################

	DecodeStart:
		la $s2, NumberArray
		mul $a3, $s5, $s6
		li $t6, 10
		li $t7, 28
		li $t8, 0
		
	Decode: beq $t8, $a3 EncodeExit
		lw $t0, ($s2)
		
		div $t0, $t6	#divide by 10 to get remainder
		mfhi $t1
		
		mul $t2, $t1, $t7
		
		sw $t2, ($s2)
		
		addi $s2, $s2, 4
		addi $t8, $t8, 1
		j Decode
			
#####################	Encoding Image	##########################################################
	
	EncodeStart:
		la $s2, NumberArray
		la $s3, NumberArray2
		mul $a3, $s5, $s6
		li $t8, 0
		
	Encode: beq $t8, $a3, EncodeExit
		lw $t0, ($s2)
		lw $t1, ($s3)
		
		li $t2, 10
		
		div $t0, $t2
		
		mflo $t3
		mul  $t0, $t3, $t2
		
		sw $t0, ($s2)
		
		li $t2, 28
		div $t1, $t2
		
		mflo $t3
		
		add $t0, $t0, $t3
		
		sw $t0 ($s2)
		addi $t8, $t8, 1
		addi $s2, $s2, 4
		addi $s3, $s3, 4
		j Encode

	EncodeExit:			
#####################	PARSE IMAGE BACK INTO STRING	##########################################################

		# At this point fileWrite contains the image type, original comment, length and width of image, and range of pixel values
		# First I need to reverse the number: ex) 253 -> 352
		# Then I divide the new number by 10 and store the remainder in its ascii form to the string: ex) 352/10 = 35.2 , store 2 then 35/10 =3.5 , store 5 etc
		# t0 = loop counter for array, t1 = address of array, t4 = reversed number stored
		
		
		
		
		li $t1, 4		#size of word
		li $s4, 0
		mul  $t0, $s6, $s5	#multipling length * width
		mul $t0, $t0, $t1	#multiply by size of word to get counter for loop,			 = 36
		
		li $t4, 0
		la $t1, NumberArray
		
	RevStart:	
		lw $t2, ($t1)
		li $t3, 10
		beqz $t2, storeWord	#checks if word is equal to 0
		add $t6, $zero, $t2
		
	Reverse:	#reverses loaded word
		mul $t4, $t4, $t3
		div $t6, $t3		#divide by 10
		mfhi $t7		#remainder
		mflo $t6		#quotient
		add $t4, $t4, $t7
		beqz $t7, AddZero	#check if remainder = 0, if so add zero byte to string
		bne $t6, $zero, Reverse
		j storeWord
	
	#right now converts 0 to 1
	AddZero:
		#li $t7, 48
		#sb $t7, ($s7)
		addi $t4, $t4, 1
		j Reverse	
				
	storeWord:	
		li $t5, 0
		div $t4, $t3		#divide by 10
		mfhi $t7		#remainder
		mflo $t4		#quotient
		addi $t5, $t7, 48	#add '0' to get ascii value of number
		sb $t5, ($s7)
		addi $s7, $s7, 1
		bne $t4, $zero, storeWord
		
		addi $s4, $s4, 4	#using as counter
		addi $t1, $t1, 4
		li $t4, 16
		beq $t0, $s4, FileWriteSection	#check if all numbers were reached
		
		li $t5, 13
		div $s4, $t4			#divide by 16, checks if remainder = 0
		mfhi $t7
		bne $t7, $zero, storeWordSkip
		
		sb $t5, ($s7)
		addi $s7, $s7, 1
		
		li $t5, 10
		li $t4, 0
		sb $t5, ($s7)
		addi $s7, $s7, 1
		
		j RevStart
		
	storeWordSkip:	
		li $t5, 32
		sb $t5, ($s7)
		addi $s7, $s7, 1
		li $t4, 0
		j RevStart
		
######################## HOW TO WRITE INTO A FILE ENCODING	##########################################################
    
    	FileWriteSection:
    	
    	#check for whether encode or decode
    	li $t4, 100	
	beq $v1, $t4, DecodeFile
		
	li $t4, 68
	beq $v1, $t4, DecodeFile	
    			
    	#open file 
    	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileWriteName    # get the file name
    	li $a1,1           	# file flag = write (1)
    	syscall
    	move $s1,$v0        	# save the file descriptor. $s0 = file
    	
    	#Write the file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,fileWrite2	# the string that will be written	
    	la $a2,300000		# length of the toWrite string
    	syscall
    	
	#MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    	li $v0,16         	# close_file syscall code
    	move $a0,$s1      	# file descriptor to close
    	syscall
    	j Exit
    	
    	DecodeFile:
    	#open file 
    	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileWriteName    # get the file name
    	li $a1,1           	# file flag = write (1)
    	syscall
    	move $s1,$v0        	# save the file descriptor. $s0 = file
    	
    	#Write the file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,fileWrite	# the string that will be written	#should be fileWrite2
    	la $a2,300000		# length of the toWrite string
    	syscall
    	
	#MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    	li $v0,16         	# close_file syscall code
    	move $a0,$s1      	# file descriptor to close
    	syscall
    	j Exit

	Exit: 
