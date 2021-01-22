/// Copyright (c) 2021 Razeware LLC
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

// MARK: - 4) Creating a Vertex Shader

#include <metal_stdlib>
using namespace metal;

struct Constants {
  float animateBy;
};

struct VertexIn {
//  float4 position [[ attribute(0) ]];
//  float4 color [[ attribute(1) ]];
  
  packed_float3 position;
  packed_float4 color;

};

struct VertexOut {
  float4 position [[ position ]];
  float4 color;
};

struct Uniforms {
  float4x4 modelMatrix;
  float4x4 projectionMatrix;
};


vertex VertexOut basic_vertex(
  const device VertexIn* vertex_array [[ buffer(0) ]],
  const device Uniforms&  uniforms    [[ buffer(1) ]],           //1
  unsigned int vid [[ vertex_id ]]) {

  float4x4 mv_Matrix = uniforms.modelMatrix;                     //2
  float4x4 proj_Matrix = uniforms.projectionMatrix;

  
  VertexIn VertexIn = vertex_array[vid];

  VertexOut VertexOut;
  VertexOut.position = proj_Matrix * mv_Matrix * float4(VertexIn.position,1);  //3
  VertexOut.color = VertexIn.color;

  return VertexOut;
}

/*
 1. You add a second parameter for the uniform buffer, marking that it’s incoming in slot 1 to match up with the code you wrote earlier.
 2. You then get a handle to the model matrix in the uniforms structure.
 3. To apply the model transformation to a vertex, you simply multiply the vertex position by the model matrix.
*/

// MARK: - 5) Creating a Fragment Shader
fragment half4 basic_fragment(VertexOut vertexIn [[ stage_in ]]) { // 1
//  return half4(1, 1, 0, 1);              // 2

  return half4(vertexIn.color);
  /*
   1. All fragment shaders must begin with the keyword fragment. The function must return (at least) the final color of the fragment. You do so here by indicating half4 (a four-component color value RGBA). Note that half4 is more memory efficient than float4 because you’re writing to less GPU memory.
   2. Here, you return (1, 1, 1, 1) for the color, which is white.
  */
}
