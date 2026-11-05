# Model training rules

Load the `transformer-scratch` skill.

- Sanity check first: overfit 100 examples until train loss is ~0. Only then scale the corpus.
- Fixed seed. Every run logs config, params, tokens seen, loss curve, lr.
- Assert the causal mask in a test. A leaked future token trains beautifully and generates garbage.
- Print the parameter count and check it against the config.
- Report the bigram baseline on the same split next to the transformer's val loss.
- Checkpoint to `runs/<timestamp>/` with `config.yaml`, `metrics.json` and samples. Never overwrite a run.
- Colab: mount the drive only for checkpointing, keep the corpus small enough to re-download.
