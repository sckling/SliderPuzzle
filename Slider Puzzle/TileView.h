//
//  TileView.h
//  Slider Puzzle
//
//  Created by Stephen Ling on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileView : UIImageView {
    CGPoint originalPosition;
}

@property (nonatomic, assign) CGPoint originalPosition;

@end
