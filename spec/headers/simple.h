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
void function_pointer(int (*x)(float, char));

typedef int (*fun_ptr)(float, char);
void function_pointer2(fun_ptr x);

void constant_array(int x[2]);

const int just_const_int();

void variadic(int x, ...);

int some_int;
fun_ptr some_fun_ptr;
