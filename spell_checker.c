/***********************************************************************
* File       : <spell_checker.c>
*
* Author     : <Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/18
*
***********************************************************************/
// ==========================================================================
// Spell checker
// ==========================================================================
// Marks misspelled words in a sentence according to a dictionary

// Inf2C-CS Coursework 1. Task B/C
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2018

#include <stdio.h>

// maximum size of input file
#define MAX_INPUT_SIZE 2048
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 10000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 20

int dictionary_string_checker(char*, char*);

int read_char() { return getchar(); }
int read_int()
{
    int i;
    scanf("%i", &i);
    return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
char dictionary_file_name[] = "dictionary.txt";
// input file name
char input_file_name[] = "input.txt";
// content of input file
char content[MAX_INPUT_SIZE + 1];
// valid punctuation marks
char punctuations[] = ",.!?";
// tokens of input file
char tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];
// number of tokens in input file
int tokens_number = 0;

int dictionary_tokens_number = 0;
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1];

char dictionary_tokens[MAX_DICTIONARY_WORDS][MAX_WORD_SIZE + 1];

char spell_tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////


// Task B

void spell_checker() {

  //index of current token
  int i = 0;
  do{
    //if space token do nothing
    if (tokens[i][0] == ' ') {
    //if punctuation token do nothing
    }else if(tokens[i][0] == ',' || tokens[i][0] == '.' || tokens[i][0] == '!' || tokens[i][0] == '?'){
    //other wise must be a alpha token
    }else {
      //index of token character
      int token_char_idx =0;
      do {
        //if null character set spell token to null and
        //break out of the loop
        if(tokens[i][token_char_idx] == '\0'){
          spell_tokens[i][token_char_idx] = '\0';
          break;
        }
        //if uppercase character set spell token to
        //character +32, this makes all spell tokens
        //lowercase
        if (tokens[i][token_char_idx] < 91){
          spell_tokens[i][token_char_idx] = tokens[i][token_char_idx] + 32;
        //else must be lowercase character, set spell token
        //to character
        }else{
          spell_tokens[i][token_char_idx] = tokens[i][token_char_idx];
        }
        //increase index of token character
        token_char_idx +=1;
      }while(1);

      //initilze spelled_Correct_bool which is used as a boolean
      int spelled_Correct_bool = 0;
      //index of current dictionary token
      int k =0;

      //calls my fuction which checks if too string are the same
      //passes the parameters, current dictionary token and
      //the indexed spell token, this compares the current spell
      //token (which is lowercase) with all word in the dictionary
      //
      //if the current spell token is in the dictionary, spelled_Correct_bool
      //is set to 1 and break out of loop, otherwise loop until checked all
      //of dictionary
      do{
          if (dictionary_string_checker(dictionary_tokens[k], spell_tokens[i])==1){
            spelled_Correct_bool = 1;
            break;
          }
          k=k+1;
      }while(k<dictionary_tokens_number);

      //this adds underscores if the current token is not in the
      //dictionary
      if (spelled_Correct_bool ==0){
        char letter = tokens[i][0];
        int j = 0;
        tokens[i][j] = '_';
        //after setting the first character of the token to an
        //underscore, sets sets the second character of the
        //token to the original first and continues until reaches
        //end of the token, where null is replaced with an
        //underscore and a new null is added on the end.
        do{
          if(letter == '\0'){
            tokens[i][j+1] = '_';
            tokens[i][j+2] = '\0';
            break;
          }else{
            j=j+1;
            char temp = tokens[i][j];
            tokens[i][j] = letter;
            letter = temp;
          }
        }while(1);
      }else{
      }
    }
    //increase index of current token index
    i = i+1;
  //loop until have spell checked all tokens
  }while(i<tokens_number);
  return;

}
//this is my function
//it takes two strings and returns 1 if they're the
//same and 0 if they're different.
//this fucntion loops while character of the string are
//the same, and breaks when a character is null, it
//returns 1 is both characters are null
int dictionary_string_checker(char *a, char *b) {
   while (*a == *b) {
      if (*a == '\0' || *b == '\0')
         break;
      a++;
      b++;
   }
   if (*a == '\0' && *b == '\0')
      return 1;
   else
      return 0;
}


//the is the output fucntion
//it loops through the tokens and prints them output
//finishes with a newline
void output_tokens() {
  int i;
  for (i = 0; i < tokens_number; ++i) {
    output(tokens[i]);
  }
  output("\n");
  return;
}

//this is the dictionary tokenizer, it reads the dictionary
//and puts each word in a token
void dictionary_tokenizer(){
  char d;
  // index of dictionary
  int d_idx = 0;
  //d is first character in the dictionary
  d = dictionary[d_idx];
  do {
    // end of dictionary
    if(d == '\0'){
      break;
    }
    //if the token starts with an alphabetic character
    //this is very similar to the content tokenizer
    if(d >= 'a' && d <= 'z') {
      int token_d_idx = 0;
      // tokenize  untill see any non-alphabetic character
      do {
        dictionary_tokens[dictionary_tokens_number][token_d_idx] = d;

        token_d_idx += 1;
        d_idx += 1;
        d = dictionary[d_idx];
      } while(d >= 'a' && d <= 'z');
      //adds a null to the end of the dictionary token, this is usful
      //when comparing strings in my function
      //increase the dictionary token number, this is user in my
      //spell check.
      dictionary_tokens[dictionary_tokens_number][token_d_idx] = '\0';
      dictionary_tokens_number += 1;

    // if the token is not alpha or null it must be a newline as
    //per the assupmtions so, skip over this character and continute
    //tokenizing the dictionary
    }else{
      d_idx += 1;

      d = dictionary[d_idx];
    }
  } while(1);
}


//---------------------------------------------------------------------------
// Tokenizer function
// Split content into tokens
//---------------------------------------------------------------------------

void tokenizer(){
  char c;

  // index of content
  int c_idx = 0;
  c = content[c_idx];
  do {

    // end of content
    if(c == '\0'){
      break;
    }

    // if the token starts with an alphabetic character
    if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {

      int token_c_idx = 0;
      // copy till see any non-alphabetic character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with one of punctuation marks
    } else if(c == ',' || c == '.' || c == '!' || c == '?') {

      int token_c_idx = 0;
      // copy till see any non-punctuation mark character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ',' || c == '.' || c == '!' || c == '?');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with space
    } else if(c == ' ') {

      int token_c_idx = 0;
      // copy till see any non-space character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ' ');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;
    }
  } while(1);
}
//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{


  /////////////Reading dictionary and input files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;

  // open input file
  FILE *input_file = fopen(input_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the input file failed
  if(input_file == NULL){
    print_string("Error in opening input file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }

  // reading the input file
  do {
    c_input = fgetc(input_file);
    // indicates the the of file
    if(feof(input_file)) {
      content[idx] = '\0';
      break;
    }

    content[idx] = c_input;

    if(c_input == '\n'){
      content[idx] = '\0';
    }

    idx += 1;

  } while (1);

  // closing the input file
  fclose(input_file);

  idx = 0;

  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }

    dictionary[idx] = c_input;
    idx += 1;
  } while (1);

  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ////////////////////////////////////////////////////////////////

  tokenizer();

  dictionary_tokenizer();

  spell_checker();

  output_tokens();

  return 0;
}
