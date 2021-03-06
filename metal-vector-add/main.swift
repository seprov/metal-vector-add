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
var count: Int = 1000
// Set device to default
let device = MTLCreateSystemDefaultDevice()
// Space out the Metal messages
print()

for i in 0...6 {
    count = Int(1000*(pow(Double(10),Double(i))))
    // Generate on CPU and add on CPU
    // -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
    let startAllCPUTime = CFAbsoluteTimeGetCurrent()
    do {
        let CPUGenerationStartTime1 = CFAbsoluteTimeGetCurrent()
        let CPUGeneratedFloatArray1 = getRandomArrayFromCPU()
        let CPUGenerationElapsedTime1 = CFAbsoluteTimeGetCurrent() - CPUGenerationStartTime1
        //print("time elapsed: \(String(format: "%.05f", CPUGenerationElapsedTime1)) seconds")

        // Generate the second Array and time it
        let CPUGenerationStartTime2 = CFAbsoluteTimeGetCurrent()
        let CPUGeneratedFloatArray2 = getRandomArrayFromCPU()
        let CPUGenerationElapsedTime2 = CFAbsoluteTimeGetCurrent() - CPUGenerationStartTime2
        //print("time elapsed: \(String(format: "%.05f", CPUGenerationElapsedTime2)) seconds")
        
        addTwoArraysOnCPU(arr1 : CPUGeneratedFloatArray1, arr2 : CPUGeneratedFloatArray2, printExtraInfo: false)

    }
    let totalAllCPUElapsed = CFAbsoluteTimeGetCurrent() - startAllCPUTime
    //print("total time elapsed \(String(format: "%.05f", totalAllCPUElapsed)) seconds")
    //print()

    // Generate on CPU and add on GPU
    // -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

    // Set start time for total CPU computation
    let startCPUTime = CFAbsoluteTimeGetCurrent()
    do {
        // Generate the first Array and time it
        let CPUGenerationStartTime1 = CFAbsoluteTimeGetCurrent()
        let CPUGeneratedFloatArray1 = getRandomArrayFromCPU()
        let CPUGenerationElapsedTime1 = CFAbsoluteTimeGetCurrent() - CPUGenerationStartTime1
        //print("time elapsed: \(String(format: "%.05f", CPUGenerationElapsedTime1)) seconds")

        // Generate the second Array and time it
        let CPUGenerationStartTime2 = CFAbsoluteTimeGetCurrent()
        let CPUGeneratedFloatArray2 = getRandomArrayFromCPU()
        let CPUGenerationElapsedTime2 = CFAbsoluteTimeGetCurrent() - CPUGenerationStartTime2
        //print("time elapsed: \(String(format: "%.05f", CPUGenerationElapsedTime2)) seconds")

        // Add the Arrays and calculate total time elapsed
        addTwoArraysOnGPU(arr1 : CPUGeneratedFloatArray1, arr2 : CPUGeneratedFloatArray2, printExtraInfo: false)
        
    }
    let totalCPUElapsed = CFAbsoluteTimeGetCurrent() - startCPUTime
    //print("total time elapsed \(String(format: "%.05f", totalCPUElapsed)) seconds")
    //print()

    // Generate on GPU and add on GPU
    // -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

    // Set start time for total GPU computation
    let startGPUTime = CFAbsoluteTimeGetCurrent()
    do {
        // Generate the first Array and time it
        let getGPURandomStart1 = CFAbsoluteTimeGetCurrent()
        let array1 = getRandomArrayFromGPU()
        let getGPURandomElapsed1 = CFAbsoluteTimeGetCurrent() - getGPURandomStart1
        //print("time elapsed: \(String(format: "%.05f", getGPURandomElapsed1)) seconds")

        let getGPURandomStart2 = CFAbsoluteTimeGetCurrent()
        let array2 = getRandomArrayFromGPU()
        let getGPURandomElapsed2 = CFAbsoluteTimeGetCurrent() - getGPURandomStart2
        //print("time elapsed: \(String(format: "%.05f", getGPURandomElapsed2)) seconds")

        addTwoArraysOnGPU(arr1: array1, arr2: array2, printExtraInfo: false)
    }
    let totalGPUElapsed = CFAbsoluteTimeGetCurrent() - startGPUTime
    //print("total time elapsed \(String(format: "%.05f", totalGPUElapsed)) seconds")
    //print()

    print("with n = ", count, "element arrays")
    print("generated on | computed on | total time |  speedup  ")
    print("cpu           cpu           \(String(format: "%.05f", totalAllCPUElapsed))     ", 1.00000)
    print("cpu           gpu           \(String(format: "%.05f", totalCPUElapsed))     ", "\(String(format: "%.03f", totalAllCPUElapsed/totalCPUElapsed))")
    print("gpu           gpu           \(String(format: "%.05f", totalGPUElapsed))     ", "\(String(format: "%.03f", totalAllCPUElapsed/totalGPUElapsed))")
    print()
    /*
    if totalCPUElapsed > totalGPUElapsed {
        print("total time is \(String(format: "%.05f", totalCPUElapsed/totalGPUElapsed)) times less when \nrandom numbers are generated on the GPU")
    }
    if totalCPUElapsed < totalGPUElapsed {
        print("total time is \(String(format: "%.05f", totalGPUElapsed/totalCPUElapsed)) times less when \nrandom numbers are generated on the CPU")
    }*/
}


