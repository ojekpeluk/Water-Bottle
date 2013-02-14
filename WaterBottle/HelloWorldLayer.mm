#import "HelloWorldLayer.h"

#define PTM_RATIO 32
#define WALL_WIDTH 0.2
#define ICEBOXES 5

@interface HelloWorldLayer()
@property (assign) CGSize ws;
@end


@implementation HelloWorldLayer

@synthesize waterTexture, waterColor;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [[[HelloWorldLayer alloc] init] autorelease];
	[scene addChild: layer];	
	return scene;
}


-(id) init
{

	if( (self=[super init])) {
        self.ws = [CCDirector sharedDirector].winSize;

		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;

		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		bool doSleep = false;
		
		world = new b2World(gravity);
        world->SetAllowSleeping(doSleep);
        world->SetContinuousPhysics(true);

		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2Draw::e_shapeBit;
		flags += b2Draw::e_jointBit;
        //		flags += b2Draw::e_aabbBit;
        //		flags += b2Draw::e_pairBit;
//		flags += b2Draw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);
		

//		b2BodyDef groundBodyDef;
//		groundBodyDef.position.Set(0, 0);
//		
//		b2Body *groundBody = world->CreateBody(&groundBodyDef);
//
//		b2PolygonShape groundBox;
//        b2FixtureDef groundFixDef;
//        groundFixDef.shape = &groundBox;
//        groundFixDef.density = 0;
//        
//        // top
//        groundBox.SetAsBox(self.ws.width/2/PTM_RATIO, WALL_WIDTH, b2Vec2(self.ws.width/2/PTM_RATIO, self.ws.height/PTM_RATIO), 0);
//		groundBody->CreateFixture(&groundFixDef);
//		
//        groundFixDef.filter.maskBits = 0xFFFF;
//		// left
//        groundBox.SetAsBox(4, self.ws.height/2/PTM_RATIO, b2Vec2(-4, self.ws.height/2/PTM_RATIO), 0);
//		groundBody->CreateFixture(&groundFixDef);
//		
//		// right
//        groundBox.SetAsBox(4, self.ws.height/2/PTM_RATIO, b2Vec2(self.ws.width/PTM_RATIO + 4, self.ws.height/2/PTM_RATIO), 0);
//		groundBody->CreateFixture(&groundFixDef);
//        
//        // bottom
//        groundBox.SetAsBox(self.ws.width/2/PTM_RATIO, 4, b2Vec2(self.ws.width/2/PTM_RATIO, -4), 0);
//        groundBody->CreateFixture(&groundFixDef);
        
        waterColor = ccc4(100, 0, 0, 200);
        waterLine = [WaterLine waterLineWithWorld:world];
        waterLine.layer = self;
        [self addChild:waterLine];

        CCLOG(@"================> Hello World Layer <================");
		[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	}
	return self;
}


-(void) draw
{
    
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();

	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

-(void) tick: (ccTime) dt
{
	//http://gafferongames.com/game-physics/fix-your-timestep/
    
//	int32 velocityIterations = 8;
//	int32 positionIterations = 1;
	int32 velocityIterations = 20;
	int32 positionIterations = 10;
	
	world->Step(dt, velocityIterations, positionIterations);

	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{

	static float prevX= 0, prevY= 0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 0.5f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
    
	prevX = accelX;
	prevY = accelY;
	
    b2Vec2 gravity( accelX * 10, accelY * 10);
    [waterLine updatePosWithAccelX:accelX andAccelY:accelY];
	world->SetGravity( gravity );
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void) onExit{
    [self removeAllChildrenWithCleanup: YES];
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache removeSpriteFrames];
    [CCTextureCache purgeSharedTextureCache];
    [super onExit];
}

- (void) dealloc
{
    NSLog(@"==========> Hello World Dealloc <==========");
	delete m_debugDraw;
    [waterLine release];
    delete world;
	world = NULL;
	[super dealloc];
}
@end
