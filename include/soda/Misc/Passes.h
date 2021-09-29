//===- Passes.h - soda-opt pass entry points --------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This header file defines prototypes that expose pass constructors.
//
//===----------------------------------------------------------------------===//

#ifndef SODA_MISC_PASSES_H
#define SODA_MISC_PASSES_H

#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassRegistry.h"
#include <memory>

namespace mlir {
class Pass;
} // namespace mlir

namespace mlir {
namespace memref {
class DeallocOp;
} // namespace memref
} // namespace mlir

namespace mlir {
namespace soda {

//===----------------------------------------------------------------------===//
// Misc
//===----------------------------------------------------------------------===//
std::unique_ptr<mlir::Pass> createTestPrintOpNestingPass();
std::unique_ptr<mlir::Pass> createTestArgumentsToXMLPass();

std::unique_ptr<mlir::Pass> createEraseMemrefDeallocPass();
void populateEraseMemrefDeallocPattern(RewritePatternSet &patterns);

//===----------------------------------------------------------------------===//
// Optimizations
//===----------------------------------------------------------------------===//

/// Performs packing (or explicit copying) of accessed memref regions into
/// buffers in the specified faster memory space through either pointwise copies
/// or DMA operations.
std::unique_ptr<OperationPass<FuncOp>> createAffineDataCopyGenPass(
    unsigned slowMemorySpace, unsigned fastMemorySpace,
    unsigned tagMemorySpace = 0, int minDmaTransferSize = 1024,
    uint64_t fastMemCapacityBytes = std::numeric_limits<uint64_t>::max(),
    bool generateDma = false);

std::unique_ptr<OperationPass<FuncOp>>
createAffineLoopTilingPass(unsigned tileSize);

//===----------------------------------------------------------------------===//
// Lowerings
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Register passes
//===----------------------------------------------------------------------===//

/// Include the auto-generated definitions for passes
// TODO: only the registration call is necessary. Move pass class decls to
// another file
#define GEN_PASS_CLASSES
#include "soda/Misc/SODAMiscPasses.h.inc"

#define GEN_PASS_REGISTRATION
#include "soda/Misc/SODAMiscPasses.h.inc"

} // namespace soda
} // namespace mlir

#endif // SODA_MISC_PASSES_H
