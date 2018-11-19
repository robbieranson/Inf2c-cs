
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
spell_tokens:           .space 411849

tokens:                 .space 411849    #2D array for tokens
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
dictionary_tokens:      .space 441849                
# You can add your data here!

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


tokenizer:
        move   $s1,$0        
        #set s1 to 0 c_idx
        move   $s4,$0        
        #set s4 to 0 token_number
        la   $s0, content    
        #load address of content to s0
        lb   $s3, 0($s0)    
        #s3 = first element at $s0
        #c = content[c_idx];
        j    tokenizer2
        #jump to tokenizer
        #do{

tokenizer2:
        move   $s7,$0        
        #s1 = token_c_idx = 0
        bge    $s3, 65, alpha_char 
        #branch if s3 greater than or equal to 65
        #if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {
        beq    $s3, 33, punct_char
        #branch if s3 equal to 33
        beq    $s3, 46, punct_char  
        #branch if s3 equal to 45
        beq    $s3, 63, punct_char  
        #branch if s3 equal to 63
        beq    $s3, 44, punct_char  
        #branch if s3 equal to 44 
        #else if(c == ',' || c == '.' || c == '!' || c == '?') {
        beq    $s3, 32, space_char
        #branch if s3 equal to 32
        #else if(c == ' ') {              
        beqz   $s3, dict_tokenizer 
        #branch if s3 equal 0
        #if(c == '\0'){
        #break;
alpha_char:            
	#do{
        la   $s5, tokens
        #load address of tokens to s5    
        li   $t3,201        
        #load t3 with 201
        mult $t3,$s4        
        #multiply t3 and s4
        #token_number * offset
        mflo $t7        
        #load t7 with lower 32 bits of mult
        add  $t4,$t7,$s7    
        #token_number * offset + token_c_idx
        add  $t1, $s5, $t4    
        #tokens[#token_number * offset + token_c_idx] address
        sb   $s3,0($t1)
        #store byte s3 in t1 with an offset of 0
        #tokens[tokens_number][token_c_idx] = c;
        addi $s7, $s7, 1    
        #token_c_idx += 1;                
        addi $s1, $s1, 1    
        #c_idx + 1
        add  $t1, $s1,$s0    
        #content address + c_idx
        lb  $s3, 0($t1)
        #load byte in s3 of t1 with an offset of 0
        #c = content[c_idx];
        bge  $s3,65, alpha_char
        #branch if s3 greater than or equal to 65
        #while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');              
        li   $t3,201
        #load t3 with 201
        mult $t3,$s4
        #multiply t3 and s4
        #token_number * offset
        mflo $t7        
        #load t7 with lower 32 bits of mult    
        add  $t4,$t7,$s7    
        #token_number * offset + token_c_idx
        add  $t1,$s5,$t4
        #tokens[#token_number * offset + token_c_idx] address
        sb   $0, 0($t1)    
        #store byte 0 in t1 with an offset of 0
        #tokens[tokens_number][token_c_idx] = '\0';
        addi $s4, $s4, 1
        #tokens_number += 1;
        j tokenizer2
        #loop back to tokenizer2
space_char:
        #do{
        la   $s5, tokens
        #load address of tokens to s5    
        li   $t3,201
        #load t3 with 201
        mult $t3,$s4        
        #multiply t3 and s4
        #token_number * offset
        mflo $t7        
        #load t7 with lower 32 bits of mult
        add  $t4,$t7,$s7    
        #token_number * offset + token_c_idx
        add  $t1, $s5, $t4    
        #tokens[#token_number * offset + token_c_idx] address
        sb   $s3,0($t1)
        #store byte s3 in t1 with an offset of 0
        #tokens[tokens_number][token_c_idx] = c;
  	addi $s7, $s7, 1    
        #token_c_idx += 1;                
        addi $s1, $s1, 1    
        #c_idx + 1
        add  $t1, $s1,$s0    
        #content address + c_idx
        lb  $s3, 0($t1)
        #load byte in s3 of t1 with an offset of 0
        #c = content[c_idx];
        beq  $s3,32, space_char 
        #branch if s3 equal to 32
        #while(c == ' '); 
        li   $t3,201 
        #load t3 with 201
        mult $t3,$s4
        #multiply t3 and s4
        #token_number * offset
        mflo $t7        
        #load t7 with lower 32 bits of mult    
        add  $t4,$t7,$s7    
        #token_number * offset + token_c_idx
        add  $t1,$s5,$t4
        #tokens[#token_number * offset + token_c_idx] address
        sb   $0, 0($t1)    
        #store byte 0 in t1 with an offset of 0
        #tokens[tokens_number][token_c_idx] = '\0';
        addi $s4, $s4, 1
        #tokens_number += 1;
        j tokenizer2
        #loop back to tokenizer2
