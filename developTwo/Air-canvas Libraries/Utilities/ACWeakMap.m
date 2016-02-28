#import "ACWeakMap.h"

#import "ACWeakReference.h"

#define Record ACWeakMap_Record

#pragma mark -

@interface ACWeakMap() {
	NSMutableArray* _records;
}

@end

#pragma mark -

@interface Record : NSObject

- (id)initWithKey: (id)key andValue: (id)value;

@property(nonatomic, weak) id key;
@property(nonatomic, strong) id value;

@end

#pragma mark -

@implementation ACWeakMap

- (id)init {
	self = [super init];
	if(self != nil) {
		_records = [NSMutableArray new];
	}
	
	return self;
}

- (void)setObject: (id)value forKey: (id)key {
	if(key == nil) {
		return;
	}
	
	// Check if there is a matching key.
	for(NSInteger i = [_records count] - 1; i >= 0; i--) {
		Record* record = [_records objectAtIndex: i];
		id recordKey = [record key];
		
		if(recordKey == key) {
			if(value != nil) {
				[record setValue: value];
			}
			else {
				[_records removeObjectAtIndex: i];
			}
			
			return;
		}
		
		if(recordKey == nil) {
			[_records removeObjectAtIndex: i];
		}
	}
	
	// Add a new key-value pair if there is no matching key.
	if(value != nil) {
		Record* record = [[Record alloc] initWithKey: key andValue: value];
		[_records addObject: record];
	}
}

- (id)objectForKey: (id)key {
	for(NSInteger i = [_records count] - 1; i >= 0; i--) {
		Record* record = [_records objectAtIndex: i];
		id recordKey = [record key];
		
		if(recordKey == key) {
			return [record value];
		}
		
		if(recordKey == nil) {
			[_records removeObjectAtIndex: i];
		}
	}
	
	return nil;
}

- (NSArray*)allKeys {
	NSMutableArray* keys = [NSMutableArray new];
	for(NSInteger i = [_records count] - 1; i >= 0; i--) {
		Record* record = [_records objectAtIndex: i];
		id key = [record key];
		
		if(key != nil) {
			[keys addObject: key];
		}
		else {
			[_records removeObjectAtIndex: i];
		}
	}
	
	for(NSInteger i = 0, j = [keys count] - 1; i < j; i++, j--) {
		Record* record0 = [_records objectAtIndex: i];
		Record* record1 = [_records objectAtIndex: j];
		[_records replaceObjectAtIndex: i withObject: record1];
		[_records replaceObjectAtIndex: j withObject: record0];
	}
	
	return keys;
}

- (BOOL)containsKey: (id)key {
	for(NSInteger i = [_records count] - 1; i >= 0; i--) {
		Record* record = [_records objectAtIndex: i];
		id recordKey = [record key];
		
		if(recordKey == key) {
			return TRUE;
		}
		
		if(recordKey == nil) {
			[_records removeObjectAtIndex: i];
		}
	}
	
	return FALSE;
}

- (NSArray*)allKeysForObject: (id)value {
	NSMutableArray* keys = [NSMutableArray new];
	for(NSInteger i = [_records count] - 1; i >= 0; i--) {
		Record* record = [_records objectAtIndex: i];
		id recordKey = [record key];
		
		if(recordKey != nil) {
			if([record value] == value) {
				[keys addObject: recordKey];
			}
		}
		else {
			[_records removeObjectAtIndex: i];
		}
	}
	
	for(NSInteger i = 0, j = [keys count] - 1; i < j; i++, j--) {
		Record* record0 = [_records objectAtIndex: i];
		Record* record1 = [_records objectAtIndex: j];
		[_records replaceObjectAtIndex: i withObject: record1];
		[_records replaceObjectAtIndex: j withObject: record0];
	}
	
	return keys;
}

- (void)removeAllObjects {
	[_records removeAllObjects];
}

- (void)removeObjectForKey: (id)key {
	for(NSInteger i = [_records count] - 1; i >= 0; i--) {
		Record* record = [_records objectAtIndex: i];
		id recordKey = [record key];
		
		if(recordKey == nil || recordKey == key) {
			[_records removeObjectAtIndex: i];
		}
	}
}

- (void)removeObjectForKeys: (NSArray*)keys {
	for(NSInteger i = [_records count] - 1; i >= 0; i--) {
		Record* record = [_records objectAtIndex: i];
		id recordKey = [record key];
		
		if(recordKey == nil || [keys containsObject: recordKey]) {
			[_records removeObjectAtIndex: i];
		}
	}
}

- (void)setValue: (id)value forKey: (NSString*)key {
	[self setObject: value forKey: key];
}

- (id)valueForKey: (NSString*)key {
	return [self objectForKey: key];
}

@end

#pragma mark -

@interface Record() {
	ACWeakReference* _keyReference;
	id _value;
}

@end

#pragma mark -

@implementation Record

- (id)initWithKey: (id)key andValue: (id)value {
	self = [super init];
	if(self != nil) {
		[self setKey: key];
		[self setValue: value];
	}
	
	return self;
}

- (id)key {
	return [_keyReference object];
}

- (void)setKey: (id)key {
	_keyReference = [ACWeakReference weakReferenceForObject: key];
}

- (id)value {
	return _value;
}

- (void)setValue: (id)value {
	_value = value;
}

@end