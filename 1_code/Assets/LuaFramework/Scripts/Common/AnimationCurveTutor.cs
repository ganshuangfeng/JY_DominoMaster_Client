using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationCurveTutor : MonoBehaviour
{
    [SerializeField]
    public List<string> curveName;
    [SerializeField]
    public List<AnimationCurve> curve;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public AnimationCurve GetAnimationCurve(string name){
        for (int i = 0; i < curveName.Count; i++)
        {
            if(curveName[i] == name){
                return curve[i];
            }
        }
        return null;
    }
}
