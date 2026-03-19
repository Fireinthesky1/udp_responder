////////////////////////////////////////////////////////////////////////////////
//  <mac_tx component to drive 1 RMII lane.>
//  Copyright (C) 2026 James Hicks
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// DETAILS
//
// Responsibilities of this component are transmission of ethernet packets.
// - This component features an RMII interface.
// - This component features a ready/valid input.
// - Once tx_en has asserted this component must output data every clock until
//   the entire packet has been transmitted.
// - The downstream component (PHY) has no ability to apply backpressure.
// - The upstream component is required to provide us data as needed during the
//   transmission of the packet and may not starve this component of data.
// - This component may apply back pressure to the upstream component as needed.
////////////////////////////////////////////////////////////////////////////////

//TODO(HICKS): module in developement

module mac_tx
  (
  // system signals
  input  logic       clk,
  input  logic       reset,
  // Ready/Valid input with sof and eof flags
  output logic       ready,
  input  logic       valid,
  input  logic [7:0] data,
  input  logic       sof,
  input  logic       eof,
  // RMII Egress
  output logic       txen,
  output logic [1:0] txd,
  // Diagnostic output
  output logic       data_starvation
  );

  typedef enum logic [1:0]
  {
    idle_st,
    send_st,
    final_byte_st
  } state_t;

  state_t fsm_state;
  logic handshake;

  // Number of crumbs remaining in the shift register after the next shift.
  logic [1:0] num_crumbs;

  // Used to regiter the input
  logic [7:0] shift_reg;

  assign handshake = ready & valid;
  assign txd       = shift_reg[1:0];

  // Shift register process
  always_ff @(posedge clk) begin
    if (handshake == 1'b1 && txen == 1'b1) begin  // data in and data out
      shift_reg  <= data;
      num_crumbs <= 2'd3; // next time we shift we'll have 3 crumbs left
    end else if (handshake == 1'b1) begin         // just data in
      shift_reg  <= data;
      num_crumbs <= 2'd3; // next time we shift we'll have 3 crumbs left
    end else if (txen == 1'b1) begin              // just data out
      shift_reg  <= {2'b00, shift_reg[7:2]};
      num_crumbs <= num_crumbs - 1;
    end                                           // no data in no data out
  end

  always_ff @(posedge clk) begin
    if (reset == 1'b1) begin
      ready      <= 1'b0;
      txen       <= 1'b0;
      fsm_state  <= idle_st;
    end else if (ready == 1'b1 && valid == 1'b0) begin
      // TODO(HICKS): do we report tx error?
      // data starvation
      data_starvation  <= 1'b1;
      fsm_state        <= idle_st;
    end else begin
      case(fsm_state)
        send_st: begin
          if (handshake == 1'b1 && eof == 1'b1) begin
            fsm_state  <= final_byte_st;
          end

          if (num_crumbs == 2'd1) begin
            // Next clock shift data in and data out
            ready      <= 1'b1;
          end else begin
            ready      <= 1'b0;
          end
        end // case: send_st

        final_byte_st: begin
          if (num_crumbs == 2'd0) begin
            ready     <= 1'b1;
            txen      <= 1'b0;
            fsm_state <= idle_st;
	  end
        end // case: final_byte_st

        default: begin // idle_st
          data_starvation <= 1'b0;   // Clear Data starvation flag.
          ready           <= 1'b1;   // Always ready to receive in idle_st.
          if (handshake == 1'b1 && sof == 1'b1) begin
            ready      <= 1'b0;      // Apply backpressure
            txen       <= 1'b1;      // begin transmission next clock
            fsm_state  <= send_st;   // Go to the send state.
          end // case: idle_st
        end // case: idle_st
      endcase
    end    // if we're not in reset and no data starvation
  end      // always_ff @ (posedge clk)
endmodule  // mac_tx
