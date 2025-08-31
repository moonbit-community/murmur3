# MurmurHash3 for MoonBit

A native MoonBit implementation of Austin Appleby's third MurmurHash revision (MurmurHash3).

This is a port of the Go implementation from [github.com/twmb/murmur3](https://github.com/twmb/murmur3) to MoonBit, providing fast, portable hash functions for 32-bit, 64-bit, and 128-bit outputs.

## Features

- **32-bit, 64-bit, and 128-bit hash variants**
- **Streaming and one-shot APIs**
- **Portable across architectures** - always reads bytes as little endian
- **Memory-safe implementation** without unsafe operations
- **Compatible API design** following MoonBit conventions

## Usage Examples

### One-shot Hashing

```moonbit
test "32-bit hash example" {
  let data = "Hello, World!".to_bytes()
  let hash = @murmur3.sum32(data)
  inspect(hash, content="1777475617")
}

test "64-bit hash example" {
  let data = "Hello, World!".to_bytes()
  let hash = @murmur3.sum64(data)
  inspect(hash, content="11400168794036550540")
}

test "128-bit hash example" {
  let data = "Hello, World!".to_bytes()
  let hash = @murmur3.sum128(data)
  inspect(hash, content="{hi: 11400168794036550540, lo: 3017233662317374139}")
}
```

### Streaming Hashing

For large data or incremental processing:

```moonbit
test "streaming 32-bit hash" {
  let hasher = @murmur3.Digest32::new()
  
  hasher.write("Hello".to_bytes()) |> ignore
  hasher.write(", ".to_bytes()) |> ignore
  hasher.write("World!".to_bytes()) |> ignore
  
  let result = hasher.sum32()
  inspect(result, content="1777475617")
}

test "streaming 128-bit hash" {
  let hasher = @murmur3.Digest128::new()
  
  hasher.write("Hello".to_bytes()) |> ignore
  hasher.write(", ".to_bytes()) |> ignore
  hasher.write("World!".to_bytes()) |> ignore
  
  let hash = hasher.sum128()
  inspect(hash, content="{hi: 11400168794036550540, lo: 3017233662317374139}")
}
```

### Seeded Hashing

For consistent hashing across runs or creating hash families:

```moonbit
test "seeded hashing" {
  let data = "Hello, World!".to_bytes()
  let seed32 = 42U
  let seed64 = 42UL
  let seed128 = @murmur3.UInt128::{ hi: 42UL, lo: 84UL }
  
  // Seeded 32-bit hash
  let hash32 = @murmur3.seed_sum32(seed32, data)
  
  // Seeded 64-bit hash  
  let hash64 = @murmur3.seed_sum64(seed64, data)
  
  // Seeded 128-bit hash
  let hash128 = @murmur3.seed_sum128(seed128, data)
  
  inspect(hash32, content="374868951")
  inspect(hash64, content="2089968197194997941")
  inspect(hash128, content="{hi: 15086572923677321942, lo: 14159238408620771331}")
}
```

## API Reference

### Types

- **`Digest32`** - 32-bit streaming hasher
- **`Digest64`** - 64-bit streaming hasher  
- **`Digest128`** - 128-bit streaming hasher
- **`UInt128`** - 128-bit unsigned integer with `hi` and `lo` fields

### 32-bit Functions

| Function | Description |
|----------|-------------|
| `sum32(data : Bytes) -> UInt` | Hash bytes with default seed |
| `seed_sum32(seed : UInt, data : Bytes) -> UInt` | Hash bytes with custom seed |

### 64-bit Functions

| Function | Description |
|----------|-------------|
| `sum64(data : Bytes) -> UInt64` | Hash bytes with default seed |
| `seed_sum64(seed : UInt64, data : Bytes) -> UInt64` | Hash bytes with custom seed |

### 128-bit Functions

| Function | Description |
|----------|-------------|
| `sum128(data : Bytes) -> UInt128` | Hash bytes with default seed |
| `seed_sum128(seed : UInt128, data : Bytes) -> UInt128` | Hash bytes with custom seed |

### Streaming API

#### Digest32 Methods
- `new() -> Digest32` - Create new 32-bit hasher
- `new_with_seed(seed : UInt) -> Digest32` - Create new 32-bit hasher with seed
- `write(self, data : Bytes) -> Int` - Add data to hash
- `sum32(self) -> UInt` - Get final hash value
- `reset(self) -> Unit` - Reset hasher state
- `size(self) -> Int` - Get hash size in bytes

#### Digest64 Methods  
- `new() -> Digest64` - Create new 64-bit hasher
- `new_with_seed(seed : UInt64) -> Digest64` - Create new 64-bit hasher with seed
- `write(self, data : Bytes) -> Int` - Add data to hash
- `sum64(self) -> UInt64` - Get final hash value
- `reset(self) -> Unit` - Reset hasher state
- `size(self) -> Int` - Get hash size in bytes

#### Digest128 Methods  
- `new() -> Digest128` - Create new 128-bit hasher
- `new_with_seed(hi : UInt64, lo : UInt64) -> Digest128` - Create new 128-bit hasher with seed
- `write(self, data : Bytes) -> Int` - Add data to hash
- `sum128(self) -> UInt128` - Get final hash value
- `reset(self) -> Unit` - Reset hasher state
- `size(self) -> Int` - Get hash size in bytes

## Algorithm Details

This implementation maintains compatibility with the original MurmurHash3 algorithm while providing MoonBit-specific optimizations:

- **Little Endian Consistency**: Always reads bytes as little endian for cross-platform compatibility
- **Memory Safety**: No unsafe operations, all bounds checking preserved
- **Streaming Support**: Efficient incremental hashing for large datasets
- **Zero-Copy Processing**: Direct bytes processing without intermediate allocations

## Performance Characteristics

- **32-bit hash**: ~4 bytes per hash, fastest option
- **64-bit hash**: ~8 bytes per hash, good balance
- **128-bit hash**: ~16 bytes per hash, best distribution
- **Streaming**: Constant memory usage regardless of input size

## Testing

Run the comprehensive test suite:

```bash
moon test
```

The tests include:
- Reference vectors from original implementation
- Cross-platform compatibility tests  
- Streaming vs one-shot consistency tests
- Edge case validation

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) file for details.

## Credits

This implementation is based on:
- Austin Appleby's original C++ implementation
- Travis Brown's Go port ([github.com/twmb/murmur3](https://github.com/twmb/murmur3))
- Adapted for MoonBit by the MoonBit community

## Contributing

Contributions are welcome! Please ensure all tests pass and follow MoonBit coding conventions.