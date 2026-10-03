# Photoshop Spot Channel Check — Preflight Spot & Alpha Channels

A small Photoshop prepress utility for answering a deceptively annoying question:

**What channels are actually inside this file?**

Run the script and get a compact report of the document's **spot channels, alpha channels, empty channels, and color mode** without clicking through the Channels panel one channel at a time.

## What it checks

**Spot Channel Check** scans the open Photoshop document and reports:

- every real **Spot Color channel**
- every regular **alpha channel**
- empty channels
- other non-component channels that may need attention
- the document color mode

Spot channels with content are marked **OK**. Empty channels are marked **EMPTY**. Alpha and unusual channels are surfaced for inspection rather than silently treated as print separations.

The script does not guess what your RIP expects and does not declare a spot name “correct” or “incorrect.” A channel called `White`, `Spot 1`, `Varnish`, `Pantone 186 C`, or something custom may all be valid depending on the production workflow.

## Why this is useful

Production files accumulate surprises.

A supplied PSD or TIFF may contain a correctly prepared spot white separation, an old alpha mask left behind by the designer, an empty varnish channel, or several special-color channels whose names matter downstream.

Instead of manually isolating channels just to understand the file structure, run one check before the artwork moves further into prepress.

Typical uses include:

- **spot color preflight in Photoshop**
- checking **white ink / spot white channels**
- inspecting **Pantone and special-ink separations**
- finding forgotten **alpha channels**
- catching **empty spot channels**
- checking PSD/TIFF production files before RIP or handoff
- prepress troubleshooting for UV, flatbed, DTF/DTG, screen and specialty printing workflows

## Example report

```text
SPOT CHANNEL CHECK

Document mode: CMYK

Spot channels:
White — OK
Pantone 186 C — OK
Varnish — OK

Alpha channels:
Alpha 1 — CHECK

Empty channels:
None

3 spot channels found.
```

## Safe by design

This is an **inspection tool**.

It does not rename, delete, create, fill, convert, flatten, save, or print anything. Existing artwork and channels remain untouched.

## Install

Place `Spot_Channel_Check.jsx` in Photoshop's Scripts folder and restart Photoshop. Then run:

`File → Scripts → Spot_Channel_Check`

You can also run it directly through:

`File → Scripts → Browse...`

## Production note

The report describes what Photoshop can see in the file. It does not replace RIP-specific preflight, trapping, separation preview, overprint checks, or the production requirements supplied by the print provider.

## Status

**First public prototype.**

Built for fast inspection of Photoshop production files before they become somebody else's problem.

## Contact

Questions, feedback, or custom workflow requests: **usta.scripts@gmail.com**
