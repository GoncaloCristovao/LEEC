# Ultrasonic Non-Destructive Testing (NDT) System for Wind Turbine Blades

This repository contains the engineering work developed for the **Capstone Project (Licenciatura em Engenharia Eletrotécnica)** at the University of Aveiro (DETI). The project aimed to build an automated, non-destructive inspection system for internal flaw detection and structural integrity assessment of wind turbine composite blades.

>  **Live Demonstrations & Hardware Prototypes:**  
> Check experimental testing, field validations, and hardware videos on Instagram:  
> 🔗 **[@winspect_deti](https://www.instagram.com/winspect_deti/)**

---

##  Role & Scope: Hardware & Acoustic Modeling

While the overall platform integrated robotic/machine learning classification pipelines, my individual responsibility was the **complete physical and hardware front-end**:
1. Acoustic velocity modeling and layer impedance calculation across composite substrates.
2. Selection and characterization of the **5 MHz ultrasonic transducer**.
3. Analog signal conditioning: high-frequency preamplification, input protection, and a **6th-order Butterworth bandpass filter**.
4. Benchtop implementation, LTspice simulation, and oscilloscope characterization.

---

##  Acoustic Analysis & Frequency Selection (5 MHz)

To reliably resolve internal defects and boundaries in multi-layer composites (fiberglass and epoxy resin), acoustic propagation parameters were analytically modeled and validated via MATLAB:

* **Longitudinal Wave Velocity ($V_L$):**
  * **Fiberglass ($V_L \approx 5705\,\text{m/s}$):** Modeled considering material density ($\rho = 2540\,\text{kg/m}^3$), Young's modulus ($E = 72.4\,\text{GPa}$), and Poisson ratio ($\nu = 0.22$).
  * **Epoxy Resin ($V_L \approx 1673\,\text{m/s}$):** Modeled as isotropic matrix ($\rho = 1250\,\text{kg/m}^3$, $E = 3.5\,\text{GPa}$).
* **Frequency Trade-off:** A **5 MHz central frequency** was chosen to balance spatial resolution (resolving millimetric layer thickness and delamination) against material attenuation ($\alpha = 25\text{--}40\,\text{dB/m}$).
* **Reflection & Time-of-Flight:** Developed algorithms to predict acoustic impedance mismatches ($Z = \rho \cdot V_L$), reflection coefficients ($R$), and boundary echo returns.

---

##  Analog Front-End & Receiver Circuit Design

The ultrasonic echo signals returned from composite defects feature microvolt/millivolt amplitudes with high background noise. A dedicated acquisition chain was developed:

### 1. High-Frequency Preamplifier Stage
* **Core OpAmp:** Analog Devices **AD8038** (350 MHz bandwidth, ultra-low noise, high slew rate).
* **Input Clamping & Protection:** Back-to-back fast switching diodes (1N4148) to protect the amplifier inputs against high-voltage excitation pulses.
* **AC Coupling:** Integrated DC-blocking capacitance for stable bias points.
* **Common-Emitter Booster Stage:** Incorporated an NPN stage with degeneration resistor ($R_E$) to improve linearity, suppress harmonic distortion, and deliver high composite voltage gain ($A_v \approx 80\,\text{V/V}$).

### 2. 6th-Order Butterworth Bandpass Filter
* **Design Specifications:** Centered around $f_0 \approx 5\,\text{MHz}$ with a passband bandwidth of $\approx 1\,\text{MHz}$ ($-3\,\text{dB}$ cutoffs between $4.28\,\text{MHz}$ and $5.21\,\text{MHz}$).
* **Topology:** Multi-stage active LC/OpAmp bandpass architecture delivering flat passband response and rapid roll-off ($-40\,\text{dB}$ rejection outside the operating window).
* **Noise Suppression:** Filter simulation with injected white noise verified extraction of clear sinusoidal echo returns.

### 3. Prototyping & Laboratory Validation
* Full schematics and transient/Bode frequency response simulated in **LTspice**.
* Surface-mount (SOIC) component adaptation using custom breakout PCBs to enable breadboard characterization.
* Verified experimental gain ($A_{v,\text{practical}} \approx 3.96\,\text{V/V}$ vs $3.64\,\text{V/V}$ theoretical) on digital storage oscilloscopes.

---

##  Tools & Technologies

* **Simulation & Hardware Design:** LTspice, Custom SMT adapter boards, Breadboard prototyping
* **Acoustic & Numerical Modeling:** MATLAB (impedance matching, reflection coefficients, attenuation models)
* **Instrumentation & Test Equipment:** Tektronix Digital Storage Oscilloscopes, High-Frequency Signal Generators, Benchtop Power Supplies
* **Hardware Components:** AD8038, AD8091, 1N4148, RF Inductors/Capacitors, 5 MHz Ultrasonic Transducers
