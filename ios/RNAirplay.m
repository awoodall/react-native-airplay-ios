#import "RNAirplay.h"
#import "RNAirplayManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVRoutePickerView.h>

@implementation RNAirplay
@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(startScan)
{
    printf("init Airplay");
    AVAudioSessionRouteDescription* currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    BOOL isAvailable = NO;
    NSUInteger routeNum = [[currentRoute outputs] count];
    if(routeNum > 0) {
        isAvailable = YES;
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector: @selector(airplayChanged:)
         name: AVAudioSessionRouteChangeNotification
         object: nil];
    }
    [self sendEventWithName:@"airplayAvailable" body:@{@"available": @(isAvailable)}];
    [ self sendAirplayConnectedStatus];
}
RCT_EXPORT_METHOD(showMenu) {
    CGRect frame = CGRectMake(-100, -100, 0, 0);

    AVRoutePickerView *pickerView = [[AVRoutePickerView alloc] initWithFrame:frame];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *topView = window.rootViewController.view;

    for (UIButton *button in pickerView.subviews)
    {
        if ([button isKindOfClass:[UIButton class]])
        {
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    [topView addSubview:pickerView];
}

RCT_EXPORT_METHOD(getAirplayState:(RCTResponseSenderBlock)callback)
{
    AVAudioSessionRouteDescription* currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    BOOL isAirPlayPlaying = NO;
    BOOL isMirroring = NO;
    for (AVAudioSessionPortDescription* output in currentRoute.outputs) {
      if([output.portType isEqualToString:AVAudioSessionPortAirPlay]) {
          isAirPlayPlaying = YES;
          break;
      }
    }
    if (isAirPlayPlaying) {
        if ([[UIScreen screens] count] < 2) {
             //streaming
             isMirroring = NO;
         } else {
             //mirroring
             isMirroring = YES;
         }
    }
    callback(@[ @{ @"connected" : @(isAirPlayPlaying), @"mirroring" : @(isMirroring) } ]);
}

RCT_EXPORT_METHOD(disconnect)
{
    printf("disconnect Airplay");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self sendEventWithName:@"airplayAvailable" body:@{@"available": @(NO) }];
}

- (void)airplayChanged:(NSNotification *)sender
{
     [self sendAirplayConnectedStatus];
}

- (void)sendAirplayConnectedStatus {
    AVAudioSessionRouteDescription* currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    
    BOOL isAirPlayPlaying = NO;
    for (AVAudioSessionPortDescription* output in currentRoute.outputs) {
        if([output.portType isEqualToString:AVAudioSessionPortAirPlay]) {
            isAirPlayPlaying = YES;
            break;
        }
    }

    [self sendEventWithName:@"airplayConnected" body:@{@"connected": @(isAirPlayPlaying)}];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"airplayAvailable", @"airplayConnected"];
}


@end
