using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ImageFadeEffect : MonoBehaviour
{
    public bool inEffect = true;
    
    private Material material;
    private float tick;
    private int factor;
    void Awake()
    {
        tick = -0.1f;
        factor = 1;
        material = GetComponent<Image>().material;
        if (inEffect)
            material.SetFloat("_InOut", 0);
        else
            material.SetFloat("_InOut", 1);
    }

    void Update()
    {
        tick += Time.deltaTime * factor;
        if (tick >= 1.5f)
        {
            tick = 1.5f;
            factor = -1;
        }
        else if (tick <= -0.1f)
        {
            tick = -0.1f;
            factor = 1;
        }

        material.SetFloat("_Offset", tick);
    }

}
