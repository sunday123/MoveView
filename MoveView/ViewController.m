//
//  ViewController.m
//  MoveView
//
//  Created by wei on 2020/6/5.
//  Copyright © 2020 cofortune. All rights reserved.
//

#import "ViewController.h"
#define screenH ([[UIScreen mainScreen] bounds].size.height) //屏幕高度  ,-124 滚动
#define screenW ([[UIScreen mainScreen] bounds].size.width) //屏幕宽度

#define PIC_WIDTH screenW*0.41  //按钮宽
#define PIC_HEIGHT screenW*0.27 //按钮高
#define PicX1 PIC_WIDTH*0.146
#define PicX2 PIC_WIDTH*1.293
#define mutil 1.3 //Y轴系数
#define HEIGHT_INCREMENT 30
#define COL_COUNT 2 //按钮一行的数目
#define angelToRandian(x) ((x)/180.0*M_PI) //抖动







@interface ViewController (){
    CGPoint startPoint;
    Boolean isMoveing;
    NSString *moveStr;
}

@end

@implementation ViewController



- (void)viewDidLoad {
    isMoveing=false;
    [super viewDidLoad];
    for (UIView *v in self.view.subviews) {
        [v removeFromSuperview];
    }
    
    
        for( int i =0;i<5;i++ ){

            
            
            NSInteger row = i / COL_COUNT+1;
            NSInteger col = i % COL_COUNT;
            CGFloat picY =  PIC_HEIGHT*mutil*(row-1)+ HEIGHT_INCREMENT;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame =  CGRectMake(col==0?PicX1:PicX2, picY,PIC_WIDTH, PIC_HEIGHT);
            btn.backgroundColor =[UIColor colorWithWhite:0.1 alpha:0.5];

            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitle:[@"A" stringByAppendingFormat:@"%d",i]  forState:UIControlStateNormal];


            [btn setTag:i+1];
            [btn.layer setCornerRadius:20];


            UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(doMoveAction:)];
            [btn addGestureRecognizer:panGestureRecognizer];
            [btn addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn removeGestureRecognizer:panGestureRecognizer];
            [self.view addSubview:btn];
             
        }

    
    

}
-(void)addClick:(UIButton *)sender{
    NSLog(@"点击了:%@",sender.titleLabel.text);
}
#pragma mark - 移动拖拽按钮事件
-(void)doMoveAction:(UIPanGestureRecognizer *)recognizer{
    UIButton *btn =(id)recognizer.view;
    if (isMoveing && btn.titleLabel.text !=moveStr) {
        return;
    }
    
    // Figure out where the user is trying to drag the view.
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint newCenter = CGPointMake(recognizer.view.center.x+ translation.x,
                                    recognizer.view.center.y + translation.y);
//    限制屏幕范围：
    newCenter.y = MAX(recognizer.view.frame.size.height/2, newCenter.y);
    newCenter.y = MIN(self.view.frame.size.height - recognizer.view.frame.size.height/2, newCenter.y);
    newCenter.x = MAX(recognizer.view.frame.size.width/2, newCenter.x);
    newCenter.x = MIN(self.view.frame.size.width - recognizer.view.frame.size.width/2,newCenter.x);
    recognizer.view.center = newCenter;
    
//    NSLog(@"坐标newCenter x:%f y:%f",newCenter.x,newCenter.y);
    
    if(recognizer.state==UIGestureRecognizerStateBegan){
//       NSLog(@"开始时坐标x:%f y:%f",newCenter.x,newCenter.y);
        moveStr=btn.titleLabel.text;
        isMoveing=true;
        startPoint = newCenter;
    }else if(recognizer.state==UIGestureRecognizerStateEnded){
        isMoveing=false;
        moveStr=NULL;
//       NSLog(@"结束时坐标x:%f y:%f",newCenter.x,newCenter.y);
        Boolean change=false;
        CGFloat ex =newCenter.x,ey=newCenter.y;
            NSArray<UIView *> *arrays = self.view.subviews;
        NSLog(@"总数:%lu",(unsigned long)arrays.count);
            for( int i =0; i<arrays.count;i++ ){
                NSInteger row = i / COL_COUNT+1;
                NSInteger col = i % COL_COUNT;
                CGFloat picY =  PIC_HEIGHT*mutil*(row-1)+ HEIGHT_INCREMENT;
                CGFloat picX=(col==0)?PicX1:PicX2;
//                 NSLog(@"%d|x:%f y:%f",i,picX,picY);
                if(ey >picY && ey<(picY+PIC_HEIGHT) &&ex>picX && ex<(picX+PIC_WIDTH)){ //执行
                    ex = PIC_WIDTH*0.5+picX;
                    ey = PIC_HEIGHT*0.5+picY;
                    
                    NSLog(@"后x:%f y:%f",ex,ey);
                    NSLog(@"前x:%f y:%f",startPoint.x,startPoint.y);
                    NSLog(@"差x:%f y:%f",ex-startPoint.x,ey-startPoint.y);
                    change =true;
                    //移动前的View
                    Boolean preMove =true;
                    //判断前后移动四种情况
                    //(ex<startPoint.x && ey<startPoint.y)||(ex>startPoint.x && ey<startPoint.y) ||(ex==startPoint.x && ey<startPoint.y)|| (ey==startPoint.y && ex <startPoint.x)
                    //偏差5都认为相等
                    CGFloat diff =10;
                    if ((startPoint.x-ex>diff && startPoint.y-ey>diff)||(ex>(startPoint.x+diff) && (ey+diff)<startPoint.y) ||(fabs(ex-startPoint.x)<=diff && (ey+diff)<startPoint.y)|| (fabs(ey-startPoint.y)<=diff && (ex+diff) <startPoint.x) ) {
//                        NSLog(@"前移");
                        preMove=true;
                    }else{
//                        NSLog(@"后移");
                        preMove=false;
                    }
                    NSLog(@"  %d  | %ld ",i+1,(long)recognizer.view.tag);
                    long tag =preMove? i+1 : recognizer.view.tag ;
                    long tag2= tag ;
                    [recognizer.view setTag:-1];
                    for(int j=0;j<arrays.count;j++){
                         UIView *v = arrays[j];
                        if(v.tag >=tag){
                            if (preMove) {
                                [v setTag:(++tag2)];
                            }else{
                                
                                if (tag2==(i+1)) {
//                                    NSLog(@"后");
                                    tag2++;
                                }
                               [v setTag:tag2];
                               tag2++;
                            }
                            long cTag =v.tag-1;
                            NSInteger row2 = cTag / COL_COUNT+1;
                            NSInteger col2 = cTag % COL_COUNT;
                            CGRect rect =v.frame;
                            rect.origin.x = (col2==0)?PicX1:PicX2;
                            rect.origin.y= PIC_HEIGHT*mutil*(row2-1)+ HEIGHT_INCREMENT;
                            [v setFrame:rect];
                        }
                    }
                    
                    [recognizer.view setTag:i+1];
                    CGPoint newPoint = CGPointMake(PIC_WIDTH*0.5+picX,PIC_HEIGHT*0.5+picY);
                    recognizer.view.center =newPoint;
                    break;//退出for
                }
        }
        if(change ==false){
            NSLog(@"false");
             recognizer.view.center= startPoint;
         }
    }
    [recognizer setTranslation:CGPointZero inView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
