
#=========================================================================
# Punctuation checker 
#=========================================================================
# Marks misspelled words and punctuation errors in a sentence according to a dictionary
# and punctuation rules
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
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL
        
# You can add your data here!

tokens:                 .space 4098     # (Tokens Array + Null) * 2
dictTokens:             .space 204001   # Dictionary tokens array (MAX_DICTIONARY_WORDS + Null) * 2
tokensCopy:             .space 4098     # Copy of the original tokens array

separator:              .byte '@'       # Intitialise separator variable
underscore:             .byte '_'       # Initialise highlight variable

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
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)               
        lb   $t1, dictionary($t0)               
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

# Tokenizer from previous exercise
 
tokenizer:

	li $s0, 0                         # Initialise i
	li $s1, 0                         # intialise j
	jal tokenCheck			    # Jump and link to tokenCheck
	
	j dt_main                         # Jump to dt_main
	
tokenCheck:
	
	lb $t0, separator	                # Load separator into $t0
	sb $t0, tokens($s1)               # store separator into tokens[j]
	
	addi $s1, $s1, 1                  # j++
	lb $t1, content($s0)              # load item in content[i]
	
	beqz $t1, endCheck                # If content[i] == null, go to endCheck
	
	beq $t1, 32, ifSpace		    # If content[i] == space, go to ifSpace
	
	sgt $t6, $t1, 64                  # If letter, then set $t6 to 1. Else, 0
	beq $t6, 1, ifLetter              # If $t6 == 1, go to ifLetter
	
	slti $t8, $t1, 64                 # If content[i] is punct then set $t5 to 1, else 0
	sgt $t7, $t1, 32
	beq $t7, $t8, ifPunct		    # If $t5 == 1, then go to ifPunct
	
	j tokenCheck
	
ifLetter:
	
	lb $t0, content($s0)              # load content[i] into $t0
	
	beq $t0, 32, nextSpace		    # If content[i] == space, go to end token
	
	beqz $t0, endCheck                # If content[i] == null, end loop
	slti $t8, $t0, 64                 # If content[i] is punct then set $t5 to 1, else 0
	sgt $t7, $t0, 32
	beq $t7, $t8, nextPunct		    # If $t5 == 1, then go to ifPunct
	
	sb $t0, tokens($s1)               # Store content[i] into tokens[i]
	
	addi $s1, $s1, 1                  # j++
	addi $s0, $s0, 1                  # i++
	
	j ifLetter                        # Loop back to beginning

ifSpace:
	
	lb $t0, content($s0)              # load content[i] into $t0
	
	beqz $t0, endCheck                # If content[i] == null, end loop
	
	slti $t8, $t0, 64                 # if content is punct, go to nextPunct
	sgt $t7, $t0, 32
	beq $t7, $t8, nextPunct	
	
	sgt $t6, $t0, 64                  # Set $t6 to 1 if letter, else 0
	beq $t6, 1, nextLetter		    # If next char is immediately a letter, go to nextLetter
	
	sb $t0, tokens($s1)               # Store content[i] into tokens[j]
	
	addi $s1, $s1, 1                  # j++
	addi $s0, $s0, 1                  # i++
	
	j ifSpace                         # Loop back to beginning

nextSpace:

	lb $t0, separator	                # Load separator into $t0
	sb $t0, tokens($s1)	          # Save separator in tokens[i]
	
	lb $t1, content($s0)		    # Load content[i] into $t1
	
	addi $s1, $s1, 1                  # j++
	sb $t1, tokens($s1)		    # Store content[i-1] into tokens[j]
	addi $s0, $s0, 1		          # i++
	addi $s1, $s1, 1                  # j++
	j tokenCheck                      # loop back to tokenCheck
	
nextPunct:

	lb $t0, separator	               # Load separator into $t0
	sb $t0, tokens($s1)	         # Save separator in tokens[i]
	
	lb $t1, content($s0)		   # Load content[i] into $t1
	
	addi $s1, $s1, 1                 # j++
	sb $t1, tokens($s1)		   # Store content[i-1] into tokens[i]
	addi $s0, $s0, 1		         # i++
	addi $s1, $s1, 1                 # j++
	
	j ifPunct                        # jump to ifPunct
	
