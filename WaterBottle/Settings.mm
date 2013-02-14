#import "cocos2d.h"
#import "Settings.h"
#define SCORE @"score.plist"
#define GAME @"game.plist"


@interface Settings()

// Init
-(id) initSettings;

// Sound
-(void) stopCurrentEffect;

// Screenshot
@property int myDataLength;
@property (assign) GLubyte *buffer;
@property (retain) NSString *gameName;

// Waterline
-(void) createMap;
-(void) fillEllipseMap;
-(void) caseOne;
-(void) caseThreeWithA:(float)numA andB:(float)numB;
-(float) getXForLowerAngle:(float) angle withA:(float) a withB:(float) b;
-(float) getYForLowerAngle:(float) angle withX:(float) x;
@end

@implementation Settings

@synthesize decreaseGap, yMap = _yMap, gameName, buffer, myDataLength, playMusic, playSound;

+(BOOL) isiphone5{
    static BOOL isSet = FALSE;
    static BOOL iphone5 = FALSE;
    if(isSet){
        return iphone5;
    }
    iphone5 = [CCDirector sharedDirector].winSize.height > 480;
    isSet = TRUE;
    return iphone5;
}

+(Settings *) sharedSetting{
    
    // Persistent instance
    static Settings * instance = nil;
    
    if(instance != nil){
        return instance;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    // Allocates once with Grand Central Dispatch (GCD) routine.
    // It's thread safe.
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      instance = [[Settings alloc] initSettings];
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
            instance = [[Settings alloc] initSettings];
        }
    }
#endif
    
    return instance;
}

-(id) initSettings{
    self = [super init];
    if(self){
        decreaseGap = 10;
        playSound = playMusic = TRUE;
        playingEffect = 0;
        [self createMap];
    }
    return self;
}

- (id) retain
{
    return self;
}

- (oneway void) release
{
    // Does nothing here.
}

- (id) autorelease
{
    return self;
}

- (NSUInteger) retainCount
{
    return INT32_MAX;
}

-(void) playEffect:(NSString *) effect{
    if(!playSound){
        return;
    }
    playingEffect = [[SimpleAudioEngine sharedEngine] playEffect:effect];
}

-(void) playEffect:(NSString *)effect withVolume:(float)vol{
    if(!playSound){
        return;
    }
    [[SimpleAudioEngine sharedEngine] playEffect:effect pitch:1.0 pan:0.0 gain:vol];
}

-(void) stopCurrentEffect{
    [[SimpleAudioEngine sharedEngine] stopEffect:playingEffect];
}

-(void) playBackgroundMusic:(NSString *)music{
    if(!playMusic){
        return;
    }
    playingBGMusic = music;
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:music loop:TRUE];
}

-(void) playBackgroundMusic:(NSString *)music loop:(BOOL)loop{
    if(!playMusic){
        return;
    }
    if([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] && music == playingBGMusic){
        return;
    }
    playingBGMusic = music;
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:music loop:loop];
}

-(void) setPlaySound:(BOOL)play{
    playSound = play;
    if(!play){
        [self stopCurrentEffect];
    }
}

-(void) togglePlaySound{
    playSound = !playSound;
    if(!playSound){
        [self stopCurrentEffect];
    }
}

-(void) togglePlayMusic{
    playMusic = !playMusic;
    if(!playMusic){
        [self stopBackgroundMusic];
    }else{
        [self playBackgroundMusic:playingBGMusic loop:TRUE];
    }
}

-(void) setPlayMusic:(BOOL)play{
    playMusic = play;
    if(!play){
        [self stopBackgroundMusic];
    }
}

-(void) stopBackgroundMusic{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

#pragma mark - Data persistence

/**
 Ada tiga struktur data yang disimpen. 
 Satu NSArray berisi nama-nama game. 
 Setiap NSString dalam NSArray yg berisi nama game mempunyai satu NSArray lain yg berisi items dalam game itu.
 Satu lagi NSDictionary yang berisi mapping nama game dan highest score.
 **/

-(NSString *)dataFilePathFor:(NSString*)string{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [path objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:string];
}

-(void) writeGame:(NSString*)name withItems:(NSArray*)items{
    NSString *filePath = [self dataFilePathFor:GAME];
    NSMutableArray *array;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        array  = [NSMutableArray arrayWithContentsOfFile:filePath];
    }else{
        array = [NSMutableArray array];
    }

    BOOL found = FALSE;
    for(NSString *s in array){
        if([s isEqualToString:name]){
            found = TRUE;
            break;
        }
    }
    if(!found){
        NSLog(@"Found");
        [array addObject:name];
        BOOL b =  [array writeToFile:filePath atomically:TRUE];
        NSLog(@"Write game name: %d", b);
    }
    filePath = [self dataFilePathFor:name];
    BOOL b = [items writeToFile:filePath atomically:TRUE];
    NSLog(@"Write game objects: %d", b);
}

-(void) writeScore:(int)score forGame:(NSString *)name{
    NSString *filePath = [self dataFilePathFor:SCORE];
    NSMutableDictionary *dict;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        dict = [[NSMutableDictionary dictionaryWithContentsOfFile:filePath] retain];
    }else{
        dict = [NSMutableDictionary dictionary];
    }
    [dict setValue:[NSNumber numberWithInt:score] forKey:name];
    BOOL b = [dict writeToFile:filePath atomically:TRUE];
    NSLog(@"Write score: %d", b);
}

