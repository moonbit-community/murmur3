///| MurmurHash3 Test Suite
/// Comprehensive tests to verify compatibility with reference implementation
/// Test data from github.com/twmb/murmur3 test suite

///|
/// Test data structure matching the Go reference implementation
struct TestVector {
  h32 : UInt
  h64_1 : UInt64
  h64_2 : UInt64
  s : Bytes
}

///|
/// Reference test vectors from the original Go implementation
let test_data : Array[TestVector] = [
  {
    h32: 0x00000000U,
    h64_1: 0x0000000000000000UL,
    h64_2: 0x0000000000000000UL,
    s: "",
  },
  {
    h32: 0x248bfa47U,
    h64_1: 0xcbd8a7b341bd9b02UL,
    h64_2: 0x5b1e906a48ae1d19UL,
    s: "hello",
  },
  {
    h32: 0x149bbb7fU,
    h64_1: 0x342fac623a5ebc8eUL,
    h64_2: 0x4cdcbc079642414dUL,
    s: "hello, world",
  },
  {
    h32: 0xe31e8a70U,
    h64_1: 0xb89e5988b737affcUL,
    h64_2: 0x664fc2950231b2cbUL,
    s: "19 Jan 2038 at 3:14:07 AM",
  },
  {
    h32: 0xd5c48bfcU,
    h64_1: 0xcd99481f9ee902c9UL,
    h64_2: 0x695da1a38987b6e7UL,
    s: "The quick brown fox jumps over the lazy dog.",
  },
]

///|
/// Test 32-bit hash function
test "sum32 reference vectors" {
  for i = 0; i < test_data.length(); i = i + 1 {
    let test_vec = test_data[i]
    let data = test_vec.s
    let hash = sum32(data)
    assert_eq(hash, test_vec.h32)
  }
}

///|
/// Test 64-bit hash function
test "sum64 reference vectors" {
  for i = 0; i < test_data.length(); i = i + 1 {
    let test_vec = test_data[i]
    let data = test_vec.s
    let hash = sum64(data)
    assert_eq(hash, test_vec.h64_1)
  }
}

///|
/// Test 128-bit hash function
test "sum128 reference vectors" {
  for i = 0; i < test_data.length(); i = i + 1 {
    let test_vec = test_data[i]
    let data = test_vec.s
    let hash128 = sum128(data)
    let h1 = hash128.hi
    let h2 = hash128.lo
    assert_eq(h1, test_vec.h64_1)
    assert_eq(h2, test_vec.h64_2)
  }
}

///|
/// Test 32-bit streaming hasher
test "Digest32 streaming" {
  for i = 0; i < test_data.length(); i = i + 1 {
    let test_vec = test_data[i]
    let data = test_vec.s
    let hasher = Digest32::new()
    hasher.write(data) |> ignore
    let hash = hasher.sum32()
    assert_eq(hash, test_vec.h32)
  }
}

///|
/// Test 128-bit streaming hasher
test "Digest128 streaming" {
  for i = 0; i < test_data.length(); i = i + 1 {
    let test_vec = test_data[i]
    let data = test_vec.s
    let hasher = Digest128::new()
    hasher.write(data) |> ignore
    let hash128 = hasher.sum128()
    let h1 = hash128.hi
    let h2 = hash128.lo
    assert_eq(h1, test_vec.h64_1)
    assert_eq(h2, test_vec.h64_2)
  }
}

///|
/// Test seed functionality for 32-bit
test "seed_sum32 functionality" {
  let data = "test".to_bytes()
  let hash1 = seed_sum32(0U, data)
  let hash2 = seed_sum32(1U, data)

  // Different seeds should produce different hashes
  assert_not_eq(hash1, hash2)

  // Same seed should produce same hash
  let hash3 = seed_sum32(0U, data)
  assert_eq(hash1, hash3)
}

