//
//  ViewController.m
//  TuringMachine
//
//  Created by 曾思健 on 2020/8/13.
//

#import "HomeViewController.h"
#import <QMUIKit.h>
#import <SDAutoLayout.h>
#import "InstructionModel.h"

@interface HomeViewController ()
@property(nonatomic, strong) UISegmentedControl *segmentedView;
@property(nonatomic,strong)QMUILabel * curMoveLab;
@property(nonatomic,strong)QMUILabel * curStateLab;
@property(nonatomic,strong)UISwitch * observeSwith;
@property(nonatomic,strong)QMUILabel * curOrderLab;
@property(nonatomic,strong)QMUIButton * nextStepBtn;
@property(nonatomic,strong)QMUIButton * playBtn;

@property(nonatomic,strong)NSTimer * timer;
@property(nonatomic,copy)NSString * beginBit;
@property(nonatomic,strong)NSMutableArray* bitArr;
@property(nonatomic,copy)NSString* curState;
@property(nonatomic,copy)NSArray* instructionStrArr;
@property(nonatomic,strong)NSMutableArray * instructionModelArr;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self instructionInit];
    [self prepartUI];
}
//TODO:指令集初始化
- (void)instructionInit
{
    //最初字符
    self.beginBit = @"111101110";
    //最初状态
    self.curState = @"q1";
    //命令集 参数顺序：读取状态,读取数值,写入状态,写入数值,移动指令(L|R|S)  用【,】隔开
    self.instructionStrArr = @[
        @"q1,1,q1,1,R",
        @"q1,0,q2,1,R",
        @"q2,1,q2,1,R",
        @"q2,0,q3,0,L",
        @"q3,1,q3,0,S",
        @"q3,0,q3,0,S",
    ];
    [self bindModel];
}
- (void)bindModel
{
    NSMutableArray * instructionModelArr = [NSMutableArray new];
    self.instructionModelArr = instructionModelArr;
    for (NSString * each in self.instructionStrArr) {
        NSArray * eachArr = [each componentsSeparatedByString:@","];
        InstructionModel * model = [InstructionModel new];
        model.readState = eachArr[0];
        model.readValue = eachArr[1];
        model.writeState = eachArr[2];
        model.writeValue = eachArr[3];
        model.moveStr = eachArr[4];
        if ([eachArr[4] isEqualToString:@"L"]) {
            model.moveType = instructionModelTypeMoveLeft;
        }
        else if ([eachArr[4] isEqualToString:@"R"])
        {
            model.moveType = instructionModelTypeMoveRight;
        }
        else{
            model.moveType = instructionModelTypeMoveHold;
        }
        [instructionModelArr addObject:model];
    }
}
- (void)prepartUI
{
    self.title = @"图灵机";
    self.view.backgroundColor = QMUICMI.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (!self.segmentedView) {
        NSMutableArray * items = [NSMutableArray new];
        [self.beginBit enumerateSubstringsInRange:NSMakeRange(0, self.beginBit.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            [items addObject:substring];
        }];
        self.bitArr = items;
        self.segmentedView = [[UISegmentedControl alloc] initWithItems:items];
        self.segmentedView.userInteractionEnabled = NO;
        self.segmentedView.apportionsSegmentWidthsByContent = YES;
        self.segmentedView.backgroundColor = UIColorMake(49, 189, 243);
        UIColor *tintColor = QMUICMI.whiteColor;
        if (@available(iOS 13.0, *)) {
            self.segmentedView.selectedSegmentTintColor = tintColor;
        } else {
            self.segmentedView.tintColor = tintColor;
        }
        [self.segmentedView setTitleTextAttributes:@{NSForegroundColorAttributeName: QMUICMI.whiteColor} forState:UIControlStateNormal];
        [self.segmentedView setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorMake(49, 189, 243)} forState:UIControlStateSelected];
    }
    [self.view addSubview:self.segmentedView];
    self.segmentedView.sd_layout
    .centerXEqualToView(self.view)
    .heightIs(30.0f)
    .topEqualToView(self.view).offset(25.0f);
    [self.segmentedView setSelectedSegmentIndex:0];
    
    QMUILabel * observeTitle = [[QMUILabel alloc]init];
    observeTitle.text = @"Observe execution:";
    [self.view addSubview:observeTitle];
    observeTitle.sd_layout
    .leftEqualToView(self.view).offset(20.0f)
    .widthRatioToView(self.view, 0.5)
    .autoHeightRatio(0)
    .topSpaceToView(self.segmentedView, 20.0f);

    QMUILabel * curMoveTitle = [[QMUILabel alloc]init];
    curMoveTitle.text = @"Current Move:";
    [self.view addSubview:curMoveTitle];
    curMoveTitle.sd_layout
    .leftEqualToView(observeTitle)
    .widthRatioToView(observeTitle, 1)
    .autoHeightRatio(0)
    .topSpaceToView(observeTitle, 15.0f);

    QMUILabel * curStateTitle = [[QMUILabel alloc]init];
    curStateTitle.text = @"Current State:";
    [self.view addSubview:curStateTitle];
    curStateTitle.sd_layout
    .leftEqualToView(curMoveTitle)
    .widthRatioToView(curMoveTitle, 1.0)
    .autoHeightRatio(0)
    .topSpaceToView(curMoveTitle, 15.0f);

    QMUILabel * curInstructionTitle = [[QMUILabel alloc]init];
    curInstructionTitle.text = @"Current instruction:";
    [self.view addSubview:curInstructionTitle];
    curInstructionTitle.sd_layout
    .leftEqualToView(curInstructionTitle)
    .widthRatioToView(curInstructionTitle, 1.0)
    .autoHeightRatio(0)
    .topSpaceToView(curStateTitle, 15.0f);

    QMUILabel * curMoveLab = [[QMUILabel alloc]init];
    self.curMoveLab = curMoveLab;
    curMoveLab.text = @"move right";
    curMoveLab.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:curMoveLab];
    curMoveLab.sd_layout
    .rightEqualToView(self.view).offset(-20.0f)
    .widthRatioToView(self.view,0.4)
    .autoHeightRatio(0)
    .centerYEqualToView(curMoveTitle);

    QMUILabel * curStateLab = [[QMUILabel alloc]init];
    self.curStateLab = curStateLab;
    curStateLab.text = @"Q1";
    curStateLab.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:curStateLab];
    curStateLab.sd_layout
    .rightEqualToView(curMoveLab)
    .widthRatioToView(curMoveLab,1)
    .autoHeightRatio(0)
    .centerYEqualToView(curStateTitle);
    
    UISwitch * observeSwith = [UISwitch new];
    [self.view addSubview:observeSwith];
    observeSwith.onTintColor = QMUICMI.buttonTintColor;
    self.observeSwith = observeSwith;
    observeSwith.sd_layout
    .rightEqualToView(curMoveLab)
    .centerYEqualToView(observeTitle);
    
    QMUILabel * curOrderLab = [[QMUILabel alloc]init];
    self.curOrderLab = curOrderLab;
    curOrderLab.font = [UIFont systemFontOfSize:17.0f weight:1];