punct_char:      
        #do{
        la   $s5, tokens
        #load address of tokens to s5    
        li   $t3,201       
        #load t3 with 201
        mult $t3,$s4        
        #multiply t3 and s4
        #token_number * offset
        mflo $t7        
        #load t7 with lower 32 bits of mult
        add  $t4,$t7,$s7    
        #token_number * offset + token_c_idx
        add  $t1, $s5, $t4    
        #tokens[#token_number * offset + token_c_idx] address
        sb   $s3,0($t1)
        #store byte s3 in t1 with an offset of 0
        #tokens[tokens_number][token_c_idx] = c;
        addi $s7, $s7, 1    
        #token_c_idx += 1;                
        addi $s1, $s1, 1    
        #c_idx + 1
        add  $t1, $s1,$s0    
        #content address + c_idx
        lb  $s3, 0($t1)
        #load byte in s3 of t1 with an offset of 0
        #c = content[c_idx];
        beq    $s3,33,punct_char 
        beq    $s3,46,punct_char  
        beq    $s3,63,punct_char  
        beq    $s3,44,punct_char
        #branch if s3 equal to 33 or 46 or 63 or 44
        #while(c == ',' || c == '.' || c == '!' || c == '?');
        li   $t3,201
        #load t3 with 201
        mult $t3,$s4
        #multiply t3 and s4
        #token_number * offset
        mflo $t7        
        #load t7 with lower 32 bits of mult    
        add  $t4,$t7,$s7    
        #token_number * offset + token_c_idx
        add  $t1,$s5,$t4
        #tokens[#token_number * offset + token_c_idx] address
        sb   $0, 0($t1)    
        #store byte 0 in t1 with an offset of 0
        #tokens[tokens_number][token_c_idx] = '\0';
        addi $s4, $s4, 1
        #tokens_number += 1;
        j tokenizer2
        #loop back to tokenizer2
    

end_tokenizer:
	#output_tokens() {
        move $s6,$0
        #int i =0;
        j print
        #jump to print

print:
        beq  $s6,$s4,main_end    
        #branch if s6 and s4 and equal
        #for (i = 0; i < tokens_number; ++i) {
        la   $s5, tokens  
        #load address of tokens to s5
        li   $t3, 201   
        #load t3 with 201   
        mult $t3,$s6 
        #multiply t3 and s6
        #i * offset      
        mflo $t4        
        #load t4 with lower 32 bits of mult    
        add  $t6,$t4,$s5        #a0 = (201 * loop_index) + tolken_address
        #tokens[i * offset] address
        la   $a0, 0($t6)
        #load address of t6 with offset 0 into a0
        li   $v0, 4        
        #load v0 with 4
        #system call for printing string
        syscall 
        #output(tokens[i]);           
        #system call on v0
        addi $s6, $s6, 1
        # ++i
        j print            
        #loop back
        
#DICTIONARY TOKENIZER

dict_tokenizer:
        move   $s6,$0
        #dictionary_token_number = 0;
        move   $s1,$0
        #int d_idx = 0;
        la  $s0, dictionary
        lb  $s3,0($s0)
        #d = dictionary[d_idx];
        j dict_tokenizer_main_loop
        #jump to dict_tokenizer_main_loop
    
dict_tokenizer_main_loop:
        #do{
        beqz $s3,dict_tokenizer_end
        #if (d == '\0') {break;}
        bge  $s3,65,dict_tokenizer_sub_call
        #  if(d >= 'a' && d <= 'z')
        addi $s1,$s1,1
        #else d_idx += 1;
        add $t1,$s1,$s0
        lb  $s3,0($t1)
        #d = dictionary[d_idx];
        j dict_tokenizer_main_loop
        #loop back to dict_tokenizer_main_loop
        
