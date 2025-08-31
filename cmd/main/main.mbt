///|
fn main {
  // Test MurmurHash3 implementation
  let test_data : Bytes = "hello, world"
  println("Testing MurmurHash3 with: \{test_data}")
  println("32-bit hash: \{@murmur3.sum32(test_data)}")
  let hash128 = @murmur3.sum128(test_data)
  let h1 = hash128.hi
  let h2 = hash128.lo
  println("128-bit hash: (\{h1}, \{h2})")
}