ifPunct:
	
	lb $t0, content($s0)             # Get content[i] and store in $t0
	
	beqz $t0, endCheck               # If content[i] == null, end loop
	
	sgt $t6, $t0, 64                 # Set $t6 to 1 if letter, else 0
	beq $t6, 1, nextLetter		   # If next char is immediately a letter, go to nextLetter
	beq $t0, 32, nextSpace           # If content[i] == space, go to nextSpace
	
	sb $t0, tokens($s1)              # Store content[i] into tokens[j]
	
	addi $s1, $s1, 1                 # j++
	addi $s0, $s0, 1                 # i++
	
	j ifPunct                        # Loop back to beginning

nextLetter:

	lb $t0, separator	               # Load separator into $t0
	sb $t0, tokens($s1)	         # Save separator in tokens[j]
	
	lb $t1, content($s0)		   # Load content[i] into $t1
	                          
	addi $s1, $s1, 1
	sb $t1, tokens($s1)		   # Store content[i-1] into tokens[j]
	addi $s0, $s0, 1	               # i++
	addi $s1, $s1, 1                 # j++
	
	j ifLetter                       # jump to ifLetter
	
endToken:
	
	lb $t0, separator                # Load separator into $t0
	sb $t0, tokens($s1)              # Store separator in tokens[j]
	addi $s0, $s0, 1	               # i++
	addi $s1, $s1, 1                 # j++
	
	j tokenCheck			   # Jump back to tokenCheck
	
endCheck:
	
	lb $t0, separator	               # Load separator into $t0
	sb $t0, tokens($s1)	         # Save separator in tokens[j]
	
	jr $ra				   # Jump back to main
 
#Tokenizes dictionary words  
 
dt_main:
   
    li $s0, 0                          # Initialise counter i for the dictionary tokenizer
   
    jal dictTokenizer                  # jump and link to dictTokenizer
    
    j copyTokensIdx                    # jump to copyTokensIdx
   
dictTokenizer:
   
    lb $t0, dictionary($s0)         # Load dictionary[i] into $t0
   
    beqz $t0, endDT                 # If dictionary[i] == null, end dictTokenizer
   
    beq $t0, 10, endDToken          # If dictionary[i] == '\n', go to endDToken
   
    sb $t0, dictTokens($s0)         # Store dictionary[i] into dictTokens[i]
   
    addi $s0, $s0, 1                # i++
   
    j dictTokenizer                 # Loop back to beginning
   
endDToken:
 
    lb $t0, separator               # Load separator int $t0
    sb $t0, dictTokens($s0)         # Store separator in dictTokens[i]
    addi $s0, $s0, 1                # i++
   
    j dictTokenizer                 # Jump back to dictTokenizer
 
endDT:
    
    lb $t0, separator               # Load separator int $t0
    sb $t0, dictTokens($s0)         # Store separator in dictTokens[i]
    
    jr $ra                          # Loop back to dt_main
 
copyTokensIdx:
 	
    li $s0, 0                       # set i = 1
    
copyTokens:
    
    lb $t0, tokens($s0)             # load tokens[i] into $t0
    
    beqz $t0, checker               # branch to checker if tokens[i] == null
    
    sb $t0, tokensCopy($s0)         # store tokens[i] into tokensCopy[i]
   
    addi $s0, $s0, 1                # i++
    
    j copyTokens                    # loop back

# SpellChecker
    
checker:
    
    li $s0, 1                       # tokenStart = 1
    li $s1, 1                       # tc_idx = 1     (tokensCopy counter)
    li $s6, 0                       # pc_idx = 0     (previous token counter)
    li $s5, 0                       # nc_idx = 0     (next token counter)                   
    
    jal checkWord                   # jump and link to checkWord
    
    j main_end                      # jump to main_end
    
