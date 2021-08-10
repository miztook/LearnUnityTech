using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using System;



[CustomEditor(typeof(EditorTestFiled))]
public class EditorTestInspector : Editor {

 
    EditorTestFiled _Target;
    SerializedObject _ExtTarget;
    static int[] copyiedPriorities;
    TestExt _Ext;
    bool IsHide = false;
 

    SerializedProperty m_IntProp1;
    SerializedProperty m_VectorProp1;
    SerializedProperty m_GameObjectProp1;
    SerializedProperty m_IntProp2;
    SerializedProperty m_VectorProp2;
    SerializedProperty m_GameObjectProp2;
    SerializedProperty m_IntProp3;
    SerializedProperty m_VectorProp3;
    SerializedProperty m_GameObjectProp3;

    void OnEnable()
    {
        _Target = serializedObject.targetObject as EditorTestFiled;
        _Ext = _Target.gameObject.GetComponent<TestExt>();
        //_Target._GlobalLight = _Ext._GlobalLight;
        //_Target._PlayerLight = _Ext._PlayerLight;
        //_Target._SunComponent = _Ext._SunComponent;
        //_Target._SkyComponet = _Ext._SkyComponet; 
        //_Target._SkyBoxSphere = _Ext.SkyBox;
        //_Target._SkyBoxSphereEx = _Ext.SkyBoxEx;
        //_Target._HostPlayer = _Ext.HostPlayer;
         _ExtTarget  =new SerializedObject(_Ext);
         m_IntProp1 = _ExtTarget.FindProperty("m_IntProp1");
         m_VectorProp1 = _ExtTarget.FindProperty("m_VectorProp1");
         m_GameObjectProp1 = _ExtTarget.FindProperty("m_GameObjectProp1");

         m_IntProp2 = _ExtTarget.FindProperty("m_IntProp2");
         m_VectorProp2 = _ExtTarget.FindProperty("m_VectorProp2");
         m_GameObjectProp2 = _ExtTarget.FindProperty("m_GameObjectProp2");

         m_IntProp3 = _ExtTarget.FindProperty("m_IntProp3");
         m_VectorProp3 = _ExtTarget.FindProperty("m_VectorProp3");
         m_GameObjectProp3 = _ExtTarget.FindProperty("m_GameObjectProp3");
      
    }


    Vector2 scroll1;
    Vector2 scroll2;
    Vector2 scroll3;
    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        //_Target._CurrentPrefab = EditorGUILayout.ObjectField("Gameobject挂载测试", _Target._CurrentPrefab,typeof(GameObject),false) as GameObject;
        //EditorGUIUtility.ExitGUI();
       
        _Target.LerpTime = EditorGUILayout.IntField("Int测试1", _Target.LerpTime);
        _Target.isDebug = EditorGUILayout.Toggle("Toggele测试", _Target.isDebug);
        _Target.DebugLerp = EditorGUILayout.Slider("slider测试",_Target.DebugLerp, 0, 1);
        _Target._StartEffectID = EditorGUILayout.IntField("Int测试2", _Target._StartEffectID);
        _Target._EndEffectID = EditorGUILayout.IntField("Int测试3", _Target._EndEffectID);
        _Target.vec1 = EditorGUILayout.Vector3Field("vector3测试1", _Target.vec1);
        _Target.vec2 = EditorGUILayout.Vector3Field("vector3测试2", _Target.vec2);
        _Target.vec3 = EditorGUILayout.Vector3Field("vector3测试3", _Target.vec3);

        _Target.vec4 = EditorGUILayout.Vector2Field("vector2测试1", _Target.vec4);
        _Target.vec5 = EditorGUILayout.Vector2Field("vector2测试2", _Target.vec5);
        _Target.vec6 = EditorGUILayout.Vector2Field("vector2测试3", _Target.vec6);

        _Target.vec7 = EditorGUILayout.Vector4Field("vector4测试1", _Target.vec7);
        _Target.vec8 = EditorGUILayout.Vector4Field("vector4测试2", _Target.vec8);
        _Target.vec9 = EditorGUILayout.Vector4Field("vector4测试3", _Target.vec9);

        _Target.str1 = EditorGUILayout.TextField("TextFeild测试1", _Target.str1);
        _Target.str2 = EditorGUILayout.TextField("TextFeild测试2", _Target.str2);
        _Target.str3 = EditorGUILayout.TextField("TextFeild测试3", _Target.str3);

        EditorGUILayout.HelpBox("Text Area 测试 1", MessageType.Info);
        scroll1 = EditorGUILayout.BeginScrollView(scroll1);
        _Target.str4 = EditorGUILayout.TextArea( _Target.str4,EditorStyles.textArea);
        EditorGUILayout.EndScrollView();
        EditorGUILayout.HelpBox("Text Area 测试 2", MessageType.Info);
        scroll2 = EditorGUILayout.BeginScrollView(scroll2);
        _Target.str5 = EditorGUILayout.TextArea(_Target.str5, EditorStyles.textArea);
        EditorGUILayout.EndScrollView();
        EditorGUILayout.HelpBox("Text Area 测试 3", MessageType.Info);
        scroll3 = EditorGUILayout.BeginScrollView(scroll3);
        _Target.str6 = EditorGUILayout.TextArea(_Target.str6, EditorStyles.textArea);
        EditorGUILayout.EndScrollView();
  


        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("按钮测试1"))
        {
            _Target.ShowRegion();
        }
        if (GUILayout.Button("按钮测试2"))
        {
            _Target.HideRgion();
        }
        EditorGUILayout.EndHorizontal();
        IsHide = EditorGUILayout.Toggle("显隐测试", IsHide);
        EditorGUI.BeginDisabledGroup(IsHide);
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("按钮测试3"))
        {
            _Target.Test3();
        }
        if (GUILayout.Button("按钮测试4"))
        {
            _Target.Test4();
        }
        EditorGUILayout.EndHorizontal();
        EditorGUI.EndDisabledGroup();


        EditorGUILayout.PropertyField(m_IntProp1, new GUIContent("PropertyField Int Feild测试1"), GUILayout.Height(20));
        EditorGUILayout.PropertyField(m_VectorProp1, new GUIContent("PropertyField  Vector Object 测试1"));
        EditorGUILayout.PropertyField(m_GameObjectProp1, new GUIContent("PropertyField Game Object 测试1"));

        EditorGUILayout.PropertyField(m_IntProp2, new GUIContent("PropertyField Int Feild测试1"), GUILayout.Height(20));
        EditorGUILayout.PropertyField(m_VectorProp2, new GUIContent("PropertyField  Vector Object 测试1"));
        EditorGUILayout.PropertyField(m_GameObjectProp2, new GUIContent("PropertyField Game Object 测试1"));

        EditorGUILayout.PropertyField(m_IntProp3, new GUIContent("PropertyField Int Feild测试1"), GUILayout.Height(20));
        EditorGUILayout.PropertyField(m_VectorProp3, new GUIContent("PropertyField  Vector Object 测试1"));
        EditorGUILayout.PropertyField(m_GameObjectProp3, new GUIContent("PropertyField Game Object 测试1"));
        // Apply changes to the serializedProperty - always do this at the end of OnInspectorGUI.

        _ExtTarget.ApplyModifiedProperties();
        serializedObject.ApplyModifiedProperties();
    }

    void Stop()
    {
         
    }


    public static string sceneName = string.Empty;
   
    
}
