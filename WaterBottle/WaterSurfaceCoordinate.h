//
//  WaterSurfaceCoordinate.h
//  WaterBottle
//
//  Created by Firman Wijaya on 2/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaterSurfaceCoordinate : NSObject{
    int decreaseGap; // how much to decrease when disedot
    NSMutableDictionary *_ellipseMap;
    NSMutableDictionary *_yMap;
    CGPoint center;
}
+(WaterSurfaceCoordinate *) instance;
@property (readonly) int decreaseGap;
@property (readonly) NSDictionary *yMap;
@end