-(int) readScoreForGame:(NSString *)name{
    NSString *filePath =[self dataFilePathFor:SCORE];
    NSLog(@"Filepath: %@", filePath);
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSLog(@"Exist");
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSNumber *val = (NSNumber*)[dict valueForKey:name];
        if(val != nil){
            int i = val.intValue;
            return  i;
        }else{
            return 0;
        }
    }else{
        NSLog(@"Does not exist");
        return 0;
    }
}

-(NSArray *) gameNames{
    NSString *filePath =[self dataFilePathFor:GAME];
    NSLog(@"Filepath: %@", filePath);
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSLog(@"Exist");
        NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:filePath];
        return array;
    }else{
        NSLog(@"Does not exist");
        return nil;
    }
}

-(NSArray*) readGame:(NSString *)name{
    NSString *filePath =[self dataFilePathFor:name];
    NSLog(@"Filepath: %@", filePath);
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSLog(@"Exist");
        NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:filePath];
        return array;
    }else{
        NSLog(@"Does not exist");
        return nil;
    }
}

-(void) deleteGame:(NSString *)name{
    NSError *error;
    NSString *filePath = [self dataFilePathFor:GAME];
    NSMutableArray *array;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        array  = [NSMutableArray arrayWithContentsOfFile:filePath];
    }else{
        return;
    }
    
    BOOL found = FALSE;
    for(NSString *s in array){
        if([s isEqualToString:name]){
            found = TRUE;
            break;
        }
    }
    if(!found){
        return;
    }
    [array removeObject:name];
    BOOL b =  [array writeToFile:filePath atomically:TRUE];
    NSLog(@"Update game name: %d", b);
    
    filePath = [self dataFilePathFor:name];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        BOOL b = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if(!b){
            NSLog(@"Gagal hapus file items: %@", [error localizedDescription]);
        }else{
            NSLog(@"Sukses hapus file items");
        }
    }
    [self deleteScreenshotFor:name];
}

#pragma mark - WaterLine related methods

-(void) createMap{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    center = ccp(screenSize.width/2, screenSize.height/2 + 10 * decreaseGap);
    
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
        CGPoint point = ccp(x, y);
        [_ellipseMap setObject:[NSValue valueWithCGPoint:point] forKey:[NSNumber numberWithInt:key]];
        
        // Negative angle
        x = [self getXForLowerAngle:-f withA:numA withB:numB];
        y = [self getYForLowerAngle:-f withX:x];
        // the calculation is based on the assumption that the center of the ellipse is at (0,0)
        // translate it, because our ellipse is centered at (width/2, height/2)
        x = x + screenSize.width/2;
        y = y + screenSize.height/2;
        point = ccp(x, y);
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
    CGPoint point = ccp(x, y);
    [_ellipseMap setObject:[NSValue valueWithCGPoint:point] forKey:[NSNumber numberWithInt:key]];
    // Negative angle
    x = [self getXForLowerAngle:-M_PI withA:numA withB:numB];
    y = [self getYForLowerAngle:-M_PI withX:x];
    // the calculation is based on the assumption that the center of the ellipse is at (0,0)
    // translate it, because our ellipse is centered at (width/2, height/2)
    x = x + screenSize.width/2;
    y = y + screenSize.height/2;
    point = ccp(x, y);
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

#pragma mark - Screenshot methods
-(void) deleteScreenshotFor:(NSString*)game{
    NSError *error;
    NSString *filePath = [self dataFilePathFor:[NSString stringWithFormat:@"%@.png", game]];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        BOOL b = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if(!b){
            NSLog(@"Gagal hapus screenshot: %@.png karena: %@", game, [error localizedDescription]);
        }else{
            NSLog(@"Sukses hapus screenshot: %@.png", game);
        }
    }
}
- (void) saveScreenshotFor:(id)sender data:(NSString *)game{
    // Check to see if game with such name has been saved
    if([self readGame:game] == nil){
        return;
    }
    // Check whether it has been saved
    NSString *filePath = [self dataFilePathFor:[NSString stringWithFormat:@"%@.png", game]];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        return;
    }
    self.gameName = game;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int screenScale = [UIScreen mainScreen].scale;
    int width = winSize.width * screenScale;
    int height = winSize.height * screenScale;
    
    self.myDataLength = width * height * 4;
    
    // allocate array and read pixels into it.
    self.buffer = (GLubyte *) malloc(self.myDataLength); // NOW PART OF THE CLASS DEFINITION
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, self.buffer);
    [self performSelectorInBackground:@selector(finishScreenshotFor:) withObject:self.gameName];
}

-(void)finishScreenshotFor:(NSString*)game{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int screenScale = [UIScreen mainScreen].scale;
    int width = winSize.width * screenScale;
    int height = winSize.height * screenScale;
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(self.myDataLength);
    for(int y = 0; y < height; y++)
    {
        for(int x = 0; x < width * 4; x++)
        {
            buffer2[(height-(1*screenScale) - y) * width * 4 + x] = self.buffer[y * 4 * width + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, self.myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    NSString *file = [self dataFilePathFor:[NSString stringWithFormat:@"%@.png", self.gameName]];
    BOOL b = [UIImagePNGRepresentation(myImage) writeToFile:file atomically:TRUE];
    CCLOG(@"Write image: %d", b);
    free(self.buffer);
    free(buffer2);
    self.gameName = nil;
}

-(NSString*) screenShotFor:(NSString*)game{
    NSString *filePath = [self dataFilePathFor:[NSString stringWithFormat:@"%@.png", game]];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        return filePath;
    }else{
        return nil;
    }
}

@end
