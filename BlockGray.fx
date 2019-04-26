//edit by KarlVonDonitz
float Extent
<
   string UIName = "Extent";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 0.01;
> = float( 0.007 );

float4 ClearColor
<
   string UIName = "ClearColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4(0,0,0,0);

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

float Time :TIME;
float X : CONTROLOBJECT < string name = "(self)"; string item = "X";>;
float Y : CONTROLOBJECT < string name = "(self)"; string item = "Y";>;
float XSpeed : CONTROLOBJECT < string name = "(self)"; string item = "Rx";>;
float YSpeed : CONTROLOBJECT < string name = "(self)"; string item = "Ry";>;
float Transparent : CONTROLOBJECT < string name = "(self)"; string item = "Tr";>;
float ClearDepth  = 1.0;

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

float Gary(float4 Color)
{
	return Color.r*0.3+Color.g*0.59+Color.b*0.11;
}

struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_Main( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex;
    return Out;
}

float4 PS_Effect( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 Color = 0;
	float4 GaryColor = Gary( tex2D(ScnSamp,Tex) );
	float4 OriginColor = tex2D(ScnSamp,Tex);
	bool Flag;
	if (sin(Tex.x*X+Time*XSpeed)>0)
	{
	    Flag = 1;
	} else {
	    Flag = 0;
	}
	if (sin(Tex.y*Y+Time*YSpeed)>0)
	{
	    Flag = !Flag;
	} else {
	    Flag = Flag;
	}
	if ( Flag )
	{
	Color = GaryColor;
	} else {
	Color = OriginColor;
	}
	Color = Color*Transparent + OriginColor*(1-Transparent);
    return Color;
}

technique Effect <
    string Script = 
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=EffectPass;"
    ;
    
> {
    pass EffectPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Main();
        PixelShader  = compile ps_2_0 PS_Effect();
    }
}