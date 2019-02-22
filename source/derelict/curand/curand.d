// Copyright 2019, University of Freiburg.
// Chair of Algorithms and Data Structures.
// Markus Näther <naetherm@informatik.uni-freiburg.de>

module derelict.curand;

import derelict.util.loader;
import derelct.cuda;

private
{
  import derelict.util.system;

  static if(Derelict_OS_Windows)
    enum libNames = "curand32_100.dll,curand64_100.dll";
  else static if (Derelict_OS_Mac)
    enum libNames = "libcurand.dylib,/usr/local/lib/libcurand.dylib";
  else static if (Derelict_OS_Linux)
  {
    version(X86)
      enum libNames = "libcurand.so,libcurand.so.10.0,/opt/cuda/lib/libcurand.so";
    else version(X86_64)
      enum libNames = "libcurand.so,libcurand.so.10.0,/opt/cuda/lib64/libcurand.so,/usr/lib/x86_64-linux-gnu/libcurand.so.10.0";
    else
      static assert(0, "Need to implement CUDA libNames for this arch.");
  }
  else
    static assert(0, "Need to implement CUDA libNames for this operating system.");
}





/**
 * CURAND function call status types
 */
alias curandStatus = int;
enum : curandStatus {
  CURAND_STATUS_SUCCESS = 0, ///< No errors
  CURAND_STATUS_VERSION_MISMATCH = 100, ///< Header file and linked library version do not match
  CURAND_STATUS_NOT_INITIALIZED = 101, ///< Generator not initialized
  CURAND_STATUS_ALLOCATION_FAILED = 102, ///< Memory allocation failed
  CURAND_STATUS_TYPE_ERROR = 103, ///< Generator is wrong type
  CURAND_STATUS_OUT_OF_RANGE = 104, ///< Argument out of range
  CURAND_STATUS_LENGTH_NOT_MULTIPLE = 105, ///< Length requested is not a multple of dimension
  CURAND_STATUS_DOUBLE_PRECISION_REQUIRED = 106, ///< GPU does not have double precision required by MRG32k3a
  CURAND_STATUS_LAUNCH_FAILURE = 201, ///< Kernel launch failure
  CURAND_STATUS_PREEXISTING_FAILURE = 202, ///< Preexisting failure on library entry
  CURAND_STATUS_INITIALIZATION_FAILED = 203, ///< Initialization of CUDA failed
  CURAND_STATUS_ARCH_MISMATCH = 204, ///< Architecture mismatch, GPU does not support requested feature
  CURAND_STATUS_INTERNAL_ERROR = 999 ///< Internal library error
}

/*
 * CURAND function call status types
*/
/** \cond UNHIDE_TYPEDEFS */
alias curandStatus_t = curandStatus;
/** \endcond */

/**
 * CURAND generator types
 */
alias curandRngType = int;
enum : curandRngType {
  CURAND_RNG_TEST = 0,
  CURAND_RNG_PSEUDO_DEFAULT = 100, ///< Default pseudorandom generator
  CURAND_RNG_PSEUDO_XORWOW = 101, ///< XORWOW pseudorandom generator
  CURAND_RNG_PSEUDO_MRG32K3A = 121, ///< MRG32k3a pseudorandom generator
  CURAND_RNG_PSEUDO_MTGP32 = 141, ///< Mersenne Twister MTGP32 pseudorandom generator
  CURAND_RNG_PSEUDO_MT19937 = 142, ///< Mersenne Twister MT19937 pseudorandom generator
  CURAND_RNG_PSEUDO_PHILOX4_32_10 = 161, ///< PHILOX-4x32-10 pseudorandom generator
  CURAND_RNG_QUASI_DEFAULT = 200, ///< Default quasirandom generator
  CURAND_RNG_QUASI_SOBOL32 = 201, ///< Sobol32 quasirandom generator
  CURAND_RNG_QUASI_SCRAMBLED_SOBOL32 = 202,  ///< Scrambled Sobol32 quasirandom generator
  CURAND_RNG_QUASI_SOBOL64 = 203, ///< Sobol64 quasirandom generator
  CURAND_RNG_QUASI_SCRAMBLED_SOBOL64 = 204  ///< Scrambled Sobol64 quasirandom generator
}

/*
 * CURAND generator types
 */
/** \cond UNHIDE_TYPEDEFS */
alias curandRngType_t = curandRngType;
/** \endcond */

/**
 * CURAND ordering of results in memory
 */
