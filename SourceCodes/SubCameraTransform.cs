using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SubCameraTransform : MonoBehaviour {
    [SerializeField] private GameObject mainCamera;
	
	// Update is called once per frame
	void LateUpdate () {
        Vector3 v = mainCamera.transform.position;
        v.y = -v.y;
        this.gameObject.transform.position = v;
        Vector3 q = mainCamera.transform.localEulerAngles;
        q.x = -q.x;
        this.gameObject.transform.localEulerAngles = q;
	}
}
