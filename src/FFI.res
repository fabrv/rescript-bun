/**
 * `bun:ffi` lets you efficiently call C functions & FFI functions from JavaScript
 * without writing bindings yourself.
 *
 * This is powered by just-in-time compiling C wrappers
 * that convert JavaScript types to C types and back. Internally,
 * bun uses [tinycc](https://github.com/TinyCC/tinycc).
 */

/** Opaque pointer type representing a memory address */
type pointer

/** FFI type enum for specifying C ABI types */
type ffiType =
  | @as(0) Char
  | @as(1) Int8_t
  | @as(2) Uint8_t
  | @as(3) Int16_t
  | @as(4) Uint16_t
  | @as(5) Int32_t
  | @as(6) Uint32_t
  | @as(7) Int64_t
  | @as(8) Uint64_t
  | @as(9) Double
  | @as(10) Float
  | @as(11) Bool
  | @as(12) Ptr
  | @as(13) Void
  | @as(14) Cstring
  | @as(15) I64_fast
  | @as(16) U64_fast
  | @as(17) Function
  | @as(18) Napi_env
  | @as(19) Napi_value
  | @as(20) FFIBuffer

/** FFI type can also be specified as a string */
type ffiTypeOrString =
  | FFIType(ffiType)
  | @as("char") CharStr
  | @as("int8_t") Int8_tStr
  | @as("i8") I8Str
  | @as("uint8_t") Uint8_tStr
  | @as("u8") U8Str
  | @as("int16_t") Int16_tStr
  | @as("i16") I16Str
  | @as("uint16_t") Uint16_tStr
  | @as("u16") U16Str
  | @as("int32_t") Int32_tStr
  | @as("i32") I32Str
  | @as("int") IntStr
  | @as("uint32_t") Uint32_tStr
  | @as("u32") U32Str
  | @as("int64_t") Int64_tStr
  | @as("i64") I64Str
  | @as("uint64_t") Uint64_tStr
  | @as("u64") U64Str
  | @as("double") DoubleStr
  | @as("f64") F64Str
  | @as("float") FloatStr
  | @as("f32") F32Str
  | @as("bool") BoolStr
  | @as("ptr") PtrStr
  | @as("pointer") PointerStr
  | @as("void") VoidStr
  | @as("cstring") CstringStr
  | @as("function") FunctionStr
  | @as("usize") UsizeStr
  | @as("callback") CallbackStr
  | @as("napi_env") Napi_envStr
  | @as("napi_value") Napi_valueStr
  | @as("buffer") BufferStr

/** Definition of a C function for FFI */
type ffiFunction = {
  args?: array<ffiTypeOrString>,
  returns?: ffiTypeOrString,
  ptr?: pointer,
  threadsafe?: bool,
}

/** A library opened with dlopen */
type library<'symbols> = {
  symbols: 'symbols,
}

/** Close a library, unloading the symbols and freeing allocated memory */
@send external closeLibrary: library<'a> => unit = "close"

/**
 * Open a library using `"bun:ffi"`
 *
 * @param name The name of the library or file path. This will be passed to `dlopen()`
 * @param symbols Map of symbols to load where the key is the symbol name and the value is the FFIFunction
 */
