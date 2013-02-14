//
//  WaterSurfaceCoordinate.mm
//  WaterBottle
//
//  Created by Firman Wijaya on 2/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import "WaterLine.h"
#import "HelloWorldLayer.h"
#define PTM_RATIO 32
@interface WaterLine()
@property BOOL init;
-(id) initWithWorld:(b2World*) world;
-(void) createPhysics;
-(void) createMap;
-(void) fillEllipseMap;
-(void) caseOne;
-(void) caseThreeWithA:(float)numA andB:(float)numB;
-(float) getXForLowerAngle:(float) angle withA:(float) a withB:(float) b;
-(float) getYForLowerAngle:(float) angle withX:(float) x;
@end

@implementation WaterLine

@synthesize decreaseGap, yMap = _yMap, init, layer;

- (void) draw {
//    float x = point1Body->GetPosition().x * PTM_RATIO * CC_CONTENT_SCALE_FACTOR();
//    float y = point1Body->GetPosition().y * PTM_RATIO * CC_CONTENT_SCALE_FACTOR();
//    vertices[0] = Vertex3DMake(x, y, 0);
//    x = point2Body->GetPosition().x * PTM_RATIO * CC_CONTENT_SCALE_FACTOR();
//    y = point2Body->GetPosition().y * PTM_RATIO * CC_CONTENT_SCALE_FACTOR();
//    vertices[1] = Vertex3DMake(x, y, 0);
//    x = point3Body->GetPosition().x * PTM_RATIO * CC_CONTENT_SCALE_FACTOR();
//    y =  point3Body->GetPosition().y * PTM_RATIO * CC_CONTENT_SCALE_FACTOR();
//    vertices[2] = Vertex3DMake(x, y, 0);
//    x = point4Body->GetPosition().x * PTM_RATIO * CC_CONTENT_SCALE_FACTOR();
//    y = point4Body->GetPosition().y * PTM_RATIO * CC_CONTENT_SCALE_FACTOR();
//    vertices[3] = Vertex3DMake(x, y, 0);
    /*
     // Enable texture mapping stuff
     glEnable(GL_TEXTURE_2D);
     glEnableClientState(GL_TEXTURE_COORD_ARRAY);
     glDisableClientState(GL_COLOR_ARRAY);
     
     glColor4f(1.0, 1.0, 1.0, 0.8);
     // Bind the OpenGL texture
     glBindTexture(GL_TEXTURE_2D, layer.waterTexture.name);
     
     // Send the texture coordinates to OpenGL
     glTexCoordPointer(3, GL_FLOAT, 0, textVertices);
     // Send the polygon coordinates to OpenGL
     glVertexPointer(3, GL_FLOAT, 0, vertices);
     // Draw it
     glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
     
     glEnableClientState(GL_COLOR_ARRAY);
     */
    
    if(!self.init){
        self.init = TRUE;
        ccColor4B color = self.layer.waterColor;
        colors[0] = Color3DMake(color.r/255.f, color.g/255.f, color.b/255.f, 0.5);
        colors[1] = Color3DMake(color.r/255.f, color.g/255.f, color.b/255.f, 1.0);
        colors[2] = Color3DMake(color.r/255.f, color.g/255.f, color.b/255.f, 0.5);
        colors[3] = Color3DMake(color.r/255.f, color.g/255.f, color.b/255.f, 1.0);
    }
    
//	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//	glDisable(GL_TEXTURE_2D);
//    
//    // Send the polygon coordinates to OpenGL
//    glVertexPointer(3, GL_FLOAT, 0, vertices);
//    // Send the color array to OpenGL
//    glColorPointer(4, GL_FLOAT, 0, colors);
//    // Draw it
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    
//	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
//	glEnable(GL_TEXTURE_2D);
}

+(id) waterLineWithWorld:(b2World *)world_{
    return [[[self alloc] initWithWorld:world_] autorelease];
}

