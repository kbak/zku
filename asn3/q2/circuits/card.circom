pragma circom 2.0.0;

include "./utils/mimcsponge.circom";

template Card() {  

   // private inputs
   signal input number;  
   signal input suit;  
   signal input secret;

   // public input
   signal input cardHash;

   // output
   signal output card;

   // hash suit with the secret
   component mimc1 = MiMCSponge(2, 220, 1);
   mimc1.ins[0] <== suit;
   mimc1.ins[1] <== secret;
   mimc1.k <== 0;

   // hash number with the previous hash output
   component mimc2 = MiMCSponge(2, 220, 1);
   mimc2.ins[0] <== number;
   mimc2.ins[1] <== mimc1.outs[0];
   mimc2.k <== 0;

   card <== mimc2.outs[0];
   cardHash === card;
}

component main {public [cardHash]} = Card();