define(["Vue", "text!../../../views/home/index.html"], (Vue, template) ->
    
    return Vue.component("v-home", {
        template: template,
        data: () -> { 
            timeout: undefined,
            count: 0,
            lastTime: new Date().getTime(),
            during: 2000   
        },
        mounted: () -> (
            this.refresh()
        ),
        methods: {
            refresh: () -> (
                this.now = new Date();
                setTimeout(this.refresh, 2000);
            ),
            # 防抖
            debounce: () -> (
                if !this.timeout 
                    this.timeout = window.setTimeout(() =>
                        this.count++
                        console.log(this.count)
                    , 1000)
                else
                    window.clearTimeout(this.timeout)
                    this.timeout = window.setTimeout(() =>
                        this.count++
                        console.log(this.count)
                    , 1000)
            ),
            throttleFun: () -> (
                this.count++
                console.log(this.count)
            ),
            # 节流
            throttle: () -> (
                now = new Date().getTime()
                if now - this.lastTime > this.during
                    this.throttleFun()
                    this.lastTime = now
            )
        }
    });
)