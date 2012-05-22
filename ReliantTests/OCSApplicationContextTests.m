//
//  OCSApplicationContextTests.m
//  Reliant
//
//  Created by Michael Seghers on 16/05/12.
//  Copyright (c) 2012 Oak Consultancy Services. All rights reserved.
//

#import <OCMock/OCMock.h>

#import "OCSApplicationContextTests.h"

#import "OCSConfigurator.h"
#import "OCSApplicationContext.h"

@protocol SomeSuperProtocol <NSObject>

@property (nonatomic, retain) NSString *superProtocolProperty;

@end

@interface DummyClass : NSObject<SomeSuperProtocol> {
    @private
    NSString *publiclyKnownPrivate;
}

@property (nonatomic, retain) NSString *publiclyKnownPrivate;
@property (nonatomic, retain) NSString *publiclyKnownProperty;
@property (nonatomic, readonly) NSString *readOnlyProperty;
@property (nonatomic, assign) BOOL boolProperty;
@property (nonatomic, assign) char charProperty;
@property (nonatomic, assign) int intProperty;
@property (nonatomic, assign) float floatProperty;
@property (nonatomic, assign) double doubleProperty;
@property (nonatomic, assign) long longProperty;

@end

@interface DummyClass () 

@property (nonatomic, retain) NSString *privateProperty;
@property (nonatomic, retain) id privatePropertyWithCustomVarName;
@property (nonatomic, retain) id unknownProperty;

@end

@protocol SomeProtocol <NSObject>

@property (nonatomic, retain) NSString *prototypeProperty;

@end

@interface ExtendedDummyClass : DummyClass<SomeProtocol>

@property (nonatomic, retain) NSString *extendedProperty;

@end

@interface EmptyClass : NSObject

@end



@implementation OCSApplicationContextTests {
    //SUT
    
    OCSApplicationContext *context;
    
    id configurator;
}

- (void) setUp {
    [super setUp];
    
    // Set-up code here.
    configurator = [OCMockObject mockForProtocol:@protocol(OCSConfigurator)];
    context = [[OCSApplicationContext alloc] initWithConfigurator:configurator];
}

- (void) tearDown {
    // Tear-down code here.
    configurator = nil;
    context = nil;
    
    [super tearDown];
}

- (void) testStart {
    [[configurator expect] contextLoaded:context];
    
    BOOL result = [context start];
    STAssertTrue(result, @"Application context startup is expected to succeed");
    
    [configurator verify];
}

- (void) testObjectForKey {
    [[[configurator stub] andReturn:@"StringObject"] objectForKey:@"SomeKey" inContext:context];
    [[[configurator stub] andReturn:nil] objectForKey:@"UnknownKey" inContext:context];
    
    STAssertTrue([@"StringObject" isEqualToString:[context objectForKey:@"SomeKey"]], @"SomeKey key should return the configurator's StringObject");
    STAssertNil([context objectForKey:@"UnknownKey"], @"UnknownKey should return nil");
}

- (void) testPerformInjection {
    DummyClass *dummy = [[DummyClass alloc] init];
    
    [[[configurator expect] andReturn:@"PRKP"] objectForKey:@"publiclyKnownPrivate" inContext:context];
    [[[configurator expect] andReturn:@"PUKP"] objectForKey:@"publiclyKnownProperty" inContext:context];
    [[[configurator expect] andReturn:@"PP"] objectForKey:@"privateProperty" inContext:context];
    [[[configurator expect] andReturn:@"PPCN"] objectForKey:@"privatePropertyWithCustomVarName" inContext:context];
    [[[configurator expect] andReturn:@"SPP"] objectForKey:@"superProtocolProperty" inContext:context];
    [[[configurator expect] andReturn:nil] objectForKey:@"unknownProperty" inContext:context];
    
    
    [context performInjectionOn:dummy];
    
    STAssertTrue([@"PRKP" isEqualToString:[dummy valueForKey:@"publiclyKnownPrivate"]], @"publiclyKnownPrivate should be set to PRKP");
    STAssertTrue([@"PUKP" isEqualToString:[dummy valueForKey:@"publiclyKnownProperty"]], @"publiclyKnownProperty should be set to PUKP");
    STAssertTrue([@"PP" isEqualToString:[dummy valueForKey:@"privateProperty"]], @"privateProperty should be set to PP");
    STAssertTrue([@"PPCN" isEqualToString:[dummy valueForKey:@"privatePropertyWithCustomVarName"]], @"privatePropertyWithCustomVarName should be set to PPCN");
    STAssertTrue([@"SPP" isEqualToString:[dummy valueForKey:@"superProtocolProperty"]], @"superProrocolProperty should be set to SPP");
    STAssertNil(dummy.unknownProperty, @"unknownProperty should be nil");
    
    [configurator verify];
}

