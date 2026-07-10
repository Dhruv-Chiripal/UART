# Synthesizable UART Module (9600 Baud)

A modular Verilog HDL implementation of a UART communication core using the standard 8-N-1 format (1 Start bit, 8 Data bits, 1 Stop bit) running on a 100MHz system clock. Features an internal hardware loopback switch for simulation verification.

---

## Hardware Architecture & Mathematics

The project divides a 100MHz clock to drive asynchronous serial communication safely using 16x oversampling:

* **Baud Rate Divisor:** To get a 9600 baud rate with 16x oversampling, the system clock is divided down to 153.6 kHz.
  Divisor = 100,000,000 Hz / (9600 * 16) = 651.04 = approx 651 clock cycles
  (The Baud Generator counts from 0 to 650 to create a single-cycle active-high pulse).

* **Frame Latency:** Every data packet transfers 10 bits total (1 Start + 8 Data + 1 Stop). At 9600 bits per second, the transfer time per byte is:
  Latency = 10 bits / 9600 bps = approx 1.04 ms

* **Clock Drift Tolerance:** Receiver samples data at the absolute center (8th tick out of 16). Accumulating drift across 10 bits allows a specific timing mismatch margin:
  Drift Tolerance = +/- 7.5 ticks / (10 bits * 16 ticks) = approx +/- 4.68%

---

## File Structure

* `baud_gen.v`: 10-bit synchronous counter generating the **16x oversampling ticks** (153.6 kHz).
* `uart_tx.v`: 4-state Finite State Machine converting parallel bytes to serial streams.
* `uart_rx.v`: Receiver FSM utilizing **mid-bit oversampling** for data recovery.
* `uart_top.v`: Structural wrapper integrating TX, RX, and a **Loopback MUX** (`loopen = 1` for self-testing).
* `uart_tb.v`: Testbench providing custom stimuli with automatic `$monitor` tracking.

---

## Simulation Checklist

1. Load all design sources and the simulation source into Xilinx Vivado.
2. Click **Run Behavioral Simulation**.
3. Set the simulation runtime target to **3 ms** in the toolbar and hit the Run For button.
4. Verify `tx_pin` serial modulation and check that `rx_data` updates from `00` to `41` (Hex for 'A') and `5A` (Hex for 'Z') right after each **1.04 ms** boundary.
