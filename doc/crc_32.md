# CRC 32
This takes in 8-bit data and outputs a 32-bit CRC value.

## Overview
The `crc_32` module computes the CRC value by performing the following steps:
1. Pad 32-bits to the right of the input data.
2. Perform modulo-2 binary division.
3. Store the remainder of the modulo-2 binary division as the CRC.


## Implementation
The algorithm used is the algorithm described by Ross N. Williams in
"A painless guide to CRC error detection algorithms". The CRC register flows
from right to left.


## Timing
TODO: Latency
TODO: Throughput
TODO: discuss init signal.
TODO: discuss valid signal.
TODO: discuss en signal.