//    curOrderLab.text = @"";
    curOrderLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:curOrderLab];
    curOrderLab.sd_layout
    .widthRatioToView(self.view,1)
    .centerXEqualToView(self.view)
    .autoHeightRatio(0)
    .topSpaceToView(curStateTitle, 20.0f);
    
    QMUIButton * nextStepBtn = [QMUIButton buttonWithType:UIButtonTypeSystem];
    self.nextStepBtn = nextStepBtn;
    [nextStepBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextStepBtn addTarget:self action:@selector(nextStepBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextStepBtn.titleLabel.font = UIFontBoldMake(16);
    [nextStepBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
    nextStepBtn.backgroundColor = QMUICMI.buttonTintColor;
    nextStepBtn.highlightedBackgroundColor = [QMUICMI.buttonTintColor qmui_transitionToColor:UIColorBlack progress:.15];// 高亮时的背景色
    nextStepBtn.layer.cornerRadius = 4;
    [self.view addSubview:nextStepBtn];
    nextStepBtn.sd_layout
    .leftEqualToView(curStateTitle)
    .topSpaceToView(curOrderLab, 20.0f)
    .rightEqualToView(self.view).offset(-(self.view.width_sd*0.5+5.0f))
    .heightIs(45.0f);
    
    QMUIButton * playBtn = [QMUIButton buttonWithType:UIButtonTypeSystem];
    self.playBtn = playBtn;
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    playBtn.titleLabel.font = UIFontBoldMake(16);
    [playBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
    playBtn.backgroundColor = QMUICMI.buttonTintColor;
    playBtn.highlightedBackgroundColor = [QMUICMI.buttonTintColor qmui_transitionToColor:UIColorBlack progress:.15];// 高亮时的背景色
    playBtn.layer.cornerRadius = 4;
    [self.view addSubview:playBtn];
    playBtn.sd_layout
    .rightEqualToView(curMoveLab)
    .leftSpaceToView(nextStepBtn, 10.0f)
    .heightRatioToView(nextStepBtn, 1.0)
    .centerYEqualToView(nextStepBtn);
    
}
#pragma mark- UIAction
-(void)nextStepBtnClick:(QMUIButton*)sender
{
    [self nextStep];
}
-(void)playBtnClick:(QMUIButton*)sender
{
    if (!self.timer) {
//        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(nextStep) userInfo:nil repeats:YES];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self nextStep];
        }];
        [self.playBtn setTitle:@"停止" forState:UIControlStateNormal];
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
        [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    }
}

-(void)nextStep
{
    //读取目前状态
    NSString * readValue = [self.segmentedView titleForSegmentAtIndex:self.segmentedView.selectedSegmentIndex];
    __block BOOL searchSuccess = NO;
    [self.instructionModelArr enumerateObjectsUsingBlock:^(InstructionModel*  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.readValue isEqualToString:readValue] && [model.readState isEqualToString:self.curState]) {
            [self moveSegmentWtihModel:model];
            searchSuccess = YES;
            * stop = YES;
        }
    }];
    if (searchSuccess == NO) {
        //展示没法下一步错误信息
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
            [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
        }
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"信息" message:@"无法找到下一个适配指令" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:action1];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}
-(void)moveSegmentWtihModel:(InstructionModel*)model
{
//    NSLog(@"moveSegmentWtihModel:%@",model);
    [self.segmentedView setTitle:model.writeValue forSegmentAtIndex:self.segmentedView.selectedSegmentIndex];
    self.curState = model.writeState;
    self.curStateLab.text = self.curState;
    if (self.observeSwith.isOn == YES) {
        NSString * orderStr = [NSString stringWithFormat:@"%@ %@ -> %@ %@ %@",model.readState,model.readValue,model.writeState,model.writeValue,model.moveStr];
        self.curOrderLab.text = orderStr;
    }
    switch (model.moveType) {
        case instructionModelTypeMoveLeft:
            self.curMoveLab.text = @"move left";
            [self moveLeftSegment];
            break;
        case instructionModelTypeMoveRight:
            self.curMoveLab.text = @"move right";
            [self movieRightSegment];
            break;
        default:
            break;
    }
}
-(void)moveLeftSegment
{
    //超出限界处理情况
    if (self.segmentedView.selectedSegmentIndex == 0) {
        [self.segmentedView insertSegmentWithTitle:@" " atIndex:0 animated:YES];
        [self.segmentedView setSelectedSegmentIndex:0];
        return;
    }
    [self.segmentedView setSelectedSegmentIndex:self.segmentedView.selectedSegmentIndex-1];
}
-(void)movieRightSegment
{
    //超出限界处理情况
    if (self.segmentedView.selectedSegmentIndex == self.segmentedView.numberOfSegments) {
        [self.segmentedView insertSegmentWithTitle:@" " atIndex:self.segmentedView.numberOfSegments animated:YES];
        [self.segmentedView setSelectedSegmentIndex:self.segmentedView.numberOfSegments];
        return;
    }
    [self.segmentedView setSelectedSegmentIndex:self.segmentedView.selectedSegmentIndex+1];
}
-(void)startMoveSegment
{
    
}

@end
