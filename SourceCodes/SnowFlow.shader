// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SnowFlow" {
    Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
    }
	SubShader {
   		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha // alpha blending
		
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
 			#pragma target 3.0
 			
 			#include "UnityCG.cginc"

            uniform sampler2D _MainTex;

 			struct appdata_custom {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

 			struct v2f {
 				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
 			};
 			
 			float4x4 _PrevInvMatrix;
			float3   _TargetPosition;
			float    _Range;
			float    _RangeR;
			float    _Size;
			float3   _MoveTotal;
			float3   _CamUp;
   
            v2f vert(appdata_custom v)
            {
				float3 target = _TargetPosition;
				float3 trip;
				float3 mv = v.vertex.xyz;
				mv += _MoveTotal;
				trip = floor( ((target - mv)*_RangeR + 1) * 0.5 );
				trip *= (_Range * 2);
				mv += trip;

				float3 diff = _CamUp * _Size;
				float3 finalposition;
				float3 tv0 = mv;
				tv0.x += sin(mv.x*0.2) * sin(mv.y*0.3) * sin(mv.x*0.9) * sin(mv.y*0.8);
				tv0.z += sin(mv.x*0.1) * sin(mv.y*0.2) * sin(mv.x*0.8) * sin(mv.y*1.2);
				{
					float3 eyeVector = ObjSpaceViewDir(float4(tv0, 0));
					float3 sideVector = normalize(cross(eyeVector,diff));
					tv0 += (v.texcoord.x-0.5f)*sideVector * _Size;
					tv0 += (v.texcoord.y-0.5f)*diff;
					finalposition = tv0;
				}
            	v2f o;
			    o.pos = UnityObjectToClipPos( float4(finalposition,1));
				o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.texcoord);
            	return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
				return tex2D(_MainTex, i.uv);
            }

            ENDCG
        }
    }
}

/*
MIT License

Copyright (c) 2016 Yuji YASUHARA

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