-(id) initWithWorld:(b2World *)world_{
    self = [super init];
    if(self){
        self.init = FALSE;
        decreaseGap = 10;
        self.position = ccp(0, 0);
        world = world_;
        [self createMap];
        [self createPhysics];
    }
    return self;
}

-(void) setPosition:(CGPoint)position{
    // Override kosong karena kita gag mau posisi water line ini diubah!
    // Sudah diset ccp(0,0) di init
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

-(void) createPhysics{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    colors = (Color3D*)malloc(sizeof(Color3D) * 4);
    vertices = (Vertex3D*)malloc(sizeof(Vertex3D) * 4);
    textVertices = (Vertex3D*)malloc(sizeof(Vertex3D) * 4);
    
    textVertices[1] = Vertex3DMake(0, 1.0, 0);
    textVertices[0] = Vertex3DMake(0, 0, 0);
    textVertices[3] = Vertex3DMake(1.0, 1.0, 0);
    textVertices[2] = Vertex3DMake(1.0, 0, 0);
    
    center = ccp(screenSize.width/2, screenSize.height/2 + 10 * decreaseGap);
    
    // Physics....
    b2BodyDef bodyDef;
    bodyDef.fixedRotation = FALSE;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(center.x/PTM_RATIO, center.y/PTM_RATIO);
    waterBody = world->CreateBody(&bodyDef);
    b2PolygonShape boxShape;
    boxShape.SetAsBox(320/PTM_RATIO, 2/PTM_RATIO, b2Vec2_zero, 0);
    b2FixtureDef fixDef;
    fixDef.shape = &boxShape;
    fixDef.isSensor = TRUE;
    fixDef.density = 2.0f;
    waterBody->CreateFixture(&fixDef);
    
}

-(void) decrease{
    center = ccp(center.x, center.y - decreaseGap);
}

-(float) getAngleWithAccelX:(float) accelX andAccelY:(float) accelY{
    
    int tempX = accelX * 100;
    int tempY = accelY * 100;
    float x = tempX / 100.0f;
    float y = tempY / 100.0f;
    float result = 0;
    
    if(y > 0){
        
        if(x > 0){
            result = M_PI_2 * (1 - x);
        }else if(x == 0){
            result = M_PI_2;
        }else{
            result = M_PI_2 + M_PI_2 * -x;
        }
        
    } else{
        
        if(x > 0){
            result = -M_PI_2 * (1 - x);
        }else if(x == 0){
            result = -M_PI_2;
        }else{
            result = -(M_PI_2 + M_PI_2 * -x);
        }
        
    }
    
    return result;
    
}

-(void) updatePosWithAccelX:(float)accelXNum andAccelY:(float)accelYNum{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    float angle = [self getAngleWithAccelX:accelXNum andAccelY:accelYNum] + M_PI_2;
    
    // I don't understand this part myself :p
    int key = (angle  + M_PI_2) * 100;
    int pi = M_PI * 100;
    if(key > pi){
        key = -(2 * pi - key);
    }else if(key < -pi){
        key = 2 * pi + key;
    }
    
    float yPos = center.y;
    if(yPos < screenSize.height/2){
        yPos = screenSize.height - yPos;
        if(key < 0){
            key = key + (M_PI * 100);
        }else{
            key = key - (M_PI * 100);
        }
    }
    
    id obj = [_yMap objectForKey:[NSNumber numberWithInt:yPos]];
    if(obj == nil){
        return;
    }
    NSDictionary *ellipseMap = (NSMutableDictionary*) obj;
    id val = [ellipseMap objectForKey:[NSNumber numberWithInt:key]];
    if(val == nil){
        return;
    }
    CGPoint point = [val CGPointValue];
    point.x = point.x/PTM_RATIO;
    point.y = point.y/PTM_RATIO;
    b2Vec2 temp = b2Vec2(point.x, point.y);
    waterBody->SetTransform(temp, angle);
}

-(void) dealloc{
    NSLog(@"==========>> Waterline Dealloc <<==========");
    free(colors);
    free(vertices);
    free(textVertices);
    self.layer = nil;
    [super dealloc];
}

@end
