Shader "GPUSkinning/GPUSkinning_Specular_AdamAnim"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		
		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		_GlossMapScale("Smoothness Factor", Range(0.0, 1.0)) = 1.0
		[Enum(Specular Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

		_SpecColor("Specular", Color) = (0.2,0.2,0.2)
		_SpecGlossMap("Specular", 2D) = "white" {}
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

		_BumpScale("Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}

		_Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
		_ParallaxMap ("Height Map", 2D) = "black" {}

		_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		_OcclusionMap("Occlusion", 2D) = "white" {}

		_EmissionColor("Color", Color) = (0,0,0)
		_EmissionMap("Emission", 2D) = "white" {}
		
		_DetailMask("Detail Mask", 2D) = "white" {}

		_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
		_DetailNormalMapScale("Scale", Float) = 1.0
		_DetailNormalMap("Normal Map", 2D) = "bump" {}

		[Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0


		// Blending state
		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _ZWrite ("__zw", Float) = 1.0
    }
 
CGINCLUDE
    // You may define one of these to expressly specify it.
    // #define UNITY_BRDF_PBS BRDF1_Unity_PBS
    // #define UNITY_BRDF_PBS BRDF2_Unity_PBS
    // #define UNITY_BRDF_PBS BRDF3_Unity_PBS
 
    // You can reduce the time to compile by constraining the usage of eash features.
    // Corresponding shader_feature pragma should be disabled.
    // #define _NORMALMAP 1
    // #define _ALPHATEST_ON 1
    // #define _EMISSION 1
    // #define _METALLICGLOSSMAP 1
    // #define _DETAIL_MULX2 1
ENDCG
 
    SubShader
    {
        Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
        LOD 300
 
        // It seems Blend command is getting overridden later
        // in the processing of  Surface shader.
        // Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
 
    CGPROGRAM
        #pragma target 3.0
        // TEMPORARY: GLES2.0 temporarily disabled to prevent errors spam on devices without textureCubeLodEXT
        #pragma exclude_renderers gles
 
 
        #pragma shader_feature _NORMALMAP
        #pragma shader_feature _ALPHATEST_ON
        #pragma shader_feature _EMISSION
        #pragma shader_feature _SPECGLOSSMAP
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

        #pragma skip_variants _PARALLAXMAP _DETAIL_MULX2

        // may not need these (not sure)
        // #pragma multi_compile_fwdbase
        // #pragma multi_compile_fog
 
        #pragma surface surfSpecular StandardSpecular vertex:myvert finalcolor:finalSpecular fullforwardshadows // Opaque or Cutout
        // #pragma surface surfSpecular StandardSpecular vertex:vert finalcolor:finalSpecular fullforwardshadows alpha:fade // Fade
        // #pragma surface surfSpecular StandardSpecular vertex:vert finalcolor:finalSpecular fullforwardshadows alpha:premul // Transparent
 
        #include "Assets/GPUSkinning/Resources/GPUSkinningSurface.cginc"

        uniform float4x4 _GPUSkinning_MatrixArray[35];

        void myvert (inout appdata_vert v, out Input o) 
        {
		   UNITY_INITIALIZE_OUTPUT(Input,o);
		   o.texcoords.xy = TRANSFORM_TEX(v.uv0, _MainTex); // Always source from uv0

		   // Skinning
		   {
				float4 normal = float4(v.normal, 0);
				float4 tangent = float4(v.tangent.xyz, 0);

				

				

				
				float4 pos =
					mul(_GPUSkinning_MatrixArray[v.uv1.x], v.vertex) * v.uv1.y +
					mul(_GPUSkinning_MatrixArray[v.uv1.z], v.vertex) * v.uv1.w + 
					mul(_GPUSkinning_MatrixArray[v.uv2.x], v.vertex) * v.uv2.y + 
					mul(_GPUSkinning_MatrixArray[v.uv2.z], v.vertex) * v.uv2.w;

				normal =
					mul(_GPUSkinning_MatrixArray[v.uv1.x], normal) * v.uv1.y +
					mul(_GPUSkinning_MatrixArray[v.uv1.z], normal) * v.uv1.w + 
					mul(_GPUSkinning_MatrixArray[v.uv2.x], normal) * v.uv2.y + 
					mul(_GPUSkinning_MatrixArray[v.uv2.z], normal) * v.uv2.w;

				tangent =
					mul(_GPUSkinning_MatrixArray[v.uv1.x], tangent) * v.uv1.y +
					mul(_GPUSkinning_MatrixArray[v.uv1.z], tangent) * v.uv1.w + 
					mul(_GPUSkinning_MatrixArray[v.uv2.x], tangent) * v.uv2.y + 
					mul(_GPUSkinning_MatrixArray[v.uv2.z], tangent) * v.uv2.w;
				

				v.vertex = pos;
				v.normal = normal.xyz;
				v.tangent = float4(tangent.xyz, v.tangent.w);
		   }
		}
    ENDCG
 
        // For some reason SHADOWCASTER works. Not ShadowCaster.
        // UsePass "Standard/ShadowCaster"
        UsePass "Standard/SHADOWCASTER"
    }
 
    FallBack Off
    CustomEditor "GPUSkinningStandardShaderGUI"
}