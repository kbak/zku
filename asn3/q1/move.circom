pragma circom 2.0.0;

/*
    Prove: I know (aX,aY,bX,bY,cX,cY) such that:
    - (bX-aX)^2+(bY-aY)^2 <= energy^2
    - (cX-bX)^2+(cY-bY)^2 <= energy^2
    - (aX-cX)^2+(aY-cY)^2 <= energy^2
    - (cY - bY) * (bX - aX) != (bY - aY) * (cX - bX)
    - MiMCSponge(aX,aY) = pub1
    - MiMCSponge(bX,bY) = pub2
    - MiMCSponge(cX,cY) = pub3
*/

include "mimcsponge.circom";
include "comparators.circom";

template EnergyBound() {
    signal input x1;
    signal input y1;
    signal input x2;
    signal input y2;
    signal input energy;

    // (x2-x1)^2+(y2-y1)^2 <= energy^2

    signal diffX;
    diffX <== x1 - x2;
    signal diffY;
    diffY <== y1 - y2;

    component ltDist = LessThan(32);
    signal firstDistSquare;
    signal secondDistSquare;
    firstDistSquare <== diffX * diffX;
    secondDistSquare <== diffY * diffY;
    ltDist.in[0] <== firstDistSquare + secondDistSquare;
    ltDist.in[1] <== energy * energy + 1;
    ltDist.out === 1;
}

template Main(energy) {
    signal input aX;
    signal input aY;
    signal input bX;
    signal input bY;
    signal input cX;
    signal input cY;

    signal output pub1;
    signal output pub2;
    signal output pub3;

    // check that A, B, C are on a triangle
    component isEq = IsEqual();
    isEq.in[0] <== (cY - bY) * (bX - aX);
    isEq.in[1] <== (bY - aY) * (cX - bX);
    isEq.out === 0;

    // check that A->B and B->C and C->A are within energy levels
    component energyBoundAB = EnergyBound();
    energyBoundAB.x1 <== aX;
    energyBoundAB.y1 <== aY;
    energyBoundAB.x2 <== bX;
    energyBoundAB.y2 <== bY;
    energyBoundAB.energy <== energy;

    component energyBoundBC = EnergyBound();
    energyBoundBC.x1 <== bX;
    energyBoundBC.y1 <== bY;
    energyBoundBC.x2 <== cX;
    energyBoundBC.y2 <== cY;
    energyBoundBC.energy <== energy;

    component energyBoundCA = EnergyBound();
    energyBoundCA.x1 <== cX;
    energyBoundCA.y1 <== cY;
    energyBoundCA.x2 <== aX;
    energyBoundCA.y2 <== aY;
    energyBoundCA.energy <== energy;
    
    
    /* check MiMCSponge(aX,aY) = pub1, MiMCSponge(bX,bY) = pub2, MiMCSponge(cX,cY) = pub3 */
    /*
        220 = 2 * ceil(log_5 p), as specified by mimc paper, where
        p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    */
    component mimc1 = MiMCSponge(2, 220, 1);
    component mimc2 = MiMCSponge(2, 220, 1);
    component mimc3 = MiMCSponge(2, 220, 1);

    mimc1.ins[0] <== aX;
    mimc1.ins[1] <== aY;
    mimc1.k <== 0;
    mimc2.ins[0] <== bX;
    mimc2.ins[1] <== bY;
    mimc2.k <== 0;
    mimc3.ins[0] <== cX;
    mimc3.ins[1] <== cY;
    mimc3.k <== 0;

    pub1 <== mimc1.outs[0];
    pub2 <== mimc2.outs[0];
    pub3 <== mimc3.outs[0];
}

component main = Main(10);