alias curandOrdering = int;
enum : curandOrdering {
  CURAND_ORDERING_PSEUDO_BEST = 100, ///< Best ordering for pseudorandom results
  CURAND_ORDERING_PSEUDO_DEFAULT = 101, ///< Specific default 4096 thread sequence for pseudorandom results
  CURAND_ORDERING_PSEUDO_SEEDED = 102, ///< Specific seeding pattern for fast lower quality pseudorandom results
  CURAND_ORDERING_QUASI_DEFAULT = 201 ///< Specific n-dimensional ordering for quasirandom results
}

/*
 * CURAND ordering of results in memory
 */
/** \cond UNHIDE_TYPEDEFS */
alias curandOrdering_t = curandOrdering;
/** \endcond */

/**
 * CURAND choice of direction vector set
 */
alias curandDirectionVectorSet = int;
enum : curandDirectionVectorSet {
  CURAND_DIRECTION_VECTORS_32_JOEKUO6 = 101, ///< Specific set of 32-bit direction vectors generated from polynomials recommended by S. Joe and F. Y. Kuo, for up to 20,000 dimensions
  CURAND_SCRAMBLED_DIRECTION_VECTORS_32_JOEKUO6 = 102, ///< Specific set of 32-bit direction vectors generated from polynomials recommended by S. Joe and F. Y. Kuo, for up to 20,000 dimensions, and scrambled
  CURAND_DIRECTION_VECTORS_64_JOEKUO6 = 103, ///< Specific set of 64-bit direction vectors generated from polynomials recommended by S. Joe and F. Y. Kuo, for up to 20,000 dimensions
  CURAND_SCRAMBLED_DIRECTION_VECTORS_64_JOEKUO6 = 104 ///< Specific set of 64-bit direction vectors generated from polynomials recommended by S. Joe and F. Y. Kuo, for up to 20,000 dimensions, and scrambled
}

/*
 * CURAND choice of direction vector set
 */
/** \cond UNHIDE_TYPEDEFS */
alias curandDirectionVectorSet_t = curandDirectionVectorSet;
/** \endcond */

/**
 * CURAND array of 32-bit direction vectors
 */
/** \cond UNHIDE_TYPEDEFS */
alias curandDirectionVectors32_t = uint[32];
/** \endcond */

 /**
 * CURAND array of 64-bit direction vectors
 */
/** \cond UNHIDE_TYPEDEFS */
alias curandDirectionVectors64_t = ulong[64];
/** \endcond **/

/**
 * CURAND generator (opaque)
 */
struct curandGenerator_st;

/**
 * CURAND generator
 */
/** \cond UNHIDE_TYPEDEFS */
alias curandGenerator_t = curandGenerator_st *;
/** \endcond */

/**
 * CURAND distribution
 */
/** \cond UNHIDE_TYPEDEFS */
alias curandDistribution_st = double;
alias curandDistribution_t = curandDistribution_st*;
alias curandDistributionShift_t = curandDistributionShift_st*;
/** \endcond */
/**
 * CURAND distribution M2
 */
/** \cond UNHIDE_TYPEDEFS */
alias curandDistributionM2Shift_t = curandDistributionM2Shift_st*;
alias curandHistogramM2_t = curandHistogramM2_st*;
alias curandHistogramM2K_st = uint;
alias curandHistogramM2K_t = curandHistogramM2K_st*;
alias curandHistogramM2V_st = curandDistribution_st;
alias curandHistogramM2V_t = curandHistogramM2V_st *;

alias curandDiscreteDistribution_t = curandDiscreteDistribution_st *;
/** \endcond */

/*
 * CURAND METHOD
 */
/** \cond UNHIDE_ENUMS */
alias curandMethod = int;
enum : curandMethod {
  CURAND_CHOOSE_BEST = 0, // choose best depends on args
  CURAND_ITR = 1,
  CURAND_KNUTH = 2,
  CURAND_HITR = 3,
  CURAND_M1 = 4,
  CURAND_M2 = 5,
  CURAND_BINARY_SEARCH = 6,
  CURAND_DISCRETE_GAUSS = 7,
  CURAND_REJECTION = 8,
  CURAND_DEVICE_API = 9,
  CURAND_FAST_REJECTION = 10,
  CURAND_3RD = 11,
  CURAND_DEFINITION = 12,
  CURAND_POISSON = 13
}

alias curandMethod_t = curandMethod;


extern(System) nothrow {

}


