//
//  FIImport.h
//  Pods
//

#ifndef FIImport_h
#define FIImport_h

#if TARGET_OS_IOS
#import <CoreText/CoreText.h>
typedef UIImage FIImage;
typedef UIFont FIFont;
typedef UIColor FIColor;
typedef UIBezierPath FIBezierPath;
typedef UIFont FIFont;
#endif

#if TARGET_OS_OSX
#import <CoreText/CoreText.h>
typedef NSImage FIImage;
typedef NSFont FIFont;
typedef NSColor FIColor;
typedef NSBezierPath FIBezierPath;
typedef NSFont FIFont;
#endif

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#elif TARGET_OS_IOS
#import <Flutter/Flutter.h>
#endif

#endif /* PMImport_h */
