//
//  Comment.m
//  NicoTimeShift
//
//  Created by 小川 洸太郎 on 11/12/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GetComment.h"
#import "sqlite3.h"
#import "RegexKitLite.h"
//#import "RKLMatchEnumerator.h"

#define CHROME 0
#define SAFARI 1
#define FIREFOX 2
@implementation GetComment


@synthesize sessionId;
@synthesize delegate;
@synthesize keepString;
@synthesize dataStream;
@synthesize rtmpdumpPath;
@synthesize threadId;
@synthesize TICKET;

-(NSString *)getMovieComment:(NSInteger)browser lvNumber:(NSString *)lvNum{
    // BOOL isRtmpdumpOk = [self checkRtmpdump];
    
    
    lv = [[NSString alloc]initWithString: lvNum];
    isOpen = NO;
	startOfComment = NO;
    self.keepString = @"";
	self.waybackKey = nil;
	dumpedString = nil;
    [self getUserSession:browser];
    
    [self getXml];//,@"didn't get xml.");
    [self getComment];//,@"didn't get comment.");
    [self getMovie];//,@"didn't get movie.");
    //
    //[delegate stopIndicator]; 
    
    
    return @"ok";
}
/*
 - (BOOL)checkRtmpdump{
 
 NSString *a_home_dir = NSHomeDirectory();
 taskWhich = [[NSTask alloc]init];
 pipeWhich = [[NSPipe alloc]init];
 NSPipe *pipeError = [[NSPipe alloc]init];
 [taskWhich setStandardOutput:pipeWhich];
 [taskWhich setStandardError:pipeError];
 [taskWhich setLaunchPath: @"/usr/bin/which"];
 
 [taskWhich setCurrentDirectoryPath:a_home_dir];
 
 
 [taskWhich setEnvironment:[NSDictionary dictionaryWithObject:@"/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin:/usr/X11/bin" forKey:@"PATH"]];
 //[taskWhich setArguments: [NSArray arrayWithObjects: @"-c", @"/bin/ls", nil]];
 [taskWhich setArguments: [NSArray arrayWithObjects: @"rtmpdump", nil]];
 
 [taskWhich launch];
 
 // [taskWhich waitUntilExit];
 
 NSData *dataOutput = [[pipeWhich fileHandleForReading] readDataToEndOfFile];
 
 //fh   = [pipe fileHandleForReading];
 //result_data = [fh availableData];
 NSString *result_str  = [[[NSString alloc]initWithData:dataOutput encoding:NSUTF8StringEncoding]autorelease];
 NSLog(@"result_str : %@",result_str);
 
 NSData*   dataErr = [[pipeError fileHandleForReading ] readDataToEndOfFile];
 NSString* strErr  = [[NSString alloc] initWithData:dataErr encoding:NSUTF8StringEncoding];
 NSLog(@"std err --\n%@",strErr);
 [strErr release];
 [pipeError release];
 
 
 //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readDataWhich:) name:NSFileHandleReadCompletionNotification object:nil];
 // [[pipeWhich fileHandleForReading] readInBackgroundAndNotify];
 
 if(![result_str isEqualToString:@""]){
 self.rtmpdumpPath = result_str;
 self.rtmpdumpPath = [self.rtmpdumpPath stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
 NSLog(@"rtmpDumpPath : %@", self.rtmpdumpPath);
 return YES;
 }else{
 return NO;
 }
 
 
 }
 */
- (void)readDataWhich:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
    
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"%@",string);
    
    
    
    
    if ( [taskWhich isRunning] ) {
        [[pipeWhich fileHandleForReading] readInBackgroundAndNotify];
        NSLog(@"task inRunning");
        return;
    } else {
        //      NSLog(@"doTask end taskIndex : %d", taskIndex);
        [taskWhich release];
        //pipe = nil;
        [pipeWhich release];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        taskIndex++;
        if(taskIndex == [URL count]){
            
        }else{
            //[self doTask];
        }
        
        
        
    }
    
    
    
}

