using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


//思路： 
//1. Awake 里生成 gridResolution * gridResolution * gridResolution 个 cube .
//2. 以世界原点为中心，GetCoordinates 计算 所有cube 的位置， 组成一个大的cube .
//3. Transformation 是变换基类，他的子类（位移，旋转，缩放） 挂在 TransformationGrid 上。
//4. update 里获取所有变换组件，放入 transformations , 并对每个cube 的 localPosition 修改 TransformPoint() ->（Apply）.
public class TransformationGrid : MonoBehaviour
{
   public Transform prefab;
   
   	public int gridResolution = 10;
   
   	Transform[] grid;
    
    List<Transformation> transformations;
   	Matrix4x4 transformation;
   	void Awake () {
	    transformations = new List<Transformation>();
	    
   		grid = new Transform[gridResolution * gridResolution * gridResolution];
   		for (int i = 0, z = 0; z < gridResolution; z++) {
   			for (int y = 0; y < gridResolution; y++) {
   				for (int x = 0; x < gridResolution; x++, i++) {
   					grid[i] = CreateGridPoint(x, y, z);
   				}
   			}
   		}
   	}
    
    Transform CreateGridPoint (int x, int y, int z) {
	    Transform point = Instantiate<Transform>(prefab);
	    point.localPosition = GetCoordinates(x, y, z);
	    point.GetComponent<MeshRenderer>().material.color = new Color(
		    (float)x / gridResolution,
		    (float)y / gridResolution,
		    (float)z / gridResolution
	    );
	    return point;
    }
    //We center it at the origin, so transformations – specifically rotation and scaling – are relative to the midpoint of the grid cube.
    Vector3 GetCoordinates (int x, int y, int z) {
	    return new Vector3(
		    x - (gridResolution - 1) * 0.5f,
		    y - (gridResolution - 1) * 0.5f,
		    z - (gridResolution - 1) * 0.5f
	    );
    }

    private void Update()
    {
	    UpdateTransformation();
	    for (int i = 0, z = 0; z < gridResolution; z++) {
		    for (int y = 0; y < gridResolution; y++) {
			    for (int x = 0; x < gridResolution; x++, i++) {
				    grid[i].localPosition = TransformPoint(x, y, z);
			    }
		    }
	    }
    }
    void UpdateTransformation () {
		 //这里 transformations 不用数组的原因是，
	    //GetComponents 的一个版本是返回数组，这里相当于每次 update 都新创建一个数组返回。
	    //而另一个版本的 GetComponents 传入一个list参数，把所有组件放入list,不会新建 list . update 里显然list 更合适。
		GetComponents<Transformation>(transformations);
		if (transformations.Count > 0) {
			transformation = transformations[0].Matrix;
			for (int i = 1; i < transformations.Count; i++) {
				transformation = transformations[i].Matrix * transformation;
			}
		}
	}

    Vector3 TransformPoint (int x, int y, int z) {
	    Vector3 coordinates = GetCoordinates(x, y, z);
	    return transformation.MultiplyPoint(coordinates);
    }
    
    
    
    
}