checkWord:
    
    lb $t0, tokensCopy($s1)         # load tokensCopy[tc_idx] into $t0
    
    beqz $t0, endChecker
    
    sge $t7, $t0, 'A'
    sle $t6, $t0, 'Z'               # if tokens char is uppercase,
    and $t5, $t7, $t6               # go to loop case
    beq $t5, 1, loopCase           
    
    slti $t8, $t0, 64               # if content is punct, go to checkPunctReset
    sgt $t7, $t0, 32
    beq $t7, $t8, checkPunctReset
    
    beq $t0, 32, printCorrect       # if $t0 is a space, go to printSpace
    
    li $s2, 0                       # dict_idx = 0
    
    j checkDict                     # jump to checkDict

#Punctuation Checker

checkPunctReset:
    
    add $s6, $zero, $s0             # Set pc_idx == tokenStart
    subi $s6, $s6, 2                # pc_idx - 2 (to get to previous token)
    
    add $s5, $zero, $s0             # set nc_idx == tokenStart
    addi $s5, $s5, 1                # nc_idx ++
    
checkPunct:
    
    lb $t0, tokensCopy($s1)         # load tokensCopy[tc_idx] into $t0
    lb $t1, tokensCopy($s6)         # load tokensCopy[pc_idx] into $t1
    lb $t2, tokensCopy($s5)         # load tokensCopy[nc_idx] into $t2
    
    beq $t1, 32, printIncorrect     # branch to printIncorrect if tokensCopy[pc_idx] == space
    
    beq $t2, 64, checkNextToken     # if there is only one punctuation mark in the token, branch to checkNextToken
    
    seq $t9, $t0, 46                # set $t8 to 1 if tokensCopy[tc_idx] == '.'
    seq $t8, $t2, 46                # set $t7 to 1 if tokensCopy[nc_idx] == '.'
    and $t7, $t8, $t9               # if both tokensCopy[tc_idx] == '.' and tokensCopy[nc_idx] == '.'
    beq $t7, 1, checkNextPunct      # then branch to checkNextPunct
    
    j printIncorrect                # for everything else, jump to printIncorrect
 
checkNextToken:
    
    addi $s5, $s5, 1                # nc_idx++
    lb $t2, tokensCopy($s5)         # load tokensCopy[nc_idx] into $t2
    
    sgt $t6, $t2, 64                # Set $t6 to 1 if letter, else 0
    beq $t6, 1, printIncorrect      # if $t6 == 1, go to printIncorrect
    
    j printCorrect
    
checkNextPunct:
    
    addi $s5, $s5, 1                # nc_idx++
    lb $t2, tokensCopy($s5)         # load tokensCopy[nc_idx] into $t2
    
    beq $t2, 64, printIncorrect     # if there are only 2 fullstops, go to printIncorrect
    
    addi $s5, $s5, 1                # nc_idx++
    lb $t2, tokensCopy($s5)         # load tokensCopy[nc_idx] into $t2
    
    beq $t2, 64, printCorrect       # if there are 3 fullstops, go to printCorrect
    
    j printIncorrect                # jump to printIncorrect
    
checkDict:


    lb $t0, tokensCopy($s1)         # load tokensCopy[tc_idx] into $t0
    lb $t1, dictTokens($s2)         # load dictTokens[dict_idx] into $t1
    
    beqz $t1, printIncorrect
     
    sge $t7, $t0, 'A'
    sle $t6, $t0, 'Z'               # if tokens char is uppercase,
    and $t5, $t7, $t6               # go to loop case
    beq $t5, 1, loopCase           
    
    bne $t0, $t1, nextDict          # if tokensCopy[tc_idx] != dictTokens[dict_idx] go to nextDict   
    beq $t0, $t1, nextChar          # if tokensCopy[tc_idx] == dictTokens[dict_idx] go to nextChar  
    
