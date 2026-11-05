# Workflow: train a small transformer

Run these steps in order. Do not skip a step because the previous one looked fine.
Stop and report if a step fails twice.

## 1. Corpus
- Pick the text file(s). Report bytes, characters, unique characters.
- Split train/val by position (last 10% is val). Never random by character.

## 2. Tokenizer
- Char-level: vocab from sorted unique chars.
- `pytest -q tests/test_tokenizer.py` — encode/decode round-trip must pass.

## 3. Model
- Read `configs/model.yaml`: `n_layer, n_head, n_embd, block_size, dropout`.
- Print parameter count. Compare with the size guide in the skill.
- `pytest -q tests/test_attention.py` — the causal mask test must pass.

## 4. Sanity run
- Train on 100 examples for 200 steps. Train loss must go below 0.1.
- If it does not, the bug is in the model or the loss, not the data. Stop and report.

## 5. Real run
- Run `python train.py --config configs/model.yaml --out runs/$(date +%Y%m%d-%H%M)`.
- Log loss every 50 steps; eval on val every 250; keep the best checkpoint.

## 6. Sample and report
- Generate 3 samples at temperature 0.8, top_k 40, fixed seed.
- Compute the bigram baseline val loss on the same split.
- Write `runs/<id>/report.md`: params, tokens seen, val loss, bigram baseline, samples, and the loss curve path.
