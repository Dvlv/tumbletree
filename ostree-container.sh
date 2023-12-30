#!/bin/bash
wget https://github.com/ostreedev/ostree-rs-ext/archive/refs/tags/ostree-ext-v0.12.0.tar.gz;
gunzip ostree-ext-v0.12.0.tar.gz;
tar -xvf ostree-ext-v0.12.0.tar;
cd ostree-rs-ext-ostree-ext-v0.12.0;
cargo build --release;
