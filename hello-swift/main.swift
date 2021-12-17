//
//  main.swift
//  hello-swift
//
//  Created by Sebastian Provenzano on 12/15/21.
//

import Foundation
import MetalKit

/*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o**/
/*o*o*o*o*o*o*o*o*o*o*o*o*o Start main o*o*o*o*o*o*o*o*o*o*o*o*o*/
/*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o**/

// Setup
// -_-_-
// Set number of elements to add
let count: Int = 10000000
// Set device to default
let device = MTLCreateSystemDefaultDevice()
// Space out the Metal messages
print()


// Generate on CPU and add on GPU
// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

// Set start time for total CPU computation
let startCPUTime = CFAbsoluteTimeGetCurrent()
do {
    // Generate the first Array and time it
    let CPUGenerationStartTime1 = CFAbsoluteTimeGetCurrent()
    let CPUGeneratedFloatArray1 = generateArrayOfRandomFloatsOnCPU()
    let CPUGenerationElapsedTime1 = CFAbsoluteTimeGetCurrent() - CPUGenerationStartTime1
    print("time elapsed: \(String(format: "%.05f", CPUGenerationElapsedTime1)) seconds")

    // Generate the second Array and time it
    let CPUGenerationStartTime2 = CFAbsoluteTimeGetCurrent()
    let CPUGeneratedFloatArray2 = generateArrayOfRandomFloatsOnCPU()
    let CPUGenerationElapsedTime2 = CFAbsoluteTimeGetCurrent() - CPUGenerationStartTime2
    print("time elapsed: \(String(format: "%.05f", CPUGenerationElapsedTime2)) seconds")

    // Add the Arrays and calculate total time elapsed
    addTwoArraysOnGPU(arr1 : CPUGeneratedFloatArray1, arr2 : CPUGeneratedFloatArray2)
    
}
let totalCPUElapsed = CFAbsoluteTimeGetCurrent() - startCPUTime
print("total time elapsed \(String(format: "%.05f", totalCPUElapsed)) seconds")
print()

// Generate on GPU and add on GPU
// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

// Set start time for total GPU computation
let startGPUTime = CFAbsoluteTimeGetCurrent()
do {
    // Generate the first Array and time it
    let getGPURandomStart1 = CFAbsoluteTimeGetCurrent()
    let array1 = getRandomArrayFromGPU()
    let getGPURandomElapsed1 = CFAbsoluteTimeGetCurrent() - getGPURandomStart1
    print("time elapsed: \(String(format: "%.05f", getGPURandomElapsed1)) seconds")

    let getGPURandomStart2 = CFAbsoluteTimeGetCurrent()
    let array2 = getRandomArrayFromGPU()
    let getGPURandomElapsed2 = CFAbsoluteTimeGetCurrent() - getGPURandomStart2
    print("time elapsed: \(String(format: "%.05f", getGPURandomElapsed2)) seconds")

    addTwoArraysOnGPU(arr1: array1, arr2: array2)
}
let totalGPUElapsed = CFAbsoluteTimeGetCurrent() - startGPUTime
print("total time elapsed \(String(format: "%.05f", totalGPUElapsed)) seconds")
print()

if totalCPUElapsed > totalGPUElapsed {
    print("total time is \(String(format: "%.05f", totalCPUElapsed/totalGPUElapsed)) times less when \nrandom numbers are generated on the GPU")
}
if totalCPUElapsed < totalGPUElapsed {
    print("total time is \(String(format: "%.05f", totalGPUElapsed/totalCPUElapsed)) times less when \nrandom numbers are generated on the CPU")
}

// Prints a blank line to space out the exit code
print()
/*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o**/
/*o*o*o*o*o*o*o*o*o*o*o*o*o* End main *o*o*o*o*o*o*o*o*o*o*o*o*o*/
/*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o**/

