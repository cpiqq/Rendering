using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScaleTransformation : Transformation
{
    public override Matrix4x4 Matrix {
			get {
			Matrix4x4 matrix = new Matrix4x4();
			matrix.SetRow(0, new Vector4(scale.x, 0f, 0f, 0f));
			matrix.SetRow(1, new Vector4(0f, scale.y, 0f, 0f));
			matrix.SetRow(2, new Vector4(0f, 0f, scale.z, 0f));
			matrix.SetRow(3, new Vector4(0f, 0f, 0f, 1f));
			return matrix;
		}
	}
    public Vector3 scale = Vector3.one;

    //only adjusting the positions of our grid points, so scaling won't change the size of their visualizations
    //如果和 PositionTransformation 会发现 , 缩放会影响位移，这是因为 PositionTransformation 和 ScaleTransformation 组件挂的顺序决定的，
    //如果ScaleTransformation 在上， PositionTransformation 在下，也就是先缩放后位移，就对了。

}
