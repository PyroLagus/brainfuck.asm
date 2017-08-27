#include <unistd.h>
#define DATASIZE 30000
#define INPUTSIZE 10000
#define CODESIZE 10000
#define STACKSIZE 10000


unsigned int instruction_pointer = 0;
unsigned short int data_pointer = 0;
unsigned int stack_pointer = 0;

unsigned long int cells[DATASIZE] = {0};
unsigned char code[CODESIZE] = {0};
unsigned char input[INPUTSIZE] = {0};
unsigned int stack[STACKSIZE] = {0};

int main() {
  register unsigned char c = 0;
  register unsigned int source = 0;
  register unsigned int dest = 0;

  read(0, input, INPUTSIZE);

  while(1) {
    c = input[source];
    source++;
    if(c == 0) {
      break;
    }
    switch(c) {
    case '>': break;
    case '<': break;
    case '+': break;
    case '-': break;
    case '.': break;
    case ',': break;
    case '[':
      stack[stack_pointer] = instruction_pointer;
      stack_pointer++;
      code[dest] = c;
      dest += sizeof(instruction_pointer) + 1;
      instruction_pointer += sizeof(instruction_pointer) + 1;
      continue;
    case ']':
      stack_pointer--;
      *(typeof(instruction_pointer) *)(code+dest*sizeof(char)+1) = stack[stack_pointer];
      code[dest] = c;
      dest += sizeof(instruction_pointer) + 1;
      *(typeof(instruction_pointer) *)(code+stack[stack_pointer]*sizeof(char)+1) = instruction_pointer;
      instruction_pointer += sizeof(instruction_pointer) + 1;
    default: continue;
    }
    code[dest] = c;
    dest++;
    instruction_pointer++;
  }

  instruction_pointer = 0;
  while(1) {
    switch(code[instruction_pointer]) {
    case 0: return 0;
    case '>':
      data_pointer++;
      break;
    case '<':
      data_pointer--;
      break;
    case '+':
      cells[data_pointer]++;
      break;
    case '-':
      cells[data_pointer]--;
      break;
    case '.':
      write(1, &cells[data_pointer], 1);
      break;
    case ',':
      read(0, &cells[data_pointer], 1);
      break;
    case '[':
      if (cells[data_pointer] == 0) {
        instruction_pointer = *(typeof(instruction_pointer) *)(code+instruction_pointer*sizeof(char)+1);
      }
      instruction_pointer += sizeof(instruction_pointer) + 1;
      continue;
    case ']':
      if (cells[data_pointer] != 0) {
        instruction_pointer = *(typeof(instruction_pointer) *)(code+instruction_pointer*sizeof(char)+1);
      }
      instruction_pointer += sizeof(instruction_pointer) + 1;
      continue;
    }
    instruction_pointer++;
  }
}
