//
//  SKBitmap.swift
//  SkiaKit
//
//  Created by Michael Bullington on 3/9/21.
//  Copyright © 2019 Miguel de Icaza. All rights reserved.
//

#if canImport(CSkiaSharp)
import CSkiaSharp
#endif

public enum GRSurfaceOrigin {
    case topLeft
    case bottomLeft
}

public typealias CString = UnsafePointer<UInt8>

public typealias GRGLGetProcCallback = (_ ctx: UnsafeMutableRawPointer?, _ name: CString?) -> gr_gl_func_ptr

public final class GRGLInterface {
    var handle: OpaquePointer
    
    public init (handle: OpaquePointer)
    {
        self.handle = handle
    }

    public static func createNativeInterface() -> GRGLInterface? {
        guard let ptr = gr_glinterface_create_native_interface() else {
            return nil
        }

        return GRGLInterface(handle: ptr)
    }

    // public static func assembleGLInterface(ctx: UnsafeMutableRawPointer? = nil, getProc: GRGLGetProcCallback) -> GRGLInterface? {
    //     let ptr = gr_glinterface_assemble_gl_interface(ctx, getProc)
    
    //     guard ptr != nil else {
    //         return nil
    //     }

    //     return GRGLInterface(handle: ptr!)
    // }

    // public static func assembleGLESInterface(ctx: UnsafeMutableRawPointer? = nil, getProc: GRGLGetProcCallback) -> GRGLInterface? {
    //     let ptr = gr_glinterface_assemble_gles_interface(ctx, getProc)
    
    //     guard ptr != nil else {
    //         return nil
    //     }

    //     return GRGLInterface(handle: ptr!)
    // }
}

public final class GRContext {
    var handle: OpaquePointer
    
    init (handle: OpaquePointer)
    {
        self.handle = handle
    }

    public static func makeGL(interface: GRGLInterface? = nil) -> GRContext? {
        guard let handle = gr_context_make_gl(interface != nil ? interface!.handle : nil) else {
            return nil
        }

        return GRContext(handle: handle)
    }
}

public final class GRBackendRenderTarget {
    var handle: OpaquePointer

    // https://github.com/google/skia/blob/master/src/gpu/gl/GrGLDefines.h#L519
    static let rgba8: CUnsignedInt = 0x8058

    init (handle: OpaquePointer) {
        self.handle = handle
    }

    public static func makeGL(width: CInt, height: CInt, samples: CInt, stencils: CInt, fFBOID: CUnsignedInt) -> GRBackendRenderTarget? {
        var info = gr_gl_framebufferinfo_t(
            fFBOID: fFBOID,
            fFormat: rgba8
        )

        guard let handle = gr_backendrendertarget_new_gl(width, height, samples, stencils, &info) else {
            return nil
        }

        return GRBackendRenderTarget(handle: handle)
    }
}