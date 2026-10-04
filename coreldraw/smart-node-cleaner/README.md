# CorelDRAW Smart Node Cleaner — Experimental v0.1

Experimental VBA macro for reducing redundant nodes in CorelDRAW curves while comparing every candidate result against the **unchanged original geometry**.

## Why

Converted text, imported vectors and traced artwork can contain absurd numbers of nodes that contribute little or nothing to the actual shape. CorelDRAW can reduce nodes automatically, but the order in which nodes are removed can affect the resulting curve.

This prototype uses a greedy approach:

1. Keep the original curve untouched as the reference.
2. Duplicate the working curve.
3. Try removing every currently removable node.
4. Measure the resulting curve against the original in both directions.
5. Permanently remove the candidate with the smallest geometric error.
6. Repeat until no candidate remains within the requested tolerance.

It does **not** use CorelDRAW AutoReduce as its simplification algorithm.

## Status

**Experimental prototype — not production tested.**

Currently intended for CorelDRAW 2018 / VBA and one selected Curve object.

The v0.1 geometry check uses dense sampling and point-to-segment distance. It prioritizes easy inspection and correctness testing over speed. Large curves may be slow.

## First test

Select one Curve object and run:

`UstaSmartNodeCleaner`

Start with a conservative maximum deviation such as:

`0.01 mm`

The selected original is left untouched. The macro creates and simplifies a duplicate beside it so the result can be inspected against the source.

## Current limitations

- One selected Curve object at a time.
- Experimental geometry sampling.
- No adaptive Bezier subdivision yet.
- No polished preview UI yet.
- Large node counts may be very slow.
- Needs real-world testing before production use.

Built because deleting a node, staring at the curve, pressing Undo, and doing it again 200 times is not a workflow.

## Contact

Questions, test results, ugly curves, or nodes that clearly have no reason to exist: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
