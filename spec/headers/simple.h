#include <stdlib.h>

int just_int();
short just_short();
char just_char();
long just_long();
long long just_long_long();
void just_void();
unsigned char just_unsigned_char();
unsigned int just_unsigned_int();
unsigned short just_unsigned_short();
unsigned long just_unsigned_long();
unsigned long long just_unsigned_long_long();
float just_float();
double just_double();
size_t just_size_t();
void function_pointer(int (*x)(float, char));

typedef int (*fun_ptr)(float, char);
void function_pointer2(fun_ptr x);

void constant_array(int x[2]);

const int just_const_int();

void variadic(int x, ...);

int some_int;
fun_ptr some_fun_ptr;

typedef struct opaque *opaque_reference;

opaque_reference just_opaque_reference();

typedef enum {
  x,
  y = 123
} some_enum_1;
some_enum_1 just_some_enum_1();

enum some_enum_2 {
  z = 456
};
enum some_enum_2 just_some_enum_2();

typedef struct { int x; } some_struct_1;
some_struct_1 just_some_struct_1();

struct some_struct_2 {
  int y;
};
struct some_struct_2 just_some_struct_2();

typedef union { int x; } some_union_1;
some_union_1 just_some_union_1();

struct some_struct_3 {
  struct unexposed* x;
};
struct some_struct_3 just_some_struct_3();

void just_some_incomplete_array(char* argv[]);

typedef struct some_recursive_struct {
  int x;
  struct some_recursive_struct* y;
} some_recursive_struct;
some_recursive_struct just_some_recursive_struct();


