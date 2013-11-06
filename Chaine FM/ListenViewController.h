//
//  ListenViewController.h
//  Chaine FM
//
//  Created by Mark McWhirter on 06/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//


#import <UIKit/UIKit.h>
#include <stdio.h>
#include <string.h>
#include <netdb.h>
#include <netinet/in.h>
#include <unistd.h>
#include <pthread.h>
#include <AudioToolbox/AudioToolbox.h>
#include <CFNetwork/CFHTTPMessage.h>
#include <CoreAudio/CoreAudioTypes.h>
#include <MediaPlayer/MediaPlayer.h>
#include <AVFoundation/AVAudioSession.h>


#define kNumAQBufs 3		// number of audio queue buffers we allocate
#define kAQBufSize  128*1024		// number of bytes in each audio queue buffer
#define kAQMaxPacketDescs 512		// number of packet descriptions in our array

struct MyData
{
	AudioFileStreamID audioFileStream;	// the audio file stream parser
	
	AudioQueueRef audioQueue;								// the audio queue
	AudioQueueBufferRef audioQueueBuffer[kNumAQBufs];		// audio queue buffers
	
	AudioStreamPacketDescription packetDescs[kAQMaxPacketDescs];	// packet descriptions for enqueuing audio
	
	unsigned int fillBufferIndex;	// the index of the audioQueueBuffer that is being filled
	size_t bytesFilled;				// how many bytes have been filled
	size_t packetsFilled;			// how many packets have been filled
	
	bool inuse[kNumAQBufs];			// flags to indicate that a buffer is still in use
	bool started;					// flag to indicate that the queue has been started
	bool failed;					// flag to indicate an error occurred
	
	pthread_mutex_t mutex;			// a mutex to protect the inuse flags
	pthread_cond_t cond;			// a condition varable for handling the inuse flags
	pthread_cond_t done;			// a condition varable for handling the inuse flags
};
typedef struct MyData MyData;




@interface ListenViewController : UIViewController
{
    
    IBOutlet UIButton *playPauseButton; //Toggles the playback state
    IBOutlet UISlider *volumeControl; //Sets the volume for the audio player
    IBOutlet UILabel *alertLabel; //The alert label showing the status of the loading of the file
    
    IBOutlet UIButton *pause2;
    IBOutlet UIButton *pause1;
    IBOutlet UIButton *playPauseButton2;
    IBOutlet UILabel *ShowTitle;
    IBOutlet UILabel *ShowInformation;
    IBOutlet UILabel *PresenterName;

    IBOutlet UILabel *songTitle;
    IBOutlet UIButton *ResumeRButton;

}


void MyPacketsProc(void *							inClientData,
				   UInt32							inNumberBytes,
				   UInt32							inNumberPackets,
				   const void *					inInputData,
				   AudioStreamPacketDescription	*inPacketDescriptions);

int MyFindQueueBuffer(MyData* myData, AudioQueueBufferRef inBuffer);

void MyPropertyListenerProc(void *							inClientData,
							AudioFileStreamID				inAudioFileStream,
							AudioFileStreamPropertyID		inPropertyID,
							UInt32 *						ioFlags);


void MyAudioQueueIsRunningCallback(void*					inClientData,
								   AudioQueueRef			inAQ,
								   AudioQueuePropertyID	inID);

OSStatus MyEnqueueBuffer(MyData* myData);

void WaitForFreeBuffer(MyData* myData);

void MyAudioQueueOutputCallback(void*					inClientData,
								AudioQueueRef			inAQ,
								AudioQueueBufferRef		inBuffer);

OSStatus StartQueueIfNeeded(MyData* myData);


@end


