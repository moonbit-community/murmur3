///|
fn main {
  // Test MurmurHash3 implementation
  let test_data = "hello, world"
  let byte_array = @lib.string_to_utf8_bytes(test_data)
  println("Testing MurmurHash3 with: \{test_data}")
  println("32-bit hash: \{@lib.sum32(byte_array)}")
  let hash128 = @lib.sum128(byte_array)
  let h1 = hash128.high()
  let h2 = hash128.low()
  println("128-bit hash: (\{h1}, \{h2})")
}
