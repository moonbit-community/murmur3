///| 32-bit MurmurHash3 Implementation
/// Constants and core algorithm for 32-bit MurmurHash3

///|
/// Constants for 32-bit MurmurHash3
let c1_32 : UInt = 0xcc9e2d51U

///|
let c2_32 : UInt = 0x1b873593U

///|
/// Left rotate a 32-bit unsigned integer
fn rotate_left_32(x : UInt, k : Int) -> UInt {
  (x << k) | (x >> (32 - k))
}

///|
/// 32-bit digest structure for MurmurHash3
/// Implements the BMixer trait for 32-bit hash computation
struct Digest32 {
  /// Base digest for common streaming functionality
  digest : Digest
  /// Seed value for hash initialization  
  seed : UInt
  /// Unfinalized running hash state
  mut h1 : UInt
}

///|
/// Create a new 32-bit hasher with the given seed
pub fn Digest32::new_with_seed(seed : UInt) -> Digest32 {
  { digest: Digest::new(4), seed, h1: seed }
}

///|
/// Create a new 32-bit hasher with seed 0
pub fn Digest32::new() -> Digest32 {
  Digest32::new_with_seed(0U)
}

///|
/// Implement BMixer trait for Digest32
impl BMixer for Digest32 with bmix(self, p) {
  let mut data = p
  let mut h1 = self.h1

  // Process 4-byte chunks
  while data.length() >= 4 {
    let k1 = data[0].to_uint() |
      (data[1].to_uint() << 8) |
      (data[2].to_uint() << 16) |
      (data[3].to_uint() << 24)
    data = data[4:].to_bytes()
    let mut k1_processed = k1 * c1_32
    k1_processed = rotate_left_32(k1_processed, 15)
    k1_processed = k1_processed * c2_32
    h1 = h1 ^ k1_processed
    h1 = rotate_left_32(h1, 13)
    h1 = h1 * 5U + 0xe6546b64U
  }
  self.h1 = h1
  data
}

///|
impl BMixer for Digest32 with size(_self) {
  4
}

///|
impl BMixer for Digest32 with reset(self) {
  self.h1 = self.seed
}

///|
/// Get the size in bytes (4 for 32-bit hash)
pub fn Digest32::size(_self : Digest32) -> Int {
  4
}

///|
/// Write data to the 32-bit hasher
pub fn Digest32::write(self : Digest32, data : Bytes) -> Int {
  self.digest.write(self, data)
}

///|
/// Finalize and return the 32-bit hash
pub fn Digest32::sum32(self : Digest32) -> UInt {
  let mut h1 = self.h1
  let mut k1 = 0U

  // Handle remaining bytes
  let tail_len = self.digest.tail.length()
  if tail_len >= 3 {
    k1 = k1 ^ (self.digest.tail[2].to_uint() << 16)
  }
  if tail_len >= 2 {
    k1 = k1 ^ (self.digest.tail[1].to_uint() << 8)
  }
  if tail_len >= 1 {
    k1 = k1 ^ self.digest.tail[0].to_uint()
    k1 = k1 * c1_32
    k1 = rotate_left_32(k1, 15)
    k1 = k1 * c2_32
    h1 = h1 ^ k1
  }
  h1 = h1 ^ self.digest.clen.reinterpret_as_uint()

  // Final mix
  h1 = h1 ^ (h1 >> 16)
  h1 = h1 * 0x85ebca6bU
  h1 = h1 ^ (h1 >> 13)
  h1 = h1 * 0xc2b2ae35U
  h1 = h1 ^ (h1 >> 16)
  h1
}

///|
/// Get the hash as a byte array (big-endian)
pub fn Digest32::sum(self : Digest32) -> Bytes {
  let h = self.sum32()
  let array = [
    ((h >> 24) & 0xFFU).to_byte(),
    ((h >> 16) & 0xFFU).to_byte(),
    ((h >> 8) & 0xFFU).to_byte(),
    (h & 0xFFU).to_byte(),
  ]
  Bytes::from_array(array)
}

///|
/// Reset the 32-bit hasher to initial state
pub fn Digest32::reset(self : Digest32) -> Unit {
  self.digest.reset(self)
}