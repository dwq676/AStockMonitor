//
//  ASMainWindow.m
//  AStockMonitor
//
//  Created by __huji on 17/1/2016.
//  Copyright © 2016 huji. All rights reserved.
//

#import "ASMainWindow.h"
#import "ASConstant.h"

@implementation ASMainWindow{
    
}
-(BOOL)canBecomeKeyWindow{
    return YES;
}
-(void)keyDown:(NSEvent *)theEvent{
    if ([theEvent.characters isEqualToString:@"["]) {
        [self setWindowAlpha:self.alphaValue - 0.05f];
    }else if ([theEvent.characters isEqualToString:@"]"]){
        [self setWindowAlpha:self.alphaValue + 0.05f];
    }
}
-(void)setWindowAlpha:(CGFloat)alpha{
    if (alpha>1.0) {
        alpha = 1.0f;
    }else if (alpha<0.05){
        alpha = 0.05;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(alpha) forKey:ASAlphaValueKey];
    self.alphaValue = alpha;
}
@end
