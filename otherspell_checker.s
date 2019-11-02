#=========================================================================
# Spell checker
#=========================================================================
# Marks misspelled words in a sentence according to a dictionary
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
 
tokensIdx:              .space 2049     # Tokens index
tokensType:             .space 2049 # Token types
dictIdx:                .space 200001   # Dictionary index
dictType:               .space 200001   # Dictionary types
 
temporary:              .space 2049     # Temporary word
errors:                 .space 2049     # errors array
underscore:             .byte '_'       # Used to highlight incorrect words
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
 
READ_LOOP2:  
                                        # do {
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
 
tokenizer:
   
    li $s0, 0                         # c_idx = 0  
    li $s1, 0                         # current_idx = 0
    li $s6, 0                         # type
    li $s5, 1                         # lastType = 1
   
    jal tokenCheck
   
    #jal debug_print_token_idx
   
    j dtMain                            # Jump to dictionary tokenizer
   
tokenCheck:
   
    lb $t0, content($s0)
    beqz $t0, endCheck
   
    sgt $t6, $t0, 64                    # If letter, then set $t6 to 1. Else, 0
    beq $t6, 1, ifLetter                # If $t6 == 1, go to ifLetter
   
    beq $t0, 32, ifSpace
   
    slti $t8, $t0, 64                   # If content[c_idx] is punct then set $t7 to 1, else 0
    sgt $t7, $t0, 32
    beq $t7, $t8, ifPunct               # If $t7 == 1, then go to ifPunct
   
    j tokenCheck
   
ifLetter:

    li $s6, 1
    sb $s6, tokensType($s1)
    bne $s5, $s6, newToken
   
    sb $s1, tokensIdx($s0)
    addi $s0, $s0, 1 

    j tokenCheck
   
 
ifPunct:
   
    li $s6, 2
    sb $s6, tokensType($s1)
    bne $s5, $s6, newToken
   
    sb $s1, tokensIdx($s0)
    
    addi $s0, $s0, 1 
    
    j tokenCheck
   
ifSpace:
   
    li $s6, 3
    sb $s6, tokensType($s1)
    bne $s5, $s6, newToken
   
    sb $s1, tokensIdx($s0)
   
    addi $s0, $s0, 1 
    j tokenCheck
   
newToken:
 
    addi $s1, $s1, 1
    add $s5, $zero, $s6
   
    j tokenCheck
   
   
endCheck:
   
    jr $ra
   
dtMain:
   
    li $s0, 0                           # i = 0 (word loop)
    li $s1, 0                           # j = 0 (char loop)
    li $s6, 0        
    li $s5, 1
   
    jal dictTokenizer
   
    j scMain
   
dictTokenizer:
 
    lb $t0, dictionary($s0)
    lb $t1, newline
   
    beq $t0, '\0', endDT
   
    beq $t0, $t1, ifNL
   
    sgt $t6, $t0, 64                    # If letter, then set $t6 to 1. Else, 0
    beq $t6, 1, ifChar                  # If $t6 == 1, go to ifChar
   
    j dictTokenizer
   
ifChar:
 
    li $s6, 1  
    sb $s6, dictType($s1)
   
    bne $s5, $s6, newWord
   
    sb $s1, dictIdx($s0)
    addi $s0, $s0, 1
 
    j dictTokenizer
 
ifNL:
   
    li $s6, 4
    sb $s6, dictType($s1)
   
    bne $s5, $s6, newWord
   
    sb $s1, dictIdx($s0)
    addi $s0, $s0, 1
   
    j dictTokenizer
     
newWord:
   
    addi $s1, $s1, 1
    add $s5, $zero, $s6
   
    j dictTokenizer
   
endDT:
   
    jr $ra 
 
   
scMain:
 
    li $s0, 0                     # token = 0
   
    jal spellChecker
   
    j printTokens                  
   
spellChecker:
   
    lb $t0, tokensType($s0)
   
    beqz $t0, spellCheckerEnd
   
    li $s7, 1                     # failed = 1
   
    j resetC
 
resetC:
 
    li $s1, 0                      # c = 0
   
    j resetTemp
   
resetTemp:
   
    lb $t1, temporary($s1)
    beq $t1, '\0', copyTempIdx
   
    sb $zero, temporary($s1)
   
    addi $s1, $s1, 1
   
    j resetTemp
   
