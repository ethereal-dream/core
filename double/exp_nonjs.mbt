// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
// origin: FreeBSD /usr/src/lib/msun/src/s_expm1.c
// ====================================================
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunSoft, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.
// ====================================================
//

///|
#deprecated("use `@math.exp` instead")
#coverage.skip
pub fn Double::exp(self : Double) -> Double {
  fn get_high_word(x : Double) -> UInt {
    (x.reinterpret_as_uint64() >> 32).to_uint()
  }

  fn get_low_word(x : Double) -> UInt {
    x.reinterpret_as_uint64().to_uint()
  }

  fn insert_words(ix0 : UInt64, ix1 : UInt64) -> Double {
    let mut bits : UInt64 = 0
    bits = bits | (ix0 << 32)
    bits = bits | ix1
    bits.reinterpret_as_double()
  }

  let mut x = self
  let one = 1.0
  let halF = [0.5, -0.5]
  let o_threshold = 7.09782712893383973096e+02
  let u_threshold = -7.45133219101941108420e+02
  let ln2HI = [6.93147180369123816490e-01, -6.93147180369123816490e-01]
  let ln2LO = [1.90821492927058770002e-10, -1.90821492927058770002e-10]
  let invln2 = 1.44269504088896338700e+00
  let p1 = 1.66666666666666019037e-01
  let p2 = -2.77777777770155933842e-03
  let p3 = 6.61375632143793436117e-05
  let p4 = -1.65339022054652515390e-06
  let p5 = 4.13813679705723846039e-08
  let e = 2.718281828459045
  let mut hi = 0.0
  let mut lo = 0.0
  let huge = 1.0e+300
  let twom1000 = 9.33263618503218878990e-302
  let two1023 = 8.988465674311579539e307
  let mut k : Int = 0
  let mut hx : UInt = get_high_word(self)
  let xsb : Int = ((hx >> 31) & 1).reinterpret_as_int()
  hx = hx & 0x7FFFFFFF
  if hx >= 0x40862E42 {
    if hx >= 0x7FF00000 {
      let lx : UInt = get_low_word(self)
      if ((hx & 0xFFFFF) | lx) != 0 {
        return self + self
      } else if xsb == 0 {
        return self
      } else {
        return 0.0
      }
    }
    if self > o_threshold {
      return huge * huge
    }
    if self < u_threshold {
      return twom1000 * twom1000
    }
  }
  if hx > 0x3FD62E42 {
    if hx < 0x3FF0A2B2 {
      if self == 1.0 {
        return e
      }
      hi = self - ln2HI[xsb]
      lo = ln2LO[xsb]
      k = 1 - xsb - xsb
    } else {
      k = (invln2 * self + halF[xsb]).to_int()
      let t = k.to_double()
      hi = self - t * ln2HI[0]
      lo = t * ln2LO[0]
    }
    x = hi - lo
  } else if hx < 0x3E300000 {
    if huge + x > one {
      return one + x
    }
  } else {
    k = 0
  }
  let t = x * x
  let twopk = if k >= -1021 {
    insert_words(
      (0x3FF00000 + (k.reinterpret_as_uint() << 20).reinterpret_as_int())
      .to_int64()
      .reinterpret_as_uint64(),
      0,
    )
  } else {
    insert_words(
      0x3FF00000UL + ((k + 1000).reinterpret_as_uint() << 20).to_uint64(),
      0,
    )
  }
  let c = x - t * (p1 + t * (p2 + t * (p3 + t * (p4 + t * p5))))
  if k == 0 {
    return one - (x * c / (c - 2.0) - x)
  }
  let y = one - (lo - x * c / (2.0 - c) - hi)
  if k >= -1021 {
    if k == 1024 {
      return y * 2.0 * two1023
    } else {
      return y * twopk
    }
  } else {
    return y * twopk * twom1000
  }
}

///|
#deprecated("use `@math.expm1` instead")
#coverage.skip
pub fn Double::expm1(self : Double) -> Double {
  if self.is_nan() {
    return not_a_number
  }
  let o_threshold = 7.09782712893383973096e+02
  if self > o_threshold {
    return infinity
  }
  if self.is_inf() {
    return -1.0
  }
  let huge = 1.0e+300
  let tiny = 1.0e-300
  let ln2_hi = 6.93147180369123816490e-01
  let ln2_lo = 1.90821492927058770002e-10
  let invln2 = 1.44269504088896338700e+00
  let q1 = -3.33333333333331316428e-02
  let q2 = 1.58730158725481460165e-03
  let q3 = -7.93650757867487942473e-05
  let q4 = 4.00821782732936239552e-06
  let q5 = -2.01099218183624371326e-07
  let mut x = self
  let mut hx = get_high_word(x)
  let xsb : Int = (hx & 0x80000000).reinterpret_as_int()
  let mut y : Double = if xsb == 0 { x } else { -x }
  hx = hx & 0x7fffffff
  if hx >= 0x4043687A {
    if xsb != 0 {
      if x + tiny < 0.0 {
        return tiny - 1.0
      }
    }
  }
  let mut hi = 0.0
  let mut lo = 0.0
  let mut k = 0
  let mut c = 0.0
  let mut t = 0.0
  if hx > 0x3fd62e42 {
    if hx < 0x3FF0A2B2 {
      hi = if xsb == 0 { x - ln2_hi } else { x + ln2_hi }
      lo = if xsb == 0 { ln2_lo } else { -ln2_lo }
      k = if xsb == 0 { 1 } else { -1 }
    } else {
      k = (invln2 * x + (if xsb == 0 { 0.5 } else { -0.5 })).to_int()
      t = k.to_double()
      hi = x - t * ln2_hi
      lo = t * ln2_lo
    }
    x = hi - lo
    c = hi - x - lo
  } else if hx < 0x3c900000 {
    t = huge + x
    return x - (t - (huge + x))
  } else {
    k = 0
  }
  let hfx : Double = 0.5 * x
  let hxs : Double = x * hfx
  let r1 : Double = 1.0 +
    hxs * (q1 + hxs * (q2 + hxs * (q3 + hxs * (q4 + hxs * q5))))
  let t : Double = 3.0 - r1 * hfx
  let e : Double = hxs * ((r1 - t) / (6.0 - x * t))
  if k == 0 {
    return x - (x * e - hxs)
  } else {
    let e : Double = x * (e - c) - c
    let e : Double = e - hxs
    if k == -1 {
      return 0.5 * (x - e) - 0.5
    }
    if k == 1 {
      return if x < -0.25 {
        -2.0 * (e - (x + 0.5))
      } else {
        1.0 + 2.0 * (x - e)
      }
    }
    if k <= -2 || k > 56 {
      y = 1.0 - (e - x)
      y = set_high_word(y, get_high_word(y) + (k << 20).reinterpret_as_uint())
      return y - 1.0
    }
    let mut t : Double = 1.0
    if k < 20 {
      t = set_high_word(0, (0x3ff00000 - (0x200000 >> k)).reinterpret_as_uint())
      y = t - (e - x)
      y = set_high_word(y, get_high_word(y) + (k << 20).reinterpret_as_uint())
    } else {
      t = set_high_word(0, ((0x3ff - k) << 20).reinterpret_as_uint())
      y = x - (e + t) + 1.0
      y = set_high_word(y, get_high_word(y) + (k << 20).reinterpret_as_uint())
    }
  }
  y
}
