# Oryx symbol-layer rework — todo

Goal: type `()=>{}` and friends with **left-thumb hold (space) + right hand only**,
no Shift, no layer-hopping. Plus make `{`/`}` (your #5/#6 most-pressed keys, ~25k)
a single base-layer tap.

Layer map after this work:
- **Layer 0** Base
- **Layer 1** Symbols (held with **Space**)
- **Layer 2** Numbers (unchanged — stays on right thumb `MO(2)`)
- **Layer 3** Arrows/media (moves from Space-hold → `'`-hold)

---

## 1. Base layer — swap brackets for braces (bottom row, right hand)
- [ ] Click the base-layer **`[`** key (bottom row, right side) → assign **`{`**
- [ ] Click the base-layer **`]`** key (next to it) → assign **`}`**
  - Oryx sends the Shift internally, so these become single unshifted taps.
  - `[` and `]` are not lost — they move onto the symbol layer (step 4).

## 2. Base layer — left thumb (Space) becomes the symbol-layer trigger
- [ ] Click the big **Space** key (left thumb)
- [ ] Keep **tap = Space**
- [ ] Set **Dual-function → hold = Layer Shift → Layer 1**
  - (It currently holds Layer 3; we're just repointing the hold to Layer 1.)

## 3. Base layer — rehome the old Space-hold layer onto `'`
- [ ] Click the **`'` / quote** key (right pinky, home row)
- [ ] Keep **tap = `'`**
- [ ] Set **Dual-function → hold = Layer Shift → Layer 3**
  - This is where the arrows/media you used to get from Space-hold now live.

---

## 4. Layer 1 (Symbols) — RIGHT HAND ONLY
Select the **Layer 1** tab. Assign the right-hand keys as below.
Reference is the base-layer letter under each finger.

```
 top  (Y  U  I  O  P  \):    [    <    >    ]    \    |
 home (H  J  K  L  ;  '):    =    (    {    }    )    `
 bot  (N  M  ,  .  /):       &    -    _    +    *
```

- [ ] Top row:  `Y`→`[`  `U`→`<`  `I`→`>`  `O`→`]`  `P`→`\`  `\`-key→`|`
- [ ] Home row: `H`→`=`  `J`→`(`  `K`→`{`  `L`→`}`  `;`→`)`  `'`→`` ` ``
- [ ] Bottom row: `N`→`&`  `M`→`-`  `,`→`_`  `.`→`+`  `/`→`*`

So `()=>{}` = hold Space, then right hand: `J` `;` `=` `I` `K` `L`
(`( ) = > { }`) — all home/top row, one hand.

## 5. Layer 1 — keep the LEFT HAND transparent (important)
- [ ] On Layer 1, set the old `! @ # $ %` keys (left home row `A S D F G`) back to
      **Transparent** (the "▽" / no-op in Oryx).
  - Why: your nvim leader is Space. A transparent left hand means `<leader>w`,
    `<leader>sf`, etc. pass straight through even if Space registers as a hold.
  - `! @ # $ % ^` stay reachable via the Numbers layer (`MO(2)`) + Shift.
- [ ] Leave the `MO(1)` key (left of `N`) as-is — a harmless right-hand backup
      trigger for this same layer.

---

## 6. (Optional) `=>` macro
Skip if the keys in step 4 feel fine; add if you want one tap for the arrow.
- [ ] Oryx → create a **Macro** that types `=>` (or ` => ` with spaces)
- [ ] Put it on **Layer 1, top row above `(`** (the topmost right-hand row is free) —
      doesn't disturb the left-hand-transparent rule.

---

## 7. Flash + sanity check
- [ ] Compile/download in Oryx, flash with Keymapp/Wally
- [ ] Test: `() => {}` , a generic `<T>` , `arr[0]` , `a || b` , `x += 1`
- [ ] Test nvim leader still works: `<leader>w` (save), `<leader>sf` (find files),
      `<leader>e` (tree) — all left-hand, should be unaffected
- [ ] Test `{`/`}` paragraph jumps in nvim are now a single base-layer tap
