# hello-swift
	Some basic programming with Swift (and Metal of course)

	Adds 2 arrays of random numbers on the GPU.

	Random numebers are generated in 2 ways:
	  CPU - An array of floats is created, random numbers are assigned serially by the CPU.
	  GPU - A buffer is created and bound to an array of floats, then the GPU computes each random number in parallel.

	Outputs the total time and compute time for computing the sum array of each addend-pair of arrays.

	--

	Somewhat scalable
	
	--
	
	Sample output:
	
	with n =  1000 element arrays
	generated on | computed on | total time |  speedup  
	cpu           cpu           0.00439      1.0
	cpu           gpu           0.00680      0.646
	gpu           gpu           0.00466      0.942

	with n =  10000 element arrays
	generated on | computed on | total time |  speedup  
	cpu           cpu           0.03990      1.0
	cpu           gpu           0.02953      1.351
	gpu           gpu           0.00522      7.645

	with n =  100000 element arrays
	generated on | computed on | total time |  speedup  
	cpu           cpu           0.36545      1.0
	cpu           gpu           0.25147      1.453
	gpu           gpu           0.02115      17.281

	with n =  1000000 element arrays
	generated on | computed on | total time |  speedup  
	cpu           cpu           3.60501      1.0
	cpu           gpu           2.38105      1.514
	gpu           gpu           0.02785      129.467
	
	with n =  10000000 element arrays
	generated on | computed on | total time |  speedup  
	cpu           cpu           35.68431      1.0
	cpu           gpu           23.59721      1.512
	gpu           gpu           0.08422      423.694

	with n =  100000000 element arrays
	generated on | computed on | total time |  speedup  
	cpu           cpu           361.38911      1.0
	cpu           gpu           426.35468      0.848
	gpu           gpu           0.79917      452.207
	
	--
	
	I guess CPU-CPU computation would have taken close to an hour for the next largest array.
	
	GPU-GPU can compute up to 1000000000 element arrays (10.42998 seconds). 
	The program crashes on addition of arrays of the next largest size with the following error:

	Execution of the command buffer was aborted due to an error during execution. 
	Insufficient Memory (00000008:kIOGPUCommandBufferCallbackErrorOutOfMemory)
