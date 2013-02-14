//
//  WaterSurfaceCoordinate.h
//  WaterBottle
//
//  Created by Firman Wijaya on 2/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@class HelloWorldLayer;
typedef struct
{
    GLfloat x;
    GLfloat y;
    GLfloat z;
} Vertex3D;

static inline Vertex3D Vertex3DMake(CGFloat inX, CGFloat inY, CGFloat inZ)
{
    Vertex3D ret;
    ret.x = inX;
    ret.y = inY;
    ret.z = inZ;
    return ret;
}

typedef struct
{
    Vertex3D v1;
    Vertex3D v2;
    Vertex3D v3;
} Triangle3D;

typedef struct
{
    GLfloat r;
    GLfloat g;
    GLfloat b;
    GLfloat a;
} Color3D;

static inline Color3D Color3DMake(CGFloat inR, CGFloat inG, CGFloat inB, CGFloat inA)
{
    Color3D ret;
    ret.r = inR;
    ret.g = inG;
    ret.b = inB;
    ret.a = inA;
    return ret;
}

@interface WaterLine : CCNode{
    b2World *world ;
    b2Body *waterBody;
    int decreaseGap; // how much to decrease when disedot
    NSMutableDictionary *_ellipseMap;
    NSMutableDictionary *_yMap;
    CGPoint center;
    // OpenGL draw
    Vertex3D *vertices, *textVertices;
    Color3D *colors;
}
@property (readonly) int decreaseGap;
@property (readonly) NSDictionary *yMap;
@property (assign) HelloWorldLayer *layer;
+(id) waterLineWithWorld:(b2World *)world;
-(void) decrease;
-(void) updatePosWithAccelX:(float)accelXNum andAccelY:(float)accelYNum;
@end
