pragma circom 2.0.0;

include "mimcsponge.circom";

/*
    This circuit template checks that root is the merkle root of N leaves.
    Leaves are assumed to be any data and so they get hashed before computing the root.

    N is assumed to be a positive power of 2    
 */

template Merkle(N) {
    // Declaration of signals.  
    signal input leaves[N];
    signal output root;
    component comp[(2 * N) - 1];

    // Create components for the leaves and hash them
    for (var i = 0; i < N; i++) {
        // we pass the following: 1 input, 220 rounds, 1 output
        comp[i] = MiMCSponge(1, 220, 1);
        comp[i].k <== 0;
        comp[i].ins[0] <== leaves[i];
    }

    // Compute the Merkle root
    for (var step = N, offset = 0; 0 < step; step /= 2) {
        for (var j = 0; j < step / 2; j += 1) {
            var idx = offset + step + j;
            comp[idx] = MiMCSponge(2, 220, 1);
            comp[idx].k <== 0;
            comp[idx].ins[0] <== comp[offset + (2 * j)].outs[0];
            comp[idx].ins[1] <== comp[offset + (2 * j) + 1].outs[0];
        }
        offset += step;
    }

    root <== comp[(2 * N) - 2].outs[0];
}

component main = Merkle(8);