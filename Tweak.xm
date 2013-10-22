@interface NowPlayingArtPluginController : NSObject
- (id)view;
@end

@interface SBAwayView : UIView
-(id)topBar;
-(id)bottomBar;
-(id)_defaultDesktopImage;
@end

@interface SBAwayDateView : UIView
-(void)setPositon;
@end

@interface SBDeviceLockViewWithKeypad : UIView
@end

@interface SBAwayController : NSObject
-(id)sharedAwayController;
@end

@interface TPLCDTextView : UIView {}
-(void)setShadowColor:(UIColor *)fp8;
-(void)setText:(id)fp8;
-(void)setTextColor:(UIColor *)fp8; 
-(void)setFont:(UIFont*)font;
- (void)setLCDTextFont:(id)arg1;
@end

CGPoint _priorPoint;

%hook SBAwayView
-(void)finishedAnimatingIn{
	%orig;
	UIView *&_backgroundView(MSHookIvar<UIView *>(self, "_backgroundView"));
	[_backgroundView setUserInteractionEnabled:YES]; //Allows backbround to use gesture

	SBAwayDateView *&_dateHeaderView(MSHookIvar<SBAwayDateView *>(self, "_dateHeaderView"));
	[_dateHeaderView setPositon]; //reset the position of the date view to be below the larger clock

	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(newUnlockStyleMover:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    //[_backgroundView addGestureRecognizer:panRecognizer] This can be used but is incompatible with LockHTML 
    [[self.subviews objectAtIndex:0] addGestureRecognizer:panRecognizer]; //Add gesture to the background view or LockHTML's z order organizer
	[panRecognizer release];

	panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(newUnlockStyleMover:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [[self bottomBar] addGestureRecognizer:panRecognizer]; //Lockbar
	[panRecognizer release];

	panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(newUnlockStyleMover:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [[self topBar] addGestureRecognizer:panRecognizer]; //Clock and Date View's
	[panRecognizer release];
}

%new
- (void)newUnlockStyleMover:(UIPanGestureRecognizer *)sender {
		UIView *&_lockBar(MSHookIvar<UIView *>(self, "_lockBar"));
		CGPoint point = [sender locationInView:sender.view.superview];
		if (sender.state == UIGestureRecognizerStateChanged && _lockBar.frame.size.height == 96) {
			UIImage *_defaultDesktopImage = [self _defaultDesktopImage];
			for(UIView *obj in [self subviews]){	
				if(obj != [self.subviews objectAtIndex:0]){
					CGPoint center = obj.center;
					if(center.x < 160)
						center.x += (point.x - _priorPoint.x)/3;
					else
						center.x += point.x - _priorPoint.x;

					obj.center = center;
				}
			}
		}
		else if (sender.state == UIGestureRecognizerStateEnded && _lockBar.frame.size.height == 96){
			if(_lockBar.center.x < 300){

				for(UIView *obj in [self subviews]){	
					if(obj != [self.subviews objectAtIndex:0]){
						CGPoint center = obj.center;
						center.x = 160;
						[UIView animateWithDuration:0.6
							 animations:^{ 
								obj.center = center;
							 } 
							 completion:^(BOOL finished){
							 }];
					}
				}
			}
			else{
				for(UIView *obj in [self subviews]){	
					if(obj != [self.subviews objectAtIndex:0]){
						CGPoint center = obj.center;
						center.x = 480;
						[UIView animateWithDuration:0.2
							 animations:^{ 
								obj.center = center;
							 } 
							 completion:^(BOOL finished){
							 }];
					}
				}
				if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/Library/MobileSubstrate/DynamicLibraries/AndroidLock.dylib"]] == TRUE && [[[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zmaster.AndroidLock.plist"] objectForKey:@"Enable"] boolValue] == TRUE){
					[[%c(SBAwayController) sharedAwayController] unlockWithSound:TRUE bypassPinLock:[[%c(SBDeviceLockController) sharedController] isPasswordProtected]];
					CGPoint center = _lockBar.center;
					center.x = 160;
					_lockBar.center = center;
				}
				else{
					//[[%c(SBAwayController) sharedAwayController] _sendToDeviceLockOwnerSetShowingDeviceLock:TRUE animated:FALSE];
					[[[[%c(SBAwayController) sharedAwayController] awayView] bottomBar] setHidden:YES];

					[[[[%c(SBAwayController) sharedAwayController] awayView] bottomBar] unlock];
				}
			}
		}
		_priorPoint = point; 

}

-(id)_topBarLCDImage{
	return [self _topBarLCDControlsImage];
}

- (id)_topBarLCDControlsImage{
	return [self getUIImageForControls];
}

%new
-(UIImage*)getUIImageForControls{
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 133), NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return blank;
}

