//
//  LoginCredentialFactoryTest.m
//  Hours
//
//  Created by Tommy Wendelborg on 11/29/12.
//  Copyright (c) 2012 steria. All rights reserved.
//

#import "LoginCredentialFactoryTest.h"
#import "RandomGeneratorFake.h"

@interface LoginCredentialFactoryTest()
@property(nonatomic, strong) RandomGeneratorFake *randomGeneratorFake;
@end

@implementation LoginCredentialFactoryTest

NSString const * expectedSalt = @"BBBBBBBB";
NSString const * password = @"pass_word";
NSString const * expectedBase64WithSalt = @"BBBBBBBB_qRxee96RxsOH8iLU5lAdtwwF1T0="; // SHA1 of "BBBBBBBB_pass_word", base64-encoded

@synthesize loginCredentialFactory = _loginCredentialFactory;
@synthesize randomGeneratorFake = _randomGeneratorFake;

- (void)setUp
{
    [super setUp];
    
    self.loginCredentialFactory = [[LoginCredentialFactory alloc] init];
    self.randomGeneratorFake = [[RandomGeneratorFake alloc] initWithFixedBaseStringAlphaAtIndex:1]; // Always returns B
    self.loginCredentialFactory.randomGenerator = self.randomGeneratorFake;
}

- (void)tearDown
{
    // Tear-down code here.
    self.loginCredentialFactory = nil;
    self.randomGeneratorFake = nil;
    [super tearDown];
}

- (void)test_saltAndHash_mustReturnSaltAsFirst8characters;
{
    NSString *hashedAndSalted = [self executeSaltAndHash];
    NSString *first8characters = [hashedAndSalted substringToIndex:8];
    
    STAssertTrue([expectedSalt isEqualToString:first8characters], @"Wrong result in salted password, first 8 characters: %@", first8characters);
}

-(void)test_saltAndHash_mustReturnHashedPassword
{
    NSString *hashedAndSalted = [self executeSaltAndHash];
    STAssertTrue([expectedBase64WithSalt isEqualToString:hashedAndSalted], @"Wrong result in encoded hashed password, result: %@", hashedAndSalted);
}

-(void)test_saltAndHash_twoHashedPasswordWithRandomSaltMustNotBeTheSame
{
    self.loginCredentialFactory.randomGenerator = nil; // Make sure the factory uses its own random generator
    NSString *hashedAndSalted1 = [self executeSaltAndHash];
    NSString *hashedAndSalted2 = [self executeSaltAndHash];
    
    STAssertFalse([hashedAndSalted1 isEqualToString:hashedAndSalted2], @"Generated hashes are equal: %@", hashedAndSalted1);
}

- (NSString *)executeSaltAndHash
{
    return [self.loginCredentialFactory saltAndHash:password.copy];
}

@end
