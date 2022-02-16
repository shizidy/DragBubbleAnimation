//
//  ViewController.m
//  DragBubbleAnimation
//
//  Created by wdyzmx on 2022/2/16.
//

#import "ViewController.h"
#define KScreenWidth UIScreen.mainScreen.bounds.size.width
#define KScreenHeight UIScreen.mainScreen.bounds.size.height

@interface ViewController ()
/// 固定的小圆
@property (nonatomic, strong) UIView *view1;
/// 拖动的圆
@property (nonatomic, strong) UIView *view2;
/// layer
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
/// 保存view1初始的center
@property (nonatomic, assign) CGPoint oldViewCenter;
/// 保存view1初始的frame
@property (nonatomic, assign) CGRect oldViewFrame;
/// view1圆半径
@property (nonatomic, assign) CGFloat r1;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    // Do any additional setup after loading the view.
}

- (void)setUI {
    self.view1 = [[UIView alloc] initWithFrame:CGRectMake(KScreenWidth / 2 - 20, 100, 40, 40)];
    [self.view addSubview:self.view1];
    self.view1.backgroundColor = UIColor.blueColor;
    self.view1.layer.cornerRadius = 20;
    
    self.view2 = [[UIView alloc] initWithFrame:self.view1.frame];
    [self.view addSubview:self.view2];
    self.view2.backgroundColor = UIColor.orangeColor;
    self.view2.layer.cornerRadius = 20;
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:self.view2.bounds];
    [self.view2 addSubview:numberLabel];
    numberLabel.text = @"66";
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.textColor = UIColor.whiteColor;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.view2 addGestureRecognizer:panGesture];
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillColor = UIColor.redColor.CGColor;
    
    self.oldViewFrame = self.view1.frame;
    self.oldViewCenter = self.view1.center;
    self.r1 = CGRectGetWidth(self.view1.frame) / 2;
}

#pragma mark - 拖动手势
- (void)panAction:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateChanged) {
        self.view2.center = [pan locationInView:self.view];
        if (self.r1 < 1) {
            self.view1.hidden = YES;
            [self.shapeLayer removeFromSuperlayer];
        } else {
            [self calculatePoint];
        }
    } else if (pan.state == UIGestureRecognizerStateFailed || pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        [self.shapeLayer removeFromSuperlayer];
        [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.3 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view2.center = self.oldViewCenter;
        } completion:^(BOOL finished) {
            self.view1.hidden = NO;
            self.r1 = self.oldViewFrame.size.width / 2;
            self.view1.frame = self.oldViewFrame;
            self.view1.layer.cornerRadius = self.r1;
        }];
    }
}

#pragma mark - 计算贝塞尔图形
- (void)calculatePoint {
    // 计算出两个中心点
    CGPoint center1 = self.view1.center;
    CGPoint center2 = self.view2.center;
    // 计算2个中心点的距离
    CGFloat dis = sqrtf((center1.x - center2.x) * (center1.x - center2.x) + (center1.y - center2.y) * (center1.y - center2.y));
    // 计算正弦余弦
    CGFloat sin = (center2.x - center1.x) / dis;
    CGFloat cos = (center1.y - center2.y) / dis;
    // 计算半径
    CGFloat r1 = CGRectGetWidth(self.oldViewFrame) / 2 - dis / 20;
    CGFloat r2 = CGRectGetWidth(self.view2.bounds) / 2;
    self.r1 = r1;
    // 计算6个关键点
    CGPoint pA = CGPointMake(center1.x - cos * r1, center1.y - sin * r1);
    CGPoint pB = CGPointMake(center1.x + cos * r1, center1.y + sin * r1);
    CGPoint pD = CGPointMake(center2.x - cos * r2, center2.y - sin * r2);
    CGPoint pC = CGPointMake(center2.x + cos * r2, center2.y + sin * r2);
    CGPoint pP = CGPointMake(pB.x + dis / 2 * sin, pB.y - dis / 2 * cos);
    CGPoint pO = CGPointMake(pA.x + dis / 2 * sin, pA.y - dis / 2 * cos);
    // 画贝塞尔曲线
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:pA];
    [bezierPath addQuadCurveToPoint:pD controlPoint:pO];
    [bezierPath addLineToPoint:pC];
    [bezierPath addQuadCurveToPoint:pB controlPoint:pP];
    [bezierPath closePath];
    // 添加到bezierPath,shapeLayer
    self.shapeLayer.path = bezierPath.CGPath;
    [self.view.layer insertSublayer:self.shapeLayer below:self.view1.layer];
    //重设view的大小
    self.view1.center = self.oldViewCenter;
    self.view1.bounds = CGRectMake(0, 0, self.r1 * 2, self.r1 * 2);
    self.view1.layer.cornerRadius = self.r1;
}

@end
