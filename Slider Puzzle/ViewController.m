//
//  ViewController.m
//  Slider Puzzle
//
//  Created by Stephen Ling on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "TileView.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *myTiles;
@property (nonatomic, assign) NSInteger emptyPocketIndex;
@property (nonatomic, assign) NSInteger tileSize;
@property (nonatomic, assign) NSInteger puzzleLayout;
@property (nonatomic, assign) NSInteger totalNumberOfTiles;

- (void)checkPuzzle;
- (void)startPuzzle:(id)sender;
- (void)resetPuzzle:(id)sender;
- (void)showHint:(id)sender;
@end

const int kHintLabel = 99;
const int kPuzzleImage = 100;

@implementation ViewController
@synthesize myTiles = _myTiles;
@synthesize emptyPocketIndex = _emptyPocketIndex;
@synthesize tileSize = _tileSize;
@synthesize puzzleLayout = _puzzleLayout;
@synthesize totalNumberOfTiles = _totalNumberOfTiles;


- (NSMutableArray *)myTiles
{
    if (_myTiles == nil) _myTiles = [[NSMutableArray alloc] init];
    return _myTiles;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat buttonWidth = 90.0;
    CGFloat buttonHeight = 40.0;
    CGFloat spacingX = 15.0;
    CGFloat spacingY = 20.0;
    
    // Create puzzle imageView
    UIImage *puzzleImage = [UIImage imageNamed:@"UIE_Slider_Puzzle--globe.jpg"];
    UIImageView *puzzleImageView = [[UIImageView alloc] initWithImage:puzzleImage];
    puzzleImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
    puzzleImageView.tag = kPuzzleImage;
    [self.view addSubview:puzzleImageView];

    // Create a button for puzzle layout 4x4
    UIButton *button4x4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button4x4.frame = CGRectMake(self.view.bounds.size.width/2-buttonWidth/2, puzzleImageView.frame.size.height+spacingY, buttonWidth, buttonHeight);
    button4x4.tag = 400;
    [button4x4 setTitle:@"Puzzle 4x4" forState:UIControlStateNormal];
    [button4x4 addTarget:self action:@selector(startPuzzle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4x4];
    
    // Create a button for puzzle layout 5x5
    UIButton *button5x5 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button5x5.frame = CGRectMake(button4x4.frame.origin.x+buttonWidth+spacingX, puzzleImageView.frame.size.height+spacingY, buttonWidth, buttonHeight);
    button5x5.tag = 500;
    [button5x5 setTitle:@"Puzzle 5x5" forState:UIControlStateNormal];
    [button5x5 addTarget:self action:@selector(startPuzzle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button5x5];
    
    // Create a button for puzzle layout 3x3
    UIButton *button3x3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button3x3.frame = CGRectMake(button4x4.frame.origin.x-spacingX-buttonWidth, puzzleImageView.frame.size.height+spacingY, buttonWidth, buttonHeight);
    button3x3.tag = 300;
    [button3x3 setTitle:@"Puzzle 3x3" forState:UIControlStateNormal];
    [button3x3 addTarget:self action:@selector(startPuzzle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3x3];
        
    // Create a hint button to toggle displays tile numbers on each tile 
    UIButton *hintButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    hintButton.frame = CGRectMake(self.view.bounds.size.width/2-spacingX*2-buttonWidth, button3x3.frame.origin.y+button3x3.frame.size.height+spacingY,
                                  buttonWidth, buttonHeight);
    [hintButton setTitle:@"Hint" forState:UIControlStateNormal];
    [hintButton addTarget:self action:@selector(showHint:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hintButton];
    
    // Create a reset button to reset the puzzle
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    resetButton.frame = CGRectMake(self.view.bounds.size.width/2+spacingX*2, button3x3.frame.origin.y+button3x3.frame.size.height+spacingY,
                                   buttonWidth, buttonHeight);
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetPuzzle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


#pragma Helper methods

/***********************************************************************
 *  "Hint Button" selector to toggle hints (display/hide tile number)  *
 ***********************************************************************/
- (void)showHint:(id)sender
{
    if (self.myTiles) {
        for (TileView *tile in self.myTiles) {
            UILabel *label = (UILabel *)[tile viewWithTag:kHintLabel];
            label.hidden = label.hidden==YES? NO:YES;
        }
    }
}


/***********************************************************************************
 *  "Reset Button" selector to reset puzzle and display the original puzzle image  *
 ***********************************************************************************/
- (void)resetPuzzle:(id)sender
{
    UIImageView *puzzleImageView = (UIImageView *)[self.view viewWithTag:kPuzzleImage];
    puzzleImageView.hidden = NO;
    [self.view bringSubviewToFront:puzzleImageView];
}


/******************************************************
 *  Start the puzzle and construct the puzzle layout  *
 ******************************************************/
- (void)startPuzzle:(id)sender
{
    int tileIndex;
    self.puzzleLayout = [sender tag]/100;
    self.tileSize = self.view.bounds.size.width / self.puzzleLayout;
    self.totalNumberOfTiles = self.puzzleLayout * self.puzzleLayout;

    UIImageView *puzzleImageView = (UIImageView *)[self.view viewWithTag:kPuzzleImage];
    CGFloat imageSize = puzzleImageView.image.size.width / self.puzzleLayout;
    puzzleImageView.hidden = YES;
    
    // Remove all the tiles from the screen if there's any
    if (self.myTiles != nil) {
        for (TileView *imageView in self.myTiles) {
            [imageView removeFromSuperview];
        }
        self.myTiles = nil;
    }

    // Create the slider puzzle layout
    for (int row=0; row<self.puzzleLayout; row++)
    {
        for (int col=0; col<self.puzzleLayout; col++)
        {
            // Create the tile image from the main image and crop/resize it
            CGImageRef tileImageRef = CGImageCreateWithImageInRect(puzzleImageView.image.CGImage, 
                                                                  CGRectMake(col*imageSize, row*imageSize, imageSize, imageSize));
            UIImage *tileImage = [UIImage imageWithCGImage:tileImageRef];
            TileView *sliderTile = [[TileView alloc] initWithFrame:CGRectMake(col*self.tileSize, row*self.tileSize, self.tileSize, self.tileSize)];
            
            // Create the tile imageview and display it on the main view
            sliderTile.userInteractionEnabled = YES;
            sliderTile.image = tileImage;
            sliderTile.originalPosition = CGPointMake(col*self.tileSize, row*self.tileSize);
            tileIndex = row*self.puzzleLayout+col+1;
            sliderTile.tag = tileIndex;

            // Create labels for puzzle hints - add tile numbers on each tile
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, self.tileSize, 10)];
            label.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.0];
            label.text = [NSString stringWithFormat:@"%d", tileIndex];
            label.textColor = [UIColor yellowColor];
            label.font = [UIFont systemFontOfSize:12];
            label.tag = kHintLabel;
            label.hidden = YES;
            [sliderTile addSubview:label];
            
            [self.view addSubview:sliderTile];
            [self.myTiles addObject:sliderTile];
        }
    }
        
    // Shuffle the tiles
    for (int i=0; i<self.totalNumberOfTiles; i++)
    {
        int randomIndex = arc4random()%(self.totalNumberOfTiles-1);
        [self.myTiles exchangeObjectAtIndex:i withObjectAtIndex:randomIndex];
    }
        
    // Display the shuffled tiles in the puzzle layout
    for (int row=0; row<self.puzzleLayout; row++)
    {
        for (int col=0; col<self.puzzleLayout; col++)
        {
            tileIndex = row*self.puzzleLayout+col+1;
            TileView *sliderTile = [self.myTiles objectAtIndex:tileIndex-1];
            sliderTile.frame = CGRectMake(col*self.tileSize, row*self.tileSize, self.tileSize, self.tileSize);

            // Store the empty tile location and hide it from the main view; by default empty tile is the last tile
            if (sliderTile.tag == self.totalNumberOfTiles)
            {
                sliderTile.hidden = YES;
                sliderTile.userInteractionEnabled = NO;
                self.emptyPocketIndex = tileIndex;
            }
            sliderTile.tag = tileIndex;
                
            // Fade-in slider puzzle tiles
            sliderTile.alpha = 0.0;
            [UIView beginAnimations:@"Fade-in" context:nil];
            [UIView setAnimationDuration:1.0];
            sliderTile.alpha = 1.0;
            [UIView commitAnimations];
        }
    }
}


/***************************************************************************
 *  Check if puzzle is solved by checking all the tiles' current position  *
 ***************************************************************************/
- (void)checkPuzzle
{
    BOOL bingo = YES;
    
    // Check and compare all the tiles original positions and current positions
    for (TileView *tile in self.myTiles)
    {    
        if ((tile.originalPosition.x!=tile.frame.origin.x)||(tile.originalPosition.y!=tile.frame.origin.y)) {
            bingo = NO;
            break;
        }
    }
    
    // If puzzle solved, display the original puzzle image
    if (bingo)
    {
        // Fade-in the entire puzzle image
        UIImageView *puzzleImageView = (UIImageView *)[self.view viewWithTag:kPuzzleImage];
        [self.view bringSubviewToFront:puzzleImageView];
        puzzleImageView.hidden = NO;
        puzzleImageView.alpha = 0.0;
        [UIView beginAnimations:@"fade in" context:nil];
        [UIView setAnimationDuration:1.0];
        puzzleImageView.alpha = 1.0;
        [UIView commitAnimations];
        
        // Alert user puzzle is solved
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Puzzle Solved!"
                                                        message:nil
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma Touches events handling

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    TileView *emptyPocket = (TileView *)[self.view viewWithTag:self.emptyPocketIndex];
    
    //NSLog(@"touch: %.1f, %.1f", point.x, point.y);
    //NSLog(@"tile: %.1f, %.1f", touch.view.center.x, touch.view.center.y);
    //NSLog(@"empty:%.1f, %.1f", emptyPocket.center.x, emptyPocket.center.y);

    if (touch.view != self.view)
    {
        CGFloat offset;
        int numberOfTilesMove;
        int direction;

        // Check if the touched tile and the empty pocket aligned vertically. If yes, only allow vertical (point.y) movement
        if (touch.view.center.x == emptyPocket.center.x)
        {
            // Calculate offset from the touhced position to the empty pocket position
            numberOfTilesMove = (emptyPocket.tag-touch.view.tag)/self.puzzleLayout;
            direction = (numberOfTilesMove>0)? 1:-1;
            offset = ((point.y+(self.tileSize*abs(numberOfTilesMove)*direction)) - emptyPocket.center.y)*direction;
            
            // Check for touch point boundaries. 
            if (offset<=0) {
                point.y = point.y - offset*direction;
            }
            else if (offset>=self.tileSize) {
                point.y = point.y-(offset-self.tileSize)*direction;
            }
            
            // Move one or more tiles in vertical based on the empty pocket position and touched tile position
            for (int i=0; i<abs(numberOfTilesMove); i++)
            {
                TileView *current = (TileView *)[self.view viewWithTag:(touch.view.tag+self.puzzleLayout*direction*i)];
                current.center = CGPointMake(current.center.x, point.y+self.tileSize*direction*i);
            }
        }
        // Check if the touched tile and the empty pocket aligned horizontally. If yes, only allow horizontal (point.x) movement
        else if (touch.view.center.y == emptyPocket.center.y)
        {
            numberOfTilesMove = emptyPocket.tag-touch.view.tag;
            direction = (numberOfTilesMove>0)? 1:-1;
            offset = ((point.x+(self.tileSize*abs(numberOfTilesMove)*direction)) - emptyPocket.center.x)*direction;
            
            // Check for touch point boundaries. 
            if (offset<=0) {
                point.x = point.x - offset*direction;
            }
            else if (offset>=self.tileSize) {
                point.x = point.x-(offset-self.tileSize)*direction;
            }
            
            // Move one or more tiles in horizontal based on the empty pocket position and touched tile position
            for (int i=0; i<abs(numberOfTilesMove); i++)
            {
                TileView *current = (TileView *)[self.view viewWithTag:(touch.view.tag+direction*i)];
                current.center = CGPointMake(point.x+self.tileSize*direction*i, current.center.y);
            }
        }
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    TileView *currentTile = (TileView *)[self.view viewWithTag:touch.view.tag];
    TileView *emptyPocket = (TileView *)[self.view viewWithTag:self.emptyPocketIndex];
    
    //NSLog(@"Touches Ended %d: %.1f %.1f", touch.view.tag, touch.view.center.x, touch.view.center.y);
    //NSLog(@"Current Ended %d: %.1f %.1f", currentTile.tag, currentTile.center.x, currentTile.center.y);
    //NSLog(@"Empty pocket %d:%.1f, %.1f", self.emptyPocketIndex, emptyPocket.center.x, emptyPocket.center.y);

    if (currentTile != self.view)
    {
        [UIView beginAnimations:@"Move tile" context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDelegate:self];
        
        int tmpIndex;
        int numberOfTilesMove;
        int direction;

        // Check if the touched tile has moved to the empty pocket position. If yes, swaped the empty pocket and the touched tile's positions
        if ((currentTile.center.x == emptyPocket.center.x)&&(currentTile.center.y == emptyPocket.center.y))
        {
            direction = currentTile.tag-emptyPocket.tag;
            
            // Vertical move
            if (abs(direction)>1) {
                direction = direction>1? 1:-1;
                emptyPocket.center = CGPointMake(emptyPocket.center.x, emptyPocket.center.y+self.tileSize*direction);
            }

            // Horizontal move
            else {
                emptyPocket.center = CGPointMake(emptyPocket.center.x+self.tileSize*direction, emptyPocket.center.y);
            }
            
            // Update the touched tile and the empty pocket position (reference based on tags)
            tmpIndex = currentTile.tag;
            currentTile.tag = emptyPocket.tag;
            emptyPocket.tag = tmpIndex;
            self.emptyPocketIndex = emptyPocket.tag;
        }
        
        // Check if touched tile and empty pocket aligned vertically. If yes, only allow vertical (y) movement
        else if (currentTile.center.x == emptyPocket.center.x)
        {
            numberOfTilesMove = (emptyPocket.tag-currentTile.tag)/self.puzzleLayout;
            direction = (numberOfTilesMove>0)? 1:-1;
            CGFloat offset = (currentTile.center.y+(self.tileSize*numberOfTilesMove)) - emptyPocket.center.y;
            
            // Tile is in it's original position and will be moved to the empty pocket
            if (offset==0) {
                offset += self.tileSize*direction;
            }

            // Tile has already moved into the empty pocket. No further movement
            else if (fabs(offset)==self.tileSize) {
                offset -= self.tileSize*direction; 
            }

            // Move all the tiles according to the touch ended positions and swap the positions with the empty pocket
            for (int i=1; i<=abs(numberOfTilesMove); i++)
            {
                // Movement is less than half way to complete and tile(s) will move back to the original positions
                if ((fabs(offset)>0)&&(fabs(offset)<self.tileSize/2)) {
                    TileView *current = (TileView *)[self.view viewWithTag:(currentTile.tag+self.puzzleLayout*direction*(i-1))];
                    current.center = CGPointMake(current.center.x, current.center.y-offset);
                }
                
                // Movement is over half way complete and tile(s) will move to the new positions
                else {
                    TileView *current = (TileView *)[self.view viewWithTag:(self.emptyPocketIndex-self.puzzleLayout*direction)];
                    TileView *empty = (TileView *)[self.view viewWithTag:self.emptyPocketIndex];
                    
                    // Update the tile(s) and the empty pocket positions
                    if ((fabs(offset)>self.tileSize/2)&&(fabs(offset)<self.tileSize)) {
                        current.center = CGPointMake(current.center.x, current.center.y+(self.tileSize-fabs(offset))*direction);
                    }
                    else {
                        current.center = CGPointMake(current.center.x, current.center.y+offset);
                    }
                    empty.center = CGPointMake(empty.center.x, empty.center.y-self.tileSize*direction);
                    
                    // Update the tiles and the empty pocket positions (based on tags)
                    tmpIndex = current.tag;
                    current.tag = empty.tag;
                    empty.tag = tmpIndex;
                    self.emptyPocketIndex = empty.tag;
                }
            }
        }

        // Check if touched tile and empty pocket aligned horizontally. If yes, only allow horizontal (point.x) movement
        else if (currentTile.center.y == emptyPocket.center.y)
        {
            numberOfTilesMove = (emptyPocket.tag-currentTile.tag);
            direction = (numberOfTilesMove>0)? 1:-1;
            CGFloat offset =  (currentTile.center.x+(self.tileSize*numberOfTilesMove)) - emptyPocket.center.x;
            
            // Tile is in it's original position and will be moved to the empty pocket
            if (offset==0) {
                offset += self.tileSize*direction;
            }
            
            // Tile has already moved into the empty pocket. No further movement
            else if (fabs(offset)==self.tileSize)
            {
                offset -= self.tileSize*direction; 
            }
            
            // Move all the tiles according to the touch ended positions and swap the positions with the empty pocket
            for (int i=1; i<=abs(numberOfTilesMove); i++)
            {
                // Movement is less than half way to complete and tile(s) will move back to the original positions
                if ((fabs(offset)>0)&&(fabs(offset)<self.tileSize/2)) {
                    TileView *current = (TileView *)[self.view viewWithTag:(currentTile.tag+(i-1)*direction)];
                    current.center = CGPointMake(current.center.x-offset, current.center.y);
                }
                
                // Movement is over half way complete and tile(s) will move to the new positions
                else {
                    TileView *current = (TileView *)[self.view viewWithTag:(self.emptyPocketIndex-direction)];
                    TileView *empty = (TileView *)[self.view viewWithTag:self.emptyPocketIndex];
                    
                    // Update the tile(s) and the empty pocket positions
                    if ((fabs(offset)>self.tileSize/2)&&(fabs(offset)<self.tileSize)) {
                        current.center = CGPointMake(current.center.x+(self.tileSize-fabs(offset))*direction, current.center.y);
                    }
                    else {
                        current.center = CGPointMake(current.center.x+offset, current.center.y);
                    }
                    empty.center = CGPointMake(empty.center.x-self.tileSize*direction, empty.center.y);
                    
                    // Update the tiles and the empty pocket positions (based on tags)
                    tmpIndex = current.tag;
                    current.tag = empty.tag;
                    empty.tag = tmpIndex;
                    self.emptyPocketIndex = empty.tag;
                }
            }
        }

        [UIView commitAnimations];
        [self checkPuzzle];
    }
}

// Disable support for landscape mode
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
*/
@end