dict_tokenizer_sub_call:
        move $s5,$0
        #int token_d_idx = 0;
        j dict_tokenizer_sub_call_loop
        #do {

dict_tokenizer_sub_call_loop:
        la  $t1, dictionary_tokens
        move $t7,$0
        addi $t7,$t7,20
        mult $s6,$t7
        mflo $t7
        add $t4,$t7,$s5
        add $t2,$t4,$t1
        sb $s3,0($t2)
        #dictionary_tokens[dictionary_tokens_number][token_d_idx] = d;
        addi $s5,$s5,1
        #token_d_idx += 1;
        addi $s1,$s1,1
        #d_idx += 1;
        add $t2,$s0,$s1
        lb $s3,0($t2)
        #d = dictionary[d_idx];
        bge $s3,65,dict_tokenizer_sub_call_loop
        #while(d >= 'a' && d <= 'z');
        j dict_tokenizer_sub_call_loop_end
        #jump to dict_tokenizer_sub_call_loop_end
    
dict_tokenizer_sub_call_loop_end:
        la  $t1, dictionary_tokens
        move $t7,$0
        addi $t7,$t7,20
        mult $s6,$t7
        mflo $t7
        add $t4,$t7,$s5
        add $t2,$t4,$t1
        sb  $0,0($t2)
        #dictionary_tokens[dictionary_tokens_number][token_d_idx] = '\0';
        addi $s6,$s6,1
        #dictionary_tokens_number += 1;
        j dict_tokenizer_main_loop
        #loop back
         
        
            
dict_tokenizer_end:
	#end of dictionary tokenizer
        j spell_checker
        #jump to spell_checker
            

        #my function to check if stings are the same
dict_str_checker:
        lb $t1,($s0)
        lb $t2,($s5)
        #load bytes from parameters
        #s0 and s1 are string and, t1 and t2 are chars
        bne $t1,$t2,diffrnt
        #branch if t1 and t2 are not equal    
        beq $t1,$0,same
        #branch if t1 equal 0
        addi $s0,$s0,1
        addi $s5,$s5,1
        #move to nexr char
        j dict_str_checker
        #loop back
diffrnt:
        move $s5,$0
        jr $ra   
        #return 0;
same:   
        move $s5,$0
        addi $s5,$s5,1
        jr $ra
        #return 1;


spell_checker:
        move $s1,$0
        #int i = 0;
        j spell_checker_main_loop
        #do{

spell_checker_main_loop:
        la $t1, tokens
        move $t3,$0
        addi $t3,$t3,201
        mult $s1,$t3
        mflo $t3
        add $t3,$t3,$t1
        lb $t7,0($t3)
        #tokens[i][0]
        beq $t7,32,spell_checker_main_loop_sub_call_1
        beq $t7,33,spell_checker_main_loop_sub_call_1
        beq $t7,44,spell_checker_main_loop_sub_call_1
        beq $t7,46,spell_checker_main_loop_sub_call_1
        beq $t7,63,spell_checker_main_loop_sub_call_1
        #if (tokens[i][0] == ' ' || '?' || ',' || '!' || '.') skip
        move $s2,$0
        #int token_char_idx =0;
        j spell_checker_sub_loop
        #do{
    
spell_checker_sub_loop:
        beq $s1,$s4,punct_checker
        la  $t1, tokens
        move $t3,$0
        addi $t3,$t3,201
        mult $s1,$t3
        mflo $t7
        #tokens[i][0]
        add $t6,$t7,$s2
        #tokens[i][token_char_idx]
        add $t6,$t6,$t1
        lb $t7,0($t6)
        beqz $t7, spell_checker_sub_loop_sub_call_1    
        #if(tokens[i][token_char_idx] == '\0'){
        blt $t7,91,spell_checker_sub_loop_sub_call_2
        j spell_checker_sub_loop_sub_call_3
    
spell_checker_sub_loop_sub_call_3:
        la $t1,spell_tokens
        move $t2,$0
        addi $t2,$t2,201
        mult $s1,$t2
        mflo $t2
        add $t6,$t2,$s2
        #spell_tokens[i][token_char_idx]
        add $t4,$t6,$t1
        sb $t7,0($t4)
        #spell_tokens[i][token_char_idx] = tokens[i][token_char_idx]
        j spell_checker_sub_loop_callback
    