-(BOOL)getXml{
    NSString *urlString = [NSString stringWithFormat:@"http://watch.live.nicovideo.jp/api/getplayerstatus?v=%@", lv];
    
    NSURL *urlLogin = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequestLogin = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
    
    [urlRequestLogin setHTTPMethod:@"POST"];
    [urlRequestLogin setValue:sessionId forHTTPHeaderField:@"Cookie"];//:[sessionId dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse* responseLogin;
    NSError* errorLogin = nil;
    NSData* resultLogin = [NSURLConnection sendSynchronousRequest:urlRequestLogin returningResponse:&responseLogin error:&errorLogin];
    
    xml= [[NSString alloc]initWithData:resultLogin encoding:NSUTF8StringEncoding];
    // xml = [NSString stringWithFormat:@"<xml>%@</xml>", xml];
    NSLog(@"xml : %@", xml);
    [urlRequestLogin release];
    return YES;
}

- (BOOL)getWaybackKey {
	if (self.threadId == nil) return NO;
	
	NSString *urlString = [NSString stringWithFormat:@"http://watch.live.nicovideo.jp/api/getwaybackkey?thread=%@", self.threadId];
	
	NSURL *urlLogin = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequestLogin = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
	
	NSURLResponse* responseLogin;
    NSError* errorLogin = nil;
    NSData* resultLogin = [NSURLConnection sendSynchronousRequest:urlRequestLogin returningResponse:&responseLogin error:&errorLogin];
	
	self.waybackKey = [[[[NSString alloc] initWithData:resultLogin encoding:NSUTF8StringEncoding] autorelease] componentsSeparatedByString:@"="][1];
	
	NSLog(@"waybackKey : %@", self.waybackKey);
    [urlRequestLogin release];
	
	return YES;
}

- (BOOL)getComment{
	NSError *error;
	NSString *a_home_dir = NSHomeDirectory();
	NSString *path = [NSString stringWithFormat:@"%@/comment_%@.xml", a_home_dir, lv];
	NSString *empty = @"";
	[empty writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
	
    //get addr, port, threadId
    [self getAPT];
    [self socketOpen:addr port:port];
    
    
    return YES;
}

- (BOOL)getAPT{
    //get addr, port, threadId
    NSError *error;
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc]initWithXMLString:xml options:NSXMLNodeOptionsNone error:&error];
    
    //  NSString *dockString = [NSString stringWithFormat:@"<xml>%@</xml>", xml];
    
    NSArray *temp = [xmlDoc nodesForXPath:@"/getplayerstatus/ms/addr/text()" error:&error];
    
    for (NSXMLNode *node in temp) {
        addr = [node stringValue];
        NSLog(@"addr : %@", addr);
    }
    
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/ms/port/text()" error:&error];
    
    for (NSXMLNode *node in temp) {
        port = [[node stringValue]integerValue];
        NSLog(@"port : %ld", port);
    }
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/ms/thread/text()" error:&error];
    
    for (NSXMLNode *node in temp) {
        self.threadId = [node stringValue];
        NSLog(@"threadId : %@", self.threadId);
    }
	
	temp = [xmlDoc nodesForXPath:@"/getplayerstatus/user/user_id/text()" error:&error];
	for (NSXMLNode *node in temp) {
        self.userId = [node stringValue];
        NSLog(@"userId : %@", self.userId);
    }
	
	comment_count = 0;
	temp = [xmlDoc nodesForXPath:@"/getplayerstatus/stream/comment_count/text()" error:&error];
	for (NSXMLNode *node in temp) {
        comment_count = [[node stringValue] integerValue];
        NSLog(@"comment_count : %ld", comment_count);
    }
    
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/stream/base_time/text()" error:&error];
    NSAssert([temp count] == 1, @"base_time is not one.");
    baseTime = [[[temp objectAtIndex:0] stringValue]integerValue];
    NSLog(@"baseTime : %ld", baseTime);
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/stream/open_time/text()" error:&error];
    NSAssert([temp count] == 1, @"open_time is not one.");
    NSInteger openTime = [[[temp objectAtIndex:0] stringValue]integerValue];
    NSAssert(baseTime == openTime, @"base_time is not equal open_time."); 
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/stream/start_time/text()" error:&error];
    NSAssert([temp count] == 1, @"start_time is not one.");
    NSInteger startTime = [[[temp objectAtIndex:0] stringValue]integerValue];
	temp = [xmlDoc nodesForXPath:@"/getplayerstatus/stream/end_time/text()" error:&error];
    NSAssert([temp count] == 1, @"start_time is not one.");
    NSInteger endTime = [[[temp objectAtIndex:0] stringValue]integerValue];
    
    testTime = startTime - baseTime;
    NSLog(@"baseTime : %ld", baseTime);
    NSLog(@"startTime : %ld", startTime);
    NSLog(@"testTime : %ld", testTime);
	NSLog(@"endTime : %ld", endTime);
	
	currentTime = endTime + 200;
	
	queSheetTime = -currentTime;
	temp = [xmlDoc nodesForXPath:@"/getplayerstatus/stream/quesheet/que" error:&error];
	for (NSXMLElement *node in temp) {
		if (![[node stringValue] hasPrefix:@"/publish "]) continue;
		
		NSXMLNode *vpos = [node attributeForName:@"vpos"];
		
		if ([[vpos stringValue] integerValue] > queSheetTime)
			queSheetTime = [[vpos stringValue] integerValue];
	}
	queSheetTime = ABS(queSheetTime);
	NSLog(@"queSheetTime : %ld", queSheetTime);
	
	[xmlDoc release];
	
	return [self getWaybackKey];
}

