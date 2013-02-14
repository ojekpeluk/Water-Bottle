#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "WaterLine.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    WaterLine *waterLine;
    // Texture for water
    CCTexture2D *waterTexture;
    // Color for water
    ccColor4B waterColor;
}

+(CCScene *) scene;
@property (readonly) CCTexture2D *waterTexture;
@property (readonly) ccColor4B waterColor;
@end
