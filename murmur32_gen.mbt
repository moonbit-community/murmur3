///| 32-bit MurmurHash3 Convenience Functions
/// One-shot hash functions for 32-bit MurmurHash3

///|
/// Compute MurmurHash3 32-bit hash of data with seed 0
/// Equivalent to: hasher = new32(); hasher.write(data); hasher.sum32()
pub fn sum32(data : Bytes) -> UInt {
  seed_sum32(0U, data)
}

///|
/// Compute MurmurHash3 32-bit hash of data with given seed
/// This reads and processes data in chunks of little endian uint32s,
/// making the hash portable across architectures
pub fn seed_sum32(seed : UInt, data : Bytes) -> UInt {
  let mut h1 = seed
  let clen = data.length().reinterpret_as_uint()
  let mut p = data

  // Process 4-byte chunks
  while p.length() >= 4 {
    let k1 = p[0].to_uint() |
      (p[1].to_uint() << 8) |
      (p[2].to_uint() << 16) |
      (p[3].to_uint() << 24)
    p = p[4:].to_bytes()
    let mut k1_processed = k1 * c1_32
    k1_processed = rotate_left_32(k1_processed, 15)
    k1_processed = k1_processed * c2_32
    h1 = h1 ^ k1_processed
    h1 = rotate_left_32(h1, 13)
    h1 = h1 * 5U + 0xe6546b64U
  }

  // Handle remaining bytes
  let mut k1 = 0U
  if p.length() >= 3 {
    k1 = k1 ^ (p[2].to_uint() << 16)
  }
  if p.length() >= 2 {
    k1 = k1 ^ (p[1].to_uint() << 8)
  }
  if p.length() >= 1 {
    k1 = k1 ^ p[0].to_uint()
    k1 = k1 * c1_32
    k1 = rotate_left_32(k1, 15)
    k1 = k1 * c2_32
    h1 = h1 ^ k1
  }
  h1 = h1 ^ clen

  // Final mix
  h1 = h1 ^ (h1 >> 16)
  h1 = h1 * 0x85ebca6bU
  h1 = h1 ^ (h1 >> 13)
  h1 = h1 * 0xc2b2ae35U
  h1 = h1 ^ (h1 >> 16)
  h1
}

///|
/// String version of sum32 - compute hash directly from string
pub fn string_sum32(data : String) -> UInt {
  seed_string_sum32(0U, data)
}

///|
/// String version of seed_sum32 - compute hash from string with seed
/// Converts string to bytes and calls seed_sum32
pub fn seed_string_sum32(seed : UInt, data : String) -> UInt {
  let byte_array = string_to_utf8_bytes(data)
  seed_sum32(seed, byte_array)
}