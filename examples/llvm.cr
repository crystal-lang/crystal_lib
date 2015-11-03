@[Include(
  "llvm-c/Core.h",
  "llvm-c/ExecutionEngine.h",
  "llvm-c/Transforms/PassManagerBuilder.h",
  "llvm-c/BitWriter.h",
  "llvm-c/Analysis.h",
  "llvm-c/Initialization.h",
  flags: "-I/usr/local/Cellar/llvm/3.6.2/include  -fPIC -fvisibility-inlines-hidden -Wall -W -Wno-unused-parameter -Wwrite-strings -Wcast-qual -Wmissing-field-initializers -pedantic -Wno-long-long -Wcovered-switch-default -Wnon-virtual-dtor -std=c++11   -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS",
  prefix: %w(LLVM_ LLVM)
  )]
@[Link("stdc++")]
@[Link(ldflags: "`(llvm-config-3.6 --libs --system-libs --ldflags 2> /dev/null) || (llvm-config-3.5 --libs --system-libs --ldflags 2> /dev/null) || (llvm-config --libs --system-libs --ldflags 2>/dev/null)`")]
lib LibLLVM
end