nextDict:
    
    lb $t1, dictTokens($s2)         # load dictTokens[dict_idx] into $t1
    
    beqz $t1, printIncorrect
    
    beq $t1, 64, skipd              # if dictTokens[dict_idx] == '@' go to skipd
    
    addi $s2, $s2, 1                # dict_idx++
    
    j nextDict                      # loop back to nextDict
    
skipd:
    
    addi $s2, $s2, 1                # dict_idx++
    add $s1, $zero, $s0             # set tc_idx = tokensStart
    
    j checkDict                     # loop back to checkDict
    
nextChar:
    
    addi $s1, $s1, 1                # tc_idx++
    addi $s2, $s2, 1                # dict_idx++
    
    lb $t0, tokensCopy($s1)         # load tokensCopy[tc_idx] into $t0
    lb $t1, dictTokens($s2)         # load dictTokens[dict_idx] into $t1
    
    sge $t8, $t0, 'A'
    sle $t7, $t0, 'Z'               # if tokens char is uppercase,
    and $t6, $t7, $t8               # go to loop case
    beq $t6, 1, loopCase           
    
    seq $t5, $t0, 64                # Set $t5 = 1 if tokensCopy[tc_idx] == separator
    seq $t4, $t1, 64                # Set $t4 = 1 if dictTokens[dict_idx] == separator
    and $t3, $t4, $t5               # sets $t3 to 1 if both $t5 == 1 && $t4 == 1
    
    beq $t3, 1, printCorrect        # go to printCorrect if $t3 == 1

    bne $t0, $t1, nextDict          # if tokensCopy[tc_idx] != dictTokens[dict_idx] go to nextDict   
    
    j nextChar                      # loop back to beginning
       
loopCase:
    
    lb $t0, tokensCopy($s1)         # load tokensCopy[tc_idx] into $t0
    
    addi $t0, $t0, 32               # change tokensCopy[tc_idx] into lowercase
    
    sb $t0, tokensCopy($s1)         # store lowercase char tokensCopy[tc_idx]
    
    j checkWord                     # loop back to checkWord


# Print Output

printIncorrect:
    
    lb $t1, underscore
    
    li $v0, 11                      # print '_'
    move $a0, $t1
    syscall
    
    j printIncorrectLoop            # jump to printIncorrectLoop
    
printIncorrectLoop:
    
    lb $t0, tokens($s0)             # load tokens[tokensStart] into $t0
   
    beq $t0, 64, printIncorrectEnd  # if tokens[tokensStart] == '@', go to printPunctEnd
    
    li $v0, 11                      # print tokens[tokensStart]
    move $a0, $t0
    syscall
    
    addi $s0, $s0, 1                # tokensStart++
    
    j printIncorrectLoop            # loop back

 printIncorrectEnd:
    
    addi $s0, $s0, 1                # tokensStart+
    
    lb $t1, underscore
    
    lb $t0, tokens($s0)             # load tokensCopy[tc_idx] into $t0
    
    li $v0, 11                      # print '_'
    move $a0, $t1
    syscall
    
    beqz $t0, endChecker            # if tokensCopy[tc_idx] == null, go to endChecker
    
    add $s1, $zero, $s0             # set tc_idx = tokensStart
    
    j checkWord                     # loop back to checkWord
    
printCorrect:
    
    lb $t0, tokens($s0)             # load tokens[tokensStart] into $t0
    
    beq $t0, 64, printCorrectEnd    # if tokens[tokensStart] == '@', go to printPunctEnd
    
    li $v0, 11                      # print tokens[tokensStart]
    move $a0, $t0
    syscall
    
    addi $s0, $s0, 1                # tokensStart++
    
    j printCorrect                  # loop back

 printCorrectEnd:
    
    addi $s0, $s0, 1                # tokensStart++
 
    lb $t0, tokens($s0)             # load tokens[tokensStart] into $t0
    beqz $t0, endChecker
    
    add $s1, $zero, $s0             # set tc_idx = tokensStart
    
    j checkWord                     # loop back to checkWord
    
 endChecker:
    
    jr $ra                         
    
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
