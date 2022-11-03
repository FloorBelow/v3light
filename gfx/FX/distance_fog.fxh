Includes = {
	"cw/camera.fxh"
	"cw/utility.fxh"
	"cw/random.fxh"
	"jomini/jomini.fxh"
	"sharedconstants.fxh"
}

Code
[[
	float GameCalculateDistanceFogFactor( float3 WorldSpacePos )
	{
		// Offset towards camera look direction
		float Scalar = CameraPosition.y / -CameraLookAtDir.y;
		float3 IntersectionPoint = CameraPosition + Scalar * CameraLookAtDir;
		IntersectionPoint.y = 1.7f; //water height

		// Rotate and scale with view
		float ScalingX = 1.6f;	
		float ScalingY = 1.0f + 1.0f * ( 1.0f + CameraLookAtDir.y );
		float2 secondaryPrincipal = float2( CameraRightDir.z, -CameraRightDir.x );
		float3 Diff = IntersectionPoint - WorldSpacePos; //vector from start of fog to point
		Diff.xz = float2( dot( Diff.xz, CameraRightDir.xz ) * ( 1.0 / ScalingX ), dot( Diff.xz, secondaryPrincipal ) * ( 1.0 / ScalingY ) );

		// Fog factor (amount) 
		float3 DiffExtendo = float3(abs(Diff.x) + 80.0f, abs(Diff.y) * FogMax, abs(Diff.z) + 80.0f);
		float vFogFactor = 1.0 - normalize(DiffExtendo).y; // abs b/c of reflections
		vFogFactor = vFogFactor * vFogFactor;
		float vMin = min( length(Diff)/FogEnd2 * (1 - FogBegin2) + FogBegin2, 1);
		return saturate( vMin * vFogFactor );
	}

	float3 GameCalculateDistanceFogColor( float3 WorldSpacePos )
	{
		float3 Diff = WorldSpacePos - CameraPosition; //vector from start of fog to point
		float FogColorFactor = saturate((dot(normalize(Diff), ToSunDir) + 1) / 2);
		FogColorFactor = FogColorFactor * FogColorFactor * 0.8f;
		return lerp(FogColor, SunDiffuse, FogColorFactor);
	}

	float3 GameApplyDistanceFog( float3 Color, float3 WorldSpacePos )
	{	
		float factor = GameCalculateDistanceFogFactor( WorldSpacePos );
		float3 fogColor = GameCalculateDistanceFogColor(WorldSpacePos);
		return lerp( Color, fogColor, factor );
	}
	float GameApplyDistanceFog( float Value, float3 WorldSpacePos )
	{
		float factor = GameCalculateDistanceFogFactor( WorldSpacePos ) ;
		
		float FogValue_ = ( FogColor.x + FogColor.y + FogColor.z ) / 3;
		FogValue_ = HardLight( Value, FogValue_ );

		return lerp( Value, FogValue_, factor );
	}
]]