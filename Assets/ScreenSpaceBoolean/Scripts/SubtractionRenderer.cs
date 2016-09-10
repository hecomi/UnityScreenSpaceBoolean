using UnityEngine;
using UnityEngine.Rendering;
using System.Collections.Generic;

namespace ScreenSpaceBoolean
{

public class CustomRendererInfo
{
    public CommandBuffer cb;
    public CameraEvent pass;
    public CustomRendererInfo(CommandBuffer cb, CameraEvent pass)
    {
        this.cb = cb;
        this.pass = pass;
    }
}

[ExecuteInEditMode]
public class SubtractionRenderer : MonoBehaviour
{
    private Dictionary<Camera, CustomRendererInfo> cameras_
        = new Dictionary<Camera, CustomRendererInfo>();

    private Mesh quad_;
    private Mesh quad
    {
        get { return quad_ ?? (quad_ = GenerateQuad()); }
    }

    [SerializeField] Material compositeMaterial;
    [SerializeField, Range(1, 2)] int maskDrawNum = 1;

    Mesh GenerateQuad()
    {
        var mesh = new Mesh();
        mesh.vertices = new Vector3[4] {
            new Vector3( 1.0f , 1.0f,  0.0f),
            new Vector3(-1.0f , 1.0f,  0.0f),
            new Vector3(-1.0f ,-1.0f,  0.0f),
            new Vector3( 1.0f ,-1.0f,  0.0f),
        };
        mesh.triangles = new int[6] { 0, 1, 2, 2, 3, 0 };
        return mesh;
    }

    void CleanUp()
    {
        foreach (var pair in cameras_) {
            var camera = pair.Key;
            if (camera) {
                var info = pair.Value;
                var cb = info.cb;
                var pass = info.pass;
                camera.RemoveCommandBuffer(pass, cb);
            }
        }
        cameras_.Clear();
    }

    void OnEnable()
    {
        CleanUp();
    }

    void OnDisable()
    {
        CleanUp();
    }

    void OnWillRenderObject()
    {
        AddCommandBuffer();
        UpdateCommandBuffer();
    }

    void AddCommandBuffer()
    {
        var active = gameObject.activeInHierarchy && enabled;
        if (!active) {
            OnDisable();
            return;
        }

        var camera = Camera.current;
        if (!camera) return;

        if (cameras_.ContainsKey(camera)) return;

        var cb = new CommandBuffer();
        var pass = CameraEvent.BeforeGBuffer;
        cb.name = "ScreenSpaceBooleanRenderer";
        camera.AddCommandBuffer(pass, cb);
        cameras_.Add(camera, new CustomRendererInfo(cb, pass));
    }

    void UpdateCommandBuffer()
    {
        var camera = Camera.current;
        if (!cameras_.ContainsKey(camera)) return;

        if (!compositeMaterial) return;

        var renderer = cameras_[camera];
        var cb = renderer.cb;
        cb.Clear();

        IssueDrawBackDepth(cb);
        IssueComposite(cb);
    }

    void IssueDrawBackDepth(CommandBuffer cb)
    {
        var id = Shader.PropertyToID("SubtracteeBackDepth");

        cb.GetTemporaryRT(id, -1, -1, 24, FilterMode.Point, RenderTextureFormat.Depth);
        cb.SetRenderTarget(id);
        cb.ClearRenderTarget(true, true, Color.black, 0f);

        foreach (var subtractee in Subtractee.GetAll()) {
            subtractee.IssueDrawBack(cb);
        }

        cb.SetGlobalTexture("_SubtracteeBackDepth", id);
    }

    void IssueComposite(CommandBuffer cb)
    {
        var id = Shader.PropertyToID("SubtractionDepth");

        cb.GetTemporaryRT(id, -1, -1, 24, FilterMode.Point, RenderTextureFormat.Depth);
        cb.SetRenderTarget(id);
        cb.ClearRenderTarget(true, true, Color.black, 1f);

        foreach (var subtractee in Subtractee.GetAll()) {
            subtractee.IssueDrawFront(cb);
        }

        for (int i = 0; i < maskDrawNum; ++i) {
            foreach (var subtractor in Subtractor.GetAll()) {
                subtractor.IssueDrawMask(cb);
            }
        }

        cb.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        cb.SetGlobalTexture("_SubtractionDepth", id);
        cb.DrawMesh(quad, Matrix4x4.identity, compositeMaterial);
    }
}

}