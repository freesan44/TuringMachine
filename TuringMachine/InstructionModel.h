//
//  instructionModel.h
//  TuringMachine
//
//  Created by 曾思健 on 2020/8/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InstructionModel : NSObject
typedef NS_ENUM(NSInteger,instructionModelType){
    instructionModelTypeMoveLeft,
    instructionModelTypeMoveRight,
    instructionModelTypeMoveHold
};

@property(nonatomic,copy)NSString* readState;
@property(nonatomic,copy)NSString* readValue;
@property(nonatomic,copy)NSString* writeState;
@property(nonatomic,copy)NSString* writeValue;
@property(nonatomic,assign)instructionModelType moveType;
@property(nonatomic,copy)NSString* moveStr;
@end

NS_ASSUME_NONNULL_END
