///| 64-bit MurmurHash3 Implementation (wrapper around 128-bit)
/// Note: As the canonical implementation does not support Sum64,
/// this uses the 128-bit version with SeedNew128(seed, seed)

///|
/// 64-bit digest structure - wraps the 128-bit version  
struct Digest64(Digest128)



///|
/// Create a new 64-bit hasher with the given seed
/// Uses the 128-bit implementation with seed duplicated
pub fn Digest64::new_with_seed(seed : UInt64) -> Digest64 {
  Digest64(Digest128::new_with_seed(seed, seed))
}

///|
/// Create a new 64-bit hasher with seed 0
pub fn Digest64::new() -> Digest64 {
  Digest64::new_with_seed(0UL)
}

///|
/// Write data to the 64-bit hasher
pub fn Digest64::write(self : Digest64, data : Bytes) -> Int {
  let Digest64(inner) = self
  inner.write(data)
}

///|
/// Finalize and return the 64-bit hash (first part of 128-bit hash)
pub fn Digest64::sum64(self : Digest64) -> UInt64 {
  let Digest64(inner) = self
  let hash128 = inner.sum128()
  hash128.hi
}

///|
/// Reset the 64-bit hasher to initial state
pub fn Digest64::reset(self : Digest64) -> Unit {
  let Digest64(inner) = self
  inner.reset()
}

///|
/// Get the size in bytes (8 for 64-bit hash)
pub fn Digest64::size(_self : Digest64) -> Int {
  8
}

///|
/// Get the hash as a byte array (big-endian, 8 bytes)
pub fn Digest64::sum(self : Digest64) -> Bytes {
  let h1 = self.sum64()
  let array = [
    ((h1 >> 56) & 0xFFUL).to_byte(),
    ((h1 >> 48) & 0xFFUL).to_byte(),
    ((h1 >> 40) & 0xFFUL).to_byte(),
    ((h1 >> 32) & 0xFFUL).to_byte(),
    ((h1 >> 24) & 0xFFUL).to_byte(),
    ((h1 >> 16) & 0xFFUL).to_byte(),
    ((h1 >> 8) & 0xFFUL).to_byte(),
    (h1 & 0xFFUL).to_byte(),
  ]
  Bytes::from_array(array)
}

///|
/// Compute MurmurHash3 64-bit hash of data
/// Returns the first 64 bits of the 128-bit hash
pub fn sum64(data : Bytes) -> UInt64 {
  let hash128 = sum128(data)
  hash128.hi
}

///|
/// Compute MurmurHash3 64-bit hash of data with given seed
/// Because the canonical implementation does not support SeedSum64,
/// this uses SeedSum128(seed, seed, data) and returns the first part
pub fn seed_sum64(seed : UInt64, data : Bytes) -> UInt64 {
  let hash128 = seed_sum128(seed, seed, data)
  hash128.hi
}