copyTempIdx:
   
    li $s6, 0                    # idx = 0
   
    j copyTemp
   
copyTemp:
   
    lb $t0, tokensType($s1)      # tokensType[c]
    lb $t1, tokensIdx($s1)
   
    beqz $t0, checkDictIdx
    beq  $t1, $s0, addIdx
   
    addi $s1, $s1, 1             # c++
   
    j copyTemp
   
addIdx:
   
    lb $t0, content($s1)         # content[c]
    sb $t0, temporary($s6)       # temporary[idx]
   
    addi $s6, $s6, 1             # idx++
    addi $s1, $s1, 1             # c++
   
   
    j copyTemp
 
checkDictIdx:
   
    li $s1, 0                    # c = 0
    li $s2, 0                    # dword = 0
   
    j checkDict
   
checkDict:
   
     lb $t0, dictIdx($s2)
     lb $t1, temporary($s1)
     lb $t2, dictionary($t0)
     
     lb $t3, dictType($s0)
   
     beqz $t3, spellCheckerEnd
     bgt $s2, 2048, nextToken
     
     bgt $s1, 20, nextDict
     
     seq $t8, $t2, '\0'
     seq $t7, $t1, '\0'
     seq $t6, $t8, $t7
     beq $t6, 1, setCorrect
     
     seq $t5, $t0, $t2
   
     addi $s1, $s1, 1               # c++
     bne $t5, 1, nextDict
     
     j spellChecker
 
nextDict:
   
    addi $s2, $s2, 1             # dword++
    li $s1, 0                    # c = 0
   
    j checkDict
   
setCorrect:
   
    li $s7, 0                    # failed = 0
    addi $s2, $s2, 1
   
    j nextToken
   
setIncorrect:
   
    addi $t0, $zero, 1
    sb $t0, errors($s0)
    addi $s2, $s2, 1
   
    j checkDict    
     
nextToken:
   
    addi $s0, $s0, 1
   
    j spellChecker
   
spellCheckerEnd:
 
    jr $ra
   
   
printTokens:
 
    li $s0, 0                      # token counter
    li $s1, 0                      # char counter
   
printLoop:
 
    # check if we need to break
    lb $t0, tokensType($s0)
    beqz $t0, printDone
   
printWord:
 
    lb $t0, tokensIdx($s1)
    lb $t2, content($s1)
   
    lb $t3, errors($s0)
   
    beq $t3, 1, incorrectPrint
   
    beqz $t2, printWordDone
   
    # check if we're actually printing the char (matches current token)
    addi $s1, $s1, 1
    beq $t0, $s0, print
   
    j printWordDone
   
incorrectPrint:
 
    li $v0, 11
    la $a0, underscore                  
    syscall
   
incorrectLoop:
   
    lb $t0, tokensIdx($s1)
    lb $t2, content($s1)
   
    bne $t0, $s0, incorrectLoopDone
 
    
    beq $t0, $s0, printIncorrect
    addi $s1, $s1, 1
    j incorrectLoop
 
printIncorrect:
    
    # print out the character
    li  $v0, 11
    move $a0, $t2
    syscall
    
    addi $s1, $s1, 1
    
    j incorrectLoop
    
incorrectLoopDone:
   
    li $v0, 11
    la $a0, underscore                  
    syscall
       
    j printWordDone
   
   
print:

    # print out the character
    li  $v0, 11
    move $a0, $t2
    syscall
 
    j printWord
   
printWordDone:
   
    addi $s0, $s0, 1
   
    j printLoop
 
printDone:
 
    j main_end
 

# debug
debug_print_token_idx:

    li  $t0, 0
    li  $v0, 11
    li  $a0, '\n'
    syscall
   
debug_print_token_idx_loop:
    lb  $t1,    tokensType($t0)
    beqz    $t1,    debug_print_token_idx_done
    beq $t0,    25, debug_print_token_idx_done
    addi    $t0,    $t0,    1
   
    li  $v0,    1
    move  $a0,  $t1
    syscall
   
    li  $v0,    11
    li  $a0,    '-'
    syscall
   
    j debug_print_token_idx_loop
   
debug_print_token_idx_done:
 
    jr $ra
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10                    # exit()
        syscall
 
#----------------------------------------------------------------
# END OF CODE
#------------------------------------------------
