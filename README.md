# My dotfiles
run `make fresh`. See makefile for more options. 

## setting up without root access:
if you have conda (and are on a server):
```
conda install gh --channel conda-forge
```
then authenticate via token!
Also:
```
make zsh_without_root
```

## change conda location
As this is often the case, an example file `condarc` is present. Copy and name it `.condarc`.
