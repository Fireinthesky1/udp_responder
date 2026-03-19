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

*  **Interfaces** Ready-Valid RMII

## Interface
| name | direction | width | description |
| :--- | :-------- | :---- | :---------- |
| `clk` | Input | 1 | System clock |
| `reset` | Input | 1 | Active High Reset |
| `ready` | Output | 1 | As per ready\_valid.md |
| `valid` | Input | 1 | As per ready\_valid.md |
| `sof` | Input | 1 | As per ready\_valid.md |
| `eof` | Input | 1 | As per ready\_valid.md |
| `tx_en` | Output | 1 | When high, data is clocked on `txd` to the transmitter |
| `tdx` | Output | 2 | Data crumb to be transmitted lsb first |