- (void)_setPluginController:(id)arg1{ 
    %orig(arg1);
    if ([arg1 isMemberOfClass:NSClassFromString(@"NowPlayingArtPluginController")]){
	    id pluginController = [self currentAwayPluginController];
	    if ([pluginController isMemberOfClass:NSClassFromString(@"NowPlayingArtPluginController")]){
	        UIView *pluginView = [(NowPlayingArtPluginController *)pluginController view];
				UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(newUnlockStyleMover:)];
			    [panRecognizer setMinimumNumberOfTouches:1];
			    [panRecognizer setMaximumNumberOfTouches:1];
			    //[panRecognizer setDelegate:self];
			    [pluginView addGestureRecognizer:panRecognizer];
				[panRecognizer release];
			for(UIView *obj in [[(NowPlayingArtPluginController *)pluginController view] subviews]){		
					if([obj isKindOfClass:[UIImageView class]]){
						obj.frame = CGRectMake(0, 0, 280, 280);
					}
					if([obj isKindOfClass:NSClassFromString(@"NowPlayingReflectionView")]){
						[obj removeFromSuperview];
					}
			}
			pluginView.frame = CGRectMake(20,173,280,280);
		}
    }
}

%end

%hook SBAwayController
- (void)undimScreen:(BOOL)arg1{
	//Slide Lockscreen back to default position after the screen sleeps
	[[[[%c(SBAwayController) sharedAwayController] awayView] bottomBar] setHidden:NO];
	for(UIView *obj in [[self awayView] subviews]){	
		if(obj != [[[self awayView] subviews] objectAtIndex:0]){
			CGPoint center = obj.center;
			center.x = 160;		
			[UIView animateWithDuration:0.6
				 animations:^{ 
					obj.center = center;
				 } 
				 completion:^(BOOL finished){
				 }];
		}
	}
	%orig;
}
%end

%hook SBAwayDateView
-(void)setFrame:(CGRect)frame{
	%orig;

    TPLCDTextView *timeLabel = MSHookIvar<TPLCDTextView *>(self, "_timeLabel");
    [timeLabel setLCDTextFont:[[timeLabel font] fontWithSize:96]];
    [timeLabel setFrame:CGRectMake(timeLabel.frame.origin.x,timeLabel.frame.origin.y,timeLabel.frame.size.width,timeLabel.frame.size.height+60)];
    
	[self setPositon];	
}

%new
-(void)setPositon{
    TPLCDTextView *dateLabel = MSHookIvar<TPLCDTextView *>(self, "_dateAndTetheringLabel");
    [dateLabel setFrame:CGRectMake(dateLabel.frame.origin.x,100,dateLabel.frame.size.width,dateLabel.frame.size.height)];
}

- (void)setVisible:(BOOL)arg1{
	%orig;
	[self setPositon]; //attempt to keep date view in proper location
}

- (void)resizeAndPositionNowPlayingLabels{
    UILabel *_nowPlayingTitleLabel = MSHookIvar<UILabel *>(self, "_nowPlayingTitleLabel");
	UILabel *_nowPlayingArtistLabel = MSHookIvar<UILabel *>(self, "_nowPlayingArtistLabel");
	UILabel *_nowPlayingAlbumLabel = MSHookIvar<UILabel *>(self, "_nowPlayingAlbumLabel");
	[_nowPlayingTitleLabel setFrame:CGRectMake(0,95,320,20)];
	[_nowPlayingArtistLabel setFrame:CGRectMake(0,109,320,20)];
	[_nowPlayingAlbumLabel setFrame:CGRectMake(0,122,320,20)];
}

%end

%hook TPLCDTextView
%new
-(UIFont *)font{
	UIFont *font = MSHookIvar<UIFont *>(self, "_font");
	return font;
}
%end

%hook SBDeviceLockView
- (void)notifyDelegateThatCancelButtonWasPressed{
	//Slide lockscreen back to default position after cancel button is pressed in lockscreen
	for(UIView *obj in [[[%c(SBAwayController) sharedAwayController] awayView] subviews]){	
		if(obj != [[[[%c(SBAwayController) sharedAwayController] awayView] subviews] objectAtIndex:0]){
			CGPoint center = obj.center;
			center.x = 160;			
			[UIView animateWithDuration:0.6
				 animations:^{ 
					obj.center = center;
				 } 
				 completion:^(BOOL finished){
				 }];
		}
		[[[[%c(SBAwayController) sharedAwayController] awayView] bottomBar] setHidden:NO];
	}
	%orig;	
}
%end

%hook SBAwayMediaControlsView 
- (void)layoutSubviews{
	%orig;
	for(UIView *obj in [self subviews]){
		if ([obj isMemberOfClass:NSClassFromString(@"UIView")]){ //This is the MediaContols Thin Line
			[obj removeFromSuperview];
		}
	}
}
%end

%hook TPLCDBar
//Everything here make sure there is no thin black/grey line below the view
- (id)initWithDefaultSize{
	id topBar = %orig;
	UIImageView *&_shadowView(MSHookIvar<UIImageView *>(self, "_shadowView"));
	[_shadowView removeFromSuperview];
	return topBar;
}

- (id)initWithDefaultSizeForOrientation:(int)arg1{
	id topBar = %orig;
	UIImageView *&_shadowView(MSHookIvar<UIImageView *>(self, "_shadowView"));
	[_shadowView removeFromSuperview];
	return topBar;
}

-(id)initWithFrame:(CGRect)frame{
	id topBar = %orig;
	UIImageView *&_shadowView(MSHookIvar<UIImageView *>(self, "_shadowView"));
	[_shadowView removeFromSuperview];
	return topBar;
}

%end