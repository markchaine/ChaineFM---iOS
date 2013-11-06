//
//  ListenViewController.m
//  Chaine FM
//
//  Created by Mark McWhirter on 06/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import "ListenViewController.h"
#import <Parse/Parse.h>
#include <MediaPlayer/MediaPlayer.h>

@interface ListenViewController ()
- (IBAction)PlayPress:(id)sender;
- (IBAction)PausePress:(id)sender;
- (IBAction)ResumeRadio:(id)sender;



@end
#define RADIO_LOCATION "http://stream.chainefm.com:8004"  // set your "http://IP_ADDRESS:PORT"

//#define PRINTERROR(LABEL)	printf("%s err %4.4s %d\n", LABEL, &err, err)
#define PRINTERROR(LABEL)	printf("%s err %4.4s %d\n", LABEL, (char*)&err, (int)err)


MyData* globalMyData;

@implementation ListenViewController

static const CFOptionFlags kNetworkEvents = kCFStreamEventOpenCompleted |
kCFStreamEventHasBytesAvailable |
kCFStreamEventEndEncountered |
kCFStreamEventErrorOccurred;


int MyFindQueueBuffer(MyData* myData, AudioQueueBufferRef inBuffer)
{
	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		if (inBuffer == myData->audioQueueBuffer[i])
			return i;
	}
	return -1;
}


void MyAudioQueueOutputCallback(void*					inClientData,
								AudioQueueRef			inAQ,
								AudioQueueBufferRef		inBuffer)
{
	// this is called by the audio queue when it has finished decoding our data.
	// The buffer is now free to be reused.
	MyData* myData = (MyData*)inClientData;
	
	unsigned int bufIndex = MyFindQueueBuffer(myData, (AudioQueueBufferRef)inBuffer);
	
	// signal waiting thread that the buffer is free.
	pthread_mutex_lock(&myData->mutex);
	myData->inuse[bufIndex] = false;
	pthread_cond_signal(&myData->cond);
	pthread_mutex_unlock(&myData->mutex);
}


OSStatus StartQueueIfNeeded(MyData* myData)
{
	OSStatus err = noErr;
	if (!myData->started) {		// start the queue if it has not been started already
		AudioQueueReset(myData->audioQueue);
        err = AudioQueueStart(myData->audioQueue, NULL);
		if (err) {
            PRINTERROR("AudioQueueStart");
            myData->failed = true;
            //return err;
            return err;
        }
		myData->started = true;
		printf("started\n");
	}
	return err;
}


OSStatus MyEnqueueBuffer(MyData* myData)
{
	OSStatus err = noErr;
	myData->inuse[myData->fillBufferIndex] = true;		// set in use flag
	
	// enqueue buffer
	AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[myData->fillBufferIndex];
	fillBuf->mAudioDataByteSize = myData->bytesFilled;
	err = AudioQueueEnqueueBuffer(myData->audioQueue, fillBuf, myData->packetsFilled, myData->packetDescs);
	if (err) { PRINTERROR("AudioQueueEnqueueBuffer"); myData->failed = true; return err; }
	
	StartQueueIfNeeded(myData);
	
	return err;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(59,226,219,49)];
    [self.view addSubview:volumeView];
    
    pause1.hidden=TRUE;
    pause2.hidden=true;
    ResumeRButton.hidden=true;
    

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //disable idle timer

    
    
	// Do any additional setup after loading the view, typically from a nib.
    {
        // Set Show information
        
        PFQuery *query = [PFQuery queryWithClassName:@"AppText"];
        [query getObjectInBackgroundWithId:@"ZyFiRteUhF" block:^(PFObject *showText, NSError *error)
         
         
         {
             // Do something with the returned PFObject in the gameScore variable.
             NSLog(@"%@", showText);
             
             
             
             ShowTitle.text = [showText objectForKey:@"TextValue"];
             ShowTitle.font = [UIFont fontWithName:@"SignikaNegative-Bold"  size:20];
         }];
        
        
        
    }
    
    {
        
        
        PFQuery *query = [PFQuery queryWithClassName:@"AppText"];
        [query getObjectInBackgroundWithId:@"3IMYg8RCr8" block:^(PFObject *djText, NSError *error)
         
         
         {
             // Do something with the returned PFObject in the gameScore variable.
             NSLog(@"%@", djText);
             
             
             
             // Set Presenter Information
             PresenterName.text = [NSString stringWithFormat:@"with %@",[djText objectForKey:@"TextValue"]];
             PresenterName.font = [UIFont fontWithName:@"SignikaNegative-Regular" size:14];
             
         }];
    }
    
    {
        // Set Show Information
        // mGTySi5af4
        
        PFQuery *query = [PFQuery queryWithClassName:@"AppText"];
        [query getObjectInBackgroundWithId:@"mGTySi5af4" block:^(PFObject *rshowText, NSError *error)
         
         
         {
             // Do something with the returned PFObject in the gameScore variable.
             NSLog(@"%@", rshowText);
             
             
             
             ShowInformation.text = [rshowText objectForKey:@"TextValue"];
             ShowInformation.textAlignment = NSTextAlignmentCenter;
             ShowInformation.font = [UIFont fontWithName:@"SignikaNegative-Regular" size:11];
             ShowInformation.numberOfLines = 0;
         }];
    }
}



