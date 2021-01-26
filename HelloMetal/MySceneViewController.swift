/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class MySceneViewController: MetalViewController,MetalViewControllerDelegate {
  
  var worldModelMatrix:Matrix4!
  var objectToDraw: Cube!
  
  let panSensivity:Float = 5.0
  var lastPanLocation: CGPoint!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    worldModelMatrix = Matrix4()
    worldModelMatrix.translate(0.0, y: 0.0, z: -4)
    worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
    
    objectToDraw = Cube(device: device, commandQ:commandQueue)
    
    setupGestures()
    
    self.metalViewControllerDelegate = self
  }
  
  //MARK: - MetalViewControllerDelegate
  func renderObjects(drawable:CAMetalDrawable) {
    objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
  }
  
  func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
    objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
  }
  
  //MARK: - Gesture related
  // 1
  func setupGestures(){
    let pan = UIPanGestureRecognizer(target: self, action: #selector(MySceneViewController.pan))
    self.view.addGestureRecognizer(pan)
  }
    
  // 2
  @objc func pan(panGesture: UIPanGestureRecognizer){
    if panGesture.state == UIGestureRecognizer.State.changed {
      let pointInView = panGesture.location(in: self.view)
      // 3
      let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
      let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
      // 4
      objectToDraw.rotationY -= xDelta
      objectToDraw.rotationX -= yDelta
      lastPanLocation = pointInView
    } else if panGesture.state == UIGestureRecognizer.State.began {
      lastPanLocation = panGesture.location(in: self.view)
    }
  }

}
