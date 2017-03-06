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
signed char just_signed_char();
float just_float();
double just_double();
long double just_long_double();
size_t just_size_t();
__builtin_va_list* just___builtin_va_list();
void function_pointer(int (*x)(float, char));

typedef int (*fun_ptr)(float, char);
void function_pointer2(fun_ptr x);

void constant_array(int x[2]);

const int just_const_int();

void variadic(int x, ...);

int some_int;
fun_ptr some_fun_ptr;

typedef struct opaque *opaque_reference;
struct anotherOpaque;
typedef struct anotherOpaque anotherOpaqueReference;

opaque_reference just_opaque_reference();
anotherOpaqueReference *just_another_opaque_reference();

typedef enum {
  x,
  y = 123
} some_enum_1;
some_enum_1 just_some_enum_1();

enum some_enum_2 {
  z = 456
};
enum some_enum_2 just_some_enum_2();

enum some_enum_3 {
  node_para = 1,
  NODE_LINK = 2,
  NodeName = 3
};
enum some_enum_3 just_some_enum_3();

enum {
  SOCK_STREAM = 1,
  #define SOCK_STREAM SOCK_STREAM
  SOCK_DGRAM = 2,
  #define SOCK_DGRAM SOCK_DGRAM
};

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

struct forwarded_struct;

typedef struct forwarded_struct forwarded_struct_typedef;

struct forwarded_struct {
  int x;
};

void just_some_forwarded_struct(forwarded_struct_typedef* handle);

struct struct_with_end {
  int end;
};
void just_some_struct_with_end(struct struct_with_end* handle);

typedef int __underscore;
__underscore just_some_underscore();

typedef int TCamelCase;
TCamelCase just_some_camelcase();

struct struct_with_nest {
  struct {
    int x;
    int y;
  } nested;
};
void just_some_struct_with_nest(struct struct_with_nest* handle);

typedef struct {
  struct {
    int x;
    int y;
  } nested;
} struct_with_nest_2;

void just_some_struct_with_nest_2(struct_with_nest_2* handle);

struct struct_foo {
  struct struct_bar* bar;
};

struct struct_bar {
  int x;
};

typedef struct struct_bar struct_bar;
void some_struct_with_other_struct_pointer(struct_bar* handle);

#define inet_pton __inet_pton
int __inet_pton(int, char*, void*);

#define OCTAL 0755
#define HEXA 0xffff
