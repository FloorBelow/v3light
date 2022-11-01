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
		float3 FogOffset = CameraLookAtDir * ( FogCloseOffset + FogFarOffset * saturate( smoothstep(0.0f, 600.0f, CameraPosition.y ) ) );
		FogOffset.y = 0.0f;	// Don't offset height

		// Rotate and scale with view
		float ScalingX = FogWidthScale;	
		float ScalingY = 1.0f + 1.0f * ( 1.0f + CameraLookAtDir.y );
		float2 secondaryPrincipal = float2( CameraRightDir.z, -CameraRightDir.x );
		float3 Diff = ( IntersectionPoint + FogOffset ) - WorldSpacePos;
		Diff.xz = float2( dot( Diff.xz, CameraRightDir.xz ) * ( 1.0 / ScalingX ), dot( Diff.xz, secondaryPrincipal ) * ( 1.0 / ScalingY ) );

		// Fog factor (amount)
		float vFogFactor = 1.0 - abs( normalize( Diff ).y ); // abs b/c of reflections
		float vSqDistance = dot( Diff, Diff );
		float vMin = ( vSqDistance - FogBegin2 ) / ( FogEnd2 - FogBegin2 );
		return saturate( vMin * vFogFactor * FogMax );
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
		return lerp( Color, HardLight( Color, fogColor ), factor );
	}
	float GameApplyDistanceFog( float Value, float3 WorldSpacePos )
	{
		float factor = GameCalculateDistanceFogFactor( WorldSpacePos ) ;
		
		float FogValue_ = ( FogColor.x + FogColor.y + FogColor.z ) / 3;
		FogValue_ = HardLight( Value, FogValue_ );

		return lerp( Value, FogValue_, factor );
	}
]]