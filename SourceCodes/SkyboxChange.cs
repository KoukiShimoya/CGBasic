using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SkyboxChange : MonoBehaviour {
    [SerializeField] private float speedMultiplier;
    [SerializeField] private Material blueSkyBox;
    [SerializeField] private Material orangeSkyBox;
    [SerializeField] private Material blackSkyBox;

    bool isRotate;
    private void Start()
    {
        RenderSettings.skybox = blueSkyBox;
        isRotate = true;
        StartCoroutine(ChangeCoroutine());
    }

    private void Update()
    {
        if (isRotate)
        {
            RenderSettings.skybox.SetFloat("_Rotation", Time.time * speedMultiplier);
        }
    }

    IEnumerator ChangeCoroutine()
    {
        yield return new WaitForSeconds(20f);
        RenderSettings.skybox = orangeSkyBox;
        yield return new WaitForSeconds(20f);
        RenderSettings.skybox = blackSkyBox;
        RenderSettings.skybox.SetFloat("_Rotation", 0f);
        isRotate = false;
        Camera.main.GetComponent<SnowFlow>().enabled = true;
        yield break;
    }
}