extern(System) @nogc nothrow {

da_curandCreateGenerator = curandStatus_t function(curandGenerator_t *generator, curandRngType_t rng_type);
da_curandCreateGeneratorHost = curandStatus_t function(curandGenerator_t *generator, curandRngType_t rng_type);
da_curandDestroyGenerator = curandStatus_t function(curandGenerator_t generator);
da_curandGetVersion = curandStatus_t function(int *version);
da_curandGetProperty = curandStatus_t function(libraryPropertyType type, int *value);
da_curandSetStream = curandStatus_t function(curandGenerator_t generator, cudaStream_t stream);
da_curandSetPseudoRandomGeneratorSeed = curandStatus_t function(curandGenerator_t generator, unsigned long long seed);
da_curandSetGeneratorOffset = curandStatus_t function(curandGenerator_t generator, unsigned long long offset);
da_curandSetGeneratorOrdering = curandStatus_t function(curandGenerator_t generator, curandOrdering_t order);
da_curandSetQuasiRandomGeneratorDimensions = curandStatus_t function(curandGenerator_t generator, unsigned int num_dimensions);
da_curandGenerate = curandStatus_t function(curandGenerator_t generator, unsigned int *outputPtr, size_t num);
da_curandGenerateLongLong = curandStatus_t function(curandGenerator_t generator, unsigned long long *outputPtr, size_t num);
da_curandGenerateUniform = curandStatus_t function(curandGenerator_t generator, float *outputPtr, size_t num);
da_curandGenerateUniformDouble = curandStatus_t function(curandGenerator_t generator, double *outputPtr, size_t num);
da_curandGenerateNormal = curandStatus_t function(curandGenerator_t generator, float *outputPtr, size_t n, float mean, float stddev);
da_curandGenerateNormalDouble = curandStatus_t function(curandGenerator_t generator, double *outputPtr, size_t n, double mean, double stddev);
da_curandGenerateLogNormal = curandStatus_t function(curandGenerator_t generator, float *outputPtr, size_t n, float mean, float stddev);
da_curandGenerateLogNormalDouble = curandStatus_t function(curandGenerator_t generator, double *outputPtr,size_t n, double mean, double stddev);
da_curandCreatePoissonDistribution = curandStatus_t function(double lambda, curandDiscreteDistribution_t *discrete_distribution);
da_curandDestroyDistribution = curandStatus_t function(curandDiscreteDistribution_t discrete_distribution);
da_curandGeneratePoisson = curandStatus_t function(curandGenerator_t generator, unsigned int *outputPtr,size_t n, double lambda);
da_curandGeneratePoissonMethod = curandStatus_t function(curandGenerator_t generator, unsigned int *outputPtr,size_t n, double lambda, curandMethod_t method);
da_curandGenerateBinomial = curandStatus_t function(curandGenerator_t generator, unsigned int *outputPtr,size_t num, unsigned int n, double p);
da_curandGenerateBinomialMethod = curandStatus_t function(curandGenerator_t generator,unsigned int *outputPtr,size_t num, unsigned int n, double p,curandMethod_t method);
da_curandGenerateSeeds = curandStatus_t function(curandGenerator_t generator);
da_curandGetDirectionVectors32 = curandStatus_t function(curandDirectionVectors32_t *vectors[], curandDirectionVectorSet_t set);
da_curandGetScrambleConstants32 = curandStatus_t function(unsigned int * * constants);
da_curandGetDirectionVectors64 = curandStatus_t function(curandDirectionVectors64_t *vectors[], curandDirectionVectorSet_t set);
da_curandGetScrambleConstants64 = curandStatus_t function(unsigned long long * * constants);

}

