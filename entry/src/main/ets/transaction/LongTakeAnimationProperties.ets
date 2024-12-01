/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { ComponentAttrUtils, RectInfoInPx } from './ComponentAttrUtils';
import { CardUtil } from './CardUtil';
import { WindowUtils } from './WindowUtils';
import { CustomTransition } from './CustomNavigationUtils';
import { logger } from 'common';

// Encapsulate the custom mirror transition animation, so that if other interfaces also need to customize a mirror transition, they can be reused directly and reduce the workload.
@Observed
export class LongTakeAnimationProperties {
  public navDestinationBgColor: ResourceColor = Color.Transparent;
  public snapShotOpacity: number = 1;
  public postPageOpacity: number = 0;
  public translateX: number = 0;
  public translateY: number = 0;
  public scaleValue: number = 1;
  public clipWidth: Dimension = '100%';
  public clipHeight: Dimension = '100%';
  public radius: number = 16;
  public positionXValue: number = 0;
  public positionYValue: number = 0;
  public snapShotSize: SizeOptions = { width: '100%', height: '100%' };
  public snapShotPositionX: number = 0;
  public snapShotPositionY: number = 0;
  private animationCount: number = 0;
  private initScale: number = 1;
  private initTranslateX: number = 0;
  private initTranslateY: number = 0;
  private initClipWidth: Dimension = 0;
  private initClipHeight: Dimension = 0;
  private initPositionValueX: number = 0;
  private initPositionValueY: number = 0;
  private cardItemInfo_px: RectInfoInPx = new RectInfoInPx();
  private recoverPrePage: () => void = () => {
  };
  private clickedCardId: string = '';

  public init(prePageCardId: string, prePageOnFinish: () => void): void {
    this.clickedCardId = prePageCardId;
    this.recoverPrePage = prePageOnFinish;
    this.cardItemInfo_px = ComponentAttrUtils.getRectInfoById(WindowUtils.window.getUIContext(), prePageCardId);
  }

  private initParams(): void {
    // let postNode = WindowUtils.window.getUIContext().getFrameNodeById(CardUtil.getPostPageImageId(this.clickedCardId));
    let postNode = WindowUtils.window.getUIContext().getFrameNodeById(this.clickedCardId);
    let postNodePositionX_vp: number = 0;
    let postNodePositionY_vp: number = 0;
    let postNodeWidth_px: number = 0;
    let postNodeHeight_px: number = 0;

    if (postNode) {
      postNodePositionX_vp = postNode.getPositionToScreenWithTransform().x;
      postNodePositionY_vp = postNode.getPositionToScreenWithTransform().y;
      postNodeWidth_px = postNode.getMeasuredSize().width;
      postNodeHeight_px = postNode.getMeasuredSize().height;
      logger.info('LongTakeAnimationProperties', 'the size is ' + postNodeWidth_px + ' and ' + postNodeHeight_px
        + ' and ' + vp2px(postNodePositionX_vp) + ' and ' + vp2px(postNodePositionY_vp));
    }

    this.initPositionValueX = -postNodePositionX_vp;
    this.initPositionValueY = -postNodePositionY_vp;
    this.snapShotPositionY = postNodePositionY_vp - px2vp(WindowUtils.topAvoidAreaHeight_px);
    this.snapShotPositionX = postNodePositionX_vp;

    // First calculate the ratio of the width and height of the card to the width and height of the window.
    this.initScale = this.cardItemInfo_px.width / postNodeWidth_px;
    if (!CardUtil.isLargeSize()) {
      this.initTranslateX = px2vp(this.cardItemInfo_px.left -
        (WindowUtils.windowWidth_px - this.cardItemInfo_px.width) / 2);
      this.initClipWidth = '100%';
      this.initClipHeight = px2vp((this.cardItemInfo_px.height) / this.initScale);
      this.snapShotSize = { width: '100%' };
      this.initTranslateY = px2vp(this.cardItemInfo_px.top -
        ((vp2px(this.initClipHeight) - vp2px(this.initClipHeight) * this.initScale) / 2));
    } else {
      this.initClipHeight = px2vp(this.cardItemInfo_px.height / this.initScale);
      this.initTranslateY = px2vp(this.cardItemInfo_px.top -
        ((vp2px(this.initClipHeight) - vp2px(this.initClipHeight) * this.initScale) / 2));
      this.initClipWidth = px2vp((this.cardItemInfo_px.width) / this.initScale);
      this.snapShotSize = { width: px2vp(postNodeWidth_px) };
      this.initTranslateX = px2vp(this.cardItemInfo_px.left - (WindowUtils.windowWidth_px / 2 - this.cardItemInfo_px.width / 2));
    }
    logger.info('LongTakeAnimationProperties', 'the value is initScale: ' + this.initScale + ' initTranslateX ' + this.initTranslateX
      + ' initClipWidth ' + this.initClipWidth + ' initClipHeight ' + this.initClipHeight + ' initTranslateY '
      + this.initTranslateY + ' initPositionValue ' + this.initPositionValueY);
  }

