//
//  ApiManager.m
//  ApiTest
//
//  Created by ios on 10/23/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import "ApiManager.h"

NSString *SERVER_API_BASE_URL = @"http://localhost:5000";

@interface ApiManager ()

@property (readonly, strong, nonatomic) NSString *serverBase;
@property (strong, nonatomic) NSString *authToken;

@end

@implementation ApiManager

+(instancetype)getInstance {
    // the 'static' keyword causes this line to only be executed once, ever.
    static ApiManager *instance = nil;
    
    // what is this doing?
    if (!instance) {
        NSLog(@"initializing ApiManager");
        instance = [[ApiManager alloc] initWithServerBase:SERVER_API_BASE_URL];
    }
    
    return instance;
}

- (instancetype)initWithServerBase:(NSString *)serverBase {
    self = [self init];

    _serverBase = serverBase;
    
    return self;
}

/**
 * This is a convenience method that takes a url fragment like '/path/to/something'
 * and it makes an absolute url like 'http://myapi.com/path/to/something'
 * you can also add substitution values like this:
 * [self url:@"/my/path?auth%@", self.authToken], which produces 'http://myapi.com/my/path?auth=ABC123'
 */
- (NSString *)url:(NSString *)pathFormat, ... NS_FORMAT_FUNCTION(1, 2) {

    va_list args;
    va_start(args, pathFormat);
    pathFormat = [[NSString alloc] initWithFormat:pathFormat arguments:args];
    va_end(args);
    
    return [NSString stringWithFormat:@"%@%@", self.serverBase, pathFormat];
}

#pragma mark CHALLENGE #1 - let's do this together with a projector
- (void)registerNewUsername:(NSString *)username withPassword:(NSString *)password completion:(void (^)(NSString *))completion failure:(void (^)(void))failure
    {
   // start talking to the server
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
   // make a request object - NSMutableURLRequest
    NSURL *url = [NSURL URLWithString:@"http://104.236.231.254:5000/user"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // populate the request with the information from documentation
    request.HTTPMethod = @"POST";
    
    // set header OR body for request
    NSMutableDictionary *userDataDictionary = [[NSMutableDictionary alloc]init];
    [userDataDictionary setObject:username forKey:@"username"];
    [userDataDictionary setObject:password forKey:@"password"];
    
    //create a pointer that points to the error class
    NSError *error;
        
    //final packing of the basket inside the house
    NSData *dataToPass = [NSJSONSerialization dataWithJSONObject:userDataDictionary options:0 error:&error];

    //put the basket into the car
    request.HTTPBody = dataToPass;
    
    // tell server what type of information to expect; talk to me in this language and say it explicitly in the content type
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //actually pass the info to the server?; everything is ready, but we havn't left yet; dataTaskWithRequest actually sends to the server;
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"There was an error with response %ld", (long) ((NSHTTPURLResponse *) response).statusCode);
        }
        else
        {
            NSLog(@"Success with response %ld", (long) ((NSHTTPURLResponse *) response).statusCode);
            if (((NSHTTPURLResponse *)response).statusCode == 200) {
                //the auth token appears somehow in data
                NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //get NSString with auth token from NSData
                completion(authToken);
            }
            else
            {
                failure();
            }
        }
    }];
    
    [dataTask resume];
    
    //what needs to happen next?
}

#pragma mark CHALLENGE #2 - with a partner
- (void)authenticateUser:(NSString *)username withPassword:(NSString *)password completion:(void (^)(NSString *))completion failure:(void (^)(void))failure {
    // start talking to the server
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    // make a request object - NSMutableURLRequest
    NSString *urlString = [NSString stringWithFormat:@"http://104.236.231.254:5000/auth?username=%@&password=%@",username, password];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // populate the request with the information from documentation
    request.HTTPMethod = @"POST";
    
    // tell server what type of information to expect; talk to me in this language and say it explicitly in the content type
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //actually pass the info to the server?; everything is ready, but we havn't left yet; dataTaskWithRequest actually sends to the server;
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"There was an error with response %ld", (long) ((NSHTTPURLResponse *) response).statusCode);
        }
        else
        {
            NSLog(@"Success with response %ld", (long) ((NSHTTPURLResponse *) response).statusCode);
            if (((NSHTTPURLResponse *)response).statusCode == 200) {
                //the auth token appears somehow in data
                NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //get NSString with auth token from NSData
                completion(authToken);
                [self setAuthToken: authToken];
            }
            else
            {
                failure();
            }
        }
    }];
    
    [dataTask resume];
    
    //what needs to happen next?
}

#pragma mark CHALLENGE #3 - with a partner or on your own
- (void)fetchAllUserDataWithCompletion:(void (^)(NSArray<User *> *))completion failure:(void (^)(void))failure {
    // start talking to the server
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    // make a request object - NSMutableURLRequest
    NSString *urlString = [NSString stringWithFormat:@"http://104.236.231.254:5000/user?auth=%@", self.authToken];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // populate the request with the information from documentation
    request.HTTPMethod = @"GET";
    
    //actually pass the info to the server?; everything is ready, but we havn't left yet; dataTaskWithRequest actually sends to the server;
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"There was an error with response %ld", (long) ((NSHTTPURLResponse *) response).statusCode);
        }
        else
        {
            NSLog(@"Success with response %ld", (long) ((NSHTTPURLResponse *) response).statusCode);
            if (((NSHTTPURLResponse *)response).statusCode == 200) {
                NSArray *arrayOfUsers = [User usersFromData:data];
                completion(arrayOfUsers);
            }
            else
            {
                failure();
            }
        }
    }];
    
    [dataTask resume];
}

#pragma mark CHALLENGE #4 - with a partner or on your own
-(void)saveDevice:(Device *)device forUser:(User *)user completion:(void (^)(void))completion failure:(void (^)(void))failure {

}

-(BOOL)isAuthenticated {
    return self.authToken;
}

/**
 * BONUS CHALLENGES...
 *
 * Below here you'll find methods that will flesh out this API Manager
 * even more. Pick and choose which you're interested in and ask for help...
 * Heads up! These have actually not been implemented as any prep for this
 * exercise, so you're probably the first one doing these!
 */

-(void)logout {
    NSLog(@"Hi! Does anybody want to implement ApiManager.logout ;)");
    
    // what should this method do?
    
    // How do we DELETE an auth token from the API?
    
    // What if ApiManager simply 'forgets' its auth token?
    
    // What do you think this method should really do?
    
    self.authToken = nil;
    
}

@end