spell_checker_sub_loop_sub_call_2:
        #if (tokens[i][token_char_idx] < 91){
        addi $t8,$t7,32
        #tokens[i][token_char_idx] + 32;
        la $t1,spell_tokens
        move $t7,$0
        addi $t7,$t7,201
        mult $s1,$t7
        mflo $t7
        add $t6,$t7,$s2
        #spell_tokens[i][token_char_idx]
        add $t4,$t6,$t1
        sb $t8,0($t4)
        #spell_tokens[i][token_char_idx] = tokens[i][token_char_idx] + 32;
        j spell_checker_sub_loop_callback
    
spell_checker_sub_loop_callback:
        addi $s2,$s2,1
        #token_char_idx +=1;
        j spell_checker_sub_loop
        #loop back
    
spell_checker_sub_loop_sub_call_1:
        #if(tokens[i][token_char_idx] == '\0'){
        la   $t1,spell_tokens
        move $t7,$0
        addi $t7,$t7,201
        mult $s1,$t7
        mflo $t7
        add $t6,$t7,$s2
        #spell_tokens[i][token_char_idx]
        add $t4,$t6,$t1
        sb $0,0($t4)
        #spell_tokens[i][token_char_idx] = '\0';
        j spell_checker_main_loop_cont
        #break;
    
    
spell_checker_main_loop_cont:
        move $s7,$0
        #int spelled_Correct_bool = 0;
        move $s3,$0
        #int k =0;
        j spell_checker_sub_loop_2

spell_checker_sub_loop_2:
        la $t4, dictionary_tokens
        move $t2,$0
        addi $t2,$t2,20
        mult $s3,$t2
        mflo $t2
        add $s0,$t2,$t4
        #dictionary_tokens[k]
        la $t4, spell_tokens
        move $t2,$0
        addi $t2,$t2,201
        mult $s1,$t2
        mflo $t2
        add $s5,$t2,$t4
        #spell_tokens[i])
        jal dict_str_checker        
        beq $s5,1,spell_checker_sub_loop_2_sub_call_1
        #if (dictionary_string_checker(dictionary_tokens[k], spell_tokens[i])==1)
        #break;
        addi $s3,$s3,1
        #k=k+1;
        beq $s3,$s6,spell_checker_main_loop_cont_2
        j spell_checker_sub_loop_2
        #while(k<dictionary_tokens_number);
    
    
spell_checker_sub_loop_2_sub_call_1:
        addi $s7,$s7,1
        #spelled_Correct_bool = 1;
        j spell_checker_main_loop_cont_2
        #jump to spell_checker_main_loop_cont_2
    
spell_checker_main_loop_cont_2:
        beqz $s7, spell_checker_main_loop_sub_call_2
        #branch if s7 =0
        #if (spelled_Correct_bool ==0){
        j spell_checker_main_loop_sub_call_1
        #else{
    
spell_checker_main_loop_sub_call_2:
        #if (spelled_Correct_bool ==0){
        la $t1, tokens
        move $t7,$0
        addi $t7,$t7,201
        mult $s1,$t7
        mflo $t7
        #tokens[i][0]
        add $t6,$t7,$t1
        lb $t8,0($t6)
        #char letter = tokens[i][0];
        move $s0,$0
        #int j = 0;
        la $t1,tokens
        move $t7,$0
        addi $t7,$t7,201
        mult $s1,$t7
        mflo $t7
        add $t4,$t7,$t1
        #tokens[i][0]
        li $t2,95
        sb $t2,0($t4)
        #tokens[i][j] = '_';
        j spell_checker_main_loop_sub_call_2_sub_loop

spell_checker_main_loop_sub_call_2_sub_loop:
   
        beqz $t8,spell_checker_main_loop_sub_call_2_sub_loop_sub_call_1
        #branch if t8 = 0
        #if(letter == '\0'){
        addi $s0,$s0,1
        #j=j+1;  
        la $t1,tokens
        #t1 = address of tokens
        move $t7,$0
        addi $t7,$t7,201
        mult $s1,$t7
        mflo $t7
        #t7 = i
        add $t4,$t7,$s0
        add $t4,$t4,$t1
        #t4 = address of tokens[i][j]
        #tokens[i][j];
        lb $t1,0($t4) 
        #t1 = char at tokens[i][j]
        #char temp = tokens[i][j];
        sb $t8,0($t4)
        #tokens[i][j] = letter;
        move $t8,$t1
        j spell_checker_main_loop_sub_call_2_sub_loop
        #loop back