  public doAnimation(transitionProxy: NavigationTransitionProxy): void {
    if (CustomTransition.getInstance().operation === NavigationOperation.PUSH) {
      this.initParams();
      this.doEnterAnimation(transitionProxy);
    } else if (CustomTransition.getInstance().operation === NavigationOperation.POP) {
      this.doBackAnimation(transitionProxy);
    }
  }

  public doEnterAnimation(transitionProxy: NavigationTransitionProxy): void {
    this.scaleValue = this.initScale;
    this.translateX = this.initTranslateX;
    this.clipWidth = this.initClipWidth;
    this.clipHeight = this.initClipHeight;
    this.translateY = this.initTranslateY;
    this.positionYValue = this.initPositionValueY;
    this.positionXValue = this.initPositionValueX;

    let animationCount = ++this.animationCount;

    animateTo({
      duration: 350,
      curve: Curve.EaseInOut,
      onFinish: () => {
        if (animationCount === this.animationCount) {
          this.radius = 0;
        }
        transitionProxy.finishTransition();
      }
    }, () => {
      this.scaleValue = 1.0;
      this.translateX = 0;
      this.translateY = 0;
      this.clipWidth = '100%';
      this.clipHeight = '100%';
      this.positionYValue = 0;
      this.positionXValue = 0;
      this.radius = 34;
      this.navDestinationBgColor = $r('app.color.background');
    });

    animateTo({
      delay: 50,
      duration: 100,
      curve: Curve.Sharp
    }, () => {
      this.snapShotOpacity = 0;
    });

    animateTo({
      delay: 100,
      duration: 350,
      curve: Curve.Sharp
    }, () => {
      this.postPageOpacity = 1.0;
    });
  }

  public doBackAnimation(transitionProxy?: NavigationTransitionProxy): void {
    ++this.animationCount;

    animateTo({
      duration: 350,
      curve: Curve.EaseInOut,
      onFinish: () => {
        this.recoverPrePage();
        transitionProxy?.finishTransition()
      }
    }, () => {
      this.scaleValue = this.initScale;
      this.translateX = this.initTranslateX;
      this.clipWidth = this.initClipWidth;
      this.clipHeight = this.initClipHeight;
      this.translateY = this.initTranslateY;
      this.radius = 16;
      this.positionXValue = this.initPositionValueX;
      this.positionYValue = this.initPositionValueY;
      this.navDestinationBgColor = $r('app.color.background');
    });

    animateTo({
      duration: 50,
      delay: 150,
      curve: Curve.Friction
    }, () => {
      this.snapShotOpacity = 1;
    });

    animateTo({
      duration: 0,
      // delay: 200,
      curve: Curve.Friction
    }, () => {
      this.postPageOpacity = 0;
    });
  }

  // When you do not go through the custom transition, you need to set the state to the normal final state.
  public setFinalStatus(): void {
    this.navDestinationBgColor = $r('app.color.background');
    this.clipWidth = '100%';
    this.clipHeight = '100%';
    this.snapShotOpacity = 0;
    this.postPageOpacity = 1;
    this.radius = 0;
  }
}