- (void)socketOpen:(NSString *)ipAddress port:(NSInteger)portNo
{
    //   data = [NSMutableData data];
	if (isOpen == NO) {
        
		NSHost *host = [NSHost hostWithName:ipAddress];
		
		[NSStream getStreamsToHost:host port:portNo inputStream:&inputStream outputStream:&outputStream];		
		
		[inputStream retain];
		[outputStream retain];
        
		
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [inputStream open];
		[outputStream open];
        
        keepString = @"";
        commentArray = [[NSMutableArray alloc]init];
        vposArray = [[NSMutableArray alloc]init];
        userIdArray = [[NSMutableArray alloc]init];
		isOpen = YES;
	}
}

- (void)socketClose
{
	if (isOpen == YES) {
		[inputStream close];
		//[outputStream close];
		[inputStream release];
		[outputStream release];
		isOpen = NO;		
	}
}

- (BOOL)getMovie{
    // taskIndex = 0;
    URL = [[NSMutableArray alloc]init];
    tasks = [[NSMutableArray alloc]init];
    pipes = [[NSMutableArray alloc]init];
    
    NSString *URLRegex = @"(rtmp://.*?fileorigin/)";
	NSString *queSheetsRegex = @"(content/.*?.f4v)";
    NSString *TICKETRegex = @"<ticket>(.*)</ticket>";
    
    NSArray *matchURL = [xml componentsMatchedByRegex:URLRegex capture:1L];
    NSLog(@"matchURL : %@", matchURL);
	
	NSArray *queSheets = [xml componentsMatchedByRegex:queSheetsRegex capture:1L];
    NSLog(@"queSheets : %@", queSheets);
    
    for (int i = 0; i < [queSheets count]; i++) {
        [URL addObject:[NSString stringWithFormat:@"%@/mp4:%@", matchURL[0], queSheets[i]]];
    }
    NSLog(@"URL : %@", URL);  
    
    //TICKET = [NSString stringWithFormat:@"S:%@",[xml stringByMatching:TICKETRegex capture:1L]];//S:を含む
    self.TICKET = [xml stringByMatching:TICKETRegex capture:1L];
    NSLog(@"TICKET : %@", self.TICKET); 
    //NSPipe       *pipe = [NSPipe pipe];
	//NSTask       *task = [[NSTask alloc] init];
	/*
     pipe = [NSPipe pipe];
     task = [[NSTask alloc] init];
     //タスクの準備
     [task setStandardOutput: pipe];
     [task setStandardError : pipe];
     [task setLaunchPath: @"/bin/sh"];
     */
    NSString *a_home_dir = NSHomeDirectory();
    NSLog(@"a_home_dir : %@", a_home_dir);
    NSLog(@"[URL count] : %ld", [URL count]);
    //
    [self doTask];
    
    return YES;
}

