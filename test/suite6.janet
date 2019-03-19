# Copyright (c) 2019 Calvin Rose & contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

(import test/helper :prefix "" :exit true)
(start-suite 6)

# some tests for bigint

(def i64 int/s64)
(def u64 int/u64)

(assert-no-error
 "create some uint64 bigints"
 (do
   # from number
   (def a (u64 10))
   # max double we can convert to int (2^53)
   (def b (u64 0x1fffffffffffff))
   (def b (u64 (math/pow 2 53)))
   # from string
   (def c (u64 "0xffff_ffff_ffff_ffff"))
   (def c (u64 "32rvv_vv_vv_vv"))
   (def d (u64 "123456789"))))

(assert-no-error
 "create some int64 bigints"
 (do
   # from number
   (def a (i64 -10))
   # max double we can convert to int (2^53)
   (def b (i64 0x1fffffffffffff))
   (def b (i64 (math/pow 2 53)))
   # from string 
   (def c (i64 "0x7fff_ffff_ffff_ffff"))
   (def d (i64 "123456789"))))

(assert-error
 "bad initializers"
 (do
   # double to big to be converted to uint64 without truncation (2^53 + 1)
   (def b (u64 (+ 0xffff_ffff_ffff_ff 1)))
   (def b (u64 (+ (math/pow 2 53) 1)))
   # out of range 65 bits
   (def c (u64 "0x1ffffffffffffffff"))
   # just to big
   (def d (u64 "123456789123456789123456789"))))

(assert (:== (:/ (u64 "0xffff_ffff_ffff_ffff") 8 2) "0xfffffffffffffff") "bigint operations")
(assert (let [a (u64 0xff)] (:== (:+ a a a a) (:* a 2 2))) "bigint operations")

(assert-error
 "trap INT64_MIN / -1"
 (:/ (int/s64 "-0x8000_0000_0000_0000") -1))

# in place operators
(assert (let [a (u64 1e10)] (:+! a 1000000 "1000000" "0xffff") (:== a 10002065535)) "in place operators")

# int64 typed arrays
(assert (let [t (tarray/new :int64 10)
              b (i64 1000)]
          (set (t 0) 1000)
          (set (t 1) b)
          (set (t 2) "1000")
          (set (t 3) (t 0))
          (set (t 4) (u64 1000))
          (and
           (:== (t 0) (t 1))
           (:== (t 1) (t 2))
           (:== (t 2) (t 3))
           (:== (t 3) (t 4))
           ))
        "int64 typed arrays")



(end-suite)
