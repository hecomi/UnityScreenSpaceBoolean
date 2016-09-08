using UnityEngine;
using UnityEngine.Rendering;
using System.Collections.Generic;

namespace ScreenSpaceBoolean
{

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class Subtractor : MonoBehaviour
{
    [SerializeField] Material maskMaterial;
    [SerializeField] int stencilMaskPass = 0;
    [SerializeField] int depthWithMaskPass = 1;
    [SerializeField] int clearDepthPass = 2;
    [SerializeField] int clearStencilPass = 3;

    static public HashSet<Subtractor> instances = new HashSet<Subtractor>();

    void OnEnable()
    {
        instances.Add(this);
    }

    void OnDisable()
    {
        instances.Remove(this);
    }

    static public HashSet<Subtractor> GetAll()
    {
        return instances;
    }

    public void IssueDrawMask(CommandBuffer cb)
    {
        if (maskMaterial) {
            var renderer = GetComponent<Renderer>();
            cb.DrawRenderer(renderer, maskMaterial, 0, stencilMaskPass);
            cb.DrawRenderer(renderer, maskMaterial, 0, depthWithMaskPass);
            cb.DrawRenderer(renderer, maskMaterial, 0, clearDepthPass);
            cb.DrawRenderer(renderer, maskMaterial, 0, clearStencilPass);
        }
    }
}

}