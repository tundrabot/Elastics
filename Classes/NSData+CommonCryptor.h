//
//  NSData+CommonCryptor.h
//
//  Created by Dmitri Goutnik on 6/28/08.
//  Copyright 2008 Dmitri Goutnik. All rights reserved.
//

//
// NSData with AES128 encryption/decryption support
//
@interface NSData (CommonCryptorAdditions)

+ (id)dataWithEncryptedFile:(NSString *)path key:(NSData *)key;
+ (id)dataWithEncryptedData:(NSData *)data key:(NSData *)key;

- (id)initWithEncryptedFile:(NSString *)path key:(NSData *)key;
- (BOOL)writeToEncryptedFile:(NSString *)path key:(NSData *)key atomically:(BOOL)flag;

- (id)initWithEncryptedData:(NSData *)data key:(NSData *)key;
- (NSData *)encryptWithKey:(NSData *)key;

@end
