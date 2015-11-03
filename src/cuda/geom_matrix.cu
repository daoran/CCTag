#include "geom_matrix.h"

using namespace std;

namespace popart {
namespace geometry {

__host__ __device__
matrix3x3::matrix3x3( const float mx[3][3] )
{
    #pragma unroll
    for( int i=0; i<3; i++ ) {
        #pragma unroll
        for( int j=0; j<3; j++ ) {
            val[i][j] = mx[i][j];
        }
    }
}

__host__ __device__
void matrix3x3::setDiag( float v00, float v11, float v22 )
{
    clear();
    val[0][0] = v00;
    val[1][1] = v11;
    val[2][2] = v22;
}

__host__ __device__
void matrix3x3::clear( )
{
    #pragma unroll
    for( int i=0; i<3; i++ ) {
        #pragma unroll
        for( int j=0; j<3; j++ ) {
            val[i][j] = 0;
        }
    }
}

__host__ __device__
float matrix3x3::det( ) const
{
    float det =  val[0][0] * ( val[1][1] * val[2][2] - val[2][1] * val[1][2] )
               - val[0][1] * ( val[1][0] * val[2][2] - val[1][2] * val[2][0] )
               + val[0][2] * ( val[1][0] * val[2][1] - val[1][1] * val[2][0] ) ;

    return det;
}

__host__ __device__
bool matrix3x3::invert( matrix3x3& result ) const
{
    float determinant = det( );

    if( determinant == 0.0f )
    {
        return false;
    }

    result(0,0) = (  val[1][1] * val[2][2] - val[1][2] * val[2][1] ) / determinant;
    result(1,0) = ( -val[1][0] * val[2][2] + val[2][0] * val[1][2] ) / determinant;
    result(2,0) = (  val[1][0] * val[2][1] - val[2][0] * val[1][1] ) / determinant;
    result(0,1) = ( -val[0][1] * val[2][2] + val[2][1] * val[0][2] ) / determinant;
    result(1,1) = (  val[0][0] * val[2][2] - val[2][0] * val[0][2] ) / determinant;
    result(2,1) = ( -val[0][0] * val[2][1] + val[2][0] * val[0][1] ) / determinant;
    result(0,2) = (  val[0][1] * val[1][2] - val[1][1] * val[0][2] ) / determinant;
    result(1,2) = ( -val[0][0] * val[1][2] + val[1][0] * val[0][2] ) / determinant;
    result(2,2) = (  val[0][0] * val[1][1] - val[1][0] * val[0][1] ) / determinant;
    return true;
}

__device__
float2 matrix3x3::applyHomography( const float2& vec ) const
{
    float u = val[0][0]*vec.x + val[0][1]*vec.y + val[0][2];
    float v = val[1][0]*vec.x + val[1][1]*vec.y + val[1][2];
    float w = val[2][0]*vec.x + val[2][1]*vec.y + val[2][2];
    float2 result; //  = make_float2( u/w, v/w );
    result.x = u/w;
    result.y = v/w;
    return result;
}

__device__
float2 matrix3x3::applyHomography( float x, float y ) const
{
    float u = val[0][0]*x + val[0][1]*y + val[0][2];
    float v = val[1][0]*x + val[1][1]*y + val[1][2];
    float w = val[2][0]*x + val[2][1]*y + val[2][2];
    float2 result; //  = make_float2( u/w, v/w );
    result.x = u/w;
    result.y = v/w;
    return result;
}

__host__ __device__
matrix3x3 prod( const matrix3x3& l, const matrix3x3& r )
{
    matrix3x3 result;
    #pragma unroll
    for( int y=0; y<3; y++ ) {
        #pragma unroll
        for( int x=0; x<3; x++ ) {
            result(y,x) = l(y,0)*r(0,x) + l(y,1)*r(1,x) + l(y,2)*r(2,x);
        }
    }
    return result;
}

__host__ __device__
matrix3x3 prod( const matrix3x3_tView& l, const matrix3x3& r )
{
    matrix3x3 result;
    #pragma unroll
    for( int y=0; y<3; y++ ) {
        #pragma unroll
        for( int x=0; x<3; x++ ) {
            result(y,x) = l(y,0)*r(0,x) + l(y,1)*r(1,x) + l(y,2)*r(2,x);
        }
    }
    return result;
}

__host__ __device__
matrix3x3 prod( const matrix3x3& l, const matrix3x3_tView& r )
{
    matrix3x3 result;
    #pragma unroll
    for( int y=0; y<3; y++ ) {
        #pragma unroll
        for( int x=0; x<3; x++ ) {
            result(y,x) = l(y,0)*r(0,x) + l(y,1)*r(1,x) + l(y,2)*r(2,x);
        }
    }
    return result;
}

}; // namespace geometry
}; // namespace popart
