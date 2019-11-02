
#=========================================================================
# Tokenizer
#=========================================================================
# Split a string into alphabetic, punctuation and space tokens
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"   
newline:                .asciiz  "\n"
    
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL

# You can add your data here!

tokens:                 .space 4098     # (Content Array + Null) * 2
separator: 			.byte '@'	    # Intitialise separator value
 
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
        
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

# reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_file);
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
        
END_LOOP:
        sb   $0,  content($t0)

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
tokenizer:

	li $s0, 0                         # Initialise i
	li $s1, 0
	jal tokenCheck			    # Jump and link to tokenCheck
	
	li $s2, 1                         # Initialise print_i
	
	j printLoop                       # Jump and link to printLoop
	
tokenCheck:
	
	lb $t0, separator	               # Load separator into $t0
	sb $t0, tokens($s1)
	
	addi $s1, $s1, 1
	lb $t1, content($s0)              # load item in content[i]
	
	beqz $t1, endCheck                # If content[i] == null, end loop
	
	beq $t1, 32, ifSpace		    # If content[i] == space, go to end token
	
	sgt $t6, $t1, 64                  # If letter, then set $t6 to 1. Else, 0
	beq $t6, 1, ifLetter              # If $t6 == 1, go to ifLetter
	
	slti $t8, $t1, 64                 # If content[i] is punct then set $t5 to 1, else 0
	sgt $t7, $t1, 32
	beq $t7, $t8, ifPunct		    # If $t5 == 1, then go to ifPunct
	
	j tokenCheck
	
ifLetter:
	
	lb $t0, content($s0)
	
	beq $t0, 32, nextSpace		    # If content[i] == space, go to end token
	
	beqz $t0, endCheck                # If content[i] == null, end loop
	slti $t8, $t0, 64                 # If content[i] is punct then set $t5 to 1, else 0
	sgt $t7, $t0, 32
	beq $t7, $t8, nextPunct		    # If $t5 == 1, then go to ifPunct
	
	sb $t0, tokens($s1)               # Store content[i] into tokens[i]
	
	addi $s1, $s1, 1
	addi $s0, $s0, 1                  # c_idx++
	
	j ifLetter                        # Loop back to beginning

ifSpace:
	
	lb $t0, content($s0)
	
	beqz $t0, endCheck                # If content[i] == null, end loop
	
	slti $t8, $t0, 64                 # if content is punct, go to nextPunct
	sgt $t7, $t0, 32
	beq $t7, $t8, nextPunct	
	
	sgt $t6, $t0, 64                 # Set $t6 to 1 if letter, else 0
	beq $t6, 1, nextLetter		   # If next char is immediately a letter, go to nextLetter
	
	sb $t0, tokens($s1)               # Store content[i] into tokens[i]
	
	addi $s1, $s1, 1
	addi $s0, $s0, 1                  # c_idx++
	
	j ifSpace                        # Loop back to beginning

nextSpace:

	lb $t0, separator	               # Load separator into $t0
	sb $t0, tokens($s1)	         # Save separator in tokens[i]
	
	lb $t1, content($s0)		   # Load content[i] into $t1
	
	addi $s1, $s1, 1
	sb $t1, tokens($s1)		   # Store content[i-1] into tokens[i]
	addi $s0, $s0, 1		         # c_idx++
	addi $s1, $s1, 1
	j tokenCheck
	
nextPunct:

	lb $t0, separator	               # Load separator into $t0
	sb $t0, tokens($s1)	         # Save separator in tokens[i]
	
	lb $t1, content($s0)		   # Load content[i] into $t1
	
	
	addi $s1, $s1, 1
	sb $t1, tokens($s1)		   # Store content[i-1] into tokens[i]
	addi $s0, $s0, 1		         # c_idx++
	addi $s1, $s1, 1
	j ifPunct
	
ifPunct:
	
	lb $t0, content($s0)             # Get content[i] and store in $t0
	
	beqz $t0, endCheck                # If content[i] == null, end loop
	
	sgt $t6, $t0, 64                 # Set $t6 to 1 if letter, else 0
	beq $t6, 1, nextLetter		   # If next char is immediately a letter, go to nextLetter
	beq $t0, 32, nextSpace            # If content[i] == space, go to end token
	
	sb $t0, tokens($s1)              # Store content[i] into tokens[j]
	
	addi $s1, $s1, 1
	addi $s0, $s0, 1                 # c_idx++
	
	j ifPunct                        # Loop back to beginning

nextLetter:

	lb $t0, separator	               # Load separator into $t0
	sb $t0, tokens($s1)	         # Save separator in tokens[i]
	
	lb $t1, content($s0)		   # Load content[i] into $t1
	                          
	addi $s1, $s1, 1
	sb $t1, tokens($s1)		   # Store content[i-1] into tokens[i]
	addi $s0, $s0, 1	               # c_idx++
	addi $s1, $s1, 1
	j ifLetter
	
endToken:
	
	lb $t0, separator                 # Load separator into $t0
	sb $t0, tokens($s1)               # Store separator in tokens[i]
	addi $s0, $s0, 1	                # c_idx++
	addi $s1, $s1, 1
	j tokenCheck			    # Jump back to tokenCheck
	
endCheck:
	
	jr $ra				    # Jump back to main

printLoop:
	
	lb $t0, tokens($s2)		    # Load value of tokens[i] into $t0

	beqz $t0, main_end                # if char == null, then end program
	
	beq $t0, 64, split                # If current char == separator, branch 
	
	li $v0, 11				    # print tokens[i]
	move $a0, $t0
	syscall
	
	addi $s2, $s2, 1                  # tokens_c_idx++
	
	j printLoop
	
split:
	
	li $v0, 11
	la $a0, newline                   # print new line
	syscall
	
	addi, $s2, $s2, 1                 # tokens_c_idx++
	
	j printLoop                       # Loop back to print


#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------

main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