///|
/// Test seed functionality for 128-bit
test "seed_sum128 functionality" {
  let data = "test".to_bytes()
  let hash128_1 = seed_sum128(UInt128::{ hi: 0UL, lo: 0UL }, data)
  let hash128_2 = seed_sum128(UInt128::{ hi: 1UL, lo: 1UL }, data)

  // Different seeds should produce different hashes
  let h1_1 = hash128_1.hi
  let h2_1 = hash128_1.lo
  let h1_2 = hash128_2.hi
  let h2_2 = hash128_2.lo
  assert_false(h1_1 == h1_2 && h2_1 == h2_2)

  // Same seed should produce same hash
  let hash128_3 = seed_sum128(UInt128::{ hi: 0UL, lo: 0UL }, data)
  let h1_3 = hash128_3.hi
  let h2_3 = hash128_3.lo
  assert_eq(h1_1, h1_3)
  assert_eq(h2_1, h2_3)
}

///|
/// Test incremental hashing (processing data in chunks)
test "incremental hashing 32-bit" {
  let test_string : Bytes = "hello, world"
  let full_data = test_string

  // Hash all at once
  let hash_full = sum32(full_data)

  // Hash incrementally
  let hasher = Digest32::new()
  let part1 : Bytes = "hello, "
  let part2 : Bytes = "world"
  hasher.write(part1) |> ignore
  hasher.write(part2) |> ignore
  let hash_incremental = hasher.sum32()
  assert_eq(hash_full, hash_incremental)
}

///|
/// Test incremental hashing (processing data in chunks)
test "incremental hashing 128-bit" {
  let test_string : Bytes = "hello, world"
  let full_data = test_string

  // Hash all at once
  let hash128_full = sum128(full_data)

  // Hash incrementally
  let hasher = Digest128::new()
  let part1 : Bytes = "hello, "
  let part2 : Bytes = "world"
  hasher.write(part1) |> ignore
  hasher.write(part2) |> ignore
  let hash128_incremental = hasher.sum128()
  let h1_full = hash128_full.hi
  let h2_full = hash128_full.lo
  let h1_incremental = hash128_incremental.hi
  let h2_incremental = hash128_incremental.lo
  assert_eq(h1_full, h1_incremental)
  assert_eq(h2_full, h2_incremental)
}

///|
/// Test 64-bit streaming hasher methods
test "Digest64 streaming methods" {
  for i = 0; i < test_data.length(); i = i + 1 {
    let test_vec = test_data[i]
    let data = test_vec.s
    let hasher = Digest64::new()
    hasher.write(data) |> ignore
    let hash = hasher.sum64()
    assert_eq(hash, test_vec.h64_1)
  }
}

///|
/// Test all digest types for consistency
test "digest types consistency" {
  let test_data : Bytes = "test consistency"

  // Test 32-bit
  let digest32 = Digest32::new()
  digest32.write(test_data) |> ignore
  let hash32 = digest32.sum32()

  // Test 64-bit  
  let digest64 = Digest64::new()
  digest64.write(test_data) |> ignore
  let hash64 = digest64.sum64()

  // Test 128-bit
  let digest128 = Digest128::new()
  digest128.write(test_data) |> ignore
  let hash128 = digest128.sum128()

  // Verify that 64-bit is the high part of 128-bit
  assert_eq(hash64, hash128.hi)

  // Verify that one-shot functions produce the same results
  assert_eq(hash32, sum32(test_data))
  assert_eq(hash64, sum64(test_data))
  assert_eq(hash128.hi, sum128(test_data).hi)
  assert_eq(hash128.lo, sum128(test_data).lo)
}

///|
/// Test UInt128 record field access and Digest64 methods
test "UInt128 field access and Digest64 methods" {
  // Create test data using only bytes (no string conversion needed)
  let test_data = b"test field access"

  // Test 128-bit hash
  let hash128 = sum128(test_data)
  let high_part = hash128.hi
  let low_part = hash128.lo

  // Test 64-bit hash matches high part of 128-bit
  let hash64 = sum64(test_data)
  assert_eq(hash64, hash128.hi)

  // Test Digest64 methods
  let digest64 = Digest64::new()
  digest64.write(test_data) |> ignore
  let digest64_result = digest64.sum64()
  assert_eq(digest64_result, hash64)

  // Test consistency between all methods
  let digest128 = Digest128::new()
  digest128.write(test_data) |> ignore
  let stream_hash128 = digest128.sum128()
  assert_eq(high_part, stream_hash128.hi)
  assert_eq(low_part, stream_hash128.lo)
}
