#valtype
pub(all) struct UInt128(UInt64, UInt64)

///|
/// Create a UInt128 from two UInt64 values (high, low)
pub fn UInt128::new(high : UInt64, low : UInt64) -> UInt128 {
  UInt128(high, low)
}

///|
/// Get the high 64 bits
pub fn UInt128::high(self : UInt128) -> UInt64 {
  let UInt128(high, _low) = self
  high
}

///|
/// Get the low 64 bits  
pub fn UInt128::low(self : UInt128) -> UInt64 {
  let UInt128(_high, low) = self
  low
}
