# Mr. House Audio Setup Guide (macOS)

Since you are on macOS, we can use the high-quality **Apple AudioUnits (AU)** that come pre-installed with your system. No downloads required!

## The Filter Chain

Add these filters to your **Mic/Aux** source in OBS.
(Right-click Audio Source -> Filters -> `+` -> **AudioUnit**)

### 1. Filter: `AUNbandEQ` (Telephone Effect)
This mimics the limited frequency range of an old intercom.

*   **Select AudioUnit:** `Apple: AUNbandEQ`
*   **Settings:**
    *   **Band 1:**
        *   Type: **High Pass**
        *   Frequency: **300 Hz**
    *   **Band 2:**
        *   Type: **Low Pass**
        *   Frequency: **3000 Hz**
*   *Note: If `AUNbandEQ` feels too complex, you can also use `AUParametricEQ` and just cut the lows and highs.*

### 2. Distortion (Optional)
Native Apple distortion allows for grit.

*   **Select AudioUnit:** `Apple: AUDistortion`
*   **Settings:**
    *   **Delay:** **0.1 ms** (Minimum)
    *   **Decay:** **0.1 ms** (Minimum)
    *   **Delay Mix:** **0%**
    *   **Ring Mod:** **0%**
    *   **Decimation:** **10% - 20%** (This adds the digital "grit")
    *   **Soft Clip Gain:** **-6 dB**

### 3. Filter: `AUDelay` (Metallic Resonance)
This creates the "voice inside a metal box" robotic ring.

*   **Select AudioUnit:** `Apple: AUDelay`
*   **Settings:**
    *   **Dry/Wet Mix:** **50%**
    *   **Delay Time:** **0.010** (10ms)
    *   **Feedback:** **15%**
    *   **Lowpass Cutoff:** **15000 Hz** (or default)

### 4. Filter: `AUDynamicsProcessor` (Compressor)
Makes your voice loud, consistent, and "broadcast" ready.

*   **Select AudioUnit:** `Apple: AUDynamicsProcessor`
*   **Settings:**
    *   **Threshold:** **-20 dB** (Adjust until you see reduction text)
    *   **Headroom:** **3 dB**
    *   **Expansion Ratio:** **1.0** (Off)
    *   **Attack Time:** **0.002** (Fast)
    *   **Release Time:** **0.100**

## Summary
The combination of cutting frequencies (EQ), slight digital crushing (Distortion), and tight metallic ringing (Delay) is what creates the signature Mr. House sound.
