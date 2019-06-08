DerelictCuRAND
============

A dynamic binding to cuRAND of CUDA for the D Programming Language.


Please see the pages [Building and Linking Derelict][2] and [Using Derelict][3], in the Derelict documentation, for information on how to build DerelictCUDA and load the CUDA library at run time. In the meantime, here's some sample code.

```D
import derelict.curand;

void main() {
  DerelictCuRAND.load();
  ...
}
```

[1] http://www.nvidia.com/object/cuda_home_new.html
[2]: http://derelictorg.github.io/compiling.html
[3]: http://derelictorg.github.io/using.html
