# hello-swift
Some basic programming with Swift (and Metal of course)

Adds 2 arrays of random numbers on the GPU.

Random numebers are generated in 2 ways:
  CPU - An array of floats is created, random numbers are assigned serially by the CPU.
  GPU - A buffer is created and bound to an array of floats, then the GPU computes each random number in parallel.
  
Outputs the total time and compute time for computing the sum array of each addend-pair of arrays.

--

In general, compute time is slightly higher with arrays with GPU-generated random numbers.
3000000 but not 30000000 element array addition has much lower total time when random numbers are GPU-generated.

--

I don't know why compute time is greater for GPU-generated (rather than CPU-generated) random numbers.
I don't know why total time becomes more similar with larger arrays.