spell_checker_main_loop_sub_call_2_sub_loop_sub_call_1:
    
        la  $t1,tokens
        #t1 = address of tokens
        move $t7,$0
        addi $t7,$t7,201
        mult $s1,$t7
        mflo $t7
        #t7 = i
        add $t4,$t7,$s0
        add $t4,$t4,$t1
        #address of tokens[i][i]
        addi $t6,$t4,1
        #tokens[i][j+1]
        li $t2,95
        sb $t2,0($t6)
        #tokens[i][j+1] = '_';
        addi $t6,$t4,2
        #tokens[i][j+2]
        sb $0,0($t6)
        #tokens[i][j+2] = '\0';
        j spell_checker_main_loop_sub_call_1
    

spell_checker_main_loop_sub_call_1:
        addi $s1,$s1,1
        j spell_checker_main_loop
   
punct_checker:
       move $s1,$0
       #int i = 0;
       j punct_checker_main_loop
       #do{
    
punct_checker_main_loop:
       beq  $s1,$s4,end_tokenizer
       #branch if s1 and s4 are equal
       #while(i<tokens_number);
       move $s7,$0
       #int punct_correct_bool = 0;
       la $t1, tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $s1,$t7
       mflo $t7
       add $t4,$t7,$t1
       lb $t1,0($t4)
       #tokens[i][0]
       beq $t1,33,punct_checker_sub_call_1
       beq $t1,44,punct_checker_sub_call_1
       beq $t1,63,punct_checker_sub_call_1
       #if(tokens[i][0] == ',' ||tokens[i][0] == '!' || tokens[i][0] == '?'){
       beq $t1,46,punct_checker_sub_call_2
       #else if(tokens[i][0] == '.'){
       j punct_checker_main_loop_call_back
       #if token[i][0] not punctuation we can skip this token
       #else{
    
punct_checker_sub_call_1:
       #this sub call checks if the punctuation is correct
       #for punctuation tokens that start with ',' '?' '!'
       la $t1, tokens
       move $t7,$0
       addi $t7,$t7,201
       addi $t2,$s1,1
       #[i+1]
       mult $t2,$t7
       mflo $t7
       add $t4,$t7,$t1
       lb $t1,0($t4)
       #tokens[i+1][0]
       bgt $t1,96,punct_checker_sub_call_1.1
       bgt $t1,64,punct_checker_sub_call_1.2
       #if ((tokens[i+1][0]>64&&tokens[i+1][0]<91)||(tokens[i+1][0]>96&&tokens[i+1][0]<123)){
       #   punct_correct_bool = 0;
       j punct_checker_sub_call_1_cont
       #else{
	    
punct_checker_sub_call_1.2:
       #checks if token after is alpha
       blt $t1,91,punct_checker_punct_incorrect
       #if token after is alpha the mark punctuation as incorrect
       j punct_checker_sub_call_1_cont
       #else if (tokens[i-1][0]==' '){
    
punct_checker_sub_call_1.1:
       #checks if token after is alpha
       blt $t1,123,punct_checker_punct_incorrect
       #if token after is alpha the mark punctuation as incorrect
       j punct_checker_sub_call_1_cont
       #else if (tokens[i-1][0]==' '){

