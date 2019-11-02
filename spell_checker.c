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
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1];


///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////

//Dictionary Tokens
char dict_tokens[MAX_DICTIONARY_WORDS +1][MAX_DICTIONARY_WORDS + 1];

// Array to identiy which tokens are misspelled
int wordStatus[2048];

// 2D Array of highlighted misspelled words
char checkedWords[MAX_INPUT_SIZE + 2][MAX_INPUT_SIZE + 2];

// Task B

//Toenises the dictionary characters

void dict_tokenizer() {
  
  int i, j, dict_count;

  j = 0;
  dict_count = 0;

  for(i = 0; i < (MAX_DICTIONARY_WORDS + 1); i++){
    for(j = 0; j < (MAX_WORD_SIZE + 1); j ++){
      dict_tokens[i][j] = '\0';
    }
  }

  for(i = 0; i < MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1; i++){

    if(dictionary[i] == '\0'){
      break;
    }
    if (dictionary[i] != '\n') {
      dict_tokens[dict_count][j] = dictionary[i];
      j++;
    } else {
      dict_count++;
    }
  }

}

void spell_checker() {

 char wordChar, dictChar;

  int i, j, k;

  // indexes of tokens and dict_tokens

  int wordMatch;

    //Compare each word character by character

  for(i = 0; i < tokens_number; i++ ){ // Loop through each token
    if (tokens[i][0] < 'A') {
      wordStatus[i] = 1;
      continue;
    }
    if (tokens[i][0] == '\0'){
      break;
    }

    wordMatch = 0;  // Set wordMatch to false

    for(j = 0; j < MAX_DICTIONARY_WORDS; j++){ // Loop through each dictionary word

      if (dict_tokens[j][0] == '\0') {
        continue;
      }

      for(k = 0; k < 21; k++){ // Loop through each char
      
        wordChar = tokens[i][k];
        dictChar = dict_tokens[j][k];


        if(wordChar == '\0' && dictChar == '\0'){
          wordMatch = 1;
          wordStatus[i] = wordMatch;
          break;
          
        } else if (wordChar != dictChar && (wordChar + 32) != dictChar ){
          break;
        }

      }

    }
    
  }

    for(i = 0; i < tokens_number; i++){
        if (tokens[i][0] == '\0'){
          break;
        }
        if(wordStatus[i] == 1){               // If word isnt misspelled
          for(j = 0; j < 21; j++){            // Print as normal
            checkedWords[i][j] = tokens[i][j];
          }
        }

        if(wordStatus[i] == 0){ // If word is misspelled

          checkedWords[i][0] = '_';

          for(j = 1; j < 23; j++){

            if(tokens[i][j-1] == '\0'){
              checkedWords[i][j] = '_';
              break;
            }

            checkedWords[i][j] = tokens[i][j-1];

          }

        }
    }
}

// Task B
void output_tokens() {
  
  int i, j;

  for(i = 0; i < tokens_number; i++){

    for(j = 0; j < 23; j++){

      printf("%c", checkedWords[i][j]);

    }

  }
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

  dict_tokenizer();

  spell_checker();

  output_tokens();

  return 0;
}
