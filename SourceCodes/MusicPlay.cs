using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicPlay : MonoBehaviour {

	// Use this for initialization
	void Start () {
        AudioSource audioSource = this.gameObject.GetComponent<AudioSource>();
        audioSource.time = 18f;
	}
}
