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
  float4 position [[ attribute(0) ]];
  float4 color [[ attribute(1) ]];
};

struct VertexOut {
  float4 position [[ position ]];
  float4 color;
};

vertex VertexOut basic_vertex(                                   // 1
//  const device packed_float3* vertex_array [[ buffer(0) ]],   // 2
  const VertexIn vertexIn [[ stage_in ]]
//  constant Constants &constants [[ buffer(1) ]],
//  unsigned int vid [[ vertex_id ]]
                           ) {                         // 3
  
//  float4 position = float4(vertex_array[vid], 1);
//  position.x += constants.animateBy;
  VertexOut vertexOut;
  vertexOut.position = vertexIn.position;
  vertexOut.color = vertexIn.color;
  
  
//  return float4(vertex_array[vid], 1.0);                      // 4
//  return position;
  return vertexOut;
  /*
   1. All vertex shaders must begin with the keyword vertex. The function must return (at least) the final position of the vertex. You do this here by indicating float4 (a vector of four floats). You then give the name of the vertex shader; you’ll look up the shader later using this name.
   2. The first parameter is a pointer to an array of packed_float3 (a packed vector of three floats) – i.e., the position of each vertex.Use the [[ ... ]] syntax to declare attributes, which you can use to specify additional information such as resource locations, shader inputs and built-in variables. Here, you mark this parameter with [[ buffer(0) ]] to indicate that the first buffer of data that you send to your vertex shader from your Metal code will populate this parameter.
   3. The vertex shader also takes a special parameter with the vertex_id attribute, which means that the Metal will fill it in with the index of this particular vertex inside the vertex array.
   4. Here, you look up the position inside the vertex array based on the vertex id and return that. You also convert the vector to a float4, where the final value is 1.0 — long story short, this is required for 3D math.
  */
}

// MARK: - 5) Creating a Fragment Shader
fragment half4 basic_fragment(VertexOut vertexIn [[ stage_in ]]) { // 1
//  return half4(1, 1, 0, 1);              // 2

  return half4(vertexIn.color);
  /*
   1. All fragment shaders must begin with the keyword fragment. The function must return (at least) the final color of the fragment. You do so here by indicating half4 (a four-component color value RGBA). Note that half4 is more memory efficient than float4 because you’re writing to less GPU memory.
   2. Here, you return (1, 1, 1, 1) for the color, which is white.
  */
}
