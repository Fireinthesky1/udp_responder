################################################################################
##  <Test Bench for mac_tx component.>
##  Copyright (C) 2026 James Hicks
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <https://www.gnu.org/licenses/>.
################################################################################

# TODO(HICKS): Something is wrong. The simulation should be driving new data
#              concurrent with driving the valid signal. Instead it's waiting
#              a clock

# TODO(HICKS): Something is wrong. The sequencer plumbing is not working
#              correctly.
#              We drive an item
#              We put it in the queue
#              But the item never gets finished (print statement on line 228)


import random

import pyuvm
from pyuvm import *

import cocotb
from cocotb.queue import Queue, QueueEmpty
from cocotb.triggers import FallingEdge, RisingEdge
from cocotb.clock import Clock

################################################################################
# MAC TX TESTS
################################################################################
@pyuvm.test()
class MacTxTest(uvm_test):
    def build_phase(self):
        self.env = MacTxEnv("env", self)

    def end_of_elaboration_phase(self):
        self.test_sequence = TestSequence.create("test_sequence")

    async def run_phase(self):
        self.raise_objection()
        await self.test_sequence.start()
        self.drop_objection()

################################################################################
# MacTxEnv uvm environment
################################################################################
class MacTxEnv(uvm_env):
    def build_phase(self):
        self.clk_drv = Clock(cocotb.top.clk, 2, "us")
        cocotb.start_soon(self.clk_drv.start())
        self.sequencer         = uvm_sequencer("sequencer",self)
        ConfigDB().set(None, "*", "SEQUENCER", self.sequencer)
        self.driver            = Driver.create("driver",self)
        self.rv_mon            = Monitor("rv_mon", self, "get_rv_transaction")
        self.rmii_mon          = Monitor("tx_rmii_mon", self, "get_tx_rmii_transaction")
        self.scoreboard        = Scoreboard("scoreboard", self)

    def connect_phase(self):
        # conect the sequencer to the driver
        self.driver.seq_item_port.connect(self.sequencer.seq_item_export)

        # connect the ready valid monitor to the scoreboard to collect data sent
        self.rv_mon.ap.connect(self.scoreboard.rv_export)

        # connect the rmii monitor to the scoreboard to collect data transmitted
        self.rmii_mon.ap.connect(self.scoreboard.tx_rmii_export)

        # connect the driver to scoreboard to collect DUT responses to stimulus
        # self.driver.ap.connect(self.scoreboard.rv_export)

class Monitor(uvm_component):
    """Creates an analysis port and writes the data it gets into that port."""
    def __init__(self, name, parent, method_name):
        super().__init__(name, parent)
        self.method_name = method_name

    def build_phase(self):
        self.ap = uvm_analysis_port("ap", self)
        self.bfm = mac_tx_bfm()
        # get a pointer to the "Get" function from Bus Functional Model
        # This allows the monitor to call the "Get Handshake" function of the
        # ready valid interface monitor and the "Get Transaction" function of
        # TX RMII interface monitor
        self.get_method = getattr(self.bfm, self.method_name)

    async def run_phase(self):
        while True:
            # await the next sequence item from the interface
            data_monitored = await self.get_method()
            # announce what we just monitored
            self.logger.debug(f"MONITORED {data_monitored}")
            # write the data to the scoreboard
            self.ap.write(data_monitored)

class Scoreboard(uvm_component):
    """
    Receives transations and handshakes from both monitors and directly compares
    them. RMII sends data out crumb by crumb so for every 4 crumbs sent over
    RMII we compare with the corresponding byte from the ready valid interface.
    """
    def build_phase(self):
        self.rv_fifo          = uvm_tlm_analysis_fifo("rv_fifo", self)
        self.tx_rmii_fifo     = uvm_tlm_analysis_fifo("tx_rmii_fifo", self)

        # TODO what do these do?
        self.rv_get_port      = uvm_get_port("rv_get_port", self)
        self.tx_rmii_get_port = uvm_get_port("tx_rmii_get_port", self)

        self.rv_export        = self.rv_fifo.analysis_export
        self.tx_rmii_export   = self.tx_rmii_fifo.analysis_export

    def connect_phase(self):
        self.rv_get_port.connect(self.rv_fifo.get_export)
        self.tx_rmii_get_port.connect(self.tx_rmii_fifo.get_export)

    # check phase occurs after run phase. This means we have all of the
    # transactions in both fifos.
    def check_phase(self):
        while self.rv_get_port.can_get():
            ok_1, crumb_1 = self.tx_rmii_get_port.try_get()
            ok_2, crumb_2 = self.tx_rmii_get_port.try_get()
            ok_3, crumb_3 = self.tx_rmii_get_port.try_get()
            ok_4, crumb_4 = self.tx_rmii_get_port.try_get()
            output_byte = (crumb_4 << 6) | (crumb_3 << 4) | (crumb_2 << 2) | crumb_1
            ok_rv, input_byte  = self.rv_get_port.try_get()
            if input_byte == output_byte:
                self.logger.info(f"PASSED: 0x{input_byte:02x} == 0x{output_byte:02x}")
            else:
                self.logger.error(f"FAILED: 0x{input_byte:02x} != 0x{output_byte:02x}")

