//
//  Comment.h
//  NicoTimeShift
//
//  Created by 小川 洸太郎 on 11/12/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GetCommentDelegate

@optional
-(void)stopIndicator;
-(void)stopIndicatorWithFail;
-(void)screenError;
-(void)addObNotifi;

@end

@interface GetComment : NSObject <NSStreamDelegate>{
    NSString *xml;
    NSString *addr;
    NSInteger port;
    NSString *lv;
	NSInteger comment_count;
	NSInteger baseTime;
	NSInteger currentTime;
	NSInteger queSheetTime;
	BOOL startOfComment;
	NSInteger chatTagCount;
	
	NSMutableString *dumpedString;
    
    NSInputStream *inputStream;
	NSOutputStream *outputStream;
	BOOL isOpen;
    
    NSMutableArray *URL;
    
    NSTask *taskWhich;
    NSPipe *pipeWhich;
    NSMutableArray *tasks;
    NSMutableArray *pipes;
    
    int taskIndex;
    
    NSInteger testTime;
}

-(NSString *)getMovieComment:(NSInteger)browse lvNumber:(NSString *)lv;
//-(BOOL)checkRtmpdump;
-(BOOL)getXml;
- (BOOL)getWaybackKey;
-(BOOL)getUserSession:(NSInteger)browser;
-(BOOL)getAPT;
-(BOOL)getComment;
-(BOOL)getMovie;
-(void)socketOpen:(NSString *)ipAddress port:(NSInteger)portNo;
-(void)doTask;
@property(nonatomic,retain) NSString *sessionId;
@property(nonatomic,retain) id <GetCommentDelegate> delegate;
@property(nonatomic,retain) NSString *keepString;
@property(nonatomic,retain) NSMutableData *dataStream;
@property(nonatomic,retain) NSString *rtmpdumpPath;
@property(nonatomic,retain) NSString *threadId;
@property(nonatomic,retain) NSString *userId;
@property (nonatomic, retain) NSString *waybackKey;
@property(nonatomic,retain) NSString *TICKET;

@end