void WaitForFreeBuffer(MyData* myData)
{
	// go to next buffer
	if (++myData->fillBufferIndex >= kNumAQBufs) myData->fillBufferIndex = 0;
	myData->bytesFilled = 0;		// reset bytes filled
	myData->packetsFilled = 0;		// reset packets filled
	
	// wait until next buffer is not in use
	printf("->lock\n");
	pthread_mutex_lock(&myData->mutex);
	while (myData->inuse[myData->fillBufferIndex]) {
		printf("... WAITING ...\n");
		pthread_cond_wait(&myData->cond, &myData->mutex);
	}
	pthread_mutex_unlock(&myData->mutex);
	printf("<-unlock\n");
}


void MyAudioQueueIsRunningCallback(void*					inClientData,
								   AudioQueueRef			inAQ,
								   AudioQueuePropertyID	inID)
{
	MyData* myData = (MyData*)inClientData;
	
	UInt32 running;
	UInt32 size;
	OSStatus err = AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &running, &size);
	if (err) { PRINTERROR("get kAudioQueueProperty_IsRunning"); return; }
	if (!running) {
		pthread_mutex_lock(&myData->mutex);
		pthread_cond_signal(&myData->done);
		pthread_mutex_unlock(&myData->mutex);
	}
}


void MyPropertyListenerProc(void *							inClientData,
							AudioFileStreamID				inAudioFileStream,
							AudioFileStreamPropertyID		inPropertyID,
							UInt32 *						ioFlags)
{
	// this is called by audio file stream when it finds property values
	MyData* myData = (MyData*)inClientData;
	OSStatus err = noErr;
	
	printf("found property '%c%c%c%c'\n", (char)(inPropertyID>>24)&255, (char)(inPropertyID>>16)&255, (char)(inPropertyID>>8)&255, (char)inPropertyID&255);
	
	switch (inPropertyID) {
		case kAudioFileStreamProperty_ReadyToProducePackets :
		{
			// the file stream parser is now ready to produce audio packets.
			// get the stream format.
			AudioStreamBasicDescription asbd;
			UInt32 asbdSize = sizeof(asbd);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
			if (err) { PRINTERROR("get kAudioFileStreamProperty_DataFormat"); myData->failed = true; break; }
			
			// create the audio queue
			err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, myData, NULL, NULL, 0, &myData->audioQueue);
			if (err) { PRINTERROR("AudioQueueNewOutput"); myData->failed = true; break; }
			
			// allocate audio queue buffers
			for (unsigned int i = 0; i < kNumAQBufs; ++i) {
				err = AudioQueueAllocateBuffer(myData->audioQueue, kAQBufSize, &myData->audioQueueBuffer[i]);
				if (err) { PRINTERROR("AudioQueueAllocateBuffer"); myData->failed = true; break; }
			}
			
			// get the cookie size
			UInt32 cookieSize;
			Boolean writable;
			err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
			if (err) { PRINTERROR("info kAudioFileStreamProperty_MagicCookieData"); break; }
			printf("cookieSize %d\n", (unsigned int)cookieSize);
			
			// get the cookie data
			void* cookieData = calloc(1, cookieSize);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
			if (err) { PRINTERROR("get kAudioFileStreamProperty_MagicCookieData"); free(cookieData); break; }
			
			// set the cookie on the queue.
			err = AudioQueueSetProperty(myData->audioQueue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
			free(cookieData);
			if (err) { PRINTERROR("set kAudioQueueProperty_MagicCookie"); break; }
			
			// listen for kAudioQueueProperty_IsRunning
			err = AudioQueueAddPropertyListener(myData->audioQueue, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, myData);
			if (err) { PRINTERROR("AudioQueueAddPropertyListener"); myData->failed = true; break; }
			
			break;
		}
	}
}


