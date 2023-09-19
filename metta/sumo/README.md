# Reasoning on SUMO Experiment

## Import SUO-KIF

### Load SUO-KIF Directly

**WIP**

MeTTa is sufficiently rich to be able to load SUO-KIF file without any
prior conversion.  The challenge then is to apply MeTTa's pattern
matching capabilities to the loaded data.  An important difference
between SUO-KIF and MeTTa is the variable format.  SUO-KIF has two
types of variables, regular variable that starts with `?` and sequence
variable that starts with `@`.  MeTTa has only one type of variable
that starts with `$`.

To load SUO-KIF directly see `load-suo-kif.metta`.

### Convert SUO-KIF to MeTTa

Due to the differences in variables between SUO-KIF and MeTTa, one may
apply the script `suo-kif-to-metta.sh` to convert SUO-KIF files into
MeTTa.  For now only SUO-KIF variables starting with `?` are
considered, thus the source file is assumed not to contain any
sequence variable.

For example

```bash
./suo-kif-to-metta.sh orientation.kif > orientation.kif.metta
```

will produce `orientation.kif.metta` where all SUO-KIF regular
variables have been replaced by MeTTa variables.

## Reasoning

### Rule Base

A set of rules have been specially crafted to reason over SUMO, see
`rules.metta`.

## Usage

First, make sure you have generated `orientation.kif.metta`.  Second,
simply run the `orientation-test.metta`.

```bash
metta orientation-test.metta
```