- (void)readData:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
    
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"string : %@",string);
    for (int i = 0; i < [URL count]; i++) {
        
        
        if ( [[tasks objectAtIndex:i] isRunning] ) {
            [[[pipes objectAtIndex:i] fileHandleForReading] readInBackgroundAndNotify];
            NSLog(@"task inRunning");
            return;
        } else {
            NSLog(@"doTask end taskIndex : %d", taskIndex);
            //[task release];
            //pipe = nil;
            //[pipe release];
            //[[NSNotificationCenter defaultCenter] removeObserver:self];
            
            
        }
        
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [delegate stopIndicator]; 
    
}

-(void)doTask{
    NSLog(@"doTask start taskIndex : %d", taskIndex);
    
    NSString *a_home_dir = NSHomeDirectory();
    //NSMutableArray *tasks = [NSMutableArray array];
    //NSMutableArray *pipes = [NSMutableArray array];
    NSString *argument;
    NSString *rtmpdumpPath = [[NSBundle mainBundle] pathForResource:@"_rtmpdump" ofType:nil];
    for (int i = 0; i < [URL count]; i++) {
        NSTask *task = [[[NSTask alloc]init]autorelease];
        NSPipe *pipe = [[[NSPipe alloc]init]autorelease];
        [task setStandardOutput:pipe];
        
        [task setLaunchPath:@"/bin/sh"];
        if (i != 0) {
            [task setStandardInput:[pipes objectAtIndex:i - 1]];
        }
                
        if (i == 0) {
            argument = [NSString stringWithFormat:@"%@ -r \"%@\" -C S:\"%@\" -f \"MAC 10,0,32,18\" -s \"http://live.nicovideo.jp/liveplayer.swf?20100531\" -o %@/%@.flv", rtmpdumpPath, [URL objectAtIndex:i], self.TICKET, a_home_dir, lv];
        }else{
            argument = [NSString stringWithFormat:@"%@ -r \"%@\" -C S:\"%@\" -f \"MAC 10,0,32,18\" -s \"http://live.nicovideo.jp/liveplayer.swf?20100531\" -o %@/%@_%d.flv", rtmpdumpPath, [URL objectAtIndex:i], self.TICKET, a_home_dir, lv, i + 1];
        }
        
        
        NSLog(@"argument : %@", argument);
        [task setArguments: [NSArray arrayWithObjects: @"-c", argument, nil]];
        [tasks addObject:task];
        [pipes addObject:pipe];
        
    }
    for (int i = 0; i < [URL count]; i++) {
#if !DEBUG
        [[tasks objectAtIndex:i] launch];
#endif
    }
    
    //[task waitUntilExit];
    //[delegate addObNotifi];
    //NSData *dataOutput = [[[pipes objectAtIndex:[URL count] - 1] fileHandleForReading]readDataToEndOfFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readData:) name:NSFileHandleReadCompletionNotification object:nil];
    
    //    for (int i = 0; i < [URL count]; i++) {
    //      [[[pipes objectAtIndex:i] fileHandleForReading] readInBackgroundAndNotify];
    
    //  }
    
	if ([URL count] > 0)
		[[[pipes objectAtIndex:[URL count] - 1 ]fileHandleForReading] readInBackgroundAndNotify];
    
}

