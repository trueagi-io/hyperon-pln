# PLN for Hyperon

## Description

Hyperon port of PLN.  Very experimental at this stage.

## Requirements

Build https://github.com/trueagi-io/hyperon-experimental

## Usage

For now, that port consists of MeTTa scripts under the `metta` folder.
To execute them, type the following

```
python [HYPERON_EXPERIMENTAL]/python/tests/metta.py metta/[META_SCRIPT]
```

where `[HYPERON_EXPERIMENTAL]` is the path where
`hyperon-experimental` has been cloned and `[META_SCRIPT]` is the
MeTTa script you wish to run.

## Idris

There is also some Idris code under the `idris` folder to prototype
some of the port to Idris before MeTTa.  This is sometimes easier
because Idris is more mature than MeTTa.  The minimum requirement is
Idris2 version 0.5.1.