punct_checker_sub_call_1_cont:
       #checks if token before is space
       la $t1, tokens
       move $t7,$0
       addi $t7,$t7,201
       addi $t2,$s1,-1
       #[i-1]
       mult $t2,$t7
       mflo $t7
       add $t4,$t7,$t1
       lb $t1,0($t4)
       #tokens[i-1][0]
       beq $t1,32,punct_checker_punct_incorrect
       #else if (tokens[i-1][0]==' '){
       #  punct_correct_bool = 0;
       la $t1, tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $s1,$t7
       mflo $t7
       #[i]
       addi $t7,$t7,1
       #[i][1]
       add $t4,$t7,$t1
       lbu $t1,0($t4)
       #tokens[i][1]
       beq $t1,33,punct_checker_punct_incorrect
       beq $t1,44,punct_checker_punct_incorrect
       beq $t1,46,punct_checker_punct_incorrect
       beq $t1,63,punct_checker_punct_incorrect
       #else if (tokens[i][1]=='.'||tokens[i][1]==','||tokens[i][1]=='!'||tokens[i][1]=='?'){
       #  punct_correct_bool = 0;
       j punct_checker_main_loop_call_back
       #j to main_loop_call_back if punctuation is correct
       #if (punct_correct_bool ==1){

punct_checker_punct_incorrect:
       #this add underscores around punctuation tokens
       #that have been marked as incorrect
       #else{
       la $s5, tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $s1,$t7
       mflo $t7
       add $t6,$t7,$s5
       lb $t8,0($t6)
       #char punct = tokens[i][0];
       move $s5,$0
       #int j = 0;
       li $t2,95
       sb $t2,0($t6)
       #tokens[i][j] = '_';
       j punct_checker_token_changer_loop
       #do{


punct_checker_token_changer_loop:
       #loop for adding underscore for incorrect puntuation
       beqz $t8,punct_checker_token_changer_loop_end
       #break loop if char punct = null
       #if(punct == '\0'){
       addi $s5,$s5,1
       #j=j+1;
       la $t1,tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $s1,$t7
       mflo $t7
       add $t4,$t7,$s5
       add $t4,$t4,$t1
       lb $t1,0($t4) 
       #char temp = tokens[i][j];
       sb $t8,0($t4)
       #tokens[i][j] = punct;
       move $t8,$t1
       #punct = temp;
       j punct_checker_token_changer_loop
       #loop back


punct_checker_token_changer_loop_end:
       #finishes underscorring incorrect punctuation 
       #if(punct == '\0'){
       la  $t1,tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $s1,$t7
       mflo $t7
       add $t4,$t7,$s5
       add $t4,$t4,$t1
       addi $t6,$t4,1
       #tokens[i][j+1]
       li $t2,95
       sb $t2,0($t6)
       #tokens[i][j+1] = '_';
       addi $t6,$t4,2
       #tokens[i][j+2]
       sb $0,0($t6)
       #tokens[i][j+2] = '\0';
       j punct_checker_main_loop_call_back
       #break;
    

punct_checker_sub_call_2:
       #this sub call is for checking the punctuation for tokens
       #that start with a '.'
       #else if(tokens[i][0] == '.'){
       la $t1, tokens
       move $t7,$0
       addi $t7,$t7,201
       addi $t2,$s1,1
       #[i+1]
       mult $t2,$t7
       mflo $t7
       add $t4,$t7,$t1
       lb $t1,0($t4)
       #tokens[i+1][0]
       bgt $t1,96,punct_checker_sub_call_2.1
       bgt $t1,64,punct_checker_sub_call_2.2
       #if ((tokens[i+1][0]>64&&tokens[i+1][0]<91)||(tokens[i+1][0]>96&&tokens[i+1][0]<123)){
       #   punct_correct_bool = 0;    
       j punct_checker_sub_call_2_cont
       #else{
punct_checker_sub_call_2.2:
       blt $t1,91,punct_checker_punct_incorrect2
       #if token[i+1][0] is alpha mark punctuation token as incorrect
       j punct_checker_sub_call_2_cont
       #else if (tokens[i-1][0]==' '){
    
punct_checker_sub_call_2.1:
       blt $t1,123,punct_checker_punct_incorrect2
       #if token[i+1][0] is alpha mark punctuation token as incorrect
       j punct_checker_sub_call_2_cont
       #else if (tokens[i-1][0]==' '){    

