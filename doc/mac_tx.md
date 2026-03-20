# MAC TX
This component accepts data on a "ready-valid" input interface then transmits
that data over an RMII interface to an ethernet PHY transmitter.

## Overview
The `mac_tx` module facilitates the transmission of data to the PHY transmitter.
Frames are transmitted one crumb (two bits) at a time from least significant bit
to most significant bit. The upstream component shall not starve this component
of data. Once tx\_en asserts this component shall output data every clock cycle
until the entire frame has been transmitted. This component shall report
data\_starvation.

## Frame Check Sequence
TODO

## Interface
| name | direction | width | description |
| :--- | :-------- | :---- | :---------- |
| `clk` | Input | 1 | System clock |
| `reset` | Input | 1 | Active High Reset |
| `ready` | Output | 1 | As per ready\_valid.md |
| `valid` | Input | 1 | As per ready\_valid.md |
| `sof` | Input | 1 | As per ready\_valid.md |
| `eof` | Input | 1 | As per ready\_valid.md |
| `tx_en` | Output | 1 | Transmit Enable. As per RMII. |
| `txd` | Output | 2 | Transmit Data. As per RMII. |

## Test Plan
A test case shall verify every requirement of the component.
### Requirements
* This component shall be capable of streaming frames of data to the PHY
  transmitter.
* This component shall report data starvation.
* This component complies with the RMII standard.
  * `tx_en` shall be asserted synchronously with the first nibble of the
	preamble and shall remain asserted while all crumbs to be transmitted
	are presented.
  * `tx_en` shall de-assert prior to the first rising edge of `clk` following
	the final crumb of the frame.
  * `txd` shall be "00" to indicate idle when `tx_en` is de-asserted.
### Test Cases
* Continually stream minimum length ethernet frames: 64 bytes.
  * Verify that the data sent is received.
  * Verify that, during the interframe gap, `txd` is "00".
* Continually stream maximum length ethernet frames: 1500 bytes.
  * Verify that the data sent is received.
  * Verify that, during the interframe gap, `txd` is "00".
* Starve the interface
  * Verify that the component reports data starvation.
* Send a minimum length ethernet frame: 64 bytes
  * Verify that `tx_en` is asserted for the duration of transmission.
