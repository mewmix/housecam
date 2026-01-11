# Housecam

**Mr. House CRT Effect Shaders**

## OBS Filters
Add these as a **User-Defined Shader** source filter in OBS.

**Tip:** For best results, use **Background Removal / Live Portrait** (specifically the "Lite" model) in OBS *before* applying these shaders to isolate the subject on a black background.


*   **`fallout_terminal.effect`**: Standard Fallout P1 Green Phosphor Terminal.
*   **`fallout_terminal_cinematic.effect`**: **Movie/Cinematic Terminal**. Olive tones, dirty bloom, aged look.
*   **`fallout_terminal_game.effect`**: **Game Version Terminal**. Mint green, clean bloom, high readability.

## Audio Setup (OBS)
To get the authentic "Mr. House" intercom voice easily:
1.  Go to **Tools > Scripts** in OBS.
2.  Click **+** and select **`mrhouse_installer.lua`** from this repo.
3.  Select your Mic source and click **Apply**.
(This automatically creates a native EQ/Distortion/Compressor chain without needing any external plugins.)

**Pro Tip:** To complete the effect, add a **Media Source** playing a looped "vinyl crackle" or "static" sound file on a separate track!

## Web Version
The `index.html` file is a WebGL port of the effect.
Hosted at: [housecam.netlify.app](https://housecam.netlify.app)
