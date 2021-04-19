/*=============================================================================

	ReShade 4 effect file
    github.com/martymcmodding

    Copyright (c) Pascal Gilcher. All rights reserved.

	Support me:
   		paypal.me/mcflypg
   		patreon.com/mcflypg

    ReGrade ALPHA 0.2

    changelog:

    0.1:    - initial release
    0.2:    - ported to refactored qUINT structure
            - removed RGB split from tone curve and lift gamma gain, replaced with
              with RGB selector
            - fixed bug with color remapper red affecting pure white
            - add more grading controls
            - remade lift gamma gain to fit convention
            - replaced histogram with McFly's '21 bomb ass histogram (TM)
            - added split toning
            - switched to internal LUT processing


    * Unauthorized copying of this file, via any medium is strictly prohibited
 	* Proprietary and confidential

=============================================================================*/

/*=============================================================================
	Preprocessor settings
=============================================================================*/

#ifndef TONE_REMAP_SIMPLE
 #define TONE_REMAP_SIMPLE		        0
#endif

/*=============================================================================
	UI Uniforms
=============================================================================*/

uniform float INPUT_BLACK_LVL <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 255.0;
	ui_step = 1.0;
	ui_label = "Black Level";
    ui_category = "Color Grading";
> = 0.00;

uniform float INPUT_WHITE_LVL <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 255.0;
	ui_step = 1.0;
	ui_label = "White Level";
    ui_category = "Color Grading";
> = 255.00;

uniform float GRADE_CONTRAST <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 1.0;
	ui_label = "Contrast";
    ui_category = "Color Grading";
> = 0.0;

uniform float GRADE_EXPOSURE <
	ui_type = "drag";
	ui_min = -4.0; ui_max = 4.0;
	ui_label = "Exposure";
    ui_category = "Color Grading";
> = 0.0;

uniform float GRADE_SATURATION <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 1.0;
	ui_label = "Saturation";
    ui_category = "Color Grading";
> = 0.0;

uniform float GRADE_VIBRANCE <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 1.0;
	ui_label = "Vibrance";
    ui_category = "Color Grading";
> = 0.0;

uniform float3 INPUT_LIFT_COLOR <
  	ui_type = "color";
  	ui_label="Lift";
  	ui_category = "Color Grading";    
> = float3(0.5, 0.5, 0.5);

uniform float3 INPUT_GAMMA_COLOR <
  	ui_type = "color";
  	ui_label="Gamma";
  	ui_category = "Color Grading";    
> = float3(0.5, 0.5, 0.5);

uniform float3 INPUT_GAIN_COLOR <
  	ui_type = "color";
  	ui_label="Gain";
  	ui_category = "Color Grading";    
> = float3(0.5, 0.5, 0.5);

uniform float INPUT_COLOR_TEMPERATURE <
	ui_type = "drag";
	ui_min = 1700.0; ui_max = 40000.0;
    ui_step = 10.0;
	ui_label = "Color Temperature";
    ui_category = "Color Grading";
> = 6500.0;

#if TONE_REMAP_SIMPLE == 1
uniform float3 COLOR_REMAP_RED <
  	ui_type = "color";
  	ui_label="New Red";
  	ui_category = "Color Remapper";   
> = float3(1.0, 0.0, 0.0);
uniform float3 COLOR_REMAP_GREEN <
  	ui_type = "color";
  	ui_label="New Green";
  	ui_category = "Color Remapper";   
> = float3(0.0, 1.0, 0.0);
uniform float3 COLOR_REMAP_BLUE <
  	ui_type = "color";
  	ui_label="New Blue";
  	ui_category = "Color Remapper";    
> = float3(0.0, 0.0, 1.0);
#else
uniform float3 COLOR_REMAP_RED <
  	ui_type = "color";
  	ui_label="New Red";
  	ui_category = "Color Remapper";   
> = float3(1.0, 0.0, 0.0);

uniform float3 COLOR_REMAP_ORANGE <
  	ui_type = "color";
  	ui_label="New Orange";
  	ui_category = "Color Remapper";    
> = float3(1.0, 0.5, 0.0);

uniform float3 COLOR_REMAP_YELLOW <
  	ui_type = "color";
  	ui_label="New Yellow";
  	ui_category = "Color Remapper";     
> = float3(1.0, 1.0, 0.0);

uniform float3 COLOR_REMAP_GREEN <
  	ui_type = "color";
  	ui_label="New Green";
  	ui_category = "Color Remapper";   