punct_checker_sub_call_2_cont:
       la $t1, tokens
       move $t7,$0
       addi $t7,$t7,201
       addi $t2,$s1,-1
       #[i-1]
       mult $t2,$t7
       mflo $t7
       add $t4,$t7,$t1
       lb $t1,0($t4)
       #tokens[i-1][0]
       beq $t1,32,punct_checker_punct_incorrect2
       #else if (tokens[i-1][0]==' '){
       #  punct_correct_bool = 0;
       la $t1,tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $t7,$s1
       mflo $t7
       addi $t7,$t7,1
       add $t4,$t7,$t1
       lb $t1,0($t4)
       #tokens[i][1]
       la $t2,tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $t7,$s1
       mflo $t7
       addi $t7,$t7,2
       add $t4,$t7,$t2
       lb $t2,0($t4)
       #tokens[i][2]    
       bne $t1,46,punct_checker_sub_call_2_cont_1
       bne $t2,46,punct_checker_sub_call_2_cont_1
       #else if(tokens[i][1] == '.'&&tokens[i][2] == '.'){
       #now we know the first 3 characters of this token are '.'
       #so we check if this token has anymore characters
       la $t1,tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $t7,$s1
       mflo $t7
       addi $t7,$t7,3
       add $t4,$t7,$t1
       lb $t1,0($t4)
       #tokens[i][3]
       beq $t1,33,punct_checker_punct_incorrect2
       beq $t1,44,punct_checker_punct_incorrect2
       beq $t1,46,punct_checker_punct_incorrect2
       beq $t1,63,punct_checker_punct_incorrect2
       #if (tokens[i][3] == '.'||tokens[i][3]==','||tokens[i][3]=='!'||tokens[i][3]=='?'){
       #   punct_correct_bool = 0;
       j punct_checker_main_loop_call_back
       #else{
       #   punct_correct_bool =1;
            
punct_checker_sub_call_2_cont_1:
       #if after one '.' there are any characters this
       #punctuation character is incorrect
       la $t1,tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $t7,$s1
       mflo $t7
       addi $t7,$t7,1
       add $t4,$t7,$t1
       lb $t1,0($t4)
       #tokens[i][1]
       beq $t1,33,punct_checker_punct_incorrect2
       beq $t1,44,punct_checker_punct_incorrect2
       beq $t1,46,punct_checker_punct_incorrect2
       beq $t1,63,punct_checker_punct_incorrect2
       #else if (tokens[i][1] == '.'||tokens[i][1]==','||tokens[i][1]=='!'||tokens[i][1]=='?'){
       #   punct_correct_bool = 0;
       j punct_checker_main_loop_call_back
       #else{
       #  punct_correct_bool = 1;

punct_checker_punct_incorrect2:
       #this add underscores around punctuation tokens
       #that have been marked as incorrect
       #else{
       la $s5, tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $s1,$t7
       mflo $t7
       add $t6,$t7,$s5
       lb $t8,0($t6)
       #char punct = tokens[i][0];
       move $s5,$0
       #int j = 0;
       li $t2,95
       sb $t2,0($t6)
       #tokens[i][j] = '_';
       j punct_checker_token_changer_loop2
       #do{


punct_checker_token_changer_loop2:
       #loop for adding underscore for incorrect puntuation
       beqz $t8,punct_checker_token_changer_loop_end2
       #break loop if char punct = null
       #if(punct == '\0'){
       addi $s5,$s5,1
       #j=j+1;
       la $t1,tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $s1,$t7
       mflo $t7
       add $t4,$t7,$s5
       add $t4,$t4,$t1
       lb $t1,0($t4) 
       #char temp = tokens[i][j];
       sb $t8,0($t4)
       #tokens[i][j] = punct;
       move $t8,$t1
       #punct = temp;
       j punct_checker_token_changer_loop2
       #loop back


punct_checker_token_changer_loop_end2:
       #finishes underscorring incorrect punctuation 
       #if(punct == '\0'){
       la  $t1,tokens
       move $t7,$0
       addi $t7,$t7,201
       mult $s1,$t7
       mflo $t7
       add $t4,$t7,$s5
       add $t4,$t4,$t1
       addi $t6,$t4,1
       #tokens[i][j+1]
       li $t2,95
       sb $t2,0($t6)
       #tokens[i][j+1] = '_';
       addi $t6,$t4,2
       #tokens[i][j+2]
       sb $0,0($t6)
       #tokens[i][j+2] = '\0';
       j punct_checker_main_loop_call_back
       #break;    

punct_checker_main_loop_call_back:
       addi $s1,$s1,1
       #i = i+1;
       j punct_checker_main_loop
       #loop back
  
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
