LLVM_BIN = ../llvm-wasm/bin
WABT_BIN = ../wabt/out/clang/Debug
BINARYEN_BIN = ../binaryen/bin

DISABLE_WARN = -Wno-bitwise-op-parentheses -Wno-shift-op-parentheses
MALLOC_OPTS = -DMORECORE_CANNOT_TRIM=1 -DHAVE_MMAP=0 -DHAVE_MREMAP=0 -DLACKS_TIME_H=1 -DNO_MALLOC_STATS=1 -Dmalloc_getpagesize=65536 -Wno-expansion-to-defined

# (import "env" "memset" (func (;3;) (type 4)))
# (import "env" "stderr" (global (;0;) i32))

# Helpers:
# ${basename $(@F)}
# LIBNAMES = ${notdir ${wildcard src/*}}
# DISTLIBS = ${addsuffix .o, ${addprefix dist/, ${LIBNAMES}}}

dist/memory.wasm: lib/malloc.wasm lib/memcpy.wasm lib/memset.wasm lib/stdlib-base.wasm
	$(LLVM_BIN)/lld -flavor wasm lib/malloc.wasm lib/memcpy.wasm lib/memset.wasm lib/stdlib-base.wasm -o dist/memory.wasm -r

lib/malloc.wasm:
	$(LLVM_BIN)/clang --target=wasm32-unknown-unknown-wasm -Iinclude/libc -Oz -c src/dlmalloc.c -o lib/malloc.wasm $(MALLOC_OPTS) $(DISABLE_WARN)

lib/memcpy.wasm:
	$(LLVM_BIN)/clang --target=wasm32-unknown-unknown-wasm -Iinclude/libc -Oz -c src/string/memcpy.c -o lib/memcpy.wasm $(DISABLE_WARN)

lib/memset.wasm:
	$(LLVM_BIN)/clang --target=wasm32-unknown-unknown-wasm -Iinclude/libc -Oz -c src/string/memset.c -o lib/memset.wasm $(DISABLE_WARN)

lib/stdlib-base.wasm:
	$(WABT_BIN)/wast2wasm -r src/stdlib-base.wast -o lib/stdlib-base.wasm

clean:
	rm lib/*.wasm lib/*.wast dist/*.wasm
