---
name: transformer-scratch
description: Build and train a small decoder-only Transformer from scratch — tokenizer, attention, blocks, training loop, sampling and eval. Use when the task mentions "transformer", "LLM from scratch", "atenção", "treinar modelo", tokenizer, attention head, or a language model that must be understood rather than imported.
---

# transformer-scratch

Build it small enough to train in minutes and complete enough that every line is understood.

## Order

1. **Data** — one text corpus, character or BPE level. Report size, vocabulary size, and the train/val split by position (not random characters).
2. **Tokenizer** — char-level first: vocab built from sorted unique chars, encode/decode round-trip test. Only then BPE.
3. **Model** — decoder-only: token embedding + positional embedding, N blocks of (LayerNorm -> causal self-attention -> residual -> LayerNorm -> MLP -> residual), final LayerNorm + head tied to the embedding.
   Parameters: `n_layer`, `n_head`, `n_embd`, `block_size`, `dropout`.
4. **Attention** — scale by `1/sqrt(head_dim)`, mask future positions with `-inf` before softmax. Assert the mask works: position t must not attend to t+1.
5. **Train loop** — cross-entropy, AdamW, warmup + cosine, grad clip, eval on val every K steps, keep the best checkpoint. Log loss, lr, tokens/sec.
6. **Sample** — temperature and top-k, with a fixed seed. Save the generated samples next to the checkpoint.
7. **Report** — params, tokens seen, train/val loss curve, 3 samples, and the honest baseline: a bigram model's val loss on the same data.

## Size guide

- CPU, ~1 MB corpus: 2-3 layers, 2-4 heads, 64-128 dim, ~1M params, minutes.
- Colab T4, ~10 MB corpus: 4-6 layers, 4-6 heads, 128-256 dim, ~10M params, 20-40 min.
- Never train a big model before the small one overfits a tiny slice. That is how you find a bug in an hour instead of a day.

## Checklist

- [ ] Encode/decode round-trip test green
- [ ] Causal mask asserted in a test, not by eye
- [ ] Parameter count printed and matches the config
- [ ] Train loss on a 100-example slice goes to ~0 (proves the model can learn)
- [ ] Val loss curve saved with the checkpoint
- [ ] Bigram baseline reported next to the transformer
- [ ] Sampling reproducible with a fixed seed

## Anti-patterns

- Training on the full corpus before the sanity check on a tiny slice.
- Random character split leaking neighbour text into val.
- Reporting train loss as the result.
- Copying a repo and calling it from scratch.
- No positional encoding, or learned positions longer than `block_size`.
