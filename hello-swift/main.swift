//
//  main.swift
//  hello-swift
//
//  Created by Sebastian Provenzano on 12/15/21.
//

import Foundation
import MetalKit

/* start main */
let totalStart = CFAbsoluteTimeGetCurrent()

print("Hello, World!")

let count: Int = 3000000

var array3 = getRandomArray()
var array4 = getRandomArray()

// make random arrays
var array1 = getRandomArrayFromGPU()
var array2 = getRandomArrayFromGPU()

// compute sums
// basicForLoopWay(arr1 : array1, arr2 : array2)
computeWay(arr1 : array3, arr2 : array4)
computeWay(arr1 : array1, arr2 : array2)
/* end main */

func computeWay(arr1 : [Float], arr2 : [Float]) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let device = MTLCreateSystemDefaultDevice()
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
    print("compute way")
    let startTime2 = CFAbsoluteTimeGetCurrent() // want to time the different parts of this i guess
    
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
    
    commandEncoder?.endEncoding()
    
    commandBuf?.commit()
    let startTime3 = CFAbsoluteTimeGetCurrent() //
    commandBuf?.waitUntilCompleted()
    let endTime1 = CFAbsoluteTimeGetCurrent() //
    
    var resultBufferPointer = resultBuf?.contents().bindMemory(to: Float.self, capacity: MemoryLayout<Float>.size * count)
    
    for i in 0..<3 {
        print("\(arr1[i]) + \(arr2[i]) = \(Float(resultBufferPointer!.pointee) as Any)")
        resultBufferPointer = resultBufferPointer?.advanced(by: 1)
    }
    
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("total time elapsed \(String(format: "%.05f", timeElapsed)) seconds")
    //print()
    
    let timeElapsed2 = endTime1 - startTime3
    print("compute time elapsed \(String(format: "%.05f", timeElapsed2)) seconds")
    print()
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
func getRandomArray()->[Float] {
    var result = [Float].init(repeating: 0.0, count: count)
    for i in 0..<count {
        result[i] = Float(arc4random_uniform(10))
    }
    return result
}

func getRandomArrayFromGPU()->[Float] {
    var result = [Float].init(repeating: 0.0, count: count)
    
    let device = MTLCreateSystemDefaultDevice()
    let commandQueue = device?.makeCommandQueue()
    let GPUFunctionLibrary = device?.makeDefaultLibrary()
    let generateRandomArrayFunction = GPUFunctionLibrary?.makeFunction(name: "generate_random_array")
    
    var generateRandomComputePipelineState: MTLComputePipelineState!
    do {
        generateRandomComputePipelineState = try device?.makeComputePipelineState(function: generateRandomArrayFunction!)
    } catch {
        print(error)
    }
    
    let resBuf = device?.makeBuffer(bytes: result, length: MemoryLayout<Float>.size * count, options: .storageModeShared)
    
    let commandBuf = commandQueue?.makeCommandBuffer()
    
    let commandEncoder = commandBuf?.makeComputeCommandEncoder()
    commandEncoder?.setComputePipelineState(generateRandomComputePipelineState)
    commandEncoder?.setBuffer(resBuf, offset: 0, index: 0)
    
    let threadsPerGrid = MTLSize(width: count, height: 1, depth: 1)
    let maxThreadsPerGroup = generateRandomComputePipelineState.maxTotalThreadsPerThreadgroup // this is intersting
    let threadsPerThreadGroup = MTLSize(width: maxThreadsPerGroup, height: 1, depth: 1)
    
    commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
    
    commandEncoder?.endEncoding()
    
    commandBuf?.commit()
    commandBuf?.waitUntilCompleted()
    
    var resultBufferPointer = resBuf?.contents().bindMemory(to: Float.self, capacity: MemoryLayout<Float>.size * count)
    result = [Float(resultBufferPointer!.pointee)] // need to get more than just this one item
    
    return result
}

