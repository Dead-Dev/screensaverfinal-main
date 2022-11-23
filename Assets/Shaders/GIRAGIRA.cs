using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GIRAGIRA : MonoBehaviour
{   
    
    public Vector3 RotateAmount;

    // Update is called once per frame
    void Update()
    {
	transform.Rotate(RotateAmount);
    }
}
