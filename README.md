# mazegen
Random maze generator using Verilog and Assembly.

Random numbers are generated from the lower bits of the accelerometer which determines the path direction of the maze. Uses a DFS style method of generating the maze: we generate a path until it can no longer grow then goes back to the next available branch point along original path until the maze is full. 