class RVSeqItem(uvm_sequence_item):
    """A ready valid sequence item."""
    def __init__(self, name, valid, data, sof, eof):
        super().__init__(name)
        # ready is driven by the UUT.
        self.valid: int = valid
        self.data:  int = data
        self.sof:   int = sof
        self.eof:   int = eof

    def randomize(self):
        self.data = random.randint(0,255)

    def __eq__(self, other):
        same = self.valid == other.valid and self.data == other.data and \
               self.sof == other.sof and self.eof == other.eof
        return same

    def __str__(self):
            return f"RVSeqItem: valid: {self.valid} \
            data: {self.data} \
            sof: {self.sof} \
            eof: {self.eof}"

class TestSequence(uvm_sequence):
    async def body(self):
        sequencer = ConfigDB().get(None,"","SEQUENCER")
        random_frame = RVSeq("MY RANDOM FRAME")
        await random_frame.start(sequencer)

class RVSeq(uvm_sequence):
    """Generate a frame of random length and random content."""
    async def body(self):
        # 1500 is max size of basic ethernet frames
        frame_length = random.randint(1, 1500)
        for i in range(0,frame_length):
            if i == 0:              # first item of the frame
                item = RVSeqItem("item", 1, 0xFF, 1, 0)
                item.randomize()
                await self.start_item(item)
                item.randomize()
                await self.finish_item(item)
            elif i == frame_length-1: # last item in the frame
                item = RVSeqItem("item", 1, None, 0, 1)
                await self.start_item(item)
                item.randomize()
                await self.finish_item(item)
            else:                   # all other items of the frame
                item = RVSeqItem("item", 1, None, 0, 0)
                await self.start_item(item)
                item.randomize()
                await self.finish_item(item)

class Driver(uvm_driver):

    def build_phase(self):
        self.ap = uvm_analysis_port("ap", self)

    def start_of_simulation_phase(self):
        self.bfm = mac_tx_bfm()

    async def launch_tb(self):
        await self.bfm.reset(5) # start simulation by resetting for 5 clocks
        self.bfm.start_bfm()

    async def run_phase(self):
        await self.launch_tb()
        while True:
            # Get a new sequence item
            item       = await self.seq_item_port.get_next_item()
            print("GOT AN ITEM")

            # Drive it to the DUT
            await self.bfm.drive_ready_valid_word(item.valid, item.data, \
                                                  item.sof, item.eof)
            print("WE DROVE IT")

            # Wait for the DUT to consume it
            response = await self.bfm.get_rv_transaction()
            print("WE GOT A RESPONSE")

            self.ap.write(response)
            print("WE WROTE THE RESPONSE")

            self.seq_item_port.item_done()
            print("THE ITEM IS DONE")

################################################################################
# Bus functional model of the mac_tx RTL component
################################################################################
class mac_tx_bfm(metaclass=Singleton):
    def __init__(self):
        self.dut                       = cocotb.top
        self.driver_queue              = Queue(maxsize=1)
        self.ready_valid_monitor_queue = Queue(maxsize=0)
        self.tx_rmii_monitor_queue     = Queue(maxsize=0)

    async def drive_ready_valid_word(self, valid, data, sof, eof):
        ready_valid_tuple = (valid, data, sof, eof)
        await self.driver_queue.put(ready_valid_tuple)

    async def get_rv_transaction(self):
        rv_transaction = await self.ready_valid_monitor_queue.get()
        return rv_transaction

    async def get_tx_rmii_transaction(self):
        crumb = await self.tx_rmii_monitor_queue.get()
        return crumb

    async def reset(self, num_clocks):
        await RisingEdge(self.dut.clk)
        self.dut.reset.value = 1 # set the reset pin high
        for i in range(0,num_clocks): # wait for num_clocks
            await RisingEdge(self.dut.clk)
        self.dut.reset.value = 0 # set the reset pin low again
        # The next time we move the simulation time forward reset will be low

    async def driver_bfm(self):
        # DUT inputs
        self.dut.valid.value  = 0
        self.dut.data.value   = 0
        self.dut.sof.value    = 0
        self.dut.eof.value    = 0
        self.current_sequence_item = None
        while True:
            await RisingEdge(self.dut.clk)
            if self.current_sequence_item is None:
                print("HERE IN THE DRIVER")
                try:
                    self.current_sequence_item = self.driver_queue.get_nowait()
                    self.dut.valid.value       = self.current_sequence_item[0]
                    self.dut.data.value        = self.current_sequence_item[1]
                    self.dut.sof.value         = self.current_sequence_item[2]
                    self.dut.eof.value         = self.current_sequence_item[3]
                except QueueEmpty:
                    print("This is exceptional")

    async def ready_valid_monitor_bfm(self):
        while True:
            await RisingEdge(self.dut.clk)
            ready = self.dut.ready.value
            valid = self.dut.valid.value
            if ready == 1 and valid == 1:         # A handshake has occured
                print("HERE IN THE MONITOR")
                data = int(self.dut.data.value)   # capture the data
                print(data)
                self.dut.valid.value = 0          # Invalid till new data
                self.ready_valid_monitor_queue.put_nowait(data)
                print("AND ALSO HERE IN THE MONITOR")
                self.current_sequence_item = None # item consumed

    async def tx_rmii_monitor_bfm(self):
        # a transaction occurs on tx_rmii every clock that txen is high
        while True:
            await RisingEdge(self.dut.clk)
            txen = self.dut.txen.value
            if txen == 1:
                crumb = int(self.dut.txd.value) # Only care about data crumb
                self.tx_rmii_monitor_queue.put_nowait(crumb)

    def start_bfm(self):
        cocotb.start_soon(self.driver_bfm())
        cocotb.start_soon(self.ready_valid_monitor_bfm())
        cocotb.start_soon(self.tx_rmii_monitor_bfm())