> = float3(0.0, 1.0, 0.0);

uniform float3 COLOR_REMAP_AQUA <
  	ui_type = "color";
  	ui_label="New Aqua";
	ui_category = "Color Remapper";
> = float3(0.0, 1.0, 1.0);

uniform float3 COLOR_REMAP_BLUE <
  	ui_type = "color";
  	ui_label="New Blue";
  	ui_category = "Color Remapper";    
> = float3(0.0, 0.0, 1.0);

uniform float3 COLOR_REMAP_MAGENTA <
  	ui_type = "color";
  	ui_label="New Magenta";
  	ui_category = "Color Remapper";     
> = float3(1.0, 0.0, 1.0);
#endif

uniform float TONECURVE_SHADOWS <
	ui_type = "drag";
	ui_min = -1.00; ui_max = 1.00;
	ui_label = "Shadows";
    ui_category = "Tone Curve";
> = 0.00;

uniform float TONECURVE_DARKS <
	ui_type = "drag";
	ui_min = -1.00; ui_max = 1.00;
	ui_label = "Darks";
    ui_category = "Tone Curve";
> = 0.00;

uniform float TONECURVE_LIGHTS <
	ui_type = "drag";
	ui_min = -1.00; ui_max = 1.00;
	ui_label = "Lights";
    ui_category = "Tone Curve";
> = 0.00;

uniform float TONECURVE_HIGHLIGHTS <
	ui_type = "drag";
	ui_min = -1.00; ui_max = 1.00;
	ui_label = "Highlights";
    ui_category = "Tone Curve";
> = 0.00;

uniform float3 SPLITTONE_SHADOWS <
  	ui_type = "color";
  	ui_label="Shadow Tint";
  	ui_category = "Split Toning";    
> = float3(1.0, 1.0, 1.0);

uniform float3 SPLITTONE_HIGHLIGHTS <
  	ui_type = "color";
  	ui_label="Highlight Tint";
  	ui_category = "Split Toning";    
> = float3(1.0, 1.0, 1.0);

uniform float SPLITTONE_BALANCE <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 1.00;
	ui_label = "Balance";
    ui_category = "Split Toning";
> = 0.5;

uniform int HISTOGRAM_MODE <
	ui_type = "combo";
    ui_label = "Histogram";
	ui_items = "Off\0Luminance\0RGB\0RGB + Luminance (separated)\0";
    ui_category = "Statistics";
> = 1;

uniform bool HISTOGRAM_UIENABLE <
    ui_label = "Hide Histogram when ReShade menu is closed";
    ui_category = "Statistics";
> = true;
/*
uniform float4 tempF1 <
    ui_type = "drag";
    ui_min = -100.0;
    ui_max = 100.0;
> = float4(1,1,1,1);

uniform float4 tempF2 <
    ui_type = "drag";
    ui_min = -100.0;
    ui_max = 100.0;
> = float4(1,1,1,1);

uniform float4 tempF3 <
    ui_type = "drag";
    ui_min = -100.0;
    ui_max = 100.0;
> = float4(1,1,1,1);
*/
/*=============================================================================
	Textures, Samplers, Globals
=============================================================================*/

uniform float FRAMETIME < source = "frametime";  >;
uniform uint FRAMECOUNT  < source = "framecount"; >;
uniform bool OVERLAY_OPEN < source = "overlay_open"; >;

//powers of 2
#define GRID_SCALE		0
#define HISTORY_SCALE	3

//can't touch this dun dundundun can't touch this
#define GRID_DIM_X				(BUFFER_WIDTH >> GRID_SCALE)
#define GRID_DIM_Y				(BUFFER_HEIGHT >> GRID_SCALE)
#define SUB_GRID_DIM_X  		(GRID_DIM_X >> HISTORY_SCALE)
#define SUB_GRID_DIM_Y  		(GRID_DIM_Y >> HISTORY_SCALE)
#define HISTORY_SIZE			((1 << HISTORY_SCALE) * (1 << HISTORY_SCALE))

#define THREAD_CONFLICT_RES_SIZE 64

texture2D HistogramTexRGBIRaw		    { Width = 256;   Height = THREAD_CONFLICT_RES_SIZE;               Format = RGBA32F;  	};
texture2D HistogramTexRGBI			    { Width = 256;   Height = 1;                Format = RGBA32F;  	};
texture2D HistogramHistoryTexRGBI	    { Width = 256;   Height = HISTORY_SIZE;     Format = RGBA32F;  	};

