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

///|
let logf_off = 0x3f330000U

///|
let logf_table_bits = 4

///|
let logf_n : UInt = 1U << logf_table_bits

///|
priv struct LogfData {
  invc : Array[Double]
  logc : Array[Double]
  ln2 : Double
  poly : Array[Double]
}

///|
let logf_data : LogfData = {
  invc: [
    0x1.661ec79f8f3bep+0, 0x1.571ed4aaf883dp+0, 0x1.49539f0f010bp+0, 0x1.3c995b0b80385p+0,
    0x1.30d190c8864a5p+0, 0x1.25e227b0b8eap+0, 0x1.1bb4a4a1a343fp+0, 0x1.12358f08ae5bap+0,
    0x1.0953f419900a7p+0, 0x1.0p+0, 0x1.e608cfd9a47acp-1, 0x1.ca4b31f026aap-1, 0x1.b2036576afce6p-1,
    0x1.9c2d163a1aa2dp-1, 0x1.886e6037841edp-1, 0x1.767dcf5534862p-1,
  ],
  logc: [
    -0x1.57bf7808caadep-2, -0x1.2bef0a7c06ddbp-2, -0x1.01eae7f513a67p-2, -0x1.b31d8a68224e9p-3,
    -0x1.6574f0ac07758p-3, -0x1.1aa2bc79c81p-3, -0x1.a4e76ce8c0e5ep-4, -0x1.1973c5a611cccp-4,
    -0x1.252f438e10c1ep-5, 0x0.0p+0, 0x1.aa5aa5df25984p-5, 0x1.c5e53aa362eb4p-4,
    0x1.526e57720db08p-3, 0x1.bc2860d22477p-3, 0x1.1058bc8a07ee1p-2, 0x1.4043057b6ee09p-2,
  ],
  ln2: 0x1.62e42fefa39efp-1,
  poly: [-0x1.00ea348b88334p-2, 0x1.5575b0be00b6ap-2, -0x1.ffffef20a4123p-2],
}

///|
#deprecated("use `@math.lnf` instead")
#coverage.skip
pub fn Float::ln(self : Float) -> Float {
  let mut ix : UInt = self.reinterpret_as_int().reinterpret_as_uint()
  if ix == 0x3f800000U {
    return 0.0
  }
  if ix - 0x00800000U >= 0x7f800000U - 0x00800000U {
    if ix * 2 == 0 {
      return neg_infinity
    }
    if ix == 0x7f800000U {
      return self
    }
    if (ix & 0x80000000U) != 0 || ix * 2 >= 0xff000000U {
      return not_a_number
    }
    ix = (self * 0x1.0p23).reinterpret_as_int().reinterpret_as_uint()
    ix -= (23 << 23).reinterpret_as_uint()
  }
  let tmp = ix - logf_off
  let i = ((tmp >> (23 - logf_table_bits)) % logf_n).reinterpret_as_int()
  let k = tmp.reinterpret_as_int() >> 23
  let iz = ix - (tmp & 0xff800000U)
  let invc = logf_data.invc[i]
  let logc = logf_data.logc[i]
  let z = iz.reinterpret_as_int().reinterpret_as_float().to_double()
  let r = z * invc - 1
  let y0 = logc + k.to_double() * logf_data.ln2
  let r2 = r * r
  let y = logf_data.poly[1] * r + logf_data.poly[2]
  let y = logf_data.poly[0] * r2 + y
  let y = y * r2 + (y0 + r)
  y.to_float()
}

///|
#deprecated("use `@math.ln_1pf` instead")
#coverage.skip
pub fn Float::ln_1p(self : Float) -> Float {
  let lg1_f : Float = 0.66666662693
  let lg2_f : Float = 0.40000972152
  let lg3_f : Float = 0.28498786688
  let lg4_f : Float = 0.24279078841
  let float_ln2_hi : Float = 6.9314575195e-01 // 0x3f317200
  let float_ln2_lo : Float = 1.4286067653e-06 // 0x35bfbe8e
  let mut ui : UInt = self.reinterpret_as_uint()
  let mut f : Float = 0
  let mut c : Float = 0
  let mut iu : UInt = 0
  let one : Float = 1.0
  let mut k = 1
  if ui < 0x3ed413d0 || ui >> 31 > 0 {
    if ui >= 0xbf800000 {
      if self == -1.0 {
        return self / 0.0
      }
      return (self - self) / 0.0
    }
    if ui << 1 < 0x33800000U << 1 {
      return self
    }
    if ui <= 0xbe95f619 {
      k = 0
      c = 0.0
      f = self
    }
  } else if ui >= 0x7f800000 {
    return self
  }
  if k > 0 {
    ui = (one + self).reinterpret_as_uint()
    iu = ui
    iu += 0x3f800000U - 0x3f3504f3U
    k = (iu >> 23).reinterpret_as_int() - 0x7f
    if k < 25 {
      let fui = ui.reinterpret_as_float()
      c = if k >= 2 { one - (fui - self) } else { self - (fui - 1.0) }
      c /= ui.reinterpret_as_float()
    } else {
      c = 0.0
    }
    iu = (iu & 0x007fffff) + 0x3f3504f3
    ui = iu
    f = ui.reinterpret_as_float() - 1.0
  }
  let s = f / (f + 2.0)
  let z = s * s
  let w = z * z
  let t1 = w * (lg2_f + w * lg4_f)
  let t2 = z * (lg1_f + w * lg3_f)
  let r = t2 + t1
  let hfsq = f * f * 0.5
  let dk = k.to_float()
  s * (hfsq + r) + (dk * float_ln2_lo + c) - hfsq + f + dk * float_ln2_hi
}
