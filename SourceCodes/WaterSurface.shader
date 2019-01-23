Shader "Water/Surface"
{

	Properties{
		_Color("Color", color) = (1,1,1,0)
		_DispTex("Disp Texture", 2D) = "gray"{}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_MinDist("Min Distance", Range(0.1,50)) = 10
		_MaxDist("Max Distance", Range(0.1, 50)) = 25
		_TessFactor("Tessellation", Range(1,50)) = 10
		_Displacement("Displacement", Range(0,1.0)) = 0.3
		_MainTex("Texture", 2D) = "white" {}
		_RefTex("Ref", 2D) = "black" {}
		_ParallaxScale("Parallax Scale", Float) = 1
		_NormalScaleFactor("Normal Scale Factor", Float) = 1
		_BumpAmt("BumpAmt", Range(0, 9999)) = 0
		_Blend("Blend", Range(0,1)) = 0.0
	}

	SubShader{
		Tags{"Queue" = "Transparent" "IgnoreProjector"="True" "RenderType" = "Transparent"}
		ZWrite On
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		#pragma surface surf Standard alpha addshadow fullforwardshadows vertex:disp tessellate:tessDistance
			//vertex:dispでvertex modifier関数が使えるようになる、多分セマンティクス的な使い方でvertexはdispを意味しますよという
			#pragma target 5.0
			#include "Tessellation.cginc"

			float _TessFactor;
			float _Displacement;
			float _MinDist;
			float _MaxDist;
			sampler2D _DispTex;
			float4 _DispTex_TexelSize;
			fixed4 _Color;
			half _Glossiness;
			half _Metallic;
			sampler2D _MainTex;
			sampler2D _RefTex;

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 ref : TEXCOORD1;
			};

			struct Input {
				float2 uv_DispTex;
				float2 uv_MainTex;
			};

			//距離に応じて、ディティールの細かさを調整
			float4 tessDistance(appdata v0, appdata v1, appdata v2) {
				return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _MinDist, _MaxDist, _TessFactor);
			}

			

			void disp(inout appdata v) {  //inoutは最終的に接続するのがappdataだと示している
				float d = tex2Dlod(_DispTex, float4(v.texcoord.xy, 0, 0)).r * _Displacement;
				//tex2Dlod(sampler2D s, float4 t)は返り値がfloat4、tex2Dと同じでuv座標を与えて色を返す
				v.vertex.xyz += v.normal * d;
				//水面のxyz座標を画像のR値によって変化させる
			}

			void surf(Input IN, inout SurfaceOutputStandard o) {
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				//clamp:(value, min, max)
				//その場所の赤色の値を取得して、色合いを変化させる

				float3 duv = float3(_DispTex_TexelSize.xy, 0) * 10;
				half v1 = tex2D(_DispTex, IN.uv_DispTex - duv.xz).y;
				half v2 = tex2D(_DispTex, IN.uv_DispTex + duv.xz).y;
				half v3 = tex2D(_DispTex, IN.uv_DispTex - duv.zy).y;
				half v4 = tex2D(_DispTex, IN.uv_DispTex + duv.zy).y;
				float3 du = float3(1, v1 - v2, 0);
				float3 dv = float3(0, v3 - v4, 1);
				float3 n = normalize(cross(dv, du));
				o.Normal = n;
				//o.Normal = normalize(float3(v1 - v2, v3 - v4, 0.3));
			}
			ENDCG

		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"


			float4x4 _RefW;
			float4x4 _RefVP;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _RefTex;
			float4 _RefTex_TexelSize;
			sampler2D _DispTex;
			float4 _DispTex_TexelSize;
			float _BumpAmt;
			float _ParallaxScale;
			float _NormalScaleFactor;
			fixed4 _Color;
			float _Blend;

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 ref : TEXCOORD1;
				fixed4 color : COLOR;
			};
	
			struct Input {
				float2 uv_DispTex;
			};

			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.ref = mul(_RefVP, mul(_RefW, v.vertex));
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float2 bump = tex2D(_DispTex, i.uv + _Time.x/4).rg;
				
				float2 shiftX = { _DispTex_TexelSize.x,  0 };
				float2 shiftZ = { 0, _DispTex_TexelSize.y };
				shiftX *= _ParallaxScale * _NormalScaleFactor;
				shiftZ *= _ParallaxScale * _NormalScaleFactor;
				float3 texX = 2 * tex2Dlod(_DispTex, float4(i.uv.xy + shiftX,0,0)) - 1;
				float3 texx = 2 * tex2Dlod(_DispTex, float4(i.uv.xy - shiftX,0,0)) - 1;
				float3 texZ = 2 * tex2Dlod(_DispTex, float4(i.uv.xy + shiftZ,0,0)) - 1;
				float3 texz = 2 * tex2Dlod(_DispTex, float4(i.uv.xy - shiftZ,0,0)) - 1;
				float3 du = { 1, 0, _NormalScaleFactor * (texX.x - texx.x) };
				float3 dv = { 0, 1, _NormalScaleFactor * (texZ.x - texz.x) };
				bump += normalize(cross(du, dv));

				float2 offset = bump * _BumpAmt * _RefTex_TexelSize.xy;
				i.ref.xy = (offset * i.ref.z)/8 + i.ref.xy;
				
				//float4 ref = tex2D(_RefTex, i.ref.xy / i.ref.w * 0.5 + 0.5);
				fixed3 tex = tex2D(_RefTex, i.ref.xy / i.ref.w * 0.5 + 0.5).rgb * _Blend;
				fixed2 scrolluv = i.ref.xy / i.ref.w * 0.5 + 0.5;
				scrolluv.x -= 0.2 * _Time;
				scrolluv.y += 0.2 * _Time;
				fixed3 tex2 = tex2D(_MainTex, scrolluv).rgb * (1-_Blend);
				fixed alpha = _Color.a * (0.5 + 0.5 * clamp(tex2D(_DispTex, i.ref.xy / i.ref.w * 0.5 + 0.5).r, 0, 1));
				fixed4 col = fixed4(tex.r + tex2.r, tex.g + tex2.g, tex.b + tex2.b, alpha);
				return col;
				//return ref;
			}
			ENDCG
		}
		}
	FallBack "Diffuse"
}