static void
ReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo) {
	
	if(type == kCFStreamEventHasBytesAvailable) {
        
		UInt8 buffer[2048];
		CFIndex bytesRead = CFReadStreamRead(stream, buffer, sizeof(buffer));
		
		if (bytesRead < 0) {
			//nothing
		}
		// If zero bytes were read, wait for the EOF to come.
		else if (bytesRead) {
			// parse the data. this will call MyPropertyListenerProc and MyPacketsProc
			OSStatus err = AudioFileStreamParseBytes(globalMyData->audioFileStream, bytesRead, buffer, 0);
			if (err) { PRINTERROR("AudioFileStreamParseBytes"); }
		}
	}
}


void MyPacketsProc(void *							inClientData,
				   UInt32							inNumberBytes,
				   UInt32							inNumberPackets,
				   const void *					inInputData,
				   AudioStreamPacketDescription	*inPacketDescriptions)
{
	// this is called by audio file stream when it finds packets of audio
	MyData* myData = (MyData*)inClientData;
	printf("got data.  bytes: %d  packets: %d\n", (unsigned int)inNumberBytes, (unsigned int)inNumberPackets);
	
	// the following code assumes we're streaming VBR data. for CBR data, you'd need another code branch here.
	
	for (int i = 0; i < inNumberPackets; ++i) {
		SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
		SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
		
		// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
		size_t bufSpaceRemaining = kAQBufSize - myData->bytesFilled;
		if (bufSpaceRemaining < packetSize) {
			MyEnqueueBuffer(myData);
			WaitForFreeBuffer(myData);
		}
        
        
		
		// copy data to the audio queue buffer
		AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[myData->fillBufferIndex];
		memcpy((char*)fillBuf->mAudioData + myData->bytesFilled, (const char*)inInputData + packetOffset, packetSize);
		// fill out packet description
		myData->packetDescs[myData->packetsFilled] = inPacketDescriptions[i];
		myData->packetDescs[myData->packetsFilled].mStartOffset = myData->bytesFilled;
		// keep track of bytes filled and packets filled
		myData->bytesFilled += packetSize;
		myData->packetsFilled += 1;
		
		// if that was the last free packet description, then enqueue the buffer.
		size_t packetsDescsRemaining = kAQMaxPacketDescs - myData->packetsFilled;
		if (packetsDescsRemaining == 0) {
			MyEnqueueBuffer(myData);
			WaitForFreeBuffer(myData);
		}
	}
}


