
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
tokens:                 .space 411849    #2D array for tokens, due to mips limitations this is not (2049*2049)


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
        sb   $0,  content($t0)

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)
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
        beqz   $s3, end_tokenizer 
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
        li   $t3,201        #t3 201
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
        li   $v0, 4
        #load v0 with 4
        #system call for printing string
        la   $a0, newline           
        #load address of newline to a0
        syscall
        #system call on v0
        #output("\n");
        addi $s6, $s6, 1
        # ++i
        j print            
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
