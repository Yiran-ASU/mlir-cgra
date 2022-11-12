#map0 = affine_map<(d0, d1)[s0] -> (d0 * 16 + s0 + d1)>
#map1 = affine_map<(d0, d1)[s0] -> (d0 * 32 + s0 + d1)>
#map2 = affine_map<(d0) -> (-d0 + 16, 256)>
module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu", soda.container_module} {
  func.func private @cgra_fusion_add_max_add(memref<?x16xf32, #map0>, memref<?x16xf32, #map0>, memref<?x16xf32, #map0>, memref<?x16xf32, #map0>)
  func.func private @cgra_matmul(memref<4x16xf32, #map1>, memref<16x4xf32, #map0>, memref<4x4xf32, #map0>)
  func.func @main_graph(%arg0: memref<16x32xf32>, %arg1: memref<32x16xf32>, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>, %arg4: memref<16x16xf32>) attributes {input_names = ["X0", "X1", "X2", "X3"], output_names = ["Z0"]} {
    %c0 = arith.constant 0 : index
    %c16 = arith.constant 16 : index
    %c4 = arith.constant 4 : index
    %c32 = arith.constant 32 : index
    %c256 = arith.constant 256 : index
    %cst = arith.constant 0.000000e+00 : f32
    %0 = memref.alloc() {alignment = 128 : i64} : memref<16x16xf32>
    linalg.fill ins(%cst : f32) outs(%0 : memref<16x16xf32>)
    %1 = memref.alloc() {alignment = 128 : i64} : memref<16x16xf32>
    memref.copy %0, %1 : memref<16x16xf32> to memref<16x16xf32>
    memref.dealloc %0 : memref<16x16xf32>
    scf.for %arg5 = %c0 to %c16 step %c4 {
      scf.for %arg6 = %c0 to %c16 step %c4 {
        scf.for %arg7 = %c0 to %c32 step %c16 {
          %3 = memref.subview %arg0[%arg5, %arg7] [4, 16] [1, 1] : memref<16x32xf32> to memref<4x16xf32, #map1>
          %4 = memref.subview %arg1[%arg7, %arg6] [16, 4] [1, 1] : memref<32x16xf32> to memref<16x4xf32, #map0>
          %5 = memref.subview %1[%arg5, %arg6] [4, 4] [1, 1] : memref<16x16xf32> to memref<4x4xf32, #map0>
          func.call @cgra_matmul(%3, %4, %5) : (memref<4x16xf32, #map1>, memref<16x4xf32, #map0>, memref<4x4xf32, #map0>) -> ()
        }
      }
    }
    %2 = memref.alloc() {alignment = 128 : i64} : memref<16x16xf32>
    scf.for %arg5 = %c0 to %c16 step %c256 {
      %3 = affine.min #map2(%arg5)
      %4 = affine.min #map2(%arg5)
      %5 = affine.min #map2(%arg5)
      %6 = affine.min #map2(%arg5)
      %7 = memref.subview %1[%arg5, 0] [%3, 16] [1, 1] : memref<16x16xf32> to memref<?x16xf32, #map0>
      %8 = memref.subview %arg2[%arg5, 0] [%4, 16] [1, 1] : memref<16x16xf32> to memref<?x16xf32, #map0>
      %9 = memref.subview %arg3[%arg5, 0] [%5, 16] [1, 1] : memref<16x16xf32> to memref<?x16xf32, #map0>
      %10 = memref.subview %2[%arg5, 0] [%6, 16] [1, 1] : memref<16x16xf32> to memref<?x16xf32, #map0>
      func.call @cgra_fusion_add_max_add(%7, %8, %9, %10) : (memref<?x16xf32, #map0>, memref<?x16xf32, #map0>, memref<?x16xf32, #map0>, memref<?x16xf32, #map0>) -> ()
    }
    memref.dealloc %1 : memref<16x16xf32>
    memref.copy %2, %arg4 : memref<16x16xf32> to memref<16x16xf32>
    return
  }
}

