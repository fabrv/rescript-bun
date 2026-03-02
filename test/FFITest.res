open RescriptBun
open Test
open FFI

let libPath = Globals.import.meta.dir ++ "/ffi_testlib.so"

describe("FFI", () => {
  test("suffix is a non-empty string", () => {
    expect(suffix)->Expect.toBeString
    expect(suffix)->Expect.toBeTruthy
  })

  test("dlopen and call add()", () => {
    let lib = dlopen(
      libPath,
      {
        "add": {
          args: [I32Str, I32Str],
          returns: I32Str,
        },
      },
    )

    let result = lib.symbols["add"](2, 3)
    expect(result)->Expect.toBe(5)
    lib->closeLibrary
  })

  test("dlopen and call multiply()", () => {
    let lib = dlopen(
      libPath,
      {
        "multiply": {
          args: [I32Str, I32Str],
          returns: I32Str,
        },
      },
    )

    let result = lib.symbols["multiply"](7, 6)
    expect(result)->Expect.toBe(42)
    lib->closeLibrary
  })

  test("dlopen and call add_doubles()", () => {
    let lib = dlopen(
      libPath,
      {
        "add_doubles": {
          args: [F64Str, F64Str],
          returns: F64Str,
        },
      },
    )

    let result = lib.symbols["add_doubles"](1.5, 2.5)
    expect(result)->Expect.toBeCloseTo(4.0)
    lib->closeLibrary
  })

  test("dlopen and call hello() returning cstring", () => {
    let lib = dlopen(
      libPath,
      {
        "hello": {
          args: [],
          returns: CstringStr,
        },
      },
    )

    // When returns is "cstring", Bun already returns a CString object
    let result: CString.t = lib.symbols["hello"]()
    expect(result->CString.toString)->Expect.toBe("Hello from C!")
    lib->closeLibrary
  })

  test("ptr and toBuffer roundtrip", () => {
    let arr = Uint8Array.fromArray([10, 20, 30])
    let p = ptrOfTypedArray(arr)
    let buf = toBufferWithOffsetAndLength(p, ~byteOffset=0, ~byteLength=3)
    expect(buf->Buffer.unsafeGet(0))->Expect.toBe(10)
    expect(buf->Buffer.unsafeGet(1))->Expect.toBe(20)
    expect(buf->Buffer.unsafeGet(2))->Expect.toBe(30)
  })

  test("Read module reads memory correctly", () => {
    let arr = Uint8Array.fromArray([42, 0, 0, 0])
    let p = ptrOfTypedArray(arr)
    expect(Read.u8(p))->Expect.toBe(42)
    expect(Read.u8(p, ~byteOffset=1))->Expect.toBe(0)
  })

  test("dlopen and call negate()", () => {
    let lib = dlopen(
      libPath,
      {
        "negate": {
          args: [I32Str],
          returns: I32Str,
        },
      },
    )

    let result = lib.symbols["negate"](42)
    expect(result)->Expect.toBe(-42)
    lib->closeLibrary
  })

  test("CC.compile compiles C source from file", () => {
    let squarePath = Globals.import.meta.dir ++ "/ffi_square.c"
    let lib = CC.compile({
      source: squarePath,
      symbols: {
        "square": {
          args: [I32Str],
          returns: I32Str,
        },
      },
    })

    let result = lib.symbols["square"](9)
    expect(result)->Expect.toBe(81)
    lib->closeLibrary
  })
})