- (void) testPerformInjectionOnExtendedObject {
    ExtendedDummyClass *dummy = [[ExtendedDummyClass alloc] init];
    
    [[[configurator expect] andReturn:@"PRKP"] objectForKey:@"publiclyKnownPrivate" inContext:context];
    [[[configurator expect] andReturn:@"PUKP"] objectForKey:@"publiclyKnownProperty" inContext:context];
    [[[configurator expect] andReturn:@"PP"] objectForKey:@"privateProperty" inContext:context];
    [[[configurator expect] andReturn:@"PPCN"] objectForKey:@"privatePropertyWithCustomVarName" inContext:context];
    [[[configurator expect] andReturn:@"EP"] objectForKey:@"extendedProperty" inContext:context];
    [[[configurator expect] andReturn:@"SPP"] objectForKey:@"superProtocolProperty" inContext:context];
    [[[configurator expect] andReturn:@"PP"] objectForKey:@"prototypeProperty" inContext:context];
    [[[configurator expect] andReturn:nil] objectForKey:@"unknownProperty" inContext:context];
    
    
    [context performInjectionOn:dummy];
    
    STAssertTrue([@"PRKP" isEqualToString:[dummy valueForKey:@"publiclyKnownPrivate"]], @"publiclyKnownPrivate should be set to PRKP");
    STAssertTrue([@"PUKP" isEqualToString:[dummy valueForKey:@"publiclyKnownProperty"]], @"publiclyKnownProperty should be set to PUKP");
    STAssertTrue([@"PP" isEqualToString:[dummy valueForKey:@"privateProperty"]], @"privateProperty should be set to PP");
    STAssertTrue([@"PPCN" isEqualToString:[dummy valueForKey:@"privatePropertyWithCustomVarName"]], @"privatePropertyWithCustomVarName should be set to PPCN");
    STAssertTrue([@"EP" isEqualToString:[dummy valueForKey:@"extendedProperty"]], @"extendedProperty should be set to EP");
    STAssertTrue([@"SPP" isEqualToString:[dummy valueForKey:@"superProtocolProperty"]], @"superProrocolProperty should be set to SPP");
    STAssertTrue([@"PP" isEqualToString:[dummy valueForKey:@"prototypeProperty"]], @"prototypeProperty should be set to PP");
    STAssertNil(dummy.unknownProperty, @"unknownProperty should be nil");
    
    [configurator verify];
}

- (void) testPerformInjectionOnEmptyClass {
    //We must be able to try to inject classes that on their own have no dependencies. No actual injection should happen. The configurator should never be called.
    EmptyClass *dummy = [[EmptyClass alloc] init];
    
    [context performInjectionOn:dummy];
    
    [configurator verify];
}

@end

@implementation DummyClass

@synthesize publiclyKnownPrivate;
@synthesize publiclyKnownProperty;
@synthesize privateProperty;
@synthesize privatePropertyWithCustomVarName = _customVarName;
@synthesize unknownProperty;
@synthesize superProtocolProperty;
@synthesize intProperty, boolProperty, longProperty, charProperty, floatProperty, doubleProperty, readOnlyProperty;

@end

@implementation ExtendedDummyClass

@synthesize extendedProperty;
@synthesize prototypeProperty;

@end

@implementation EmptyClass

@end
