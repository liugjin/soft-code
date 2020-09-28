define([
  'underscore', "three", "OrbitControls", "CopyShader", "ShaderPass", "RenderPass", "SSAARenderPass", 
  "AfterimagePass", "FXAAShader", "EffectComposer", "DRACOLoader", "GLTFLoader", "RGBELoader", "PMREMGenerator",
  "EquirectangularToCubeGenerator", "PMREMCubeUVPacker", "Water"], (_, THREE) ->
  class Scene
    constructor: (dom) -> (
      @height = dom.clientHeight
      @width = dom.clientWidth
      @status = false
      @initCamera()
      @initScene()
      @initLight()
      @initRender()
      dom.appendChild(@renderer.domElement)
      @initComposer()

      @loadFactoryModel()
      @loadSeaModel()

      window.Scene = @scene
      
      @render()
    )

    initCamera: () -> (
      @camera = new THREE.PerspectiveCamera(45, @width / @height, 10, 100000)
      @camera.position.set(1000, 200, 0)
      @controls = new THREE.OrbitControls(@camera);
      @controls.maxPolarAngle = Math.PI * 0.5;
      @controls.minDistance = 10;
      @controls.maxDistance = 3000;
      @controls.target.set(0, 0, 0);
      @controls.autoRotate = false;
      @controls.autoRotateSpeed = 2
    )

    initScene: () -> (
      @scene = new THREE.Scene()
      r = "static/asset/textures/sky4/";
      urls = [r + "posX.jpg", r + "negX.jpg", r + "posY.jpg", r + "negY.jpg", r + "posZ.jpg", r + "negZ.jpg"];
      skytexture = new THREE.CubeTextureLoader().load(urls);
      @scene.background = skytexture;
    )

    initLight: () -> (
      hemiLight = new THREE.HemisphereLight(0xc38e50, 0x111111, 0.1);
      hemiLight.position.set(0, 500, 0)
      @scene.add(hemiLight)
      
      @pointLight = new THREE.PointLight(0xffffff, 0.5)
      @scene.add(@pointLight)
      
      @sunLight = new THREE.DirectionalLight(0xc38e50, 2.0);
      @sunLight.position.set(-1000, 500, -1000);
      @sunLight.castShadow = true;
      
      @sunLight.shadow.mapSize.width = 1024;
      @sunLight.shadow.mapSize.height = 1024;
      @sunLight.shadow.camera.near = 10;
      @sunLight.shadow.camera.far = 10000;
      @sunLight.shadow.bias= -0.001;

      @sunLight.shadow.camera.left = -900;
      @sunLight.shadow.camera.right = 900;
      @sunLight.shadow.camera.top = 900;
      @sunLight.shadow.camera.bottom = -900;
      @scene.add(@sunLight);
    )

    initRender: () -> (
      @renderer = new THREE.WebGLRenderer({ antialias: true })
      @renderer.setSize(@width, @height);
      @renderer.setPixelRatio(window.devicePixelRatio);
      @renderer.shadowMap.enabled = true;
      @renderer.shadowMap.type = THREE.PCFSoftShadowMap;
      @renderer.gammaInput= true;
      @renderer.gammaOutput = true;
    )

    initComposer: () -> (
      renderScene = new THREE.RenderPass(@scene, @camera);
      effectSSAA = new THREE.SSAARenderPass(@scene, @camera);
      effectSSAA.sampleLevel = 3;
      effectFXAA = new THREE.ShaderPass(THREE.FXAAShader);
      effectFXAA.uniforms.resolution.value.set(1 / @width, 1 / @height);
      afterimagePass = new THREE.AfterimagePass();
      @composer = new THREE.EffectComposer(@renderer);
      @composer.setSize(@width, @height);
      @composer.addPass(renderScene);
      @composer.addPass(afterimagePass);
      @composer.addPass(effectFXAA)
    )

    loadFactoryModel: () -> (
      rgbeLoader = new THREE.RGBELoader().setDataType( THREE.UnsignedByteType ).setPath( 'static/asset/textures/evMap/' )
      
      dracoLoader = new THREE.DRACOLoader()
      dracoLoader.setDecoderPath("static/gltf/");

      gltfLoader = new THREE.GLTFLoader().setDRACOLoader(dracoLoader)

      rgbeLoader.load("015.hdr", (resp) => (
        result = new THREE.EquirectangularToCubeGenerator(resp, { resolution: 1024 });
        result.update(@renderer);
        generator = new THREE.PMREMGenerator(result.renderTarget.texture);
        generator.update(@renderer);
        uv = new THREE.PMREMCubeUVPacker(generator.cubeLods);
        uv.update(@renderer);
        textureCube = uv.CubeUVRenderTarget.texture
        gltfLoader.load("static/asset/models/scene/gongc.gltf", (gltf) => (
          grounds = new THREE.Group()
          grounds.position.set(300, -45, 0)
          grounds.scale.set(0.01, 0.01, 0.01)
          grounds.rotation.set(0, 0, 0)
          gltf.scene.traverse((obj) => (
            return if !obj.isMesh
            child = obj.clone()
            child.material.lightMap = child.material.aoMap;
            child.material.lightMapIntensity = 1.6;
            child.material.aoMapIntensity = 1.3;
            child.material.envMap = textureCube;
            child.material.side = THREE.DoubleSide;
            if (child.material.map != null) 
              child.material.map.anisotropy = 8
            child.castShadow = true;
            child.receiveShadow = true;
            grounds.add(child)
          ))
          @scene.add(grounds)
        ))
      ))
      
      # GLTFLoader.load("models/scene/gongc.bin", function () {}, onProgress, onError);
    )

    loadSeaModel: () -> (
      basic = new THREE.Mesh(new THREE.PlaneBufferGeometry(0.1, 0.1));
      waterGeometry = new THREE.CircleBufferGeometry(30000, 30, 0, Math.PI * 2);
      new THREE.TextureLoader().load("static/asset/textures/waternormals.jpg", (resp) =>
        resp.wrapS = THREE.RepeatWrapping
        resp.wrapT = THREE.RepeatWrapping
        @water = new THREE.Water(waterGeometry, {
          textureWidth: 1024,
          textureHeight: 1024,
          waterNormals: resp,
          alpha: 1.0,
          sunDirection: @sunLight.position.clone().normalize(),
          sunColor: 0xffdcb2,
          waterColor: 0x0f1d30,
          distortionScale: 5,
          fog: @scene.fog
        });
        @water.position.set(0, -50, 0);
        @water.rotation.x = -Math.PI * 0.5;
        basic.add(@water)
        @scene.add(basic);
      )
    )

    render: () -> (
      window.requestAnimationFrame(@render.bind(@))
      @pointLight.position.copy(@camera.position)
      @pointLight.scale.copy(@camera.scale)
      if @water
        @water.material.uniforms.time.value += 1.0 / 50.0;
      @controls.update()
      if @status
        @composer.render()
      else
        @renderer.render(@scene, @camera)
    )

    changeBtn: () => (
      @status = !@status
    )

  return Scene
)