__gshared
{
  da_curandCreateGenerator curandCreateGenerator;
  da_curandCreateGeneratorHost curandCreateGeneratorHost;
  da_curandDestroyGenerator curandDestroyGenerator;
  da_curandGetVersion curandGetVersion;
  da_curandGetProperty curandGetProperty;
  da_curandSetStream curandSetStream;
  da_curandSetPseudoRandomGeneratorSeed curandSetPseudoRandomGeneratorSeed;
  da_curandSetGeneratorOffset curandSetGeneratorOffset;
  da_curandSetGeneratorOrdering curandSetGeneratorOrdering;
  da_curandSetQuasiRandomGeneratorDimensions curandSetQuasiRandomGeneratorDimensions;
  da_curandGenerate curandGenerate;
  da_curandGenerateLongLong curandGenerateLongLong;
  da_curandGenerateUniform curandGenerateUniform;
  da_curandGenerateUniformDouble curandGenerateUniformDouble;
  da_curandGenerateNormal curandGenerateNormal;
  da_curandGenerateNormalDouble curandGenerateNormalDouble;
  da_curandGenerateLogNormal curandGenerateLogNormal;
  da_curandGenerateLogNormalDouble curandGenerateLogNormalDouble;
  da_curandCreatePoissonDistribution curandCreatePoissonDistribution;
  da_curandDestroyDistribution curandDestroyDistribution;
  da_curandGeneratePoisson curandGeneratePoisson;
  da_curandGeneratePoissonMethod curandGeneratePoissonMethod;
  da_curandGenerateBinomial curandGenerateBinomial;
  da_curandGenerateBinomialMethod curandGenerateBinomialMethod;
  da_curandGenerateSeeds curandGenerateSeeds;
  da_curandGetDirectionVectors32 curandGetDirectionVectors32;
  da_curandGetScrambleConstants32 curandGetScrambleConstants32;
  da_curandGetDirectionVectors64 curandGetDirectionVectors64;
  da_curandGetScrambleConstants64 curandGetScrambleConstants64;
}

// Runtime API loader
class DerelictCuBLASLoader : SharedLibLoader
{
  protected
  {
    override void loadSymbols()
    {
      bindFunc(cast(void**)&curandCreateGenerator, "curandCreateGenerator");
      bindFunc(cast(void**)&curandCreateGeneratorHost, "curandCreateGeneratorHost");
      bindFunc(cast(void**)&curandDestroyGenerator, "curandDestroyGenerator");
      bindFunc(cast(void**)&curandGetVersion, "curandGetVersion");
      bindFunc(cast(void**)&curandGetProperty, "curandGetProperty");
      bindFunc(cast(void**)&curandSetStream, "curandSetStream");
      bindFunc(cast(void**)&curandSetPseudoRandomGeneratorSeed, "curandSetPseudoRandomGeneratorSeed");
      bindFunc(cast(void**)&curandSetGeneratorOffset, "curandSetGeneratorOffset");
      bindFunc(cast(void**)&curandSetGeneratorOrdering, "curandSetGeneratorOrdering");
      bindFunc(cast(void**)&curandSetQuasiRandomGeneratorDimensions, "curandSetQuasiRandomGeneratorDimensions");
      bindFunc(cast(void**)&curandGenerate, "curandGenerate");
      bindFunc(cast(void**)&curandGenerateLongLong, "curandGenerateLongLong");
      bindFunc(cast(void**)&curandGenerateUniform, "curandGenerateUniform");
      bindFunc(cast(void**)&curandGenerateUniformDouble, "curandGenerateUniformDouble");
      bindFunc(cast(void**)&curandGenerateNormal, "curandGenerateNormal");
      bindFunc(cast(void**)&curandGenerateNormalDouble, "curandGenerateNormalDouble");
      bindFunc(cast(void**)&curandGenerateLogNormal, "curandGenerateLogNormal");
      bindFunc(cast(void**)&curandGenerateLogNormalDouble, "curandGenerateLogNormalDouble");
      bindFunc(cast(void**)&curandCreatePoissonDistribution, "curandCreatePoissonDistribution");
      bindFunc(cast(void**)&curandDestroyDistribution, "curandDestroyDistribution");
      bindFunc(cast(void**)&curandGeneratePoisson, "curandGeneratePoisson");
      bindFunc(cast(void**)&curandGeneratePoissonMethod, "curandGeneratePoissonMethod");
      bindFunc(cast(void**)&curandGenerateBinomial, "curandGenerateBinomial");
      bindFunc(cast(void**)&curandGenerateBinomialMethod, "curandGenerateBinomialMethod");
      bindFunc(cast(void**)&curandGenerateSeeds, "curandGenerateSeeds");
      bindFunc(cast(void**)&curandGetDirectionVectors32, "curandGetDirectionVectors32");
      bindFunc(cast(void**)&curandGetScrambleConstants32, "curandGetScrambleConstants32");
      bindFunc(cast(void**)&curandGetDirectionVectors64, "curandGetDirectionVectors64");
      bindFunc(cast(void**)&curandGetScrambleConstants64, "curandGetScrambleConstants64");
    }
  }

  public
  {
    this()
    {
      super(libNames);
    }
  }
}

__gshared DerelictCuBLASLoader DerelictCuBLAS;

shared static this()
{
  DerelictCuBLAS = new DerelictCuBLASLoader();
}
