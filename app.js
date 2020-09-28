requirejs.config({
  paths: {
    "Vue": "lib/vue@2.5.17",
    "v@": "lib/require-vuejs",
    "layui": "lib/layui/layui",
    "text": "lib/require-text",
    "json": "lib/require-json",
    "underscore": "lib/underscore-min",
    "vue-router": "lib/vue-router@3.0.1",
    "common": "common/common",
    "api": "common/api",
    "uRouter": "common/router",
    "three": "lib/three.js/build/three.min",
    "OrbitControls": "lib/three.js/examples/js/controls/OrbitControls",
    "DRACOLoader": "lib/three.js/examples/js/loaders/DRACOLoader",
    "RGBELoader": "lib/three.js/examples/js/loaders/RGBELoader",
    "EquirectangularToCubeGenerator": "lib/three.js/examples/js/loaders/EquirectangularToCubeGenerator",
    "PMREMGenerator": "lib/three.js/examples/js/pmrem/PMREMGenerator",
    "PMREMCubeUVPacker": "lib/three.js/examples/js/pmrem/PMREMCubeUVPacker",
    "GLTFLoader": "lib/three.js/examples/js/loaders/GLTFLoader",
    "CopyShader": "lib/three.js/examples/js/shaders/CopyShader",
    "AfterimageShader": "lib/three.js/examples/js/shaders/AfterimageShader",
    "ShaderPass": "lib/three.js/examples/js/postprocessing/ShaderPass",
    "RenderPass": "lib/three.js/examples/js/postprocessing/RenderPass",
    "FXAAShader": "lib/three.js/examples/js/shaders/FXAAShader",
    "SSAARenderPass": "lib/three.js/examples/js/postprocessing/SSAARenderPass",
    "AfterimagePass": "lib/three.js/examples/js/postprocessing/AfterimagePass",
    "EffectComposer": "lib/three.js/examples/js/postprocessing/EffectComposer",
    "Water": "lib/three.js/examples/js/objects/Water"
  },
  shim: {
    "Vue": {
      "exports": "Vue"
    },
    "OrbitControls": {
      deps: ["three"]
    },
    "CopyShader": {
      deps: ["three", "EffectComposer"]
    },
    "ShaderPass": {
      deps: ["three", "EffectComposer"]
    },
    "SSAARenderPass": {
      deps: ["three", "EffectComposer"]
    },
    "AfterimagePass": {
      deps: ["three", "EffectComposer", "AfterimageShader"]
    },
    "FXAAShader": {
      deps: ["three", "EffectComposer"]
    },
    "RenderPass": {
      deps: ["three", "EffectComposer"]
    },
    "layui": {
      exports: "layui"
    }
  }
});

require([
  "Vue", "vue-router", 
  "uRouter", "common", 
  "json!../setting.json", 
  "three", "layui"
], function (Vue, VueRouter, uRouter, com, setting, THREE, layui) {

  window.THREE = THREE

  layui.use(["layer", "element"])

  Vue.use(VueRouter);

  // 初始化
  var tvue = new Vue({
    data: {
      menu: setting.menu,
      selected: 0
    },
    router: uRouter
  }).$mount('#app');


  //挂载到 WINDOWS
  window.tvue = tvue
});
