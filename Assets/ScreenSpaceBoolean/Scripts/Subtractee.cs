using UnityEngine;
using UnityEngine.Rendering;
using System.Collections.Generic;

namespace ScreenSpaceBoolean
{

[ExecuteInEditMode]
public class Subtractee : MonoBehaviour
{
    [SerializeField] Material depthMaterial;
    [SerializeField] int frontDepthPass = 0;
    [SerializeField] int backDepthPass = 1;

    static public HashSet<Subtractee> instances = new HashSet<Subtractee>();

    void OnEnable()
    {
        instances.Add(this);
    }

    void OnDisable()
    {
        instances.Remove(this);
    }

    static public HashSet<Subtractee> GetAll()
    {
        return instances;
    }

    public void IssueDrawFront(CommandBuffer cb)
    {
        if (depthMaterial) {
            cb.DrawRenderer(GetComponent<Renderer>(), depthMaterial, 0, frontDepthPass);
        }
    }

    public void IssueDrawBack(CommandBuffer cb)
    {
        if (depthMaterial) {
            cb.DrawRenderer(GetComponent<Renderer>(), depthMaterial, 0, backDepthPass);
        }
    }
}

}