using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//空间变换基类
public abstract class Transformation : MonoBehaviour
{
    public abstract Matrix4x4 Matrix { get; }

    public Vector3 Apply (Vector3 point){
        return Matrix.MultiplyPoint(point);
    }
}
