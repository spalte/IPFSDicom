//
//  IPFSDicomPlugin.h
//  IPFSDicomPlugin
//
//  Created by Joël Spaltenstein on 5/12/17.
//  Copyright © 2017 Spaltenstein Natural Image. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class ViewerController;
@class DicomSeries;


@interface PluginFilter : NSObject
{
    ViewerController* viewerController;
}
- (void)initPlugin;

// these are actually on ViewerController, but we just need to have them defined somewhere so that the compiler knows the signature
- (NSMutableArray*)pixList:(long)i;
- (float) computeInterval;

- (DicomSeries *)seriesObj; // this is actually on DCMPix, but we just need to have it defined somewhere so that the compiler knows the signature

@end

@class GetIPFSDicomWindowController;

@interface IPFSDicomPlugin : PluginFilter
{
    NSMutableArray *_volumesToOpen;
}

/** This function is called to apply your plugin */
- (long) filterImage: (NSString*) menuName;

/** This function is the entry point of Pre-Process plugins */
- (long) processFiles: (NSMutableArray*) files;


@end

