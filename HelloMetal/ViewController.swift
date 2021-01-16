/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

// MARK: - 1) Creating an MTLDevice
import Metal

class ViewController: UIViewController {
  
  var device: MTLDevice!
  
  var metalLayer: CAMetalLayer!
  
  let vertexData: [Float] = [
      0.0,  1.0, 0.0,
      -1.0, -1.0, 0.0,
      1.0, -1.0, 0.0,
      0.75, 0.5, 0.0
  ]
  
  var vertexBuffer: MTLBuffer!

  var pipelineState: MTLRenderPipelineState!
  
  var commandQueue: MTLCommandQueue!
  
  var timer: CADisplayLink!
  
  override func viewDidLoad() {
  
    device = MTLCreateSystemDefaultDevice()
    
    // MARK: - 2) Creating a CAMetalLayer
    metalLayer = CAMetalLayer()          // 1
    metalLayer.device = device           // 2
    metalLayer.pixelFormat = .bgra8Unorm // 3
    metalLayer.framebufferOnly = true    // 4
    metalLayer.frame = view.layer.frame  // 5
    view.layer.addSublayer(metalLayer)   // 6
    
    /*
     1. Create a new CAMetalLayer.
     2. You must specify the MTLDevice the layer should use. You simply set this to the device you obtained earlier.
     3. Set the pixel format to bgra8Unorm, which is a fancy way of saying “8 bytes for Blue, Green, Red and Alpha, in that order — with normalized values between 0 and 1.” This is one of only two possible formats to use for a CAMetalLayer, so normally you’d just leave this as-is.
     4. Apple encourages you to set framebufferOnly to true for performance reasons unless you need to sample from the textures generated for this layer, or if you need to enable compute kernels on the layer drawable texture. Most of the time, you don’t need to do this.
     5. You set the frame of the layer to match the frame of the view.
     6. Finally, you add the layer as a sublayer of the view’s main layer.
    */
    
    // MARK: - 3) Creating a Vertex Buffer
    let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])         // 1
    vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])  // 2
    
    /*
     1. You need to get the size of the vertex data in bytes. You do this by multiplying the size of the first element by the count of elements in the array.
     2. You call makeBuffer(bytes:length:options:) on the MTLDevice to create a new buffer on the GPU, passing in the data from the CPU. You pass an empty array for default configuration.
    */
    
    // MARK: - 6) Creating a Render Pipeline
    // 1
    let defaultLibrary = device.makeDefaultLibrary()!
    let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
    let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
    // 2
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
    // 3
    pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    
    /*
     1. You can access any of the precompiled shaders included in your project through the MTLLibrary object you get by calling device.makeDefaultLibrary()!. Then, you can look up each shader by name.
     2. You set up your render pipeline configuration here. It contains the shaders that you want to use, as well as the pixel format for the color attachment — i.e., the output buffer that you’re rendering to, which is the CAMetalLayer itself.
     3. Finally, you compile the pipeline configuration into a pipeline state that is efficient to use here on out.
    */
    
    // MARK: - 7) Creating a Command Queue
    commandQueue = device.makeCommandQueue()
    
    // --------- Rendering the Triangle --------- //
    
    // MARK: - 1) Creating a Display Link
    timer = CADisplayLink(target: self, selector: #selector(gameloop)) // This sets up your code to call a method named
                                                                       // gameloop() every time the screen refreshes.
    timer.add(to: RunLoop.main, forMode: .default)
    
    
  }
  
  // MARK: - 2) Creating a Render Pass Descriptor
  func render() {
    guard let drawable = metalLayer?.nextDrawable() else { return }
    
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
      red: 0.0,
      green: 104.0/255.0,
      blue: 55.0/255.0,
      alpha: 1.0)
    
    // MARK: - 3) Creating a Command Buffer
    let commandBuffer = commandQueue.makeCommandBuffer()!

    // MARK: - 4) Creating a Render Command Encoder
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    
    // Here, you’re telling the GPU to draw a set of triangles, based on the vertex buffer. To keep things simple, you are only drawing one. The method arguments tell Metal that each triangle consists of three vertices, starting at index 0 inside the vertex buffer, and there is one triangle total.
    renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexData.count / 3, instanceCount: 1)
    renderEncoder.endEncoding()
    
    // MARK: - 5) Committing Your Command Buffer
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }

  @objc func gameloop() {
    autoreleasepool {
      self.render()
    }
  }
}