-(void)connectionStart {
	NSLog(@"%s", "Hello");
	
	@try {
		NSError *activationError = nil;
        BOOL success = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
        if (!success) { /* handle the error in activationError */ }
		// allocate a struct for storing our state
        NSError *setCategoryError = nil;
        BOOL Csuccess = [[AVAudioSession sharedInstance]
                        setCategory: AVAudioSessionCategoryPlayback
                        error: &setCategoryError];
        
        if (!Csuccess) { 			NSLog(@"Creating the cat failed");}
        
        
		MyData* myData = (MyData*)calloc(1, sizeof(MyData));
		
		//allow others
		globalMyData = myData;
		
		// initialize a mutex and condition so that we can block on buffers in use.
		pthread_mutex_init(&myData->mutex, NULL);
		pthread_cond_init(&myData->cond, NULL);
		pthread_cond_init(&myData->done, NULL);
		
		// create an audio file stream parser
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
       
        
		OSStatus err = AudioFileStreamOpen(myData, MyPropertyListenerProc, MyPacketsProc,
										   kAudioFileMP3Type, &myData->audioFileStream);
		if (err) {
            PRINTERROR("AudioFileStreamOpen");
            //return 1;
        }
		
        //ARC problem fixing by adding "(__bridge void*)"
        //from http://stackoverflow.com/questions/6868130/implicit-conversion-of-an-objective-c-pointer-to-void-is-disallowed-with-arc
        
		CFStreamClientContext ctxt = {0, (__bridge void*)self, NULL, NULL, NULL};
		
		CFStringRef bodyData = CFSTR(""); // Usually used for POST data
		CFStringRef headerFieldName = CFSTR("X-My-Favorite-Field");
		CFStringRef headerFieldValue = CFSTR("Dreams");
		
		CFStringRef url = CFSTR(RADIO_LOCATION);
		CFURLRef myURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
		CFStringRef requestMethod = CFSTR("GET");
		CFHTTPMessageRef myRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, myURL, kCFHTTPVersion1_1);
		
		CFHTTPMessageSetBody(myRequest, (CFDataRef)bodyData);
		CFHTTPMessageSetHeaderFieldValue(myRequest, headerFieldName, headerFieldValue);
		
		//CFDataRef mySerializedRequest = CFHTTPMessageCopySerializedMessage(myRequest);
		
		// Create the stream for the request.
		CFReadStreamRef stream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, myRequest);
		
		if (!stream) {
			NSLog(@"Creating the stream failed");
			return;
		}
		
		// Use persistent conections so connection-based authentications work correctly.
		//CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPAttemptPersistentConnection, kCFBooleanTrue);
		
		// Set the client
		if (!CFReadStreamSetClient(stream, kNetworkEvents, ReadStreamClientCallBack, &ctxt)) {
			CFRelease(stream);
			NSLog(@"Setting the stream's client failed.");
			return;
		}
		
		// Schedule the stream
		CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
		
		// Start the HTTP connection
		if (!CFReadStreamOpen(stream)) {
			CFReadStreamSetClient(stream, 0, NULL, NULL);
			CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
			CFRelease(stream);
			NSLog(@"Opening the stream failed.");
			return;
		}
		
		/*
		 // Don't need the old stream any more.
		 if (stream) {
         CFReadStreamClose(stream);
         CFRelease(stream);
		 }
		 */
	}
	@catch (NSException *exception) {
		NSLog(@"main: Caught %@: %@", [exception name],  [exception reason]);
	}
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        NSString *ShowInfoTitle;
        NSString *ShowInfoPresenter;
        
        ShowInfoTitle = ShowTitle.text;
        ShowInfoPresenter = PresenterName.text;



        
        [songInfo setObject:ShowInfoTitle forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:ShowInfoPresenter forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:@"Chaine FM 106.3FM" forKey:MPMediaItemPropertyAlbumTitle];

        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) resumeRadio //example for resume radio stream
 {
 NSLog(@"Resuming stream...");
 OSStatus  err = AudioQueueStart(globalMyData->audioQueue, NULL);
 if (err) { PRINTERROR("AudioQueueStart"); globalMyData->failed = true; //return err;
 }
 }
 
 -(void) pauseRadio //example for pause radio stream
 {
 NSLog(@"stream paused");

     OSStatus err = AudioQueuePause(globalMyData->audioQueue);

 if (err) { PRINTERROR("AudioQueueStart"); globalMyData->failed = true; //return err2;
 }
 //CFReadStreamClose(globalStream);
 //CFRelease(globalStream);
 //globalMyData = nil;
 
 }


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder]; [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
                //RESPOND TO PLAY/PAUSE EVENT HERE
                break;
            }
            default:
                break;
        }
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)PlayPress:(id)sender; {
    [self connectionStart];
    playPauseButton.hidden=true;
    playPauseButton2.hidden=true;
    pause1.hidden=false;
    pause2.hidden=false;
    pause1.enabled=true;
    pause2.enabled=true;
}

- (IBAction)PausePress:(id)sender; {
    [self pauseRadio];
    pause1.hidden=true;
    pause2.hidden=true;
    ResumeRButton.hidden=false;
}


- (IBAction)ResumeRadio:(id)sender; {
    [self resumeRadio];
    pause1.hidden=false;
    
    pause2.hidden=false;
    pause1.enabled=true;
    pause2.enabled=true;
    ResumeRButton.hidden=true;
    
}
@end
