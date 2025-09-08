# Rayleigh DBPSK OFDM Simulation

![GitHub repo size](https://img.shields.io/github/repo-size/AlbertoMarquillas/rayleigh-dbpsk-ofdm-simulation)
![GitHub license](https://img.shields.io/github/license/AlbertoMarquillas/rayleigh-dbpsk-ofdm-simulation)
![GitHub last commit](https://img.shields.io/github/last-commit/AlbertoMarquillas/rayleigh-dbpsk-ofdm-simulation)
![GitHub issues](https://img.shields.io/github/issues/AlbertoMarquillas/rayleigh-dbpsk-ofdm-simulation)

---

## 📖 Overview

This project implements MATLAB simulations of **hostile wireless channels**, focusing on:

- **Rayleigh fading** with Doppler shift and delay spread.
- **Channel parameter extraction** (delay, coherence time, coherence bandwidth).
- **DBPSK** modulation and demodulation.
- **OFDM** modulation with multiple subcarriers.
- **BER vs. SNR and bitrate analysis**.

---

## 📂 Repository Structure

```
├─ src/               # MATLAB source code (channel, DBPSK, OFDM, PN, etc.)
├─ test/              # Validation and smoke tests
├─ docs/
│  ├─ assets/         # Figures, plots, channel visualizations
│  └─ specs/          # Original handout / context brief
├─ tools/             # Scripts to launch simulations
├─ build/             # Output figures, temporary results (ignored)
└─ README.md
```

---

## ⚙️ Getting Started

### Requirements
- MATLAB R2023a or later
- Communications System Toolbox

### Run Example
```matlab
cd src
Practica_Hostils
```
This runs a Rayleigh channel simulation with DBPSK modulation and produces BER vs. SNR plots.

---

## 🎮 Usage
- **Channel simulation**: generate PN sequences, apply Rayleigh fading with Doppler/delay.
- **Modulation**: DBPSK and OFDM schemes implemented in MATLAB scripts.
- **Performance analysis**: run BER vs. SNR/bitrate sweeps.
- **Visualization**: scattering function, transfer function, BER curves.

---

## 📊 Features
- End-to-end hostile channel simulation
- BER analysis under fading and noise
- OFDM multi-carrier transmission
- Modular MATLAB scripts for reproducibility

---

## 🧪 Tests & Validation
- **Smoke test**: ensure scripts run and generate plots in `/build/`.
- **BER validation**: compare theoretical vs. simulated BER for DBPSK.
- **OFDM validation**: confirm subcarrier parallelism and BER improvement.

---

## 📝 What I Learned
- Modeling Rayleigh fading channels in MATLAB
- Extracting channel parameters (Doppler, delay spread)
- Trade-offs between DBPSK and OFDM in hostile conditions
- Structuring MATLAB academic work into a professional repository

---

## 🚀 Roadmap
- [ ] Add smoke test script under `/test/`
- [ ] Automate plot exports into `/build/`
- [ ] Add OFDM multi-carrier BER vs. SNR analysis
- [ ] Compare with alternative modulation schemes (QPSK, 16-QAM)

---

## 📜 License
This project is licensed under the [MIT License](LICENSE).