-(BOOL)getUserSession:(NSInteger)browser{
    NSString *a_home_dir = NSHomeDirectory();
    NSString *cookiePath = @"";
    
    
    if (browser == SAFARI) { //Safari
        
        cookiePath = [a_home_dir stringByAppendingPathComponent:@"Library/Cookies/Cookies.plist"];
        NSArray *cookieArray = [NSArray arrayWithContentsOfFile:cookiePath];
        
        for (NSDictionary *dic in cookieArray) {
            NSString *domain = [dic objectForKey:@"Domain"];
            NSString *name = [dic objectForKey:@"Name"];
            //NSLog(@"domain : %@", domain);
            //NSLog(@"name : %@", name);
            if ([domain isEqualToString:@".nicovideo.jp"] && [name isEqualToString:@"user_session"]) {
                self.sessionId = [NSString stringWithFormat:@"user_session=%@", [dic objectForKey:@"Value"]];
                NSLog(@"if ok");
            }
        }
        
        //NSLog(@"cookieArray : %@", cookieArray);
        NSLog(@"sessionId : %@", self.sessionId);
    }
    else { //Chrome, Firefox
        sqlite3 *db_;
        
        
        if (browser == CHROME) {
            
            cookiePath = [a_home_dir stringByAppendingPathComponent:@"Library/Application Support/Google/Chrome/Default/Cookies"];
            NSLog(@"cookiePath : %@", cookiePath);
        }else{
            
            //Objcでファイル取得　検索＋取得
            NSFileManager *defaultFileManager = [NSFileManager defaultManager];
            NSString* dirPath = [a_home_dir stringByAppendingPathComponent:@"Library/Application Support/Firefox/Profiles"];
            
            NSError *error;
            NSArray *contents = [defaultFileManager contentsOfDirectoryAtPath:dirPath error:&error];
            
            NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:0];
            
            for (int i = 0; i < [contents count]; i++) {
                NSString *name = [contents objectAtIndex: i];
                NSString *cookiePathTmp = [NSString stringWithFormat:@"%@/%@/cookies.sqlite", dirPath, name];
                NSLog(@"cookiePathTmp : %@", cookiePathTmp);
                if([defaultFileManager fileExistsAtPath:cookiePathTmp]){
                    NSDictionary *fileAttribs = [defaultFileManager attributesOfItemAtPath:cookiePathTmp error:&error];
                    NSDate *date = [fileAttribs valueForKey:NSFileModificationDate];
                    if([newDate compare:date] == NSOrderedAscending){
                        newDate = date;  
                        cookiePath = cookiePathTmp;
                    }
                }
            }
        }
        if(sqlite3_open_v2([cookiePath UTF8String], &db_, SQLITE_OPEN_READONLY, nil) == SQLITE_OK){
            NSLog(@"cookiePath : %@", cookiePath);
            NSLog(@"succeed_open_databasefile");
        }else {
            // エラー処理
            NSLog(@"Error!");
            exit(-1);
        }
        NSString *sqlString;
        if(browser == CHROME){
            sqlString = [NSString stringWithFormat:@"%@", @"select value from cookies where host_key = '.nicovideo.jp' and name = 'user_session' limit 1;"];
        }else {
            sqlString = [NSString stringWithFormat:@"%@", @"select value from moz_cookies where host = '.nicovideo.jp' and name = 'user_session';"];
        }
        
        const char *sql_c = [sqlString cStringUsingEncoding:NSUTF8StringEncoding];
        
        sqlite3_stmt *statement;
        int a0 = sqlite3_prepare_v2(db_, sql_c, -1, &statement, NULL);
        if(a0 != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db_));
        //int a = sqlite3_step(statement);
        
        while (SQLITE_DONE != sqlite3_step(statement)) {
            
            
            const char *ch = (char*)sqlite3_column_text(statement, 0);
            self.sessionId = [NSString stringWithFormat:@"user_session=%@", [NSString stringWithCString:ch encoding:NSUTF8StringEncoding]];   
            NSLog(@"sessionId : %@", self.sessionId);
        }
        /*
         if(a != SQLITE_DONE)
         NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db_));
         */
        
        sqlite3_finalize(statement);
        
        sqlite3_close(db_);
        
    }
    return YES;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    //NSMutableData *data = [[NSMutableData alloc]init];
    //NSLog(@"stream: handleEvent: ok");
    //NSLog(@"%lu", eventCode);
    switch (eventCode) {
        case NSStreamEventOpenCompleted:{
            NSLog(@"NSStreamEventOpenCompleted");
            
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            //NSLog(@"NSStreamEventHasBytesAvailable");
           // NSLog(@"----------\n\n\n\n\n\n");
            if (dataStream == nil) {
                dataStream = [[NSMutableData alloc] init];
            }
            uint8_t buf[1024];
            NSInteger len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            //            NSLog()
            if(len) {    
                [dataStream appendBytes:(const void *)buf length:len];
                int bytesRead;
                bytesRead += len;
            } else {
                NSLog(@"No data.");
            }
            
            NSString *str = [[NSString alloc] initWithData:dataStream
                                                  encoding:NSUTF8StringEncoding];
			if (str == nil) break;
            //NSLog(@"str : %@", str);
            NSString *strReplace = [str stringByReplacingOccurrencesOfString:@"\0" withString:@"\n"];
            //NSLog(@"strReplace : %@",strReplace);
            
            //XMLDocumentsにする
            
            //最後の改行で２つに分ける
            
            // 文字列strの中に@"\n"というパターンが存在するかどうか
            NSRange searchResult = [strReplace rangeOfString:@"\n"];
			if (strReplace == nil) {
				NSLog(@"%@, %@, %@,\n", dataStream, str, strReplace);
			}
            else if(searchResult.location == NSNotFound){
                // みつからない場
                self.keepString = [NSString stringWithFormat:@"%@%@", self.keepString, strReplace];
            }
			else {
                // みつかった場合の処
                NSRange range = [strReplace rangeOfString:@"\n" options:NSBackwardsSearch];
				//NSLog(@"range.location : %ld\n", range.location);
                
                
                NSString *front = [strReplace substringToIndex:range.location];
                NSString *rear = [strReplace substringFromIndex:range.location + 1];
				
                //NSLog(@"front : %@\n", front);
                //NSLog(@"rear : (%ld) '%@'\n", rear.length, rear);
                
                // NSString *dockString = [NSString stringWithFormat:@"<xml>%@</xml>", strReplace];
                
                NSString *dockString = [NSString stringWithFormat:@"<xml>%@%@</xml>", self.keepString, front];
				
				self.keepString = rear;
				
				BOOL needGetCurrTime = NO;
				if (dumpedString == nil) {
					dumpedString = [[NSMutableString alloc] initWithFormat:@""];
					needGetCurrTime = YES;
				}
                
                NSError *error;
                NSXMLDocument *xmlDoc = [[NSXMLDocument alloc]initWithXMLString:dockString options:NSXMLNodeOptionsNone error:&error];
                
                NSArray *temp = [xmlDoc nodesForXPath:@"/xml/chat" error:&error];
				
				if (temp.count == 0) {
					NSLog(@"XML node count is 0\n%@\n", dockString);
					[xmlDoc release];
					break;
				}
				
				if (needGetCurrTime) {
					NSArray *dates = [xmlDoc nodesForXPath:@"/xml/chat/@date" error:&error];
					
					currentTime = [[dates[0] stringValue] integerValue];
				}
				NSString *curTimeStr = [NSString stringWithFormat:@"%ld", currentTime];
				
                for (NSXMLElement *node in temp) {
					[commentArray addObject:[node stringValue]];
                    //NSLog(@"comment : %@", [node stringValue]);
					
					if ([[node stringValue] hasPrefix:@"/hb ifseetno "]) continue;
					
					NSXMLNode *date = [node attributeForName:@"date"];
					
					if (![[date stringValue] isEqualToString:curTimeStr]) {
						NSXMLNode *vpos = [node attributeForName:@"vpos"];
						
						NSString *temp3 = [[node description] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", [vpos stringValue]]
																						withString:[NSString stringWithFormat:@"\"%ld\"", [[vpos stringValue] integerValue] + queSheetTime]];
						[dumpedString appendFormat:@"%@\n", temp3];
						
						[vposArray addObject:[node stringValue]];
					}
                }
				
				if (!startOfComment && [[temp[0] stringValue] hasPrefix:@"/play "]) {
					NSMutableString *tempString = [NSMutableString stringWithFormat:@"<?xml version='1.0' encoding='UTF-8'?>\n<packet>\n"];
					
					for (NSXMLElement *node in temp) {
						if ([[node stringValue] hasPrefix:@"/hb ifseetno "]) continue;
						
						NSXMLNode *date = [node attributeForName:@"date"];
						
						if ([[date stringValue] isEqualToString:curTimeStr]) {
							NSXMLNode *vpos = [node attributeForName:@"vpos"];
							
							NSString *temp3 = [[node description] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", [vpos stringValue]]
																							withString:[NSString stringWithFormat:@"\"%ld\"", [[vpos stringValue] integerValue] + queSheetTime]];
							[tempString appendFormat:@"%@\n", temp3];
							
							[vposArray addObject:[node stringValue]];
						}
					}
					
                    [dumpedString insertString:tempString atIndex:0];
					
					startOfComment = YES;
					
					NSLog(@"detect start of comments");
				}
				
				temp = [xmlDoc nodesForXPath:@"/xml/chat[@premium=\"2\" and text()=\"/disconnect\"]" error:&error];
                [xmlDoc release];
                
				BOOL endOfComment = NO;
                if([temp count] != 0){
					[dumpedString appendFormat:@"</packet>\n"];
					endOfComment = YES;
					
					NSLog(@"detect end of comments");
				}
				
				if (isOpen && ![(NSInputStream *)stream hasBytesAvailable] && !endOfComment)
					usleep(500*1000);
				
				if (endOfComment || (isOpen && ![(NSInputStream *)stream hasBytesAvailable])) {
					//NSLog(@"commentArray count : %lu", [commentArray count]);
					
					[commentArray removeAllObjects];
					
					NSString *a_home_dir = NSHomeDirectory();
					NSString *path = [NSString stringWithFormat:@"%@/comment_%@.xml", a_home_dir, lv];
					
					NSMutableString *contents = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
					
					[contents insertString:dumpedString atIndex:0];
					[contents writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
					
					self.keepString = [NSString stringWithFormat:@"%@", rear ?: @""];
					
					[dumpedString release];
					dumpedString = nil;
					
					currentTime++;
					
					if (startOfComment) {
						[self socketClose];
						
						NSLog(@"commentArray count : %lu", [vposArray count]);
						NSLog(@"OK");
						
#if DEBUG
						[self.delegate stopIndicator];
#endif
					}
					else
						[self requestComments];
				}
            }
            
            
            [str release];
            [dataStream release];        
            dataStream = nil;
            break;
        }
		case NSStreamEventNone:
			NSLog(@"NSStreamEventNone");
			break;
			
        case NSStreamEventHasSpaceAvailable:{
			static BOOL alreadyReq = NO;
			
			if (alreadyReq) break;
			
			NSLog(@"NSStreamEventHasSpaceAvailable");
            
			alreadyReq = YES;
			
			if (isOpen == YES) {
				//lv175525659
				//lv176928469
				[self requestComments];
                
            }	
            
            break;
        }
        case NSStreamEventErrorOccurred:{
            NSLog(@"NSStreamEventErrorOccurred");
			
			[self requestComments];
			
            break;
        }
        case NSStreamEventEndEncountered:{
            NSLog(@"\n\n\n\nNSStreamEventEndCountered");
#if DEBUG
			[self.delegate stopIndicatorWithFail];
#endif
            break;
        }
            
    }
    
}

