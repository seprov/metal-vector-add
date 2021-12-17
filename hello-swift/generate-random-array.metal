//
//  generate-random-arrays.metal
//  hello-swift
//
//  Created by Sebastian Provenzano on 12/15/21.
//

#include <metal_stdlib>

using namespace metal;

struct argumentBuffer {
    device float * arr1 [[id(0)]];
    device int * seed2 [[id(1)]];
};

float rand(int x, int y, int z)
{
    int seed = x + y * 57 + z * 241;
    seed= (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

kernel void generate_random_array(device float * arr1 [[buffer(0)]],
                                  device int * seed2 [[buffer(1)]],
                                  uint index [[ thread_position_in_grid ]]) {

    //arr1[index] = 10.0 * rand(*seed2,*seed2 / 2,index+3); // total time = 6.788
    //arr1[index] = 10.0; // total time = 6.868
    arr1[index] = 10.0 * (*seed2 + index) / (index+1);

}

// Generate a random float in the range [0.0f, 1.0f] using x, y, and z (based on the xor128 algorithm)

