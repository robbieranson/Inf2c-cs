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

///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////

// You can define your global variables here!

char spell_tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];

// Task B

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

void punctuation_checker(){
  int i =0;
  do{
    int punct_correct_bool = 0;
    if(tokens[i][0] == ',' ||tokens[i][0] == '!' || tokens[i][0] == '?'){

        if ((tokens[i+1][0]>64&&tokens[i+1][0]<91)||(tokens[i+1][0]>96&&tokens[i+1][0]<123)){
          punct_correct_bool = 0;
        }else if (tokens[i-1][0]==' '){
          punct_correct_bool = 0;
        }else if (tokens[i][1]=='.'||tokens[i][1]==','||tokens[i][1]=='!'||tokens[i][1]=='?'){
          punct_correct_bool = 0;
        }else{
          punct_correct_bool = 1;
        }
      if (punct_correct_bool ==1){

      }else{
        //wrong punct
        char punct = tokens[i][0];
        int j = 0;
        tokens[i][j] = '_';

        do{
          //print_char(letter);
          if(punct == '\0'){
            tokens[i][j+1] = '_';
            tokens[i][j+2] = '\0';
            break;
          }else{
            j=j+1;
            char temp = tokens[i][j];
            tokens[i][j] = punct;
            punct = temp;

          }
        }while(1);
      }
    }else if(tokens[i][0] == '.'){
      //if char after . then incorrect
      if ((tokens[i+1][0]>64&&tokens[i+1][0]<91)||(tokens[i+1][0]>96&&tokens[i+1][0]<123)){
        punct_correct_bool = 0;
      // if space before . then incorrect
      }else if (tokens[i-1][0]==' '){
        punct_correct_bool = 0;
      // if !?, after . then incorrect
      }else if(tokens[i][1] == '.'&&tokens[i][2] == '.'){
        if (tokens[i][3] == '.'||tokens[i][3]==','||tokens[i][3]=='!'||tokens[i][3]=='?'){
          punct_correct_bool = 0;
        }else{
          punct_correct_bool =1;
        }
      }else if (tokens[i][1] == '.'||tokens[i][1]==','||tokens[i][1]=='!'||tokens[i][1]=='?'){
        punct_correct_bool = 0;
      }else{
        punct_correct_bool = 1;
      }

      if (punct_correct_bool ==1){

      }else{
        //wrong punct
        char punct = tokens[i][0];
        int j = 0;
        tokens[i][j] = '_';

        do{
          //print_char(letter);
          if(punct == '\0'){
            tokens[i][j+1] = '_';
            tokens[i][j+2] = '\0';
            break;
          }else{
            j=j+1;
            char temp = tokens[i][j];
            tokens[i][j] = punct;
            punct = temp;

          }
        }while(1);
      }
    }else{
    }
    i = i+1;
  }while(i<tokens_number);


}

void spell_checker() {


  int i = 0;
  do{

    if (tokens[i][0] == ' ') {

    }else if(tokens[i][0] == ',' || tokens[i][0] == '.' || tokens[i][0] == '!' || tokens[i][0] == '?'){

    }else {
      int token_char_idx =0;
      do {    //print_string("converting to lowercase");
        if(tokens[i][token_char_idx] == '\0'){
          spell_tokens[i][token_char_idx] = '\0';
          break;
        }
        if (tokens[i][token_char_idx] < 91){
          spell_tokens[i][token_char_idx] = tokens[i][token_char_idx] + 32;
        }else{
          spell_tokens[i][token_char_idx] = tokens[i][token_char_idx];
        }
        token_char_idx +=1;
      }while(1);


      int spelled_Correct_bool = 0;
      int k =0;

      do{

          if (dictionary_string_checker(dictionary_tokens[k], spell_tokens[i])==1){
            //print_string("IN dictionary\n");
            spelled_Correct_bool = 1;
            break;
          }
          k=k+1;
      }while(k<dictionary_tokens_number);


      if (spelled_Correct_bool ==0){
        //print_string("\nspelled incorrect\n");
        char letter = tokens[i][0];
        int j = 0;
        tokens[i][j] = '_';

        do{
          //print_char(letter);
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
        //print_string("\nspelled correct\n");
      }
    }
    i = i+1;
  }while(i<tokens_number);

  return;

}




// Task B
void output_tokens() {
  int i;

  for (i = 0; i < tokens_number; ++i) {
    output(tokens[i]);
    //output("\n");
  }
  output("\n");

  return;
}


void dictionary_tokenizer(){
  char d;

  // index of dictionary
  int d_idx = 0;
  d = dictionary[d_idx];
  do {

    // end of content
    if(d == '\0'){
      break;
    }

    // if the token starts with an alphabetic character
    if(d >= 'a' && d <= 'z') {

      int token_d_idx = 0;
      // copy till see any non-alphabetic character
      do {
        dictionary_tokens[dictionary_tokens_number][token_d_idx] = d;

        token_d_idx += 1;
        d_idx += 1;

        d = dictionary[d_idx];
      } while(d >= 'a' && d <= 'z');
      dictionary_tokens[dictionary_tokens_number][token_d_idx] = '\0';
      dictionary_tokens_number += 1;

      // if the token starts with one of punctuation marks
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

  punctuation_checker();

  output_tokens();

  return 0;
}