- (void)requestComments {
	NSString *str = [NSString stringWithFormat:@"<thread thread=\"%@\" res_from=\"-1000\" version=\"20061206\" when=\"%ld\" waybackkey=\"%@\" user_id=\"%@\" />", self.threadId, currentTime, self.waybackKey, self.userId];
	NSLog(@"comment request: %@", str);
	//NSString *str = [text stringByAppendingString:eol];
	const uint8_t *rawstring = (const uint8_t *)[str UTF8String];
	//  NSString *rawstring2 = [NSString stringWithFormat:@"%@\0", rawstring];
	[outputStream write:rawstring maxLength:strlen((char *)rawstring)];
	uint8_t *rawString2[2];
	rawString2[0] = 0;
	rawString2[1] = 0;
	[outputStream write:rawString2 maxLength:1];
	//[outputStream close];
}


-(void)dealloc{
    self.sessionId = nil;
    self.delegate = nil;
    self.keepString = nil;
    self.dataStream = nil;
    self.rtmpdumpPath = nil;
    self.TICKET = nil;
	self.waybackKey = nil;
	
	[dumpedString release];
	dumpedString = nil;
    
    [xml release];
    //[addr release];
    
    [threadId release];
    [lv release];
    
    
    
    /*
     NSString *keepString;
     NSMutableArray *vposArray;
     NSMutableArray *commentArray;
     NSMutableArray *userIdArray;
     */  
    [URL release];
    //[TICKET release];
    
    [taskWhich release];
    [pipeWhich release];
    [tasks release];
    [pipes release];
    
    
    //    NSMutableData *dataStream;
    
    
    
    [super dealloc];
}

@end