texture2D LUTInternal	                { Width = 1024;   Height = 32;     Format = RGBA8;  	};
sampler2D sLUTInternal		            { Texture = LUTInternal;  };

sampler2D sHistogramTexRGBIRaw			{ Texture = HistogramTexRGBIRaw;  };
sampler2D sHistogramTexRGBI			    { Texture = HistogramTexRGBI;  };
sampler2D sHistogramHistoryTexRGBI 	    { Texture = HistogramHistoryTexRGBI; };

/*=============================================================================
	Includes
=============================================================================*/

#include "qUINT\Global.fxh"
#include "qUINT\Colorspaces.fxh"
#include "qUINT\Whitebalance.fxh"

/*=============================================================================
	Vertex Shader
=============================================================================*/

struct VSOUT
{
	float4                  vpos        : SV_Position;
    float2                  uv          : TEXCOORD0;    
};

struct VSOUTRGBI
{
	float4                  vpos        : SV_Position;
    float2                  uv          : TEXCOORD0;
    nointerpolation uint 	channel		: TEXCOORD1; 
};

//writes single histogram for current frame
VSOUTRGBI VS_HistogramGenRGBIRaw(in uint vertex_id : SV_VertexID)
{
    VSOUTRGBI o;

    o.channel = vertex_id % 4u;          //channel currently processed
    vertex_id /= 4u;                     //reuse same math as single channel histogram

    uint rowtowrite = vertex_id % THREAD_CONFLICT_RES_SIZE;   //write points into different rows to improve performance (less threads write to same texel at the same time)   

    [flatten]
    if(HISTOGRAM_MODE == 0 //off
    || HISTOGRAM_MODE == 1 && o.channel != 3 //luma only
    || (HISTOGRAM_UIENABLE && !OVERLAY_OPEN)
    ) rowtowrite = -10000; //shift out of viewport -> pixel is not drawn

    static const uint grid_subgrid_ratio = 1u << HISTORY_SCALE; //grid = total grid that is analyzed, subgrid = part of the grid that is analyzed this frame
    uint history_num = FRAMECOUNT % HISTORY_SIZE;

    uint2 current_subgrid_point = uint2(vertex_id % SUB_GRID_DIM_X, vertex_id / SUB_GRID_DIM_X);
    uint2 current_subgrid_to_grid_offset = uint2(history_num % grid_subgrid_ratio, history_num / grid_subgrid_ratio);
    uint2 current_grid_point = current_subgrid_point * grid_subgrid_ratio + current_subgrid_to_grid_offset;

    //transform to final fullscreen pixel grid to sample
    static const uint grid_to_pixelraster_ratio = 1u << GRID_SCALE;
    uint2 current_pixel_point = current_grid_point * grid_to_pixelraster_ratio; //upscale grid to fullres texel coord
    current_pixel_point += grid_to_pixelraster_ratio / 2; //center grid

    float4 c = tex2Dfetch(ColorInput, current_pixel_point);
    c.w = dot(c.rgb, float3(0.299, 0.587, 0.114));

    float val = dot(c, int4(0, 1, 2, 3) == o.channel.xxxx); //select channel of sample to add to bin
    //write point for 256x1 texture
    o.uv.x = (round(val * 255) + 0.5) / 256.0;
   	o.uv.y = (0.5 + rowtowrite) / THREAD_CONFLICT_RES_SIZE; //select row to write to
   	o.vpos = float4(o.uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0); //can use the borked uv, as we're writing points anyways, otherwise define UV regularly and use transformed UV to define vpos
    return o;
}

