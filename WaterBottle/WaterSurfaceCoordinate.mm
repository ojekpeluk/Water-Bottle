//
//  WaterSurfaceCoordinate.mm
//  WaterBottle
//
//  Created by Firman Wijaya on 2/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "WaterSurfaceCoordinate.h"
#import "cocos2d.h"

@interface WaterSurfaceCoordinate()
-(WaterSurfaceCoordinate*) initSettings;
-(void) createMap;
-(void) fillEllipseMap;
-(void) caseOne;
-(void) caseThreeWithA:(float)numA andB:(float)numB;
-(float) getXForLowerAngle:(float) angle withA:(float) a withB:(float) b;
-(float) getYForLowerAngle:(float) angle withX:(float) x;
@end

@implementation WaterSurfaceCoordinate

@synthesize decreaseGap, yMap = _yMap;

+(WaterSurfaceCoordinate *) instance{
    
    // Persistent instance
    static WaterSurfaceCoordinate * instance = nil;
    
    if(instance != nil){
        return instance;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    // Allocates once with Grand Central Dispatch (GCD) routine.
    // It's thread safe.
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      instance = [[WaterSurfaceCoordinate alloc] initSettings];
                  });
#else
    // Allocates once using the old approach, it's slower.
    // It's thread safe.
    @synchronized([Settings class])
    {
        // The synchronized instruction will make sure,
        // that only one thread will access this point at a time.
        if (instance == nil)
        {
            instance = [[WaterSurfaceCoordinate alloc] initSettings];
        }
    }
#endif
    
    return instance;
}

-(WaterSurfaceCoordinate*) initSettings{
    self = [super init];
    if(self){
        decreaseGap = 10;
        [self createMap];
    }
    return self;
}

-(void) createMap{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    center = CGPointMake(screenSize.width/2, screenSize.height/2 + 10 * decreaseGap);
    
    _yMap = [[NSMutableDictionary dictionary] retain];
    for(int y = screenSize.height/2; y < screenSize.height; y += decreaseGap){
        center.y = y;
        [self fillEllipseMap];
        [_yMap setObject:_ellipseMap forKey:[NSNumber numberWithInt:y]];
    }
}

-(void) fillEllipseMap{
    _ellipseMap = [NSMutableDictionary dictionary];
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    float centerY = screenSize.height/2;
    float vertDistanceToCenter = center.y - centerY;
    float b = ABS(vertDistanceToCenter);
    float a = b * screenSize.width / screenSize.height;
    if(b == 0){
        // Di tengah-tengah
        [self caseOne];
    }else{
        // Center ada diatas
        [self caseThreeWithA:a andB:b];
    }
}

-(void) caseOne{
    // Di tengah-tengah (approx)
    for(float f = 0.00; f < M_PI; f += 0.01){
        int key = f * 100;
        
        [_ellipseMap setObject:[NSValue valueWithCGPoint:center] forKey:[NSNumber numberWithInt:key]];
        [_ellipseMap setObject:[NSValue valueWithCGPoint:center] forKey:[NSNumber numberWithInt:-key]];
        
    }
    int key = M_PI * 100;
    [_ellipseMap setObject:[NSValue valueWithCGPoint:center] forKey:[NSNumber numberWithInt:key]];
    [_ellipseMap setObject:[NSValue valueWithCGPoint:center] forKey:[NSNumber numberWithInt:-key]];
}

-(void) caseThreeWithA:(float)numA andB:(float)numB{
    // Center ada dibawah
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    for(float f = 0.00; f < M_PI; f += 0.01){
        int key = f * 100;
        
        // Positive angle
        float x = [self getXForLowerAngle:f withA:numA withB:numB];
        float y = [self getYForLowerAngle:f withX:x];
        // the calculation is based on the assumption that the center of the ellipse is at (0,0)
        // translate it, because our ellipse is centered at (width/2, height/2)
        x = x + screenSize.width/2;
        y = y + screenSize.height/2;
        CGPoint point = CGPointMake(x, y);
        [_ellipseMap setObject:[NSValue valueWithCGPoint:point] forKey:[NSNumber numberWithInt:key]];
        
        // Negative angle
        x = [self getXForLowerAngle:-f withA:numA withB:numB];
        y = [self getYForLowerAngle:-f withX:x];
        // the calculation is based on the assumption that the center of the ellipse is at (0,0)
        // translate it, because our ellipse is centered at (width/2, height/2)
        x = x + screenSize.width/2;
        y = y + screenSize.height/2;
        point = CGPointMake(x, y);
        [_ellipseMap setObject:[NSValue valueWithCGPoint:point] forKey:[NSNumber numberWithInt:-key]];
    }
    int key = M_PI * 100;
    // Positive angle
    float x = [self getXForLowerAngle:M_PI withA:numA withB:numB];
    float y = [self getYForLowerAngle:M_PI withX:x];
    // the calculation is based on the assumption that the center of the ellipse is at (0,0)
    // translate it, because our ellipse is centered at (width/2, height/2)
    x = x + screenSize.width/2;
    y = y + screenSize.height/2;
    CGPoint point = CGPointMake(x, y);
    [_ellipseMap setObject:[NSValue valueWithCGPoint:point] forKey:[NSNumber numberWithInt:key]];
    // Negative angle
    x = [self getXForLowerAngle:-M_PI withA:numA withB:numB];
    y = [self getYForLowerAngle:-M_PI withX:x];
    // the calculation is based on the assumption that the center of the ellipse is at (0,0)
    // translate it, because our ellipse is centered at (width/2, height/2)
    x = x + screenSize.width/2;
    y = y + screenSize.height/2;
    point = CGPointMake(x, y);
    [_ellipseMap setObject:[NSValue valueWithCGPoint:point] forKey:[NSNumber numberWithInt:-key]];
}

// Find point on eclipse given the angle
// See: http://math.stackexchange.com/questions/22064/calculating-a-point-that-lies-on-an-ellipse-given-an-angle
-(float) getXForLowerAngle:(float) angle withA:(float) a withB:(float) b{
    float tana = tanf(angle);
    float temp = b*b + a*a*tana*tana;
    float result = a * b / sqrtf(temp);
    if(angle < M_PI_2 && angle > -M_PI_2){
        return result;
    }else{
        return -result;
    }
}

-(float) getYForLowerAngle:(float) angle withX:(float) x{
    return tanf(angle)*x;
}

@end
