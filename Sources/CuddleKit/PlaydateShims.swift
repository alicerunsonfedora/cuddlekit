//
//  PlaydateShims.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 01-05-2026.
//

// NOTE(marquiskurt): These shims are added to make sure that the Playdate is supported when building for the device.
// The flags "--extra-device-o-files-build-dirs CKDL.build/src" are also required, due to some dependency searching
// errors that prevent CKDL from being located.

#if Playdate
    @_silgen_name("_exit")
    func _exit(_ status: Int32) -> Never {
        while true {
            // Do nothing.
        }
    }
#endif
