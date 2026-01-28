# Fault-Tolerant Systolic Array (VHDL)

This repository contains a VHDL implementation of a systolic array for matrix multiplication:

C = A × B

The primary goal of this project is to explore fault tolerance in systolic architectures using **Triple Modular Redundancy (TMR)**. The design instantiates three identical systolic arrays operating in parallel and applies majority voting to their outputs to tolerate single faults such as transient errors or timing violations.

This project is intended as an experimental and educational design rather than a production-ready accelerator.

---

## Project Status

**Early Development / Alpha**

This codebase is currently a work in progress. The core dataflow and computation are functional in simulation, but several architectural aspects are incomplete, provisional, or intentionally simplified. Expect breaking changes as the design evolves.

---

## High-Level Overview

The system computes matrix multiplication using a classic systolic array structure:

- Each Processing Element (PE) performs a multiply-accumulate (MAC) operation
- Data propagates horizontally and vertically through the array in a time-skewed fashion
- Three identical arrays operate in parallel
- A majority voter selects the final output when at least two arrays agree

If all three arrays disagree, the result is considered invalid.

---

## Architecture

The design is organized into three conceptual layers:

### 1. Processing Element (PE)

- Core computation unit
- Performs a MAC operation each cycle
- Forwards operands to neighboring PEs (right and bottom)

### 2. Systolic Array / In-Feed Queue

- Manages the flow of input matrices
- Applies skewing so that matrix rows and columns arrive at each PE at the correct time
- Instantiates and connects the grid of Processing Elements

### 3. TMR Top Level

- Instantiates three identical systolic arrays
- Compares their outputs using majority voting:
  - If two or three outputs match, the value is accepted
  - If all three differ, the valid signal is deasserted

---

## Implementation Checklist and Known Limitations

- [ ] **Matrix Accumulator Integration**  
      The `matrix_acc` entity is defined but not yet connected to the main pipeline. Results are currently observed directly from the Processing Elements.

- [ ] **Optimization**  
      The design has not yet been optimized for timing or resource utilization. The current focus is on functional correctness.

- [ ] **Hardcoded Dimensions**  
      The array is currently fixed at 4×4 with 8-bit inputs. Future revisions will replace this with generic parameters.

- [ ] **Reset Strategy**  
      Global reset handling is basic and may not scale well for high-fanout or larger designs.

---

## File Structure

- `systolic_array.vhd`  
  Top-level module. Instantiates the three redundant arrays and implements majority voting logic.

- `in_feed_queue.vhd`  
  Handles input buffering and skewing. Generates the physical grid of Processing Elements.

- `processing_element.vhd`  
  Defines the logic for a single PE (MAC unit).

- `matrix_pkg.vhd`  
  Common package defining array types, constants, and shared definitions.

- `matrix_acc.vhd`  
  Work-in-progress module intended to accumulate and serialize output results.

- `tb_in_feed_queue.vhd`  
  Primary testbench for verifying the matrix multiplication dataflow.

---

## Simulation

### Compilation Order

Compile the VHDL files in the following order:

1. `matrix_pkg.vhd`
2. `processing_element.vhd`
3. `in_feed_queue.vhd`
4. `systolic_array.vhd` (for testing the TMR/voter logic)  
   or  
5. `tb_in_feed_queue.vhd` (for validating the multiplication logic)

### Running the Testbench

Run the simulation using `tb_in_feed_queue.vhd`.

#### Current Test Case

- Input: Two 4×4 matrices filled with the value `16`
- Dot product length: `4`
- Calculation per cell:  
  `16 × 16 × 4`
- Expected output per matrix element: `1024`

---

## Future Work

- Integrate the `matrix_acc` module for structured result readout
- Parameterize matrix dimensions and data width using VHDL generics
- Synthesize the design to evaluate timing and resource usage on real FPGA hardware
- Explore fault injection to validate TMR behavior under error conditions



