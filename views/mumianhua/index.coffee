define(["text!../../../views/mumianhua/index.html", "Vue", "./scene"], (html, Vue, Scene) ->
    return Vue.component("v-three", {
        template: html,
        data: () => {
            scene: null
        },
        mounted: () => (
            this.scene = new Scene(document.getElementById("page-canvas"))
        ),
        methods: {
            changeBtn: () => (
                this.scene.changeBtn()
            )
        }
    });
)