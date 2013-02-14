
#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"

@interface Settings : NSObject{
    BOOL playSound;
    BOOL playMusic;
    NSString *playingBGMusic;
    ALuint playingEffect;
    
    // Waterline related
    int decreaseGap; // how much to decrease when disedot
    NSMutableDictionary *_ellipseMap;
    NSMutableDictionary *_yMap;
    CGPoint center;
}
+(Settings *) sharedSetting;
@property (readonly) int decreaseGap;
@property (readonly) NSDictionary *yMap;
@property (readonly) BOOL playMusic, playSound;
+(BOOL) isiphone5;
-(void) playEffect:(NSString *) effect;
-(void) playEffect:(NSString *) effect withVolume: (float) vol;
-(void) stopCurrentEffect;
-(void) playBackgroundMusic:(NSString *) music;
-(void) playBackgroundMusic:(NSString *) music loop:(BOOL)loop;
-(void) stopBackgroundMusic;
-(void) setPlaySound:(BOOL) play;
-(void) setPlayMusic:(BOOL) play;
-(void) togglePlaySound;
-(void) togglePlayMusic;
-(void) writeScore:(int)score forGame:(NSString*)name;
-(void) writeGame:(NSString*)name withItems:(NSArray*)items;
-(int) readScoreForGame:(NSString*)name;
-(NSArray *) gameNames;
-(NSArray*) readGame:(NSString *)name;
-(void) deleteGame:(NSString *)name;
-(void) saveScreenshotFor:(id)sender data:(NSString*)game;
-(NSString*) screenShotFor:(NSString*)game;
-(void) deleteScreenshotFor:(NSString*)game;
@end
