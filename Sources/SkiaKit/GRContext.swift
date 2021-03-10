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

public final class GRContext {
    var handle: OpaquePointer
    
    init (handle: OpaquePointer)
    {
        self.handle = handle
    }

    // Right now cannot be called with any arguments.
    //
    // This is the same as passing 'nil', where it will translate into GL calls for the current
    // context.
    public static func makeGL() -> GRContext? {
        guard let grContextPtr = gr_context_make_gl(nil) else {
            return nil
        }

        return GRContext(handle: grContextPtr)
    }
}