@module("bun:ffi")
external dlopen: (string, 'symbols) => library<'result> = "dlopen"

/**
 * Open a library from a BunFile
 */
@module("bun:ffi")
external dlopenFile: (Types.bunFile, 'symbols) => library<'result> = "dlopen"

/**
 * Link a map of symbols to JavaScript functions.
 *
 * This lets you use native libraries that were already loaded somehow.
 * You usually will want `dlopen` instead.
 */
@module("bun:ffi")
external linkSymbols: 'symbols => library<'result> = "linkSymbols"

/**
 * Get the pointer backing a TypedArray or ArrayBuffer.
 *
 * Use this to pass TypedArray or ArrayBuffer to C functions.
 */
@module("bun:ffi")
external ptrOfTypedArray: TypedArray.t<'a> => pointer = "ptr"

@module("bun:ffi")
external ptrOfArrayBuffer: ArrayBuffer.t => pointer = "ptr"

@module("bun:ffi")
external ptrOfDataView: DataView.t => pointer = "ptr"

@module("bun:ffi")
external ptrOfTypedArrayWithOffset: (TypedArray.t<'a>, ~byteOffset: int) => pointer = "ptr"

@module("bun:ffi")
external ptrOfArrayBufferWithOffset: (ArrayBuffer.t, ~byteOffset: int) => pointer = "ptr"

@module("bun:ffi")
external ptrOfDataViewWithOffset: (DataView.t, ~byteOffset: int) => pointer = "ptr"

/**
 * Read a pointer as a Buffer
 *
 * If `byteLength` is not provided, the pointer is assumed to be 0-terminated.
 */
@module("bun:ffi")
external toBuffer: pointer => Buffer.t = "toBuffer"

@module("bun:ffi")
external toBufferWithOffset: (pointer, ~byteOffset: int) => Buffer.t = "toBuffer"

@module("bun:ffi")
external toBufferWithOffsetAndLength: (pointer, ~byteOffset: int, ~byteLength: int) => Buffer.t =
  "toBuffer"

/**
 * Read a pointer as an ArrayBuffer
 *
 * If `byteLength` is not provided, the pointer is assumed to be 0-terminated.
 */
@module("bun:ffi")
external toArrayBuffer: pointer => ArrayBuffer.t = "toArrayBuffer"

@module("bun:ffi")
external toArrayBufferWithOffset: (pointer, ~byteOffset: int) => ArrayBuffer.t = "toArrayBuffer"

@module("bun:ffi")
external toArrayBufferWithOffsetAndLength: (
  pointer,
  ~byteOffset: int,
  ~byteLength: int,
) => ArrayBuffer.t = "toArrayBuffer"

/**
 * Platform-specific file extension name for dynamic libraries.
 *
 * "." is not included.
 *
 * @example "dylib" on macOS, "so" on Linux
 */
@module("bun:ffi")
external suffix: string = "suffix"

/**
 * Get a string from a UTF-8 encoded C string.
 * If `byteLength` is not provided, the string is assumed to be null-terminated.
 */
module CString = {
  type t

  @module("bun:ffi") @new
  external make: pointer => t = "CString"

  @module("bun:ffi") @new
  external makeWithOffset: (pointer, ~byteOffset: int) => t = "CString"

  @module("bun:ffi") @new
  external makeWithOffsetAndLength: (pointer, ~byteOffset: int, ~byteLength: int) => t = "CString"

  /** The ptr to the C string */
  @get external ptr: t => pointer = "ptr"

  @get external byteOffset: t => option<int> = "byteOffset"
  @get external byteLength: t => option<int> = "byteLength"

  /** Get the ptr as an ArrayBuffer */
  @get external arrayBuffer: t => ArrayBuffer.t = "arrayBuffer"

  @send external toString: t => string = "toString"
}

/**
 * Pass a JavaScript function to FFI (Foreign Function Interface)
 */
module JSCallback = {
  type t

  /**
   * Enable a JavaScript callback function to be passed to C with bun:ffi
   *
   * @param callback The JavaScript function to be called
   * @param definition The C function definition
   */
  @module("bun:ffi") @new
  external make: (@uncurry ('a => 'b), ffiFunction) => t = "JSCallback"

  /** The pointer to the C function. Becomes null once `close` is called. */
  @get @return(nullable)
  external ptr: t => option<pointer> = "ptr"

  /** Can the callback be called from a different thread? */
  @get external threadsafe: t => bool = "threadsafe"

  /** Free the memory allocated for the callback */
  @send external close: t => unit = "close"
}

/**
 * Turn a native library's function pointer into a JavaScript function.
 *
 * Libraries using Node-API & bun:ffi in the same module could use this
 * to skip an extra dlopen() step.
 */
module CFunction = {
  type t

  type cfunctionArg = {
    args?: array<ffiTypeOrString>,
    returns?: ffiTypeOrString,
    ptr: pointer,
    threadsafe?: bool,
  }

  @module("bun:ffi") @new
  external make: cfunctionArg => t = "CFunction"

  @send external close: t => unit = "close"
}

/**
 * Compile ISO C11 source code using TinyCC, and make symbols available as functions to JavaScript.
 */
module CC = {
  type options<'symbols, 'source> = {
    source: 'source,
    symbols: 'symbols,
    library?: array<string>,
    @as("include") include_?: array<string>,
    define?: Dict.t<string>,
    flags?: array<string>,
  }

  @module("bun:ffi")
  external compile: options<'symbols, string> => library<'result> = "cc"

  @module("bun:ffi")
  external compileFile: options<'symbols, Types.bunFile> => library<'result> = "cc"
}

/**
 * View the generated C code for FFI bindings.
 *
 * Useful for debugging FFI bindings.
 */
@module("bun:ffi")
external viewSource: Dict.t<ffiFunction> => array<string> = "viewSource"

@module("bun:ffi")
external viewSourceCallback: (ffiFunction, @as(json`true`) _) => string = "viewSource"

/**
 * Fast memory reading functions.
 *
 * These behave similarly to DataView, but are usually faster because
 * they don't need to create a DataView or ArrayBuffer.
 */
module Read = {
  @module("bun:ffi") @scope("read")
  external u8: (pointer, ~byteOffset: int=?) => int = "u8"

  @module("bun:ffi") @scope("read")
  external i8: (pointer, ~byteOffset: int=?) => int = "i8"

  @module("bun:ffi") @scope("read")
  external u16: (pointer, ~byteOffset: int=?) => int = "u16"

  @module("bun:ffi") @scope("read")
  external i16: (pointer, ~byteOffset: int=?) => int = "i16"

  @module("bun:ffi") @scope("read")
  external u32: (pointer, ~byteOffset: int=?) => int = "u32"

  @module("bun:ffi") @scope("read")
  external i32: (pointer, ~byteOffset: int=?) => int = "i32"

  @module("bun:ffi") @scope("read")
  external f32: (pointer, ~byteOffset: int=?) => float = "f32"

  @module("bun:ffi") @scope("read")
  external f64: (pointer, ~byteOffset: int=?) => float = "f64"

  @module("bun:ffi") @scope("read")
  external u64: (pointer, ~byteOffset: int=?) => bigint = "u64"

  @module("bun:ffi") @scope("read")
  external i64: (pointer, ~byteOffset: int=?) => bigint = "i64"

  @module("bun:ffi") @scope("read")
  external ptr: (pointer, ~byteOffset: int=?) => pointer = "ptr"

  @module("bun:ffi") @scope("read")
  external intptr: (pointer, ~byteOffset: int=?) => int = "intptr"
}
