#!/bin/bash
download=false
out=SkiaSharp.xcframework

while test x$1 != x; do
    case x in
	--download)
	    download=true
	    ;;
	--help)
	    echo "Usage is: $0 [--download] [--out=FILE]"
	    echo Output defaults to SkiaSharp.xcframework
	    exit 0
	    ;;
	--out=*)
	    ;;
    esac
done

if $download; then
    V=2.88.4-preview.70
    https://www.nuget.org/api/v2/package/SkiaSharp.NativeAssets.macOS/
    
    base=https://www.nuget.org/api/v2/package/SkiaSharp.NativeAssets
    
    for x in tvOS macOS iOS; do
        curl -L -o $x.zip $base.{$x}/$V
        unzip -d $x $x.zip
    done
fi

# used below in build methods
lipo_skiasharp() {
    local folder_name="$1"
    local arch="$2"
    local path=$folder_name/libSkiaSharp.framework/libSkiaSharp
    
    lipo -extract $arch $path -output $path
}

rm -rf build
mkdir build

# iOS
build_ios() {
    mkdir build/iOS
    cp -a iOS/runtimes/ios/native/libSkiaSharp.framework  build/iOS/libSkiaSharp.framework

    # Painfully separate all architectures.
    cp -a build/iOS build/iOS-x86_64
    cp -a build/iOS build/iOS-arm64
    rm -rf build/iOS

    # Remove other architectures.
    lipo_skiasharp build/iOS-x86_64 x86_64
    lipo_skiasharp build/iOS-arm64 arm64
}
build_ios

# tvOS
build_tvos() {
    mkdir build/tvOS
    cp -a tvOS/runtimes/tvos/native/libSkiaSharp.framework build/tvOS/libSkiaSharp.framework

    # Painfully separate all architectures.
    cp -a build/tvOS build/tvOS-x86_64
    cp -a build/tvOS build/tvOS-arm64
    rm -rf build/tvOS

    # Remove other architectures.
    lipo_skiasharp build/tvOS-x86_64 x86_64
    lipo_skiasharp build/tvOS-arm64 arm64
}
build_tvos

# macOS
build_macos() {
    mkdir -p build/macOS-x86_64/libSkiaSharp.framework

    cp macOS/runtimes/osx/native/libSkiaSharp.dylib  .
    # https://stackoverflow.com/questions/57755276/create-ios-framework-with-dylib
    lipo libSkiaSharp.dylib -output libSkiaSharp -create 
    install_name_tool -id @rpath/libSkiaSharp.framework/libSkiaSharp libSkiaSharp

    mv libSkiaSharp build/macOS-x86_64/libSkiaSharp.framework/
    rm libSkiaSharp.dylib

    cp MacOSFramework/Info.plist build/macOS-x86_64/libSkiaSharp.framework/Info.plist
}
build_macos

rm -rf $out

create_xcframework() {
    # Create XCFramework.
    xcodebuild -create-xcframework \
            -framework build/iOS-x86_64/libSkiaSharp.framework \
            -framework build/iOS-arm64/libSkiaSharp.framework \
            -framework build/tvOS-x86_64/libSkiaSharp.framework \
            -framework build/tvOS-arm64/libSkiaSharp.framework \
            -framework build/macOS-x86_64/libSkiaSharp.framework \
            -output SkiaSharp.xcframework
}
create_xcframework
rm -rf build