/*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o**/
/*o*o*o*o*o*o*o*o*o*o*o*o*o* End main *o*o*o*o*o*o*o*o*o*o*o*o*o*/
/*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o**/

func addTwoArraysOnGPU(arr1 : [Float], arr2 : [Float], printExtraInfo : Bool) {
    //print("using gpu for computation")
    let commandQueue = device?.makeCommandQueue()
    let GPUFunctionLibrary = device?.makeDefaultLibrary()
    let additionGPUFunction = GPUFunctionLibrary?.makeFunction(name: "add_arrays")
    
    var additionComputePipelineState: MTLComputePipelineState!
    do {
        additionComputePipelineState = try device?.makeComputePipelineState(function: additionGPUFunction!)
    } catch {
        print(error)
    }
    

    
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
    
    let computeStart = CFAbsoluteTimeGetCurrent()
    commandBuf?.commit()
    commandBuf?.waitUntilCompleted()
    let computeEnd = CFAbsoluteTimeGetCurrent() //
    
    var resultBufferPointer = resultBuf?.contents().bindMemory(to: Float.self, capacity: MemoryLayout<Float>.size * count)
    
    if printExtraInfo {
        print("first 3 computations")
        for i in 0..<3 {
            print("\(arr1[i]) + \(arr2[i]) = \(Float(resultBufferPointer!.pointee) as Any)")
            resultBufferPointer = resultBufferPointer?.advanced(by: 1)
        }
        print(arr1.count)
        print(arr2.count)
    }
    
    let computeElapsed = computeEnd - computeStart
    //print("compute time elapsed \(String(format: "%.05f", computeElapsed)) seconds")
    
}

func addTwoArraysOnCPU(arr1 : [Float], arr2 : [Float], printExtraInfo: Bool) {
    //print("using cpu for computation")
    
    //let startTime = CFAbsoluteTimeGetCurrent()
    var result = [Float].init(repeating: 0.0, count: count)
    
    let computeStart = CFAbsoluteTimeGetCurrent()
    for i in 0..<count {
        result[i] = arr1[i] + arr2[i]
    }
    let computeEnd = CFAbsoluteTimeGetCurrent()
    
    if printExtraInfo {
        print("first 3 computations")
        for i in 0..<3 {
            print("\(arr1[i]) + \(arr2[i]) = \(result[i])")
        }
    }
    let computeElapsed = computeEnd - computeStart
    // print("compute time elapsed \(String(format: "%.05f", computeElapsed)) seconds")
    
    //let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    //print("time elapsed: \(String(format: "%.05f", timeElapsed)) seconds")
    
}

// TODO: parallelize this
// done
func getRandomArrayFromCPU()->[Float] {
    //print("using cpu for random")
    let seed2 = Int(arc4random())
    var result = [Float].init(repeating: 0.0, count: count)
    for i in 0..<count {
        result[i] = (Float((seed2 + i) / (i+1))).truncatingRemainder(dividingBy: 100);
    
    }
    
    return result
}

func getRandomArrayFromGPU()->[Float] {
    //print("using gpu for random")
    
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

