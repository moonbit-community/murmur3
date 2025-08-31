///|
fn main {
  // Test MurmurHash3 implementation
  let test_data: Bytes = "hello, world"
  println("Testing MurmurHash3 with: \{test_data}")
  println("32-bit hash: \{@lib.sum32(test_data)}")
  let hash128 = @lib.sum128(test_data)
  let h1 = hash128.high()
  let h2 = hash128.low()
  println("128-bit hash: (\{h1}, \{h2})")
}