func addTwoArraysOnGPU(arr1 : [Float], arr2 : [Float]) {
    let commandQueue = device?.makeCommandQueue()
    let GPUFunctionLibrary = device?.makeDefaultLibrary()
    let additionGPUFunction = GPUFunctionLibrary?.makeFunction(name: "add_arrays")
    
    var additionComputePipelineState: MTLComputePipelineState!
    do {
        additionComputePipelineState = try device?.makeComputePipelineState(function: additionGPUFunction!)
    } catch {
        print(error)
    }
    
    print()
    
     // want to time the different parts of this i guess
    
    // make buffers
    // doing it straight out of the tutorial, but in the future
    // i think i'll try encapsulating into one struct
    // or the swift equivalent to have to create fewer buffers
    let arr1Buf = device?.makeBuffer(bytes: arr1, length: MemoryLayout<Float>.size * count, options: .storageModeShared)
    let arr2Buf = device?.makeBuffer(bytes: arr2, length: MemoryLayout<Float>.size * count, options: .storageModeShared)
    let resultBuf = device?.makeBuffer(length: MemoryLayout<Float>.size * count, options: .storageModeShared)
    
    let commandBuf = commandQueue?.makeCommandBuffer()
    
    let commandEncoder = commandBuf?.makeComputeCommandEncoder()
    commandEncoder?.setComputePipelineState(additionComputePipelineState)
    
    commandEncoder?.setBuffer(arr1Buf, offset: 0, index: 0)
    commandEncoder?.setBuffer(arr2Buf, offset: 0, index: 1)
    commandEncoder?.setBuffer(resultBuf, offset: 0, index: 2)
    
    let threadsPerGrid = MTLSize(width: count, height: 1, depth: 1)
    let maxThreadsPerGroup = additionComputePipelineState.maxTotalThreadsPerThreadgroup // this is intersting
    let threadsPerThreadGroup = MTLSize(width: maxThreadsPerGroup, height: 1, depth: 1)
    
    commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
     
    
    
    /*
    // Found this code, might work on it more later
    let threadgroupSizeMultiplier = 4
    let threadsPerGroup = MTLSize(width: 256, height: 1, depth: 1)
    let numThreadgroups = MTLSize(width: (count / (256 * threadgroupSizeMultiplier)), height: 1, depth:1)

    print("Block: \(threadsPerGroup.width) x \(threadsPerGroup.height)\n" +
          "Grid: \(numThreadgroups.width) x \(numThreadgroups.height) x \(numThreadgroups.depth)")

    commandEncoder?.dispatchThreads(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
    */
    commandEncoder?.endEncoding()
    
    commandBuf?.commit()
    let computeStart = CFAbsoluteTimeGetCurrent() //
    commandBuf?.waitUntilCompleted()
    let computeEnd = CFAbsoluteTimeGetCurrent() //
    
    var resultBufferPointer = resultBuf?.contents().bindMemory(to: Float.self, capacity: MemoryLayout<Float>.size * count)
    
    print("first 3 computations")
    for i in 0..<3 {
        print("\(arr1[i]) + \(arr2[i]) = \(Float(resultBufferPointer!.pointee) as Any)")
        resultBufferPointer = resultBufferPointer?.advanced(by: 1)
    }
    
    let computeElapsed = computeEnd - computeStart
    print("compute time elapsed \(String(format: "%.05f", computeElapsed)) seconds")
    
}

func basicForLoopWay(arr1 : [Float], arr2 : [Float]) {
    print("basic for loop way")
    
    let startTime = CFAbsoluteTimeGetCurrent()
    var result = [Float].init(repeating: 0.0, count: count)
    
    for i in 0..<count {
        result[i] = arr1[i] + arr2[i]
    }
    
    // could print the results i guess, who cares
    
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("time elapsed: \(String(format: "%.05f", timeElapsed)) seconds")
    
    print() // guess this prints a new line
}

// TODO: parallelize this
// done
func generateArrayOfRandomFloatsOnCPU()->[Float] {
    print("using cpu for random")
    let seed2 = Int(arc4random())
    var result = [Float].init(repeating: 0.0, count: count)
    for i in 0..<count {
        result[i] = (Float((seed2 + i) / (i+1))).truncatingRemainder(dividingBy: 100);
    
    }
    
    return result
}

func getRandomArrayFromGPU()->[Float] {
    print("using gpu for random")
    
    var result  = [Float].init(repeating: 0.0, count: count)
    let length = count * MemoryLayout<Float>.stride
    var memory: UnsafeMutableRawPointer? = nil
    let alignment = 0x1000
    let allocationSize = (length + alignment - 1) & (~(alignment - 1))
    posix_memalign(&memory, alignment, allocationSize)
    let sharedMetalBuffer = device?.makeBuffer(bytesNoCopy: memory!,
                     length: allocationSize,
                     options: [],
                     deallocator: { (pointer: UnsafeMutableRawPointer, _: Int) in
                        free(pointer)
    })

    sharedMetalBuffer?.contents().bindMemory(to: [Float].self, capacity: length)
    
    let commandQueue = device?.makeCommandQueue()
    let GPUFunctionLibrary = device?.makeDefaultLibrary()
    let generateRandomArrayFunction = GPUFunctionLibrary?.makeFunction(name: "generate_random_array")
    
    var generateRandomComputePipelineState: MTLComputePipelineState!
    do {
        generateRandomComputePipelineState = try device?.makeComputePipelineState(function: generateRandomArrayFunction!)
    } catch {
        print(error)
    }
    
    let commandBuf = commandQueue?.makeCommandBuffer()
    
    let commandEncoder = commandBuf?.makeComputeCommandEncoder()
    commandEncoder?.setComputePipelineState(generateRandomComputePipelineState)
    //commandEncoder?.setBuffer(resBuf, offset: 0, index: 0)
    commandEncoder?.setBuffer(sharedMetalBuffer, offset: 0, index: 0)
    
    // we still need one random number
    var random = Int(arc4random())
    let rp: UnsafeMutablePointer<Int> = .init(&random)
    commandEncoder?.setBuffer(device?.makeBuffer(bytes: rp, length: 4, options: .storageModeShared),offset: 0,index: 1)
    
    
    
    let threadsPerGrid = MTLSize(width: count, height: 1, depth: 1)
    let maxThreadsPerGroup = generateRandomComputePipelineState.maxTotalThreadsPerThreadgroup // this is intersting
    let threadsPerThreadGroup = MTLSize(width: maxThreadsPerGroup, height: 1, depth: 1)
    
    commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
    
    commandEncoder?.endEncoding()
 
    commandBuf?.commit()
    commandBuf?.waitUntilCompleted()
    
    memmove(&result[0], sharedMetalBuffer?.contents(), length)
    
    return result
     
}

