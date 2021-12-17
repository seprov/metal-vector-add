//
//  main.swift
//  hello-swift
//
//  Created by Sebastian Provenzano on 12/15/21.
//

import Foundation
import MetalKit

/* start main */
//let totalStart = CFAbsoluteTimeGetCurrent()

let count: Int = 10000000

// Generate on CPU and add on GPU
let startCPUTime = CFAbsoluteTimeGetCurrent()
var array3 = getRandomArray()
var array4 = getRandomArray()
computeWay(arr1 : array3, arr2 : array4)
let totalCPUElapsed = CFAbsoluteTimeGetCurrent() - startCPUTime
print("total time elapsed \(String(format: "%.05f", totalCPUElapsed)) seconds")
print()


// Generate on GPU and add on GPU
let startGPUTime = CFAbsoluteTimeGetCurrent()
var array1 = getRandomArrayFromGPU()
var array2 = getRandomArrayFromGPU()
computeWay(arr1: array1, arr2: array2)
let totalGPUElapsed = CFAbsoluteTimeGetCurrent() - startGPUTime
print("total time elapsed \(String(format: "%.05f", totalGPUElapsed)) seconds")
print()

if totalCPUElapsed > totalGPUElapsed {
    print("total time is \(String(format: "%.05f", totalCPUElapsed/totalGPUElapsed)) times less when \nrandom numbers are generated on the GPU")
}
if totalCPUElapsed < totalGPUElapsed {
    print("total time is \(String(format: "%.05f", totalGPUElapsed/totalCPUElapsed)) times less when \nrandom numbers are generated on the CPU")
}
print()
// compute sums
//basicForLoopWay(arr1 : array3, arr2 : array4)


/* end main */

func computeWay(arr1 : [Float], arr2 : [Float]) {
    
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
    
    commandEncoder?.endEncoding()
    
    commandBuf?.commit()
    let computeStart = CFAbsoluteTimeGetCurrent() //
    commandBuf?.waitUntilCompleted()
    let computeEnd = CFAbsoluteTimeGetCurrent() //
    
    var resultBufferPointer = resultBuf?.contents().bindMemory(to: Float.self, capacity: MemoryLayout<Float>.size * count)
    
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
func getRandomArray()->[Float] {
    print("using cpu for random")
    let getCPURandomStart = CFAbsoluteTimeGetCurrent()
    var result = [Float].init(repeating: 0.0, count: count)
    for i in 0..<count {
        result[i] = Float(arc4random_uniform(1000000000))/100000000
        
        
    }
    let getCPURandomElapsed = CFAbsoluteTimeGetCurrent() - getCPURandomStart
    print("time elapsed: \(String(format: "%.05f", getCPURandomElapsed)) seconds")
    return result
}

func getRandomArrayFromGPU()->[Float] {
    print("using gpu for random")
    let getGPURandomStart = CFAbsoluteTimeGetCurrent()
    //var x = UnsafeMutableRawPointer(&result)
    
    let device = MTLCreateSystemDefaultDevice()
    
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
    //let sharedMetalBuffer = device?.makeBuffer(bytes: &result, length: count * MemoryLayout<Float>.stride, options: .storageModeShared)
    //sharedMetalBuffer?.contents().initializeMemory(as: Float.self, from: result, count: count)
    
    //let sharedMetalBuffer = device?.makeBuffer(length: count * MemoryLayout<Float>.stride, options: .storageModeShared)
    //let p = sharedMetalBuffer?.contents().bindMemory(to: [Float].self, capacity: count)
    //p!.initialize(to: [Float].init(repeating: 0.0, count: count))
    //sharedMetalBuffer?.contents().initializeMemory(as: [Float].self, from: &sharedMetalBuffer, count: count)
    
    let commandQueue = device?.makeCommandQueue()
    let GPUFunctionLibrary = device?.makeDefaultLibrary()
    let generateRandomArrayFunction = GPUFunctionLibrary?.makeFunction(name: "generate_random_array")
    
    var generateRandomComputePipelineState: MTLComputePipelineState!
    do {
        generateRandomComputePipelineState = try device?.makeComputePipelineState(function: generateRandomArrayFunction!)
    } catch {
        print(error)
    }
    
    //let resBuf = device?.makeBuffer(bytes: result, length: MemoryLayout<Float>.size * count, options: .storageModeShared)
    //let resBuf = device?.makeBuffer(bytesNoCopy: x, length: MemoryLayout<Float>.size * count, options: .storageModeShared)
    let commandBuf = commandQueue?.makeCommandBuffer()
    
    let commandEncoder = commandBuf?.makeComputeCommandEncoder()
    commandEncoder?.setComputePipelineState(generateRandomComputePipelineState)
    //commandEncoder?.setBuffer(resBuf, offset: 0, index: 0)
    commandEncoder?.setBuffer(sharedMetalBuffer, offset: 0, index: 0)
    
    // we still need one random number
    var random = Int(arc4random())
    var rp: UnsafeMutablePointer<Int> = .init(&random)
    commandEncoder?.setBuffer(device?.makeBuffer(bytes: rp, length: 4, options: .storageModeShared),offset: 0,index: 1)
    
    let threadsPerGrid = MTLSize(width: count, height: 1, depth: 1)
    let maxThreadsPerGroup = generateRandomComputePipelineState.maxTotalThreadsPerThreadgroup // this is intersting
    let threadsPerThreadGroup = MTLSize(width: maxThreadsPerGroup, height: 1, depth: 1)
    
    commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
    
    commandEncoder?.endEncoding()
    
    commandBuf?.commit()
    commandBuf?.waitUntilCompleted()
    
    var resultBufferPointer = sharedMetalBuffer?.contents().bindMemory(to: Float.self, capacity: MemoryLayout<Float>.size * count)
    
    var result  = [Float].init(repeating: 0.0, count: count)
    for i in 0..<count {
        result[i] = Float(resultBufferPointer!.pointee)// need to get more than just this one item
        resultBufferPointer = resultBufferPointer?.advanced(by: 1)
    }
    // print(type(of: resultBufferPointer))
    let getGPURandomElapsed = CFAbsoluteTimeGetCurrent() - getGPURandomStart
    print("time elapsed: \(String(format: "%.05f", getGPURandomElapsed)) seconds")
    return result
    
}

