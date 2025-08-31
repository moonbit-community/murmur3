# MurmurHash3 for MoonBit

A native MoonBit implementation of Austin Appleby's third MurmurHash revision (aka MurmurHash3).

This is a port of the Go implementation from [github.com/twmb/murmur3](https://github.com/twmb/murmur3) to MoonBit, providing fast, portable hash functions for 32-bit, 64-bit, and 128-bit outputs.

## Features

- **32-bit, 64-bit, and 128-bit hash variants**
- **Streaming and one-shot APIs**
- **Portable across architectures** - always reads bytes as little endian
- **Memory-safe implementation** without unsafe operations
- **Compatible API design** following MoonBit conventions

## Usage

### One-shot Hashing

```moonbit
test "one-shot hashing examples" {
  // 32-bit hash
  let data : Array[Byte] = [72, 101, 108, 108, 111] // "Hello" as bytes
  let hash32 : UInt = sum32(data)

  // 64-bit hash  
  let hash64 : UInt64 = sum64(data)

  // 128-bit hash
  let hash_result = sum128(data)
  let h1 = hash_result.0
  let h2 = hash_result.1

  // String versions
  let hash32_str : UInt = string_sum32("Hello")
  let hash64_str : UInt64 = string_sum64("Hello")
  let hash_result_str = string_sum128("Hello")
  let h1_str = hash_result_str.0
  let h2_str = hash_result_str.1
  
  // Use the values to avoid unused warnings
  ignore(hash32)
  ignore(hash64)
  ignore(h1)
  ignore(h2)
  ignore(hash32_str)
  ignore(hash64_str)
  ignore(h1_str)
  ignore(h2_str)
}
```

### Streaming Hashing

```moonbit
test "streaming hashing examples" {
  let data : Array[Byte] = [72, 101, 108, 108, 111] // "Hello" as bytes
  
  // 32-bit streaming
  let hasher32 : Digest32 = Digest32::new()
  hasher32.write([72, 101]) |> ignore  // "He"
  hasher32.write([108, 108, 111]) |> ignore  // "llo"
  let result : UInt = hasher32.sum32()

  // 128-bit streaming
  let hasher128 : Digest128 = Digest128::new()
  hasher128.write(data) |> ignore
  let hash_result = hasher128.sum128()
  let h1 = hash_result.0
  let h2 = hash_result.1
  
  // Use the values to avoid unused warnings
  ignore(result)
  ignore(h1)
  ignore(h2)
}
```

### Seeded Hashing

```moonbit
test "seeded hashing examples" {
  let data : Array[Byte] = [72, 101, 108, 108, 111] // "Hello" as bytes
  
  // With custom seeds
  let hash32_seeded : UInt = seed_sum32(12345U, data)
  let hash64_seeded : UInt64 = seed_sum64(12345UL, data)
  let hash_result_seeded = seed_sum128(12345UL, 67890UL, data)
  let h1_seeded = hash_result_seeded.0
  let h2_seeded = hash_result_seeded.1
  
  // Use the values to avoid unused warnings
  ignore(hash32_seeded)
  ignore(hash64_seeded)
  ignore(h1_seeded)
  ignore(h2_seeded)
}
```

## Algorithm Details

Unlike the canonical source, this library **always** reads bytes as little endian numbers. This makes the hashes portable across architectures, although does mean that hashing is a bit slower on big endian architectures.

The reference algorithm has been adapted to support the streaming mode required for incremental hashing.

## API Reference

### Types

- `Digest32` - 32-bit streaming hasher
- `Digest128` - 128-bit streaming hasher  
- `Digest64` - 64-bit streaming hasher (alias for `Digest128`)

### Functions

#### 32-bit Hashing
- `sum32(data : Array[Byte]) -> UInt`
- `seed_sum32(seed : UInt, data : Array[Byte]) -> UInt`
- `string_sum32(data : String) -> UInt`
- `seed_string_sum32(seed : UInt, data : String) -> UInt`

#### 64-bit Hashing  
- `sum64(data : Array[Byte]) -> UInt64`
- `seed_sum64(seed : UInt64, data : Array[Byte]) -> UInt64`
- `string_sum64(data : String) -> UInt64`
- `seed_string_sum64(seed : UInt64, data : String) -> UInt64`

#### 128-bit Hashing
- `sum128(data : Array[Byte]) -> (UInt64, UInt64)`
- `seed_sum128(seed1 : UInt64, seed2 : UInt64, data : Array[Byte]) -> (UInt64, UInt64)`
- `string_sum128(data : String) -> (UInt64, UInt64)`
- `seed_string_sum128(seed1 : UInt64, seed2 : UInt64, data : String) -> (UInt64, UInt64)`

## Testing

Run the test suite with:

```bash
moon test
```

The tests include reference vectors from the original implementation to ensure compatibility.

## License

Licensed under the Apache License, Version 2.0. See LICENSE file for details.

This implementation is based on the Go implementation by Travis Brown, which itself is based on Austin Appleby's original C++ implementation.