VSOUT VS_HistogramHistory(in uint id : SV_VertexID)
{
    VSOUT o;    

   	uint history_size = HISTORY_SIZE; 
    uint history_num = FRAMECOUNT % history_size;

    //setup standard triangle for the UV at location
    o.uv.x = (id == 2) ? 2.0 : 0.0;
    o.uv.y = (id == 1) ? 2.0 : 0.0;

    //define area to write to in UV space of target
    float2 target_uv = o.uv;
    //transform to current row
    target_uv.y += history_num;
    target_uv.y /= history_size;
    o.vpos = float4(target_uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
    return o;
}

VSOUT VS_Basic(in uint id : SV_VertexID)
{
    VSOUT o;
    o.uv.x = (id == 2) ? 2.0 : 0.0;
    o.uv.y = (id == 1) ? 2.0 : 0.0;
    o.vpos = float4(o.uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
    return o;
}

/*=============================================================================
	Functions
=============================================================================*/

float3 color_remapper(in float3 rgb)
{
	float3 hsl = Colorspace::rgb_to_hsl(rgb);

#if TONE_REMAP_SIMPLE == 1
    float3 remapped;
    remapped.r = dot(rgb, COLOR_REMAP_RED);
    remapped.g = dot(rgb, COLOR_REMAP_GREEN);
    remapped.b = dot(rgb, COLOR_REMAP_BLUE);
#else
	static const float hue_nodes[8] = {	 0.0, 1.0/12.0, 2.0/12.0, 4.0/12.0, 6.0/12.0, 8.0/12.0, 10.0/12.0, 1.0};

	float risingedges[7];
	for(int j = 0; j < 7; j++)
		risingedges[j] = linearstep(hue_nodes[j], hue_nodes[j+1], hsl.x);

	float3 remapped = 0;
	remapped += Colorspace::hsl_to_rgb(Colorspace::rgb_to_hsl(COLOR_REMAP_RED) 	   * float3(1.0, hsl.y, 2.0 * hsl.z)) * ((1.0 - risingedges[0]) + risingedges[6]); //red - yes, this needs a +
	remapped += Colorspace::hsl_to_rgb(Colorspace::rgb_to_hsl(COLOR_REMAP_ORANGE)  * float3(1.0, hsl.y, 2.0 * hsl.z)) * ((1.0 - risingedges[1]) * risingedges[0]); //orange
	remapped += Colorspace::hsl_to_rgb(Colorspace::rgb_to_hsl(COLOR_REMAP_YELLOW)  * float3(1.0, hsl.y, 2.0 * hsl.z)) * ((1.0 - risingedges[2]) * risingedges[1]); //yellow
	remapped += Colorspace::hsl_to_rgb(Colorspace::rgb_to_hsl(COLOR_REMAP_GREEN)   * float3(1.0, hsl.y, 2.0 * hsl.z)) * ((1.0 - risingedges[3]) * risingedges[2]); //green
	remapped += Colorspace::hsl_to_rgb(Colorspace::rgb_to_hsl(COLOR_REMAP_AQUA)    * float3(1.0, hsl.y, 2.0 * hsl.z)) * ((1.0 - risingedges[4]) * risingedges[3]); //aqua
	remapped += Colorspace::hsl_to_rgb(Colorspace::rgb_to_hsl(COLOR_REMAP_BLUE)    * float3(1.0, hsl.y, 2.0 * hsl.z)) * ((1.0 - risingedges[5]) * risingedges[4]); //blue
	remapped += Colorspace::hsl_to_rgb(Colorspace::rgb_to_hsl(COLOR_REMAP_MAGENTA) * float3(1.0, hsl.y, 2.0 * hsl.z)) * ((1.0 - risingedges[6]) * risingedges[5]); //magenta
    //fix white
    remapped = lerp(rgb, remapped, smoothstep(0, 1.0/255, hsl.y));
#endif
	return remapped;
}

float tonecurve(float x, float p0, float p1, float p2, float p3)
{
	//adjust parameter range to be more user friendly
	p0 *= p0 > 0 ? 0.5 : 0.5;
	p1 *= p1 > 0 ? 1 : 2.0;
	p2 *= p2 > 0 ? 4 : 1.5;	
	p3 *= p3 > 0 ? 3 : 1.0;

	float x0 = smoothstep(0.3, 0.0, x); //shadows
    float x1 = smoothstep(0.6, 0.0, x); //darks
    float x2 = smoothstep(0.35, 1.0, x); //lights
    float x3 = smoothstep(0.7, 1.0, x); //highlights

	float4 pn = float4(p0, p1, p2, p3);
	float4 xn = float4(x0, x1, x2, x3);	

	x = pow(x, exp2(dot(-pn, xn)));
	return x;
}

float3 extended_lgg( float3 x,   
					 float3 blacklevel, 
					 float3 whitelevel,
					 float3 lift,
					 float3 gamma,
					 float3 gain)
{
	x = linearstep(blacklevel, whitelevel, x);
    //https://en.wikipedia.org/wiki/ASC_CDL
    x = pow(saturate((x * gain) + lift), gamma);
	return x;
}

float3 srgb_to_linear(float3 S)
{
    return S < 0.04045 ? S / 12.92 : pow(((S + 0.055) / 1.055), 2.4);
}

float3 linear_to_srgb(float3 L)
{
    return L <= 0.0031308 ? L * 12.92 : 1.055 * pow(L, rcp(2.4)) - 0.055;
}

float3 linear_to_alexalogc(float3 L)
{
    static const float cut = 0.010591;
    static const float a = 5.555555;
    static const float b = 0.052272;
    static const float c = 0.24719;
    static const float d = 0.385537;
    static const float e = 5.367655;
    static const float f = 0.092809;

    return L > cut ? c * log10(a * L + b) + d : e * L + f;        
}

float3 alexalogc_to_linear(float3 A)
{
    static const float cut = 0.010591;
    static const float a = 5.555555;
    static const float b = 0.052272;
    static const float c = 0.24719;
    static const float d = 0.385537;
    static const float e = 5.367655;
    static const float f = 0.092809;

    float cut2 = e * cut + f;

    return A > cut2 ? (pow(10, (A - d) / c) - b) / a : (A - f) / e;
}

float3 splittone(float3 c)
{
    float3 shadows_hsl    = Colorspace::rgb_to_hsl(SPLITTONE_SHADOWS);      
    float3 highlights_hsl = Colorspace::rgb_to_hsl(SPLITTONE_HIGHLIGHTS);

    float cluma = dot(c, float3(0.299, 0.587, 0.114));

    float2 a = saturate(float2(cluma, 1 - cluma));
    a *= a;
    a *= a;
    //a *= a;
    float bal = lerp(1 - a.y, a.x, SPLITTONE_BALANCE);

    //calculate proper tints in RGB space
    float3 tintcol = lerp(SPLITTONE_SHADOWS, SPLITTONE_HIGHLIGHTS, bal);
   float3 tintedcol = c * tintcol;

    //make tint luma-preserving
    float3 tintedcol_hsl =  Colorspace::rgb_to_hsl(tintedcol);
    float3 finaltint_hsl = Colorspace::rgb_to_hsl(c);
    //change hue and saturation only, leave luma alone
    finaltint_hsl.xy = tintedcol_hsl.xy;

    return Colorspace::hsl_to_rgb(finaltint_hsl);  
}

float3 dither(in VSOUT i)
{
    const float2 magicdot = float2(0.75487766624669276, 0.569840290998);
    const float3 magicadd = float3(0, 0.025, 0.0125) * dot(magicdot, 1);
    float3 dither = frac(dot(floor(i.vpos.xy), magicdot) + magicadd);    
    return dither;
}

/*=============================================================================
	Pixel Shaders
=============================================================================*/

void PSWritePointRGBI(in VSOUTRGBI i, out float4 o : SV_Target0)
{
	o = float4(int4(0, 1, 2, 3) == i.channel.xxxx) * rcp(SUB_GRID_DIM_X * SUB_GRID_DIM_Y);
}

void PSHistogramWriteToHistoryRGBIRaw(in VSOUT i, out float4 o : SV_Target0)
{
    o = 0;
    for(int j = 0; j < THREAD_CONFLICT_RES_SIZE; j++)
        o += tex2Dlod(sHistogramTexRGBIRaw, float4(i.uv.x, (j + 0.5)/THREAD_CONFLICT_RES_SIZE,0,0));
}

void PSHistogramAverageHistoryRGBI(in VSOUT i, out float4 o : SV_Target0)
{
	o = 0;
    for(float j = 0; j < HISTORY_SIZE / 2; j++)
        o += tex2Dlod(sHistogramHistoryTexRGBI, float2(i.uv.x, (j * 2 + 1) / 64.0), 0);
	o /= HISTORY_SIZE;
}

void PSHistogramDisplayRGBI(in VSOUT i, out float4 o : SV_Target0)
{
    float4 histogram = tex2Dfetch(sHistogramTexRGBI, int2(i.vpos.x % 256, 0)).xyzw;
    histogram = log(histogram + 1) * 12;
    histogram = min(histogram, 0.3);

    float4 histogram_mask = histogram > (1.0 - i.uv.y);

    o = 0;
    switch(HISTOGRAM_MODE)
    {
        case 0:
            o = 0;
            break;
        case 1:
            o = i.vpos.x < 256 ? float4(histogram_mask.www, histogram_mask.w > 0) : 0;
            break;
        case 2:
            o = i.vpos.x < 256 ? float4(histogram_mask.rgb, any(histogram_mask.rgb > 0)) : 0;
            break;
        case 3:
            int channel = floor(i.vpos.x / 256);
            histogram_mask *= channel.xxxx == int4(0,1,2,3); //mask channel
            histogram_mask = channel == 3 ? histogram_mask.w : histogram_mask; //visualize alpha
            o = histogram_mask;
            o.w = any(histogram_mask > 0);
            break;       
    }
}

void PSReGradeMain(in VSOUT i, out float3 o : SV_Target0)
{
    float2 lutcoord = floor(i.vpos.xy);
    float3 col = float3(lutcoord.x % 32, lutcoord.y, floor(lutcoord.x / 32));   
    col = saturate(col / 31.0);

	col = color_remapper(col);
	col = Whitebalance::set_white_balance(col, INPUT_COLOR_TEMPERATURE);

    col = extended_lgg(col, INPUT_BLACK_LVL / 255.0, 
						    INPUT_WHITE_LVL / 255.0, 
						    INPUT_LIFT_COLOR - 0.5, 
						    1.0 - INPUT_GAMMA_COLOR + 0.5, 
						    INPUT_GAIN_COLOR + 0.5);

    [unroll]
    for(int c = 0; c < 3; c++)
	    col[c] = tonecurve(col[c], TONECURVE_SHADOWS, TONECURVE_DARKS, TONECURVE_LIGHTS, TONECURVE_HIGHLIGHTS);

    col = srgb_to_linear(col);
    col *= exp2(GRADE_EXPOSURE); //exposure in linear space - looks nicer and is more correct
    col = linear_to_srgb(col);
    col = saturate(col);
    float3 contrasted = col - 0.5;
    contrasted = (contrasted / (0.5 + abs(contrasted))) + 0.5; //CJ.dk
    col = lerp(col, contrasted, GRADE_CONTRAST);

    col = Colorspace::rgb_to_hsl(col);
    col.y = pow(abs(col.y), exp2(-GRADE_VIBRANCE)) * (GRADE_SATURATION + 1.0);
    col = Colorspace::hsl_to_rgb(col);
    col = splittone(col);

	o = col;
}

void PSLutApply(in VSOUT i, out float3 o : SV_Target0)
{
    float3 col = tex2D(ColorInput, i.uv).rgb;
    const float2 lutsize = tex2Dsize(sLUTInternal);
    float3 lutvolumecoord = col * (lutsize.y - 1);

    float4 lutslicecoords;
    lutslicecoords.yw = lutvolumecoord.y;
    lutslicecoords.xz = floor(lutvolumecoord.z) * lutsize.y + float2(lutvolumecoord.x, lutvolumecoord.x + lutsize.y);
    lutslicecoords = (lutslicecoords + 0.5) * rcp(lutsize).xyxy;

    o = lerp(tex2D(sLUTInternal, lutslicecoords.xy).rgb, 
             tex2D(sLUTInternal, lutslicecoords.zw).rgb, 
             frac(lutvolumecoord.z));
}

/*=============================================================================
	Techniques
=============================================================================*/

technique qUINT_ReGrade
{
	pass
	{
		VertexShader = VS_Basic;
		PixelShader = PSReGradeMain;
        RenderTarget = LUTInternal;
	}
	pass
	{
		VertexShader = VS_Basic;
		PixelShader = PSLutApply;
	}    
    pass
	{
		VertexShader = VS_HistogramGenRGBIRaw;
		PixelShader = PSWritePointRGBI;
		RenderTarget = HistogramTexRGBIRaw;
		PrimitiveTopology = POINTLIST;
		VertexCount = SUB_GRID_DIM_X * SUB_GRID_DIM_Y * 4; //RGBI
		ClearRenderTargets = true; 
		BlendEnable = true; 
		SrcBlend = ONE; 
		DestBlend = ONE;
		SrcBlendAlpha = ONE;
		DestBlendAlpha = ONE;
    }
    pass
	{
		VertexShader = VS_HistogramHistory;
		PixelShader = PSHistogramWriteToHistoryRGBIRaw;
		RenderTarget = HistogramHistoryTexRGBI;
		ClearRenderTargets = false; //should be true by default but you never know...
									//set to true to see how each line is written
	}
    pass
	{
		VertexShader = VS_Basic;
		PixelShader = PSHistogramAverageHistoryRGBI;
		RenderTarget = HistogramTexRGBI;
	}
	pass
	{
		VertexShader = VS_Basic;
		PixelShader = PSHistogramDisplayRGBI;
        BlendEnable = true; 
		SrcBlend = SRCALPHA; 
		DestBlend = INVSRCALPHA;
	}
}
