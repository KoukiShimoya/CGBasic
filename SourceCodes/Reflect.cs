﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class Reflect : MonoBehaviour {
    [SerializeField]
    private Camera reflectCamera;

    private new Renderer renderer;
    private Material sharedMaterial;

    private readonly int ShaderPropertyReflectTex = Shader.PropertyToID("_RefTex");
    //ユニークなシェーダーIDを取得する

    private void Start()
    {
        //反射用カメラにスクリーンと同サイズのバッファを設定し、反射用テクスチャとしてマテリアルにセットする
        renderer = GetComponent<Renderer>();
        sharedMaterial = renderer.sharedMaterial;
        reflectCamera.targetTexture = new RenderTexture(Screen.width, Screen.height, 16);
        sharedMaterial.SetTexture(ShaderPropertyReflectTex, reflectCamera.targetTexture);
    }

    private void OnWillRenderObject()
    {
        var cam = Camera.current;
        if (cam == reflectCamera)
        {
            //反射用カメラの変換行列をマテリアルにセット
            var refVMatrix = cam.worldToCameraMatrix;
            var refPMatrix = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false);
            var refVP = refPMatrix * refVMatrix;
            var refW = renderer.localToWorldMatrix;
            sharedMaterial.SetMatrix("_RefVP", refVP);
            sharedMaterial.SetMatrix("_RefW", refW);

            if (Screen.width != reflectCamera.targetTexture.width || Screen.height != reflectCamera.targetTexture.height)
            {
                reflectCamera.targetTexture = new RenderTexture(Screen.width, Screen.height, 16);
                sharedMaterial.SetTexture(ShaderPropertyReflectTex, reflectCamera.targetTexture);
            }

            if (!Application.isPlaying && sharedMaterial.GetTexture(ShaderPropertyReflectTex) == null)
            {
                sharedMaterial.SetTexture(ShaderPropertyReflectTex, reflectCamera.targetTexture);
            }
        }
    }
}
