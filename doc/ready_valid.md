# Ready-Valid Communication Protocol
This document specifies the Ready-Valid protocol.

## Overview
The Ready-Valid protocol is a synchronous communication protocol in which
data is transmitted when the transmitter declares the data `valid` and the
receiver delares that they are `ready`. Data is "transmitted" each rising
edge of the `clk` in which signals `ready` and `valid` are asserted.

## Framed Ready-Valid
Optional flags `sof` and `eof` can be added to the protocol with the following
requirements:
* `sof` shall assert for exactly one transaction per "frame".
* `sof` shall de-assert on the rising edge of `clk` following a transaction.
* Consecutive assertions of `eof` before `sof` shall be ignored.
* `sof` and `eof` may assert concurrently indicating a frame of length 1.

## Signals
| name | width | description |
| :--- | :---- | :---------- |
| `clk` | 1 | System clock |
| `ready` | 1 | Active high; indicates receiver is "ready" to receive data. |
| `valid` | 1 | Active high; indicates the data to be transmitted is "valid" |
| `data` | variable | Data to be transmitted. |
| `sof` | 1 | Optional flag indicating the start of a "frame" of data. |
| `eof` | 1 | Optional flag indicating the end of a "frame" of data. |
