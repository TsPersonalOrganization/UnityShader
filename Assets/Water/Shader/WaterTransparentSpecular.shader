Shader "Ts/Water/TransparentSpecular" {
    Properties {
	_WaveSpeed ("Wave speed", Vector) = (1,-1,0.1,0.1)
	_Exposure ("Exposure", Float) = 0.05
	_Distortion ("Distortion", Range(0,1)) = 0
	_Shininess ("Shininess", Range (0.03, 1)) = 1
	_AlphaAmount ("Alpha ", Range(0.01, 1)) = 0.5
    _MainTex ("SurfaceWaveTexture", 2D) = "white" {}
    _BumpMap ("WaterNormal1", 2D) = "bump" {}
    _BumpMap2 ("WaterNormal2", 2D) = "bump" {}
    _LightDir ("lightDir", Vector) = (1,1,1,1)
    _LightColor ("Light Color", Color) = (1,1,1,1)
    }
    SubShader {


	Tags {  "Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			}
	LOD 250

    CGPROGRAM

	#pragma surface surf MobileBlinnPhong alpha exclude_path:prepass nolightmap noforwardadd halfasview


	#include "UnityCG.cginc"

	half4 _LightDir;
	uniform half4 _LightColor;

	inline fixed4 LightingMobileBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
	{
		fixed diff = max (0, dot (s.Normal, _LightDir.xyz));
		fixed nh = max (0, dot (s.Normal, halfDir));
		fixed3 reflectionDir = reflect(halfDir, s.Normal);
		fixed spec = pow (nh, s.Specular*128) * s.Gloss;

		fixed4 reflection = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflectionDir);

		fixed4 hdrReflection;
		hdrReflection.rgb = DecodeHDR(reflection, unity_SpecCube0_HDR);
		hdrReflection.a = 1.0;


		fixed4 c;
		//c.rgb = hdrReflection;

		c.rgb = (s.Albedo * _LightColor.rgb * diff + _LightColor.rgb * spec) * hdrReflection * (atten*2);
		c.a = s.Alpha;
		return c;
	}
    struct Input {
    	float2 uv_MainTex;
    };
    
    sampler2D _MainTex;
    sampler2D _BumpMap;
    sampler2D _BumpMap2;
	uniform float _Exposure;
	uniform float _Distortion;
	uniform float _AlphaAmount;
	uniform float4 _WaveSpeed;
	half _Shininess;

	void surf (Input IN, inout SurfaceOutput o) 
	{
		half4 tex = tex2D(_MainTex, IN.uv_MainTex);
		fixed4 normal1 = tex2D(_BumpMap, float2(IN.uv_MainTex.x +(_WaveSpeed.x * _Time.x),IN.uv_MainTex.y+(_WaveSpeed.y * _Time.x))) * _Distortion;
		fixed4 normal2 = tex2D(_BumpMap, float2(IN.uv_MainTex.x +(_WaveSpeed.z * _Time.x),IN.uv_MainTex.y+(_WaveSpeed.w * _Time.x))) * _Distortion;
		o.Albedo = tex.rgb * _Exposure;
		o.Gloss = tex.a;
		o.Normal = UnpackNormal (normal1) * 0.5 + UnpackNormal(normal2) * 0.5;
		o.Specular = _Shininess ;
		o.Alpha = _AlphaAmount;
	}

	ENDCG
	}

Fallback "Diffuse"
}